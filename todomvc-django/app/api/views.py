from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import permissions

from rest_framework.generics import (
    ListCreateAPIView, RetrieveUpdateDestroyAPIView, CreateAPIView)

from task.models import Task
from api.serializers import TaskSerializer, TaskListSerializer

from api.permissions import IsOwner


# Example using class based views
# -----------------------------------
class BulkUpdateModelMixin(object):

    """
    Update model instances in bulk by using the Serializers
    ``many=True`` ability from Django REST >= 2.2.5.
    """
    def bulk_update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        self.update_data = request.data
        # restrict the update to the filtered queryset
        self.qs = self.filter_queryset(self.get_queryset())
        serializer = self.get_serializer(
            self.qs,
            data=request.data,
            many=True,
            partial=partial,
        )
        serializer.is_valid(raise_exception=True)
        self.perform_bulk_update(serializer)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def partial_bulk_update(self, request, *args, **kwargs):
        kwargs['partial'] = True
        return self.bulk_update(request, *args, **kwargs)

    def perform_update(self, serializer):
        serializer.update(self.qs, self.update_data)

    def perform_bulk_update(self, serializer):
        return self.perform_update(serializer)


class TaskMixin(object):

    """
    Mixin to inherit from.
    Here we're setting the query set and the serializer
    """
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
    permission_classes = (IsOwner, permissions.IsAuthenticated)


class TaskList(TaskMixin, ListCreateAPIView, BulkUpdateModelMixin):

    """
    Return a list of all the tasks, or
    create new ones
    """
    def get_queryset(self):
        return Task.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        if serializer.is_valid():
            serializer.save(owner=self.request.user)

    def put(self, request, *args, **kwargs):
        return self.bulk_update(request, *args, **kwargs)

    def patch(self, request, *args, **kwargs):
        return self.partial_bulk_update(request, *args, **kwargs)


class TaskDetail(TaskMixin, RetrieveUpdateDestroyAPIView):
    """
    Return a specific task, update it, or delete it.
    """
    pass

class TaskDeleteCompleted(TaskMixin, CreateAPIView):
    def get_queryset(self):
        return Task.objects.filter(owner=self.request.user)

    def post(self, request, *args, **kwargs):
        user_todos = self.get_queryset()
        user_todos.filter(completed=True).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
