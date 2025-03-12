from django.urls import path
from . import views

urlpatterns = [
    path('inventory/', views.list_inventory, name='list_inventory'),
    path('compatibility/', views.analyze_compatibility, name='analyze_compatibility'),
]