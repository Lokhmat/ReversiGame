from django.db import models

# Create your models here.

class BestScore(models.Model):
    userScore = models.IntegerField()
    phoneScore = models.IntegerField()
    username = models.CharField(max_length=50)