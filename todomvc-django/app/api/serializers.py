from rest_framework import serializers
from task.models import Task


class TaskListSerializer(serializers.ListSerializer):

    def update(self, instance, validated_data):
        """
        bulk update task models
        http://www.django-rest-framework.org/api-guide/serializers/#customizing-multiple-update
        """
        print(validated_data)
        # Maps for id->instance and id->data item.
        task_mapping = {task.id: task for task in instance}
        data_mapping = {item['id']: item for item in validated_data}

        # Perform updates.
        ret = []
        for task_id, data in data_mapping.items():
            task = task_mapping.get(task_id, None)
            if task is not None:
                ret.append(self.child.update(task, data))

        return ret


class TaskSerializer(serializers.ModelSerializer):

    """
    Serializer to parse Task data
    """
    owner = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = Task
        fields = ('title', 'completed', 'id', 'owner')
        list_serializer_class = TaskListSerializer
