from django.urls import re_path
from .consumers import BudgetAlertConsumer

websocket_urlpatterns = [
    re_path(r"ws/budget-alerts/$", BudgetAlertConsumer.as_asgi()),
]
