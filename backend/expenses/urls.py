from django.urls import path
from .views import ExpenseAPIView
urlpatterns=[path('expenses/',ExpenseAPIView.as_view(),name='expenses')]
