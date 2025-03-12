from typing import Dict, List, Optional, Union
from django.db import connection, DatabaseError
import logging

logger = logging.getLogger(__name__)

class ComponentSyncDB:
    """Database interface for component compatibility and details."""

    @staticmethod
    def _run_query(query: str, params: tuple = ()) -> List[Dict]:
        """Execute a SQL query and return results as dictionaries."""
        try:
            with connection.cursor() as cursor:
                cursor.execute(query, params)
                columns = [col[0] for col in cursor.description]
                return [dict(zip(columns, row)) for row in cursor.fetchall()]
        except DatabaseError as e:
            logger.error(f"Query execution failed: {e}")
            raise

    @staticmethod
    def get_component_info(component_id: Optional[int] = None) -> Union[List[Dict], Dict]:
        """Fetch details for all components or a specific one."""
        base_query = """
            SELECT p.id, p.category, p.current_price, p.stock_count, p.brand, p.model,
                   mb.chipset, mb.number_of_memory_slots, mb.memory_speed_range, mb.wattage AS mb_wattage,
                   cpu.maximum_addressable_memory_limit, cpu.boost_frequency, cpu.base_frequency,
                   cpu.number_of_cores, cpu.number_of_threads, cpu.microarchitecture, cpu.generation,
                   ram.frequency, ram.capacity AS ram_capacity, ram.generation AS ram_gen, ram.wattage AS ram_wattage,
                   gpu.clock_speed, gpu.ram_size, gpu.number_of_fans, gpu.wattage AS gpu_wattage,
                   ssd.capacity AS ssd_capacity, ssd.wattage AS ssd_wattage,
                   clr.maximum_rotational_speed, clr.fan_size, clr.cooling_method,
                   psu.supported_wattage,
                   hdd.rotational_speed, hdd.capacity AS hdd_capacity,
                   cse.number_of_fans AS case_fans, cse.type AS case_type, cse.material
            FROM PRODUCTS p
            LEFT JOIN MOTHERBOARD mb ON p.id = mb.id AND p.category = 'Motherboard'
            LEFT JOIN CPU cpu ON p.id = cpu.id AND p.category = 'CPU'
            LEFT JOIN RAM_STICK ram ON p.id = ram.id AND p.category = 'RAM Stick'
            LEFT JOIN GPU gpu ON p.id = gpu.id AND p.category = 'GPU'
            LEFT JOIN SSD ssd ON p.id = ssd.id AND p.category = 'SSD'
            LEFT JOIN COOLER clr ON p.id = clr.id AND p.category = 'Cooler'
            LEFT JOIN POWER_SUPPLY psu ON p.id = psu.id AND p.category = 'Power Supply'
            LEFT JOIN HDD hdd ON p.id = hdd.id AND p.category = 'HDD'
            LEFT JOIN CASE_TABLE cse ON p.id = cse.id AND p.category = 'Case'
        """
        try:
            with connection.cursor() as cursor:
                if component_id is None:
                    cursor.execute(base_query)
                    columns = [col[0] for col in cursor.description]
                    return [dict(zip(columns, row)) for row in cursor.fetchall()]
                else:
                    cursor.execute(f"{base_query} WHERE p.id = %s", (component_id,))
                    columns = [col[0] for col in cursor.description]
                    result = cursor.fetchone()
                    return dict(zip(columns, result)) if result else {}
        except DatabaseError as e:
            logger.error(f"Failed to fetch component info: {e}")
            return []

    @staticmethod
    def find_compatible_components(source_category: str, source_id: int, target_category: str) -> List[int]:
        """Retrieve IDs of components compatible with the source component."""
        compatibility_queries = {
            ("CPU", "Motherboard"): "SELECT Motherboard_id FROM MC_SOCKET_COMPATIBLE_WITH WHERE Cpu_id = %s",
            ("Motherboard", "CPU"): "SELECT Cpu_id FROM MC_SOCKET_COMPATIBLE_WITH WHERE Motherboard_id = %s",
            ("CPU", "Cooler"): "SELECT Cooler_id FROM CC_SOCKET_COMPATIBLE_WITH WHERE Cpu_id = %s",
            ("Cooler", "CPU"): "SELECT Cpu_id FROM CC_SOCKET_COMPATIBLE_WITH WHERE Cooler_id = %s",
            ("RAM Stick", "Motherboard"): "SELECT Motherboard_id FROM RM_SLOT_COMPATIBLE_WITH WHERE Ram_id = %s",
            ("Motherboard", "RAM Stick"): "SELECT Ram_id FROM RM_SLOT_COMPATIBLE_WITH WHERE Motherboard_id = %s",
            ("GPU", "Motherboard"): "SELECT Motherboard_id FROM GM_SLOT_COMPATIBLE_WITH WHERE Gpu_id = %s",
            ("Motherboard", "GPU"): "SELECT Gpu_id FROM GM_SLOT_COMPATIBLE_WITH WHERE Motherboard_id = %s",
            ("SSD", "Motherboard"): "SELECT Motherboard_id FROM SM_SLOT_COMPATIBLE_WITH WHERE Ssd_id = %s",
            ("Motherboard", "SSD"): "SELECT Ssd_id FROM SM_SLOT_COMPATIBLE_WITH WHERE Motherboard_id = %s",
            ("GPU", "Power Supply"): "SELECT Power_id FROM CONNECTOR_COMPATIBLE_WITH WHERE Gpu_id = %s",
            ("Power Supply", "GPU"): "SELECT Gpu_id FROM CONNECTOR_COMPATIBLE_WITH WHERE Power_id = %s",
        }
        query_key = (source_category, target_category)
        if query_key not in compatibility_queries:
            return []

        try:
            with connection.cursor() as cursor:
                cursor.execute(compatibility_queries[query_key], (source_id,))
                return [row[0] for row in cursor.fetchall()]
        except DatabaseError as e:
            logger.error(f"Failed to find compatible components for {source_category}->{target_category}: {e}")
            return []