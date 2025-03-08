from . import views
from django.urls import path

urlpatterns = [
    path('compatibility/motherboard/<int:motherboard_id>/', views.motherboard_full_compatibility),
    path('compatibility/cpu-mb/', views.cpu_motherboard_compatibility),
    path('compatibility/ram-mb/', views.ram_motherboard_compatibility),
    path('products/', views.product_info),
    path('products/<int:pid>/', views.product_info),
    path('compatibility/ram/<int:ram_id>/', views.ram_compatibility),
    path('compatibility/cpu/<int:cpu_id>/', views.cpu_compatibility),
    path('compatibility/gpu/<int:gpu_id>/', views.gpu_compatibility),
    path('compatibility/psu/<int:power_supply_id>/', views.power_supply_compatibility),
    path('compatibility/case/<int:case_id>/', views.case_compatibility),
    path('compatibility/storage/<str:storage_type>/<int:storage_id>/', views.storage_compatibility)
]