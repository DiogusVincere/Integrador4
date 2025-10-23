from rest_framework import serializers
from .models import Chamado, Comentario
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'last_name', 'email']

class ChamadoSerializer(serializers.ModelSerializer):
    solicitante = UserSerializer(read_only=True)
    responsaveis = UserSerializer(many=True, read_only=True)

    class Meta:
        model = Chamado
        fields = '__all__'
class ComentarioSerializer(serializers.ModelSerializer):
    autor = UserSerializer(read_only=True)

    class Meta:
        model = Comentario
        fields = '__all__'
