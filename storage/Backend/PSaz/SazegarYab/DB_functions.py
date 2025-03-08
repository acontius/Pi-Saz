from django.db import connection
from django.http import JsonResponse
import logging

logger = logging.getLogger(__name__)

def check_cpu_compatibility(cpu_id: int) -> dict:
    try:
        with connection.cursor() as c:
            result = {
                "compatible_motherboards": [],
                "compatible_coolers": [],
                "compatible_psus": [],
                "compatible_cases": []
            }

            # Motherboards with matching socket
            c.execute("""
                SELECT m.id, m.brand, m.model 
                FROM MOTHERBOARD m
                JOIN MC_SOCKET_COMPATIBLE_WITH mc 
                ON m.id = mc.Motherboard_id
                WHERE mc.Cpu_id = %s
            """, [cpu_id])
            result["compatible_motherboards"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # Coolers with matching socket
            c.execute("""
                SELECT cl.id, cl.brand, cl.model 
                FROM COOLER cl
                JOIN CC_SOCKET_COMPATIBLE_WITH cc 
                ON cl.id = cc.Cooler_id
                WHERE cc.Cpu_id = %s
            """, [cpu_id])
            result["compatible_coolers"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # PSUs that can handle CPU + Cooler wattage
            c.execute("""
                SELECT ps.id, ps.brand, ps.supported_wattage 
                FROM POWER_SUPPLY ps
                WHERE ps.supported_wattage >= (
                    SELECT c.wattage + COALESCE(cl.wattage, 0)
                    FROM CPU c
                    LEFT JOIN CC_SOCKET_COMPATIBLE_WITH cc ON c.id = cc.Cpu_id
                    LEFT JOIN COOLER cl ON cc.Cooler_id = cl.id
                    WHERE c.id = %s
                )
            """, [cpu_id])
            result["compatible_psus"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # Cases that fit cooler dimensions
            c.execute("""
                SELECT ct.id, ct.brand, ct.depth, ct.height, ct.width
                FROM CASE_TABLE ct
                WHERE ct.depth >= (SELECT depth FROM COOLER WHERE id IN (
                        SELECT Cooler_id FROM CC_SOCKET_COMPATIBLE_WITH WHERE Cpu_id = %s LIMIT 1
                    ))
                AND ct.height >= (SELECT height FROM COOLER WHERE id IN (
                        SELECT Cooler_id FROM CC_SOCKET_COMPATIBLE_WITH WHERE Cpu_id = %s LIMIT 1
                    ))
                AND ct.width >= (SELECT width FROM COOLER WHERE id IN (
                        SELECT Cooler_id FROM CC_SOCKET_COMPATIBLE_WITH WHERE Cpu_id = %s LIMIT 1
                    ))
            """, [cpu_id, cpu_id, cpu_id])
            result["compatible_cases"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            return result
    except Exception as e:
        logger.error(f"CPU compatibility check failed: {e}")
        return {}



def check_motherboard_compatibility(motherboard_id: int) -> dict:
    try:
        with connection.cursor() as c:
            result = {
                "compatible_cpus": [],
                "compatible_rams": [],
                "valid_rams_by_frequency": [],
                "compatible_psus": []
            }

            # Compatible CPUs
            c.execute("""
                SELECT c.id, c.brand, c.model 
                FROM CPU c
                JOIN MC_SOCKET_COMPATIBLE_WITH mc 
                ON c.id = mc.Cpu_id
                WHERE mc.Motherboard_id = %s
            """, [motherboard_id])
            result["compatible_cpus"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # RAM generation compatibility
            c.execute("""
                SELECT r.id, r.brand, r.generation 
                FROM RAM_STICK r
                JOIN RM_SLOT_COMPATIBLE_WITH rm 
                ON r.id = rm.Ram_id
                WHERE rm.Motherboard_id = %s
            """, [motherboard_id])
            result["compatible_rams"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # RAM frequency check
            c.execute("""
                SELECT r.id, r.frequency, m.memory_speed_range 
                FROM RAM_STICK r
                JOIN RM_SLOT_COMPATIBLE_WITH rm ON r.id = rm.Ram_id
                JOIN MOTHERBOARD m ON rm.Motherboard_id = m.id
                WHERE rm.Motherboard_id = %s 
                AND r.frequency <= m.memory_speed_range
            """, [motherboard_id])
            result["valid_rams_by_frequency"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # PSU wattage check
            c.execute("""
                SELECT ps.id, ps.supported_wattage 
                FROM POWER_SUPPLY ps
                WHERE ps.supported_wattage >= (
                    SELECT wattage FROM MOTHERBOARD WHERE id = %s
                )
            """, [motherboard_id])
            result["compatible_psus"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            return result
    except Exception as e:
        logger.error(f"Motherboard compatibility check failed: {e}")
        return {}


        
def motherboard_cpu(motherboard_id=None, cpu_id=None) -> dict:
    try:
        with connection.cursor() as c:
            if cpu_id:
                c.execute("""
                    SELECT mb.id, mb.brand, mb.model 
                    FROM motherboard mb
                    JOIN mc_socket_compatible_with mc ON mb.id = mc.Motherboard_id
                    WHERE mc.Cpu_id = %s
                """, [cpu_id])
            elif motherboard_id:
                c.execute("""
                    SELECT c.id, c.brand, c.model 
                    FROM cpu c
                    JOIN mc_socket_compatible_with mc ON c.id = mc.Cpu_id
                    WHERE mc.Motherboard_id = %s
                """, [motherboard_id])
            
            columns = [col[0] for col in c.description]
            return [dict(zip(columns, row)) for row in c.fetchall()]
    
    except Exception as e:
        logger.error(f"Error: {e}")
        return []

def compatible_ram_motherboard(motherboard_id=None, ram_id=None):
    """ compatibilty of RAM and MB """
    try:
        with connection.cursor() as c:
            if ram_id:
                c.execute("""
                    SELECT m.id, m.brand, m.model, m.memory_speed_range 
                    FROM RM_SLOT_COMPATIBLE_WITH rm JOIN MOTHERBOARD m ON rm."Motherboard_id" = m.id
                    WHERE rm.Ram_id = %s
                """, [ram_id])
                
            elif motherboard_id:
                c.execute("""
                    SELECT r.id, r.brand, r.capacity, r.frequency 
                    FROM RM_SLOT_COMPATIBLE_WITH rm JOIN RAM_STICK r ON rm.Ram_id = r.id
                    WHERE rm.Motherboard_id = %s
                """, [motherboard_id])
                
            columns = [col[0] for col in c.description]
            return [dict(zip(columns, row)) for row in c.fetchall()]
            
    except Exception as e:
        logger.error(f"Error in compatible_ram_motherboard: {e}")
        return []

def about_product(pid="ALL"):
    """ everything about pid Product """
    try:
        with connection.cursor() as c:
            if pid == "ALL":
                c.execute("""
                    SELECT p.id, p.category, p.brand, p.model, p.current_price, p.stock_count,
                           COALESCE(m.chipset, c.generation, r.capacity, g.ram_size) AS spec
                    FROM PRODUCTS p LEFT JOIN MOTHERBOARD m ON p.id = m.id LEFT JOIN CPU c ON p.id = c.id
                                    LEFT JOIN RAM_STICK r ON p.id = r.id LEFT JOIN GPU g ON p.id = g.id
                """)
            else:
                c.execute("""
                    SELECT p.id, p.category, p.brand, p.model, p.current_price, p.stock_count,
                           COALESCE(m.chipset, c.generation, r.capacity, g.ram_size) AS spec
                    FROM PRODUCTS p LEFT JOIN MOTHERBOARD m ON p.id = m.id LEFT JOIN CPU c ON p.id = c.id
                                    LEFT JOIN RAM_STICK r ON p.id = r.id LEFT JOIN GPU g ON p.id = g.id
                    WHERE p.id = %s
                """, [pid])
                
            columns = [col[0] for col in c.description]
            results = c.fetchall()
            
            if pid != "ALL" and not results:
                return {"error": "Product not found"}, 404
                
            return [dict(zip(columns, row)) for row in results]
            
    except Exception as e:
        logger.error(f"Error in about_product: {e}")
        return {"error": "Database error"}, 500


def check_ram_compatibility(ram_id: int) -> dict:
    try:
        with connection.cursor() as c:
            result = {
                "compatible_motherboards": [],
                "compatible_cpus": [],
                "compatible_power_supplies": [],
                "compatible_cases": []
            }

            # Get RAM specs
            c.execute("SELECT frequency, capacity FROM RAM_STICK WHERE id = %s", [ram_id])
            ram_freq, ram_cap = c.fetchone()

            # Motherboards with matching generation and slot
            c.execute("""
                SELECT m.id, m.brand, m.model 
                FROM MOTHERBOARD m
                JOIN RM_SLOT_COMPATIBLE_WITH rm ON m.id = rm.Motherboard_id
                WHERE rm.Ram_id = %s
            """, [ram_id])
            result["compatible_motherboards"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # CPUs that support RAM capacity and frequency
            c.execute("""
                SELECT id, brand, model 
                FROM CPU 
                WHERE maximum_addressable_memory_limit >= %s
                AND base_frequency <= %s 
                AND boost_frequency >= %s
            """, [ram_cap, ram_freq, ram_freq])
            result["compatible_cpus"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # PSU check
            c.execute("""
                SELECT ps.id, ps.brand, ps.supported_wattage 
                FROM POWER_SUPPLY ps
                WHERE ps.supported_wattage >= (
                    SELECT wattage FROM RAM_STICK WHERE id = %s
                )
            """, [ram_id])
            result["compatible_power_supplies"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # Case dimensions
            c.execute("""
                SELECT ct.id, ct.brand 
                FROM CASE_TABLE ct
                WHERE ct.depth >= (SELECT depth FROM RAM_STICK WHERE id = %s)
                AND ct.height >= (SELECT height FROM RAM_STICK WHERE id = %s)
                AND ct.width >= (SELECT width FROM RAM_STICK WHERE id = %s)
            """, [ram_id, ram_id, ram_id])
            result["compatible_cases"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            return result
    except Exception as e:
        logger.error(f"RAM compatibility check failed: {e}")
        return {}



def check_gpu_compatibility(gpu_id: int) -> dict:
    try:
        with connection.cursor() as c:
            result = {
                "compatible_motherboards": [],
                "compatible_psus": [],
                "compatible_cases": []
            }

            # Motherboard compatibility via junction table
            c.execute("""
                SELECT m.id, m.brand, m.model 
                FROM MOTHERBOARD m
                JOIN GM_SLOT_COMPATIBLE_WITH gm 
                ON m.id = gm.Motherboard_id
                WHERE gm.Gpu_id = %s
            """, [gpu_id])
            result["compatible_motherboards"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # PSU wattage check
            c.execute("""
                SELECT ps.id, ps.brand, ps.supported_wattage 
                FROM POWER_SUPPLY ps
                WHERE ps.supported_wattage >= (
                    SELECT wattage FROM GPU WHERE id = %s
                )
            """, [gpu_id])
            result["compatible_psus"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # Case dimensions check
            c.execute("""
                SELECT ct.id, ct.brand, ct.depth, ct.height, ct.width
                FROM CASE_TABLE ct
                WHERE ct.depth >= (SELECT depth FROM GPU WHERE id = %s)
                AND ct.height >= (SELECT height FROM GPU WHERE id = %s)
                AND ct.width >= (SELECT width FROM GPU WHERE id = %s)
            """, [gpu_id, gpu_id, gpu_id])
            result["compatible_cases"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            return result
    except Exception as e:
        logger.error(f"GPU compatibility check failed: {e}")
        return {}

def check_power_supply_compatibility(power_supply_id: int) -> dict:
    try:
        with connection.cursor() as c:
            result = {
                "compatible_gpus": [],
                "remaining_wattage": 0,
                "compatible_storage": [],
                "component_compatibility": []
            }

            # Get total system wattage
            c.execute("""
                SELECT ps.supported_wattage - (
                    SELECT COALESCE(SUM(wattage), 0)
                    FROM (
                        SELECT wattage FROM CPU
                        UNION ALL SELECT wattage FROM GPU
                        UNION ALL SELECT wattage FROM MOTHERBOARD
                        UNION ALL SELECT wattage FROM RAM_STICK
                        UNION ALL SELECT wattage FROM COOLER
                        UNION ALL SELECT wattage FROM SSD
                        UNION ALL SELECT wattage FROM HDD
                    ) AS components
                )
                FROM POWER_SUPPLY ps
                WHERE ps.id = %s
            """, [power_supply_id])
            remaining_wattage = c.fetchone()[0] or 0
            result["remaining_wattage"] = remaining_wattage

            # Compatible GPUs through connector table
            c.execute("""
                SELECT g.id, g.brand, g.model 
                FROM GPU g
                JOIN CONNECTOR_COMPATIBLE_WITH cc 
                ON g.id = cc.Gpu_id
                WHERE cc.Power_id = %s
            """, [power_supply_id])
            result["compatible_gpus"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # Compatible storage devices
            c.execute("""
                (SELECT id, 'ssd' AS type FROM SSD WHERE wattage <= %s)
                UNION ALL
                (SELECT id, 'hdd' FROM HDD WHERE wattage <= %s)
            """, [remaining_wattage, remaining_wattage])
            result["compatible_storage"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # All compatible components
            c.execute("""
                (SELECT id, 'cpu' AS type FROM CPU WHERE wattage <= %s)
                UNION ALL
                (SELECT id, 'gpu' FROM GPU WHERE wattage <= %s)
                UNION ALL
                (SELECT id, 'ram' FROM RAM_STICK WHERE wattage <= %s)
                UNION ALL
                (SELECT id, 'ssd' FROM SSD WHERE wattage <= %s)
                UNION ALL
                (SELECT id, 'hdd' FROM HDD WHERE wattage <= %s)
            """, [remaining_wattage]*5)
            result["component_compatibility"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            return result
    except Exception as e:
        logger.error(f"Power Supply compatibility check failed: {e}")
        return {}


def check_case_compatibility(case_id: int) -> dict:
    try:
        with connection.cursor() as c:
            result = {
                "total_wattage_supported": 0,
                "component_compatibility": []
            }

            # Get case dimensions and wattage capacity
            c.execute("""
                SELECT depth, height, width, wattage 
                FROM CASE_TABLE 
                WHERE id = %s
            """, [case_id])
            case_depth, case_height, case_width, case_wattage = c.fetchone()
            result["total_wattage_supported"] = case_wattage

            # Check all components' physical compatibility
            components = [
                ('motherboard', 'depth', 'height', 'width'),
                ('gpu', 'depth', 'height', 'width'),
                ('cooler', 'depth', 'height', 'width'),
                ('hdd', 'depth', 'height', 'width'),
                ('ssd', 'depth', 'height', 'width')
            ]

            for category, d_col, h_col, w_col in components:
                c.execute(f"""
                    SELECT p.id, p.brand, p.model,
                        ({case_depth} >= {d_col}) AS depth_ok,
                        ({case_height} >= {h_col}) AS height_ok,
                        ({case_width} >= {w_col}) AS width_ok
                    FROM PRODUCTS p
                    JOIN {category.upper()} comp ON p.id = comp.id
                    WHERE p.category = %s
                """, [category])
                
                results = [dict(zip([col[0] for col in c.description], row)) 
                          for row in c.fetchall()]
                result["component_compatibility"].extend(results)

            return result
    except Exception as e:
        logger.error(f"Case compatibility check failed: {e}")
        return {}


def check_storage_compatibility(storage_id: int, storage_type: str) -> dict:
    try:
        with connection.cursor() as c:
            result = {
                "compatible_psus": [],
                "compatible_cases": [],
                "remaining_wattage": 0
            }

            # Get storage device wattage
            c.execute(f"SELECT wattage FROM {storage_type.upper()} WHERE id = %s", [storage_id])
            storage_wattage = c.fetchone()[0]

            # Compatible PSUs with enough capacity
            c.execute("""
                SELECT ps.id, ps.brand, ps.supported_wattage 
                FROM POWER_SUPPLY ps
                WHERE ps.supported_wattage >= (
                    SELECT COALESCE(SUM(wattage), 0) + %s
                    FROM (
                        SELECT wattage FROM CPU
                        UNION ALL SELECT wattage FROM GPU
                        UNION ALL SELECT wattage FROM MOTHERBOARD
                        UNION ALL SELECT wattage FROM RAM_STICK
                        UNION ALL SELECT wattage FROM COOLER
                    ) AS components
                )
            """, [storage_wattage])
            result["compatible_psus"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # Case dimension check
            c.execute(f"""
                SELECT ct.id, ct.brand 
                FROM CASE_TABLE ct
                WHERE ct.depth >= (SELECT depth FROM {storage_type.upper()} WHERE id = %s)
                AND ct.height >= (SELECT height FROM {storage_type.upper()} WHERE id = %s)
                AND ct.width >= (SELECT width FROM {storage_type.upper()} WHERE id = %s)
            """, [storage_id, storage_id, storage_id])
            result["compatible_cases"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            # Calculate remaining wattage
            c.execute("""
                SELECT ps.supported_wattage - (
                    SELECT COALESCE(SUM(wattage), 0) + %s
                    FROM (
                        SELECT wattage FROM CPU
                        UNION ALL SELECT wattage FROM GPU
                        UNION ALL SELECT wattage FROM MOTHERBOARD
                        UNION ALL SELECT wattage FROM RAM_STICK
                        UNION ALL SELECT wattage FROM COOLER
                    ) AS components
                )
                FROM POWER_SUPPLY ps
                WHERE ps.id IN (
                    SELECT id FROM POWER_SUPPLY 
                    WHERE supported_wattage >= (
                        SELECT COALESCE(SUM(wattage), 0) + %s
                        FROM (
                            SELECT wattage FROM CPU
                            UNION ALL SELECT wattage FROM GPU
                            UNION ALL SELECT wattage FROM MOTHERBOARD
                            UNION ALL SELECT wattage FROM RAM_STICK
                            UNION ALL SELECT wattage FROM COOLER
                        ) AS components
                    )
                )
            """, [storage_wattage, storage_wattage])
            result["remaining_wattage"] = c.fetchone()[0] or 0

            return result
    except Exception as e:
        logger.error(f"Storage compatibility check failed: {e}")
        return {}


def show_all_product():
    try: 
        with connection.cursor() as c:
            c.execute(""" 
                SELECT * FROM products;
            """)
            result = {
                "products": [dict(zip([col[0] for col in c.description], row)) 
                           for row in c.fetchall()]
            }
            return result
    except Exception as e: 
        logger.error(f"Error in show_all_product: {e}")
        return {}