from rest_framework import serializers
from .models import Expense,Budget
from django.contrib.auth.models import User
class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expense
        fields = "__all__"
class BudgetSerializer(serializers.ModelSerializer):
    class Meta:
        model=Budget
        fields='__all__'


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ('username', 'password', 'first_name')

    def create(self, validated_data):
        # This hashes the password before saving
        user = User.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', '')
        )
        return user