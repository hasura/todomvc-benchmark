from django.db import models
from django.contrib.auth.models import User


class Task(models.Model):
    """
    Model for storing `tasks`
    """

    # Whether this task is completed
    completed = models.BooleanField(default=False)

    # Task title
    title = models.CharField(max_length=100)

    # ForeignKey to User model
    owner = models.ForeignKey(User, related_name='tasks')
