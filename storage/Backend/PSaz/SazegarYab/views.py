# views.py
from django.shortcuts import render
from django.views.decorators.http import require_GET
from django.http import JsonResponse
from .DB_functions import (
    check_motherboard_compatibility,
    check_cpu_compatibility,
    check_ram_compatibility,
    check_gpu_compatibility,
    check_power_supply_compatibility,
    check_case_compatibility,
    check_storage_compatibility,
    motherboard_cpu,
    compatible_ram_motherboard,
    about_product,
    show_all_product
)
from PSaz.middleware import CheckVipMiddleware
import logging

logger = logging.getLogger(__name__)

def validate_id(resource_id, resource_name):
    try:
        if not isinstance(resource_id, int) or resource_id <= 0:
            raise ValueError
        return True
    except (ValueError, TypeError):
        logger.error(f"Invalid {resource_name} ID: {resource_id}")
        return False

@CheckVipMiddleware
@require_GET
def motherboard_full_compatibility(request, motherboard_id):
    if not validate_id(motherboard_id, "motherboard"):
        return JsonResponse({"error": "Invalid motherboard ID"}, status=400)
    
    try:
        result = check_motherboard_compatibility(motherboard_id)
        if not result:
            return JsonResponse({"error": "No compatibility data found"}, status=404)
        return JsonResponse(result)
    except Exception as e:
        logger.error(f"Motherboard comp error: {str(e)}")
        return JsonResponse({"error": "Server error"}, status=500)

@require_GET
def cpu_motherboard_compatibility(request):
    cpu_id = request.GET.get('cpu_id')
    mb_id = request.GET.get('mb_id')
    
    try:
        if cpu_id:
            if not validate_id(int(cpu_id), "CPU"):
                return JsonResponse({"error": "Invalid CPU ID"}, status=400)
            result = motherboard_cpu(cpu_id=int(cpu_id))
        elif mb_id:
            if not validate_id(int(mb_id), "Motherboard"):
                return JsonResponse({"error": "Invalid MB ID"}, status=400)
            result = motherboard_cpu(motherboard_id=int(mb_id))
        else:
            return JsonResponse({"error": "Missing parameters"}, status=400)
        
        return JsonResponse({"compatible_components": result}, safe=False)
    except Exception as e:
        logger.error(f"CPU/MB error: {str(e)}")
        return JsonResponse({"error": "Server error"}, status=500)

@require_GET
def ram_motherboard_compatibility(request):
    ram_id = request.GET.get('ram_id')
    mb_id = request.GET.get('mb_id')
    
    try:
        if ram_id:
            if not validate_id(int(ram_id), "RAM"):
                return JsonResponse({"error": "Invalid RAM ID"}, status=400)
            result = compatible_ram_motherboard(ram_id=int(ram_id))
        elif mb_id:
            if not validate_id(int(mb_id), "Motherboard"):
                return JsonResponse({"error": "Invalid MB ID"}, status=400)
            result = compatible_ram_motherboard(motherboard_id=int(mb_id))
        else:
            return JsonResponse({"error": "Missing parameters"}, status=400)
        
        return JsonResponse({"compatible_components": result}, safe=False)
    except Exception as e:
        logger.error(f"RAM/MB error: {str(e)}")
        return JsonResponse({"error": "Server error"}, status=500)

@require_GET
def product_info(request, pid=None):
    try:
        if pid:
            if not validate_id(pid, "product"):
                return JsonResponse({"error": "Invalid product ID"}, status=400)
            result = about_product(pid=pid)
            if isinstance(result, tuple) and result[0].get('error'):
                return JsonResponse(result[0], status=result[1])
            return JsonResponse({"product": result}, safe=False)
        else:
            result = about_product(pid="ALL")
            return JsonResponse({"products": result}, safe=False)
    except Exception as e:
        logger.error(f"Product error: {str(e)}")
        return JsonResponse({"error": "Server error"}, status=500)

@require_GET
def ram_compatibility(request, ram_id):
    if not validate_id(ram_id, "RAM"):
        return JsonResponse({"error": "Invalid RAM ID"}, status=400)
    
    try:
        result = check_ram_compatibility(ram_id)
        if not result:
            return JsonResponse({"error": "No compatibility data"}, status=404)
        return JsonResponse(result)
    except Exception as e:
        logger.error(f"RAM comp error: {str(e)}")
        return JsonResponse({"error": "Server error"}, status=500)

@require_GET
def cpu_compatibility(request, cpu_id):
    if not validate_id(cpu_id, "CPU"):
        return JsonResponse({"error": "Invalid CPU ID"}, status=400)
    
    try:
        result = check_cpu_compatibility(cpu_id)
        if not result:
            return JsonResponse({"error": "No compatibility data"}, status=404)
        return JsonResponse(result)
    except Exception as e:
        logger.error(f"CPU comp error: {str(e)}")
        return JsonResponse({"error": "Server error"}, status=500)

@require_GET
def gpu_compatibility(request, gpu_id):
    if not validate_id(gpu_id, "GPU"):
        return JsonResponse({"error": "Invalid GPU ID"}, status=400)
    
    try:
        result = check_gpu_compatibility(gpu_id)
        if not result:
            return JsonResponse({"error": "No compatibility data"}, status=404)
        return JsonResponse(result)
    except Exception as e:
        logger.error(f"GPU comp error: {str(e)}")
        return JsonResponse({"error": "Server error"}, status=500)

@require_GET
def power_supply_compatibility(request, power_supply_id):
    if not validate_id(power_supply_id, "Power Supply"):
        return JsonResponse({"error": "Invalid PSU ID"}, status=400)
    
    try:
        result = check_power_supply_compatibility(power_supply_id)
        if not result:
            return JsonResponse({"error": "No compatibility data"}, status=404)
        return JsonResponse(result)
    except Exception as e:
        logger.error(f"PSU comp error: {str(e)}")
        return JsonResponse({"error": "Server error"}, status=500)

@require_GET
def case_compatibility(request, case_id):
    if not validate_id(case_id, "Case"):
        return JsonResponse({"error": "Invalid Case ID"}, status=400)
    
    try:
        result = check_case_compatibility(case_id)
        if not result:
            return JsonResponse({"error": "No compatibility data"}, status=404)
        return JsonResponse(result)
    except Exception as e:
        logger.error(f"Case comp error: {str(e)}")
        return JsonResponse({"error": "Server error"}, status=500)

@require_GET
def storage_compatibility(request, storage_type, storage_id):
    try:
        if storage_type.lower() not in ['ssd', 'hdd']:
            return JsonResponse({"error": "Invalid storage type"}, status=400)
        
        if not validate_id(storage_id, "Storage"):
            return JsonResponse({"error": "Invalid storage ID"}, status=400)
        
        result = check_storage_compatibility(storage_id, storage_type)
        if not result:
            return JsonResponse({"error": "No compatibility data"}, status=404)
        return JsonResponse(result)
    except Exception as e:
        logger.error(f"Storage comp error: {str(e)}")
        return JsonResponse({"error": "Server error"}, status=500)

@require_GET
def show_all_p(request):
    try:
        result = show_all_product()
        if not result:
            return JsonResponse({"error": "No products found"}, status=404)
        return JsonResponse(result)
    except Exception as e:
        logger.error(f"Show all error: {str(e)}")
        return JsonResponse({"error": "Server error"}, status=500)