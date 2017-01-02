from rest_framework import permissions


class IsOwner(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object to view/edit/delete it.
    """

    def has_object_permission(self, request, view, obj):
        print('in IsOwner perms')
        return obj.owner == request.user
