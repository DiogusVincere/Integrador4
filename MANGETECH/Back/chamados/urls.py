from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ChamadoViewSet, ComentarioViewSet
from .views import export_chamados_csv
from .views import bulk_delete_chamados

router = DefaultRouter()
router.register(r'chamados', ChamadoViewSet, basename='chamado')
router.register(r'comentarios', ComentarioViewSet, basename='comentario')

urlpatterns = [
    path('', include(router.urls)),
]
urlpatterns += [
    path('chamados/export/', export_chamados_csv, name='export_chamados_csv'),
]

urlpatterns += [
    path('chamados/bulk-delete/', bulk_delete_chamados, name='bulk_delete_chamados'),
]