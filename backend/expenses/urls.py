from django.urls import path
from .views import ExpenseAPIView,BudgetAPIView
urlpatterns=[path('expenses/',ExpenseAPIView.as_view(),name='expenses'),
             path('budgets/',BudgetAPIView.as_view(),name="budgets"),
             ]
