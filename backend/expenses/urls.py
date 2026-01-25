from django.urls import path
from .views import ExpenseAPIView,BudgetStatusAPIView,MonthlyBudgetAPIView,MonthlyBudgetStatusAPIView,WeeklyBudgetAPIView,WeeklyBudgetStatusAPIView
urlpatterns=[path('expenses/',ExpenseAPIView.as_view(),name='expenses'),
            
             path("budget-status/",BudgetStatusAPIView.as_view(),name="budget-status"),
             path('expenses/<int:pk>/', ExpenseAPIView.as_view(), name='expense-detail'),
             path('budget/monthly/',MonthlyBudgetAPIView.as_view()),
             path("budget/monthly/status/", MonthlyBudgetStatusAPIView.as_view()),
             path("budget/weekly/", WeeklyBudgetAPIView.as_view()),
             path("budget/weekly/status/", WeeklyBudgetStatusAPIView.as_view()),


             ]
