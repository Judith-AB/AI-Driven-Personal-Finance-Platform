from django.urls import path
from .views import ExpenseAPIView,BudgetAPIView,BudgetStatusAPIView
urlpatterns=[path('expenses/',ExpenseAPIView.as_view(),name='expenses'),
             path('budgets/',BudgetAPIView.as_view(),name="budgets"),
             path("budget-status/",BudgetStatusAPIView.as_view(),name="budget-status"),
             path('expenses/<int:pk>/', ExpenseAPIView.as_view(), name='expense-detail'),
             ]
