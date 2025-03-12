from typing import Dict, List
from django.http import JsonResponse
from django.views.decorators.http import require_GET, require_POST
from django.views.decorators.csrf import csrf_exempt
import json
import logging
from .DB_functions import ComponentSyncDB

logger = logging.getLogger(__name__)

class InventoryView:
    """Manages HTTP endpoints for component inventory and compatibility."""

    @staticmethod
    @csrf_exempt
    @require_GET
    def list_inventory(request) -> JsonResponse:
        """List all available components in the inventory."""
        try:
            inventory = ComponentSyncDB.get_component_info()
            if not inventory:
                return JsonResponse({"error": "Inventory is empty"}, status=404)
            return JsonResponse({"inventory": inventory}, status=200)
        except Exception as e:
            logger.error(f"Failed to list inventory: {e}")
            return JsonResponse({"error": "Server error occurred"}, status=500)

    @staticmethod
    @require_POST
    @csrf_exempt
    def analyze_compatibility(request) -> JsonResponse:
        """Analyze compatibility for a set of components."""
        try:
            payload = json.loads(request.body)
            components = payload.get("components", [])
            if not components:
                return JsonResponse({"error": "No components specified"}, status=400)

            compatibility_results: Dict[str, List[int]] = {}
            is_first = True

            for comp in components:
                category = comp.get("category")
                comp_id = comp.get("id")
                if not category or not isinstance(comp_id, int):
                    return JsonResponse({"error": "Invalid component format"}, status=400)

                current_compat = InventoryView._get_compatibility(category, comp_id)
                if is_first:
                    compatibility_results.update(current_compat)
                    is_first = False
                else:
                    InventoryView._intersect_results(compatibility_results, current_compat)

            detailed_results = InventoryView._retrieve_details(compatibility_results)
            return JsonResponse({
                "compatible_items": detailed_results,
                "message": "Compatibility analysis successful"
            }, status=200)

        except json.JSONDecodeError:
            return JsonResponse({"error": "Malformed JSON input"}, status=400)
        except Exception as e:
            logger.error(f"Compatibility analysis failed: {e}")
            return JsonResponse({"error": "Server error occurred"}, status=500)

    @staticmethod
    @csrf_exempt
    def _get_compatibility(category: str, comp_id: int) -> Dict[str, List[int]]:
        """Determine compatible component IDs based on category."""
        rules = {
            "RAM Stick": [("Motherboard", ComponentSyncDB.find_compatible_components)],
            "Motherboard": [
                ("RAM Stick", ComponentSyncDB.find_compatible_components),
                ("CPU", ComponentSyncDB.find_compatible_components),
                ("GPU", ComponentSyncDB.find_compatible_components),
                ("SSD", ComponentSyncDB.find_compatible_components),
            ],
            "CPU": [
                ("Cooler", ComponentSyncDB.find_compatible_components),
                ("Motherboard", ComponentSyncDB.find_compatible_components),
            ],
            "Cooler": [("CPU", ComponentSyncDB.find_compatible_components)],
            "GPU": [
                ("Motherboard", ComponentSyncDB.find_compatible_components),
                ("Power Supply", ComponentSyncDB.find_compatible_components),
            ],
            "Power Supply": [("GPU", ComponentSyncDB.find_compatible_components)],
            "SSD": [("Motherboard", ComponentSyncDB.find_compatible_components)],
        }
        compat = {}
        if category in rules:
            for target_cat, fetch_fn in rules[category]:
                compat[target_cat] = fetch_fn(category, comp_id, target_cat)
        return compat

    @staticmethod
    @csrf_exempt
    def _intersect_results(existing: Dict[str, List[int]], new: Dict[str, List[int]]) -> None:
        """Intersect new compatibility results with existing ones."""
        for cat, new_ids in new.items():
            if cat in existing:
                existing[cat] = list(set(existing[cat]) & set(new_ids))
            else:
                existing[cat] = new_ids

    @staticmethod
    @csrf_exempt
    def _retrieve_details(compat_map: Dict[str, List[int]]) -> List[Dict]:
        """Fetch detailed info for compatible component IDs."""
        details = []
        for ids in compat_map.values():
            for cid in ids:
                info = ComponentSyncDB.get_component_info(cid)
                if info:
                    details.append(info)
        return details

# Export view functions
list_inventory = InventoryView.list_inventory
analyze_compatibility = InventoryView.analyze_compatibility