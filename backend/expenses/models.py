from django.db import models
from django.contrib.auth.models import User

class Expense(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE,null=True,blank=True)
    amount = models.FloatField()
    description = models.TextField()
    category = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        if self.user:
            return f"{self.user.username} - {self.amount}"
        return f"Anonymous - {self.amount}"
    
class Budget(models.Model):
    user=models.ForeignKey(User,on_delete=models.CASCADE)
    month=models.IntegerField()
    year=models.IntegerField()
    amount=models.FloatField()
    def __str__(self):
        return f"{self.user.username}-{self.month}/{self.year}-{self.amount}"