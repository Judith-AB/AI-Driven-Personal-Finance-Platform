from django.db import models
class Expense(models.Model):
    amount = models.FloatField()
    description = models.TextField()
    category = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)
