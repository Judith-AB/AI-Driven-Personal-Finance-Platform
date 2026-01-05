from rest_framework import serializers
from .models import Expense,Budget

class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model=Expense
        fields='__all__'
class BudgetSerializer(serializers.ModelSerializer):
    class Meta:
        model=Budget
        fields='__all__'


