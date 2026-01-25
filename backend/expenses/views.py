from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from .models import Expense,Budget
from .serializers import ExpenseSerializer,BudgetSerializer

from datetime import datetime,timedelta,date
from django.db.models import Sum

from .ml_utils import predict_category
from rest_framework.permissions import IsAuthenticated

def get_week_start(date):
    return date - timedelta(days=date.weekday())


class ExpenseAPIView(APIView):
    def get(self,request):
        expenses=Expense.objects.filter(user=request.user)
        serializer=ExpenseSerializer(expenses,many=True)
        return Response(serializer.data)
    def post(self, request):
        data = request.data.copy()
        description = data.get("description", "")
        predicted_category = predict_category(description)
        data["category"] = predicted_category
        serializer = ExpenseSerializer(data=data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    def put(self,request,pk):
        try:
            expense=Expense.objects.get(pk=pk,user=request.user)
        except Expense.DoesNotExist:
            return Response({
                "error":"Expense not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        serializer=ExpenseSerializer(
            expense,
            data=request.data,
            partial=True
        )
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors,status=status.HTTP_400_BAD_REQUEST)

class MonthlyBudgetAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        data = request.data

        period = data.get("period")
        amount = data.get("amount")
        start_date = data.get("start_date")

        if not all([period, amount, start_date]):
            return Response(
                {"error": "period, amount and start_date are required"},
                status=status.HTTP_400_BAD_REQUEST
            )

       
        budget, created = Budget.objects.update_or_create(
            user=request.user,
            period="monthly",
            start_date=start_date,
            defaults={"amount": amount}
        )

        return Response(
            {
                "id": budget.id,
                "period": budget.period,
                "amount": budget.amount,
                "start_date": budget.start_date,
            },
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK
        )
class MonthlyBudgetStatusAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = date.today()
        month_start = today.replace(day=1)

        budget = Budget.objects.filter(
            user=request.user,
            period="monthly",
            start_date=month_start
        ).first()

        total_spent = Expense.objects.filter(
            user=request.user,
            created_at__date__gte=month_start,
            created_at__date__lte=today
        ).aggregate(Sum("amount"))["amount__sum"] or 0

        remaining = None
        exceeded = False
        exceeded_by = 0

        if budget:
            remaining = budget.amount - total_spent
            if total_spent > budget.amount:
                exceeded = True
                exceeded_by = total_spent - budget.amount

        return Response({
            "month": today.month,
            "year": today.year,
            "total_spent": total_spent,
            "budget": budget.amount if budget else None,
            "remaining_budget": remaining,
            "budget_exceeded": exceeded,
            "exceeded_by": exceeded_by,
        })
class BudgetStatusAPIView(APIView):
    def get(self,request):
        now=datetime.now()
        month=now.month
        year=now.year
        total_spent=(Expense.objects.filter(user=request.user,created_at__month=month,created_at__year=year)
                     .aggregate(total=Sum("amount"))["total"]
                     ) or 0
        budget=Budget.objects.filter(user=request.user,month=month,year=year).first()
        if budget:
            remaining_budget=0 if budget.amount-total_spent<=0 else budget.amount-total_spent
            exceeded_by=abs(budget.amount-total_spent)
            budget_exceeded=total_spent>budget.amount
            budget_amount=budget.amount
        else:
            remaining_budget=None
            budget_exceeded=False
            budget_amount=None
        return Response({
            'month':month,
            'year':year,
            'total_spent':total_spent,
            'budget':budget_amount,
            'remaining_budget':remaining_budget,
            'budget_exceeded':budget_exceeded,
            'exceeded_by':exceeded_by

                                                    })
class WeeklyBudgetAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        data = request.data

        amount = data.get("amount")
        start_date = data.get("start_date")

        if not all([amount, start_date]):
            return Response(
                {"error": "amount and start_date are required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        budget, created = Budget.objects.update_or_create(
            user=request.user,
            period="weekly",
            start_date=start_date,
            defaults={"amount": amount}
        )

        return Response(
            {
                "id": budget.id,
                "period": budget.period,
                "amount": budget.amount,
                "start_date": budget.start_date,
            },
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK
        )
class WeeklyBudgetStatusAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = date.today()

        # 🔑 Find Monday of current week
        week_start = today - timedelta(days=today.weekday())
        week_end = week_start + timedelta(days=6)

        total_spent = Expense.objects.filter(
            user=request.user,
            created_at__date__range=[week_start, week_end]
        ).aggregate(Sum("amount"))["amount__sum"] or 0

        budget = Budget.objects.filter(
            user=request.user,
            period="weekly",
            start_date=week_start
        ).first()

        remaining = None
        exceeded = False
        exceeded_by = 0

        if budget:
            remaining = budget.amount - total_spent
            if remaining < 0:
                exceeded = True
                exceeded_by = abs(remaining)

        return Response({
            "period": "weekly",
            "week_start": week_start,
            "week_end": week_end,
            "total_spent": total_spent,
            "budget": budget.amount if budget else None,
            "remaining_budget": remaining,
            "budget_exceeded": exceeded,
            "exceeded_by": exceeded_by,
        })
