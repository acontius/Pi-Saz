from django.shortcuts import render
from django.views.decorators.http import require_GET
from django.http import JsonResponse
from .DB_functions import check_motherboard_compatibility
from PSaz.middleware import CheckVipMiddleware

@CheckVipMiddleware
@require_GET
def motherboard_full_compatibility(request, motherboard_id):
    """
    motherboard compatibility 
    feg(GET /api/compatibility/motherboard/123/)
    """
    try:
        if not str(motherboard_id).isdigit():
            return JsonResponse(
                {"error": "Invalid motherboard ID format"},
                status=400
            )

        result = check_motherboard_compatibility(int(motherboard_id))
        
        if not result:
            return JsonResponse(
                {"error": "Motherboard not found or compatibility data unavailable"},
                status=404
            )

        return JsonResponse(result)

    except Exception as e:
        return JsonResponse(
            {"error": f"Server error: {str(e)}"},
            status=500
        )


@require_GET
def cpu_motherboard_compatibility(request):
    """
    cpu motherboard compatibility 
    feg(GET /api/compatibility/cpu-mb/?cpu_id=123 or ?mb_id=456)
    """
    cpu_id = request.GET.get('cpu_id')
    mb_id = request.GET.get('mb_id')

    try:
        if cpu_id:
            result = motherboard_cpu(cpu_id=int(cpu_id))
        elif mb_id:
            result = motherboard_cpu(motherboard_id=int(mb_id))
        else:
            return JsonResponse(
                {"error": "Missing parameters (cpu_id or mb_id)"},
                status=400
            )

        return JsonResponse({"compatible_components": result}, safe=False)

    except ValueError:
        return JsonResponse(
            {"error": "Invalid ID format"},
            status=400
        )
    except Exception as e:
        return JsonResponse(
            {"error": f"Compatibility check failed: {str(e)}"},
            status=500
        )

@require_GET
def ram_motherboard_compatibility(request):
    """

    feg(GET /api/compatibility/ram-mb/?ram_id=789 or ?mb_id=456)
    """
    ram_id = request.GET.get('ram_id')
    mb_id = request.GET.get('mb_id')

    try:
        if ram_id:
            result = compatible_ram_motherboard(ram_id=int(ram_id))
        elif mb_id:
            result = compatible_ram_motherboard(motherboard_id=int(mb_id))
        else:
            return JsonResponse(
                {"error": "Missing parameters (ram_id or mb_id)"},
                status=400
            )

        return JsonResponse({"compatible_components": result}, safe=False)

    except ValueError:
        return JsonResponse(
            {"error": "Invalid ID format"},
            status=400
        )

@require_GET
def product_info(request, pid=None):
    """
    - GET /api/products/123/
    - GET /api/products/
    """
    try:
        if pid:
            result = about_product(pid=pid)
        else:
            result = about_product(pid="ALL")

        if isinstance(result, tuple) and result[0].get('error'):
            return JsonResponse(result[0], status=result[1])

        return JsonResponse({"products": result}, safe=False)

    except Exception as e:
        return JsonResponse(
            {"error": f"Product info retrieval failed: {str(e)}"},
            status=500
        )


from django.views.decorators.http import require_GET
from django.http import JsonResponse
from .DB_functions import check_ram_compatibility

@require_GET
def ram_compatibility(request, ram_id):
    """
    ram_id compatibilities 
    GET /api/compatibility/ram/123/
    """
    try:
        if not str(ram_id).isdigit():
            return JsonResponse(
                {"error": "Invalid RAM ID format"}, 
                status=400
            )

        result = check_ram_compatibility(int(ram_id))
        
        if not result:
            return JsonResponse(
                {"error": "RAM not found or compatibility data unavailable"},
                status=404
            )

        return JsonResponse(result)

    except Exception as e:
        return JsonResponse(
            {"error": f"Server error: {str(e)}"},
            status=500
        )


@require_GET
def cpu_compatibility(request, cpu_id):
    try:
        if not str(cpu_id).isdigit():
            return JsonResponse({"error": "Invalid CPU ID"}, status=400)
        
        data = check_cpu_compatibility(int(cpu_id))
        return JsonResponse(data if data else {"error": "No data"}, status=200 if data else 404)
    
    except Exception as e:
        return JsonResponse({"error": f"Server error: {str(e)}"}, status=500)

@require_GET
def gpu_compatibility(request, gpu_id):
    try:
        if not str(gpu_id).isdigit():
            return JsonResponse({"error": "Invalid GPU ID"}, status=400)
        
        data = check_gpu_compatibility(int(gpu_id))
        return JsonResponse(data if data else {"error": "No data"}, status=200 if data else 404)
    
    except Exception as e:
        return JsonResponse({"error": f"Server error: {str(e)}"}, status=500)


@require_GET
def power_supply_compatibility(request, power_supply_id):
    try:
        data = check_power_supply_compatibility(power_supply_id)
        return JsonResponse(data if data else {"error": "No data"}, status=200 if data else 404)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)

@require_GET
def case_compatibility(request, case_id):
    try:
        data = check_case_compatibility(case_id)
        return JsonResponse(data if data else {"error": "No data"}, status=200 if data else 404)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)

@require_GET
def storage_compatibility(request, storage_id, storage_type):
    try:
        if storage_type.lower() not in ['ssd', 'hdd']:
            return JsonResponse({"error": "Invalid storage type"}, status=400)
        
        data = check_storage_compatibility(storage_id, storage_type)
        return JsonResponse(data if data else {"error": "No data"}, status=200 if data else 404)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)