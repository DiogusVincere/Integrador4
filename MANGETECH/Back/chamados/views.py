# Django imports
import csv
from django.http import HttpResponse
from django.core.exceptions import ValidationError

# DRF imports
from rest_framework import viewsets, filters, status
from rest_framework.decorators import api_view
from rest_framework.response import Response

# Third-party imports
from django_filters.rest_framework import DjangoFilterBackend

# Local imports
from .models import Chamado, Comentario
from .serializers import ChamadoSerializer, ComentarioSerializer


class ChamadoViewSet(viewsets.ModelViewSet):
    queryset = Chamado.objects.all().order_by('-data_criacao')
    serializer_class = ChamadoSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'urgencia', 'ambiente']
    search_fields = ['titulo', 'descricao', 'ativo']
    ordering_fields = ['data_criacao', 'urgencia', 'status']


@api_view(['GET'])
def export_chamados_csv(request):
    """
    Exporta todos os chamados em CSV
    """
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="chamados.csv"'

    writer = csv.writer(response)
    writer.writerow([
        'ID', 'Título', 'Ativo', 'Ambiente', 'Solicitante',
        'Responsáveis', 'Urgência', 'Status', 'Data Criação'
    ])

    chamados = Chamado.objects.all()
    for c in chamados:
        responsaveis = ", ".join([r.get_full_name() or r.username for r in c.responsaveis.all()])
        writer.writerow([
            c.id,
            c.titulo,
            c.ativo,
            c.ambiente,
            c.solicitante.get_full_name() if c.solicitante else "",
            responsaveis,
            c.urgencia,
            c.status,
            c.data_criacao.strftime("%d/%m/%Y")
        ])

    return response


class ComentarioViewSet(viewsets.ModelViewSet):
    queryset = Comentario.objects.all().order_by('-data_criacao')
    serializer_class = ComentarioSerializer


@api_view(['POST'])
def bulk_delete_chamados(request):
    """
    Recebe uma lista de IDs e tenta deletar os chamados.
    Chamados em andamento não serão deletados.
    """
    ids = request.data.get('ids', [])
    if not ids:
        return Response({"error": "Nenhum ID fornecido."}, status=status.HTTP_400_BAD_REQUEST)

    success = []
    errors = []

    for cid in ids:
        try:
            chamado = Chamado.objects.get(id=cid)
            chamado.delete()  # Nosso delete já verifica status
            success.append(cid)
        except Chamado.DoesNotExist:
            errors.append({"id": cid, "error": "Chamado não encontrado"})
        except ValidationError as e:
            errors.append({"id": cid, "error": str(e)})

    return Response({"deleted": success, "errors": errors})
