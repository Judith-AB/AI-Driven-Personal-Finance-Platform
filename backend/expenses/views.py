from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from .models import Expense,Budget
from .serializers import ExpenseSerializer,BudgetSerializer

from datetime import datetime,timedelta,date,time
from django.utils.timezone import make_aware,localtime
from django.db.models import Sum,F
from django.db.models.functions import TruncDate

from .ml_utils import predict_category
from rest_framework.permissions import IsAuthenticated

from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer



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
            expense = serializer.save(user=request.user)
            today = date.today()
            # WEEKLY CHECK
            week_start = today - timedelta(days=today.weekday())
            week_end = week_start + timedelta(days=6)

            week_start_dt = make_aware(datetime.combine(week_start, time.min))
            week_end_dt = make_aware(datetime.combine(week_end, time.max))

            weekly_total = Expense.objects.filter(
                user=request.user,
                created_at__range=(week_start_dt, week_end_dt)
            ).aggregate(Sum("amount"))["amount__sum"] or 0

            weekly_budget = Budget.objects.filter(
                user=request.user,
                period="weekly",
                start_date=week_start
            ).first()

            channel_layer = get_channel_layer()

            if weekly_budget and weekly_total > weekly_budget.amount:
                async_to_sync(channel_layer.group_send)(
                    f"user_{request.user.id}",
                    {
                        "type": "budget_alert",
                        "message": "⚠️ Weekly budget exceeded!"
                    }
                )

            # MONTHLY CHECK
            month_start = today.replace(day=1)

            monthly_total = Expense.objects.filter(
                user=request.user,
                created_at__date__gte=month_start
            ).aggregate(Sum("amount"))["amount__sum"] or 0

            monthly_budget = Budget.objects.filter(
                user=request.user,
                period="monthly",
                start_date=month_start
            ).first()

            if monthly_budget and monthly_total > monthly_budget.amount:
                async_to_sync(channel_layer.group_send)(
                    f"user_{request.user.id}",
                    {
                        "type": "budget_alert",
                        "message": "⚠️ Monthly budget exceeded!"
                    }
                )

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
            remaining =  0 if (budget.amount - total_spent)<0 else budget.amount - total_spent
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

        week_start = today - timedelta(days=today.weekday())
        week_end = week_start + timedelta(days=6)

        week_start_dt = make_aware(datetime.combine(week_start, time.min))
        week_end_dt = make_aware(datetime.combine(week_end, time.max))

        total_spent = Expense.objects.filter(
            user=request.user,
            created_at__range=(week_start_dt, week_end_dt)
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
                remaining = 0
                
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
