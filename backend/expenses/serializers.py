from rest_framework import serializers
from .models import Expense,Budget

class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model=Expense
        fields = ['id', 'amount', 'description', 'category', 'created_at', 'user']
        read_only_fields = ['category', 'user']
class BudgetSerializer(serializers.ModelSerializer):
    user=serializers.ReadOnlyField(source='user.id')
    class Meta:
        model=Budget
        fields='__all__'


