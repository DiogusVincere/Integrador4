from django.db import models
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError

class Chamado(models.Model):
    STATUS_CHOICES = [
        ('aberto', 'Aberto'),
        ('em_andamento', 'Em andamento'),
        ('fechado', 'Fechado'),
    ]

    URGENCIA_CHOICES = [
        ('critico', 'Crítico'),
        ('alta', 'Alta'),
        ('media', 'Média'),
        ('baixa', 'Baixa'),
    ]

    AMBIENTE_CHOICES = [
        ('producao', 'Produção'),
        ('homologacao', 'Homologação'),
        ('desenvolvimento', 'Desenvolvimento'),
    ]

    titulo = models.CharField(max_length=255)
    descricao = models.TextField(blank=True)
    ativo = models.CharField(max_length=100)
    ambiente = models.CharField(max_length=20, choices=AMBIENTE_CHOICES)
    solicitante = models.ForeignKey(User, related_name='chamados_solicitados', on_delete=models.SET_NULL, null=True)
    responsaveis = models.ManyToManyField(User, related_name='chamados_responsaveis', blank=True)
    urgencia = models.CharField(max_length=20, choices=URGENCIA_CHOICES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)
    data_criacao = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"#{self.id} - {self.titulo}"

    def delete(self, *args, **kwargs):
        if self.status == 'em_andamento':
            raise ValidationError("Não é possível excluir um chamado que está em andamento.")
        super().delete(*args, **kwargs)


class Comentario(models.Model):
    chamado = models.ForeignKey(Chamado, related_name='comentarios', on_delete=models.CASCADE)
    autor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    texto = models.TextField()
    data_criacao = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Comentário de {self.autor} em Chamado #{self.chamado.id}"
