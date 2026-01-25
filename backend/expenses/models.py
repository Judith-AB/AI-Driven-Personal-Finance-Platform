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
    PERIOD_CHOICES = [
        ("monthly", "Monthly"),
        ("weekly", "Weekly"),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    period = models.CharField(max_length=10, choices=PERIOD_CHOICES)
    amount = models.FloatField()
    start_date = models.DateField()

    class Meta:
        unique_together = ("user", "period", "start_date")

    def __str__(self):
        return f"{self.user.username} - {self.period} - {self.start_date}"


