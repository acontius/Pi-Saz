from django.db import connection
from django.http import JsonResponse
import logging

logger = logging.getLogger(__name__)


def check_cpu_compatibility(cpu_id: int) -> dict:
    """
    CPU compatibilities with cooler and MB and PS
    """
    try:
        with connection.cursor() as c:
            result = {
                "compatible_motherboards": [],
                "compatible_coolers": [],
                "compatible_psus": [],
                "compatible_cases": []
            }

            """ socket with MB """
            c.execute("""
                SELECT m.id, m.brand, m.model, m.socket_type 
                FROM MOTHERBOARD m
                JOIN MC_SOCKET_COMPATIBLE_WITH mc ON m.id = mc.motherboard_id
                WHERE mc.cpu_id = %s
            """, [cpu_id])
            result["compatible_motherboards"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            """ with coolers """
            c.execute("""
                SELECT cl.id, cl.brand, cl.model, cl.depth, cl.height, cl.width
                FROM COOLER cl
                JOIN CC_SOCKET_COMPATIBLE_WITH cc ON cl.id = cc.cooler_id
                WHERE cc.cpu_id = %s
            """, [cpu_id])
            result["compatible_coolers"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            """ wattage for CPU+COOLER """
            c.execute("""
                SELECT ps.id, ps.brand, ps.supported_wattage 
                FROM POWER_SUPPLY ps
                WHERE ps.supported_wattage >= (
                    SELECT c.wattage + cl.wattage 
                    FROM CPU c
                    JOIN COOLER cl ON cl.id = (
                        SELECT cooler_id FROM CC_SOCKET_COMPATIBLE_WITH WHERE cpu_id = %s LIMIT 1
                    )
                    WHERE c.id = %s
                )
            """, [cpu_id, cpu_id])
            result["compatible_psus"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            """ case with coolers """
            c.execute("""
                SELECT ct.id, ct.brand, ct.depth, ct.height, ct.width
                FROM CASE_TABLE ct
                WHERE ct.depth >= (SELECT depth FROM COOLER WHERE id IN (
                        SELECT cooler_id FROM CC_SOCKET_COMPATIBLE_WITH WHERE cpu_id = %s
                    ))
                AND ct.height >= (SELECT height FROM COOLER WHERE id IN (
                        SELECT cooler_id FROM CC_SOCKET_COMPATIBLE_WITH WHERE cpu_id = %s
                    ))
                AND ct.width >= (SELECT width FROM COOLER WHERE id IN (
                        SELECT cooler_id FROM CC_SOCKET_COMPATIBLE_WITH WHERE cpu_id = %s
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
            """ socket """
            c.execute("""
                SELECT c.id, c.brand, c.model 
                FROM cpu c
                JOIN mc_socket_compatible_with mc ON c.id = mc.cpu_id
                WHERE mc.motherboard_id = %s
            """, [motherboard_id])
            compatible_cpus = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]
            
            """ RAM GEN """
            c.execute("""
                SELECT r.id, r.brand, r.generation 
                FROM ram_stick r
                JOIN rm_slot_compatible_with rm ON r.id = rm.ram_id
                WHERE rm.motherboard_id = %s
            """, [motherboard_id])
            compatible_rams = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            """ RAM FREQUENCY """ 
            c.execute("""
                SELECT r.id, r.frequency, m.memory_speed_range 
                FROM ram_stick r
                JOIN rm_slot_compatible_with rm ON r.id = rm.ram_id
                JOIN motherboard m ON rm.motherboard_id = m.id
                WHERE rm.motherboard_id = %s 
                AND r.frequency BETWEEN m.memory_speed_range - 100 AND m.memory_speed_range + 100
            """, [motherboard_id])
            valid_rams = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            """ Wattage """
            c.execute("""
                SELECT ps.id, ps.supported_wattage 
                FROM power_supply ps
                WHERE ps.supported_wattage >= (
                    SELECT wattage FROM motherboard WHERE id = %s
                )
            """, [motherboard_id])
            compatible_psu = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            return {
                "compatible_cpus": compatible_cpus,
                "compatible_rams": compatible_rams,
                "valid_rams_by_frequency": valid_rams,
                "compatible_psus": compatible_psu
            }
    
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
                    JOIN mc_socket_compatible_with mc ON mb.id = mc.motherboard_id
                    WHERE mc.cpu_id = %s
                """, [cpu_id])
            elif motherboard_id:
                c.execute("""
                    SELECT c.id, c.brand, c.model 
                    FROM cpu c
                    JOIN mc_socket_compatible_with mc ON c.id = mc.cpu_id
                    WHERE mc.motherboard_id = %s
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
                    FROM RM_SLOT_COMPATIBLE_WITH rm JOIN MOTHERBOARD m ON rm.motherboard_id = m.id
                    WHERE rm.ram_id = %s
                """, [ram_id])
                
            elif motherboard_id:
                c.execute("""
                    SELECT r.id, r.brand, r.capacity, r.frequency 
                    FROM RM_SLOT_COMPATIBLE_WITH rm JOIN RAM_STICK r ON rm.ram_id = r.id
                    WHERE rm.motherboard_id = %s
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
    """
    RAM compatibilities
    """
    try:
        with connection.cursor() as c:
            result = {
                "compatible_motherboards": [],
                "compatible_cpus": [],
                "compatible_power_supplies": [],
                "compatible_cases": []
            }

            """ generation compatibilities """
            c.execute("""
                SELECT m.id, m.brand, m.model, m.ram_generation_support
                FROM MOTHERBOARD m
                JOIN RM_SLOT_COMPATIBLE_WITH rm ON m.id = rm.motherboard_id
                WHERE rm.ram_id = %s 
                AND m.ram_generation_support = (
                    SELECT generation FROM RAM_STICK WHERE id = %s
                )
            """, [ram_id, ram_id])
            result["compatible_motherboards"] = [
                dict(zip([col[0] for col in c.description], row)) 
                for row in c.fetchall()
            ]

            """ frequence compatibilities with MB """
            c.execute("""
                SELECT m.id, m.brand, m.memory_speed_range
                FROM MOTHERBOARD m
                JOIN RM_SLOT_COMPATIBLE_WITH rm ON m.id = rm.motherboard_id
                JOIN RAM_STICK r ON rm.ram_id = r.id
                WHERE r.id = %s 
                AND r.frequency BETWEEN m.memory_speed_range - 100 AND m.memory_speed_range + 100
            """, [ram_id])
            result["valid_motherboards_by_frequency"] = [
                dict(zip([col[0] for col in c.description], row)) 
                for row in c.fetchall()
            ]

            """ limit compatibilities with CPU"""
            c.execute("""
                SELECT cpu.id, cpu.brand, cpu.model, cpu.maximum_addressable_memory_limit
                FROM CPU cpu
                WHERE cpu.maximum_addressable_memory_limit >= (
                    SELECT capacity FROM RAM_STICK WHERE id = %s
                )
            """, [ram_id])
            result["compatible_cpus"] = [
                dict(zip([col[0] for col in c.description], row)) 
                for row in c.fetchall()
            ]

            """ frequence compatibilities with CPU """
            c.execute("""
                SELECT cpu.id, cpu.brand, cpu.base_frequency, cpu.boost_frequency
                FROM CPU cpu
                WHERE (
                    SELECT frequency FROM RAM_STICK WHERE id = %s
                ) BETWEEN cpu.base_frequency AND cpu.boost_frequency
            """, [ram_id])
            result["valid_cpus_by_frequency"] = [
                dict(zip([col[0] for col in c.description], row)) 
                for row in c.fetchall()
            ]

            """ wattage compatibilities """
            c.execute("""
                SELECT ps.id, ps.brand, ps.supported_wattage
                FROM POWER_SUPPLY ps
                WHERE ps.supported_wattage >= (
                    SELECT wattage FROM RAM_STICK WHERE id = %s
                )
            """, [ram_id])
            result["compatible_power_supplies"] = [
                dict(zip([col[0] for col in c.description], row)) 
                for row in c.fetchall()
            ]

            """ case compatibilities """
            c.execute("""
                SELECT ct.id, ct.brand, ct.depth, ct.height, ct.width
                FROM CASE_TABLE ct
                WHERE ct.depth >= (SELECT depth FROM RAM_STICK WHERE id = %s)
                AND ct.height >= (SELECT height FROM RAM_STICK WHERE id = %s)
                AND ct.width >= (SELECT width FROM RAM_STICK WHERE id = %s)
            """, [ram_id, ram_id, ram_id])
            result["compatible_cases"] = [
                dict(zip([col[0] for col in c.description], row)) 
                for row in c.fetchall()
            ]

            return result

    except Exception as e:
        logger.error(f"RAM compatibility check failed: {e}")
        return {}


def check_gpu_compatibility(gpu_id: int) -> dict:
    """
    GPU compatibilities with MB and PS
    """
    try:
        with connection.cursor() as c:
            result = {
                "compatible_motherboards": [],
                "compatible_psus": [],
                "compatible_cases": []
            }

            """ slot with MB """
            c.execute("""
                SELECT m.id, m.brand, m.model, m.gpu_slot_type 
                FROM MOTHERBOARD m
                JOIN GM_SLOT_COMPATIBLE_WITH gm ON m.id = gm.motherboard_id
                WHERE gm.gpu_id = %s
            """, [gpu_id])
            result["compatible_motherboards"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            """ wattage """
            c.execute("""
                SELECT ps.id, ps.brand, ps.supported_wattage 
                FROM POWER_SUPPLY ps
                WHERE ps.supported_wattage >= (
                    SELECT wattage FROM GPU WHERE id = %s
                )
            """, [gpu_id])
            result["compatible_psus"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            """ GPU dementions with case """
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
    """
    PS compatibilities with GPU and ...
    """
    try:
        with connection.cursor() as c:
            result = {
                "compatible_gpus": [],
                "remaining_wattage": 0,
                "compatible_ssds": [],
                "compatible_hdds": []
            }

            """ conector with GPU """
            c.execute("""
                SELECT g.id, g.brand, g.model, g.connector_type 
                FROM GPU g
                JOIN CONNECTOR_COMPATIBLE_WITH cc ON g.id = cc.gpu_id
                WHERE cc.power_id = %s
            """, [power_supply_id])
            result["compatible_gpus"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            """ reamining wattage with """
            c.execute("""
                SELECT ps.supported_wattage - (
                    SELECT COALESCE(SUM(wattage), 0) 
                    FROM (
                        SELECT wattage FROM CPU UNION ALL
                        SELECT wattage FROM GPU UNION ALL
                        SELECT wattage FROM MOTHERBOARD
                    ) AS total
                )
                FROM POWER_SUPPLY ps 
                WHERE ps.id = %s
            """, [power_supply_id])
            result["remaining_wattage"] = c.fetchone()[0]

            """ compatibilities with SSD/HDD """ 
            c.execute("""
                SELECT ssd.id, ssd.brand, ssd.model 
                FROM SSD ssd 
                WHERE ssd.wattage <= %s
            """, [result["remaining_wattage"]])
            result["compatible_ssds"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            c.execute("""
                SELECT hdd.id, hdd.brand, hdd.model 
                FROM HDD hdd 
                WHERE hdd.wattage <= %s
            """, [result["remaining_wattage"]])
            result["compatible_hdds"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            return result

    except Exception as e:
        logger.error(f"Power Supply compatibility check failed: {e}")
        return {}


def check_case_compatibility(case_id: int) -> dict:
    """
    case compatibilites with ...
    """
    try:
        with connection.cursor() as c:
            result = {
                "compatible_components": [],
                "total_wattage_supported": 0
            }

            """ total wattage  """
            c.execute("""
                SELECT supported_wattage 
                FROM CASE_TABLE 
                WHERE id = %s
            """, [case_id])
            total_wattage = c.fetchone()[0]
            result["total_wattage_supported"] = total_wattage

            """ dementions """
            c.execute("""
                SELECT 
                    p.id, p.category, 
                    CASE 
                        WHEN p.category = 'motherboard' THEN m.depth <= ct.depth AND m.height <= ct.height AND m.width <= ct.width
                        WHEN p.category = 'gpu' THEN g.depth <= ct.depth AND g.height <= ct.height AND g.width <= ct.width
                        ELSE TRUE
                    END AS fits
                FROM PRODUCTS p
                LEFT JOIN MOTHERBOARD m ON p.id = m.id
                LEFT JOIN GPU g ON p.id = g.id
                CROSS JOIN CASE_TABLE ct
                WHERE ct.id = %s
            """, [case_id])
            result["compatible_components"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            return result

    except Exception as e:
        logger.error(f"Case compatibility check failed: {e}")
        return {}


def check_storage_compatibility(storage_id: int, storage_type: str) -> dict:
    """
    SSD/HDD compatibilities with PS and case
    """
    try:
        with connection.cursor() as c:
            result = {
                "compatible_psus": [],
                "compatible_cases": []
            }

            """ wattage compatibilities with PS """
            c.execute(f"""
                SELECT ps.id, ps.brand, ps.supported_wattage 
                FROM POWER_SUPPLY ps
                WHERE ps.supported_wattage >= (
                    SELECT wattage FROM {storage_type.upper()} WHERE id = %s
                )
            """, [storage_id])
            result["compatible_psus"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            """ demention compatibilities with case """
            c.execute(f"""
                SELECT ct.id, ct.brand 
                FROM CASE_TABLE ct
                WHERE ct.depth >= (SELECT depth FROM {storage_type.upper()} WHERE id = %s)
                AND ct.height >= (SELECT height FROM {storage_type.upper()} WHERE id = %s)
                AND ct.width >= (SELECT width FROM {storage_type.upper()} WHERE id = %s)
            """, [storage_id, storage_id, storage_id])
            result["compatible_cases"] = [dict(zip([col[0] for col in c.description], row)) for row in c.fetchall()]

            return result

    except Exception as e:
        logger.error(f"Storage compatibility check failed: {e}")
        return {}

