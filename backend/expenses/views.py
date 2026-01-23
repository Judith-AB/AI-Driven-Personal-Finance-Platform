from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from .models import Expense,Budget
from .serializers import ExpenseSerializer,BudgetSerializer

from datetime import datetime
from django.db.models import Sum

class ExpenseAPIView(APIView):
    def get(self,request):
        expenses=Expense.objects.filter(user=request.user)
        serializer=ExpenseSerializer(expenses,many=True)
        return Response(serializer.data)
    def post(self,request):
        serializer=ExpenseSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user,category='Others')
            return Response(serializer.data,status=status.HTTP_201_CREATED)
        return Response(serializer.data,status=status.HTTP_400_BAD_REQUEST)
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

class BudgetAPIView(APIView):
    def get(self, request):
        budgets = Budget.objects.filter(user=request.user)
        serializer = BudgetSerializer(budgets, many=True)
        return Response(serializer.data)

    def post(self, request):
        month = request.data.get('month')
        year = request.data.get('year')
        amount = request.data.get('amount')

        budget, created = Budget.objects.update_or_create(
            user=request.user,
            month=month,
            year=year,
            defaults={'amount': amount}
        )

        serializer = BudgetSerializer(budget)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

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