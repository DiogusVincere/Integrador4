from django.contrib import admin
from .models import Chamado

@admin.register(Chamado)
class ChamadoAdmin(admin.ModelAdmin):
    list_display = ('id', 'titulo', 'status', 'data_criacao')  # substitui criado_em por data_criacao
    search_fields = ('titulo', 'descricao')
    list_filter = ('status',)
