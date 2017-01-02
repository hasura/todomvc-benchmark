from rest_framework import serializers
from rest_auth.serializers import TokenSerializer


class MyLoginSerializer(TokenSerializer):

    user_id = serializers.IntegerField(source='user.pk', read_only=True)

    class Meta(TokenSerializer.Meta):
        fields = TokenSerializer.Meta.fields + ('user_id',)
