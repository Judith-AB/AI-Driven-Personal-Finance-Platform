
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from .models import Expense
from .serializers import ExpenseSerializer

class ExpenseAPIView(APIView):
    def get(self,request):
        expenses=Expense.objects.all()
        serializer=ExpenseSerializer(expenses,many=True)
        return Response(serializer.data)
    def post(self,request):
        serializer=ExpenseSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data,status=status.HTTP_201_CREATED)
        return Response(serializer.data,status=status.HTTP_400_BAD_REQUEST)