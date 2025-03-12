# import random
# import logging
# import psycopg2.extras
# from PSaz import authentication
# from django.db import connection

# logger = logging.getLogger(__name__)

# def find_user(phone_number):
#     """Fetches user ID and hashed password using phone number."""
#     try:
#         with connection.cursor() as c:
#             c.execute("""
#                 SELECT id, userPassword
#                 FROM CLIENT
#                 WHERE Phone_number = %s;
#             """, [phone_number])
#             return c.fetchone()
#     except psycopg2.Error as e:
#         print(f"Database error: {e}")
#         return None

# def add_user(phone_number, first_name, last_name, userpassword, referral_code):
#     """Adds a user to CLIENT or retrieves the existing user ID."""
#     generated_referral = f"{phone_number[2:8]}#{first_name[-1]}${random.randint(0, 100)}"
#     final_referral = referral_code if referral_code else generated_referral

#     try:
#         with connection.cursor() as c:
#             c.execute("""
#                 INSERT INTO CLIENT (Phone_number, First_name, Last_name, userPassword, referral_code) 
#                 VALUES (%s, %s, %s, %s, %s)
#                 ON CONFLICT (Phone_number) DO NOTHING
#                 RETURNING id;
#             """, [phone_number, first_name, last_name, userpassword, final_referral])

#             user_id = c.fetchone()
            
#             if user_id is None:
#                 c.execute("SELECT id FROM CLIENT WHERE Phone_number = %s;", [phone_number])
#                 user_id = c.fetchone()

#             return user_id[0] if user_id else None

#     except psycopg2.Error as e:
#         print(f"Database error: {e}")
#         return None


# def insert_address(user_id, new_province, new_remainer):  
#     """Inserts a new address for the user if it does not exist."""
#     try:
#         with connection.cursor() as c:
#             c.execute("""
#                 INSERT INTO ADDRESS (ID, Province, Remainer)
#                 VALUES (%s, %s, %s)
#                 ON CONFLICT (ID, Province, Remainer) DO NOTHING;
#             """, [user_id, new_province, new_remainer])

#             return c.rowcount > 0 
#     except psycopg2.Error as e:
#         print(f"Database error: {e}")
#         return False


# def add_to_referral_code(referrer_code, phone):
#     """ Inserts a referral record into the 'REFERS' table, ensuring no duplicates. """
#     try:
#         with connection.cursor() as c:
#             c.execute("SELECT id FROM CLIENT WHERE referral_code = %s;", [referrer_code])
#             referrer_row = c.fetchone()
#             if not referrer_row:
#                 return {"error": "Invalid referral code"}, False

#             c.execute("SELECT id FROM CLIENT WHERE phone_number = %s;", [phone])
#             user_row = c.fetchone()
#             if not user_row:
#                 return {"error": "User with this phone number not found."}, False

#             referrer_id, user_id = referrer_row[0], user_row[0]

#             c.execute("""
#                 INSERT INTO REFERS (Refree, Referrer)
#                 VALUES (%s, %s)
#                 ON CONFLICT (Refree) DO NOTHING;
#             """, [user_id, referrer_id])

#             inserted = c.rowcount > 0  

#             if inserted:
#                 logger.info(f"Referral added: {user_id} referred by {referrer_id}")
#             else:
#                 logger.info(f"Referral already exists: {user_id} was already referred by {referrer_id}")

#             return {"message": "Referral processed."}, inserted

#     except psycopg2.Error as e:
#         logger.error(f"Database error: {e}")
#         return {"error": "Database error occurred."}, False

# def get_user_profile(user_id):
#     """Fetches full user profile details including address and referral count."""
#     try:
#         with connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as c:
#             c.execute("""
#                 SELECT First_name, Last_name, Referal_code, wallet_balance, Time_stamp
#                 FROM CLIENT 
#                 WHERE id = %s;
#             """, [user_id])
#             profile = c.fetchone()
            
#             if not profile:
#                 return {"error": "User not found."}

#             c.execute("""
#                 SELECT province, remainer 
#                 FROM ADDRESS 
#                 WHERE id = %s;
#             """, [user_id])
#             profile["addresses"] = c.fetchall()

#             # Fetch referral count
#             c.execute("""
#                 SELECT COUNT(*) AS counter 
#                 FROM REFERS 
#                 WHERE Referrer = %s;
#             """, [user_id])
#             profile["referred_count"] = c.fetchone()["counter"]

#             return profile

#     except psycopg2.Error as e:
#         logger.error(f"Database error: {e}")
#         return {"error": "Failed to fetch user profile."}    


# def is_vip(user_id):
#     """Checks if the user has an active VIP subscription."""
#     try:
#         with connection.cursor() as c:
#             c.execute("""
#                 SELECT EXISTS(
#                     SELECT 1 FROM VIP_CLIENT
#                     WHERE id = %s 
#                     AND Subscription_expiration_time > NOW()
#                 ) AS is_vip;
#             """, [user_id])
#             return c.fetchone()["is_vip"]
#     except psycopg2.Error as e:
#         logger.error(f"Database error: {e}")
#         return False


# def users_address(user_id):
#     """Fetches all addresses associated with a user."""
#     try:
#         with connection.cursor() as c:
#             c.execute("""
#                 SELECT province, remainer
#                 FROM ADDRESS
#                 WHERE id = %s;
#             """, [user_id])
#             rows = c.fetchall()
#             return [{"province": row[0], "remainer": row[1]} for row in rows] if rows else []
#     except psycopg2.Error as e:
#         logger.error(f"Database error: {e}")
#         return []



# def refered_numbers(user_id) : 
#     """ Will bring the  count(*) of users that this user_id has refered. """
#     with connection.cursor() as c :
#         c.execute(""" 
#         select count(*) as counter
#         from REFERS 
#         where Referrer = %s;""",[user_id])
#         return c.fetchone()


# def get_cart_status(user_id) : 
#     with connection.cursor() as c :
#         c.execute(""" 
#         select STATUS, Number
#         from SHOPPING_CART 
#         where id = %s;""",[user_id])
#         names = ['number', 'stat']
#         rows  = c.fetchall()
#         return [dict(zip(names, row)) for row in rows]


# def recent_shops(user_id) :
#     with connection.cursor() as c:
#         c.execute(""" 
#             SELECT L.Cart_number, L.Number AS locked_number, 
#                    T.Timestamp AS transaction_timestamp, T.Tracking_code, 
#                    L.Timestamp AS locked_timestamp
#             FROM locked_shopping_cart L
#             JOIN issued_for IFO ON L.ID = IFO.ID 
#                 AND L.Cart_number = IFO.Cart_number 
#                 AND L.Number = IFO.Locked_number
#             JOIN transaction T ON IFO.Tracking_code = T.Tracking_code
#             WHERE L.ID = %s AND T.STATUS = 'Successful'
#             ORDER BY T.Timestamp DESC
#             LIMIT 5;""", [user_id])
#         return cur.fetchall()

# def expiring_private_codes(user_id) : 
#     with connection.cursor() as c :
#         c.execute(""" 
#         SELECT Code
#         FROM PRIVATE_CODE NATURAL JOIN DISCOUNT_CODE
#         WHERE ID = %s AND Expiration_date <= CURRENT_TIMESTAMP + INTERVAL '7 days';
#         """,[user_id])
#         rows = c.fetchall()

#     return [row[0] for row in rows]

# def get_vip_benefits(user_id):
#     """Retrieves VIP user's remaining subscription time, monthly profit, and cashback percentage."""
#     with connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as c:
#         c.execute("""
#             SELECT 
#                 (VC.Subscription_expiration_time - CURRENT_TIMESTAMP) AS remaining_time,
#                 COALESCE(SUM(T.Amount * 0.15), 0) AS monthly_profit,  
#                 15 AS cashback_percentage
#             FROM VIP_CLIENT VC 
#             LEFT JOIN TRANSACTION T ON VC.ID = T.ID
#                 AND T.STATUS = 'Successful'
#                 AND T.Timestamp >= VC.Subscription_expiration_time
#             WHERE VC.ID = %s
#             GROUP BY VC.ID, VC.Subscription_expiration_time;
#         """, [user_id])

#         return c.fetchone()


# def get_user_profile(phone_number):
#     """Fetch complete user profile from database"""
#     with connection.cursor() as cursor:
#         cursor.execute("""
#             SELECT 
#                 c.id, c.first_name, c.last_name, 
#                 c.wallet_balance, c.time_stamp, c.referal_code,
#                 v.subscription_expiration_time,
#                 COUNT(r.refree) AS referral_count
#             FROM client c
#             LEFT JOIN vip_client v ON c.id = v.id
#             LEFT JOIN refers r ON c.id = r.referrer
#             WHERE c.phone_number = %s
#             GROUP BY c.id, v.subscription_expiration_time
#         """, [phone_number])
#         user = dict(zip(
#             [col[0] for col in cursor.description], 
#             cursor.fetchone()
#         )) if cursor.rowcount else None

#         if not user:
#             return None

#         cursor.execute("""
#             SELECT province, remainer 
#             FROM address 
#             WHERE id = %s
#         """, [user['id']])
#         user['addresses'] = [
#             dict(zip(['province', 'remainer'], row)) 
#             for row in cursor.fetchall()
#         ]

#         cursor.execute("""
#             SELECT number, status, time_stamp 
#             FROM shopping_cart 
#             WHERE id = %s
#         """, [user['id']])
#         user['shopping_carts'] = [
#             dict(zip(['number', 'status', 'time_stamp'], row)) 
#             for row in cursor.fetchall()
#         ]

#         cursor.execute("""
#             SELECT t.tracking_code, t.status, t.timestamp 
#             FROM transaction t
#             JOIN issued_for i ON t.tracking_code = i.tracking_code
#             WHERE i.id = %s
#             ORDER BY t.timestamp DESC
#             LIMIT 5
#         """, [user['id']])
#         user['transactions'] = [
#             dict(zip(['tracking_code', 'status', 'timestamp'], row)) 
#             for row in cursor.fetchall()
#         ]

#         return user


from django.db import connection
from PSaz import authentication

def get_user(phone, password):
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT id FROM client WHERE phone_number = %s AND password = %s",
            (phone, auth_services.hash_pass(password))
        )
        user = cursor.fetchone()
    return user

def insert_client(first_name, last_name, phone, password, referral_code=None):
    with connection.cursor() as cursor:
        # Generate a referral code if not provided
        ref_code = referral_code or f"{first_name[0]}{last_name[0]}_{phone[-4:]}"
        cursor.execute(
            """
            INSERT INTO client (first_name, last_name, phone_number, referral_code, password)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id
            """,
            (first_name, last_name, phone, ref_code, auth_services.hash_pass(password))
        )
        return cursor.fetchone()[0]

def insert_refer(referrer_code, phone):
    with connection.cursor() as cursor:
        cursor.execute("SELECT id FROM client WHERE referral_code = %s", (referrer_code,))
        referrer_id = cursor.fetchone()
        if not referrer_id:
            raise Exception("Invalid referrer code")
        referrer_id = referrer_id[0]
        
        cursor.execute("SELECT id FROM client WHERE phone_number = %s", (phone,))
        referee_id = cursor.fetchone()[0]
        
        cursor.execute(
            "INSERT INTO refers (refree, referrer) VALUES (%s, %s)",
            (referee_id, referrer_id)
        )

def common_user_data(uid):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT first_name, last_name, referral_code, wallet_balance, time_stamp
            FROM client WHERE id = %s
            """,
            (uid,)
        )
        colnames = [desc[0] for desc in cursor.description]
        result = cursor.fetchone()
        return dict(zip(colnames, result)) if result else {}

def user_addresses(uid):
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT province, remainer FROM address WHERE id = %s",
            (uid,)
        )
        colnames = ["province", "remainder"]
        result = cursor.fetchall()
    return [dict(zip(colnames, item)) for item in result]

def check_vip(uid):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT EXISTS (
                SELECT 1 FROM vip_client
                WHERE id = %s AND subscription_expiration_time > CURRENT_TIMESTAMP
            ) AS is_vip
            """,
            (uid,)
        )
        return cursor.fetchone()[0]

def number_of_referred(uid):
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT COUNT(*) FROM refers WHERE referrer = %s",
            (uid,)
        )
        return cursor.fetchone()[0]

def vip_remainder_time(uid):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT 
                EXTRACT(DAY FROM (subscription_expiration_time - CURRENT_TIMESTAMP)),
                EXTRACT(HOUR FROM (subscription_expiration_time - CURRENT_TIMESTAMP)),
                EXTRACT(MINUTE FROM (subscription_expiration_time - CURRENT_TIMESTAMP))
            FROM vip_client 
            WHERE id = %s AND subscription_expiration_time > CURRENT_TIMESTAMP
            """,
            (uid,)
        )
        result = cursor.fetchone()
        return result if result else (0, 0, 0)

def monthly_purchases(uid):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT lsc.cart_number, lsc.number
            FROM vip_client vip
            JOIN locked_shopping_cart lsc ON vip.id = lsc.id
            JOIN issued_for isu ON lsc.id = isu.id AND lsc.cart_number = isu.cart_number AND lsc.number = isu.locked_number
            WHERE vip.id = %s 
            AND subscription_expiration_time >= CURRENT_TIMESTAMP 
            AND isu.tracking_code IN (
                SELECT tracking_code 
                FROM transaction 
                WHERE status = 'Successful'
                AND timestamp >= DATE_TRUNC('month', CURRENT_TIMESTAMP - INTERVAL '1 month')
            )
            """,
            (uid,)
        )
        return cursor.fetchall()

def carts_status(uid):
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT number, status FROM shopping_cart WHERE id = %s",
            (uid,)
        )
        colnames = ['cart_number', 'status']
        result = cursor.fetchall()
        return [dict(zip(colnames, item)) for item in result]

def recent_purchases(uid):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT isu.cart_number, isu.locked_number, trs.timestamp, trs.tracking_code, lsc.timestamp
            FROM issued_for isu
            JOIN transaction trs ON isu.tracking_code = trs.tracking_code
            JOIN locked_shopping_cart lsc ON lsc.id = isu.id AND lsc.cart_number = isu.cart_number AND lsc.number = isu.locked_number
            WHERE isu.id = %s AND trs.status = 'Successful'
            ORDER BY trs.timestamp DESC
            LIMIT 5
            """,
            (uid,)
        )
        return cursor.fetchall()

def products_of_purchase(uid, cart_number, locked_number):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT p.id, p.category, p.brand, p.model, a.quantity, p.current_price
            FROM added_to a
            JOIN products p ON a.product_id = p.id
            WHERE a.id = %s AND a.cart_number = %s AND a.locked_number = %s
            """,
            (uid, cart_number, locked_number)
        )
        colnames = ["product_id", "category", "brand", "model", "quantity", "cart_price"]
        result = cursor.fetchall()
        return [dict(zip(colnames, item)) for item in result]

def count_gift_codes(uid):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            WITH RECURSIVE referrals AS (
                SELECT refree FROM refers WHERE referrer = %s
                UNION ALL
                SELECT r.refree FROM refers r JOIN referrals rs ON r.referrer = rs.refree
            )
            SELECT COUNT(*) FROM referrals
            """,
            (uid,)
        )
        return cursor.fetchone()[0]

def check_is_introduced(uid):
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT EXISTS (SELECT 1 FROM refers WHERE refree = %s) AS is_introduced",
            (uid,)
        )
        return cursor.fetchone()[0]

def soonexp_discount_code(uid):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT pc.code, dc.usage_count, dc.amount, dc.usage_limit, dc.expiration_date
            FROM private_code pc
            JOIN discount_code dc ON pc.code = dc.code
            WHERE pc.id = %s 
            AND dc.expiration_date >= CURRENT_TIMESTAMP 
            AND dc.expiration_date < CURRENT_TIMESTAMP + INTERVAL '7 days'
            """,
            (uid,)
        )
        colnames = [desc[0] for desc in cursor.description]
        result = cursor.fetchall()
    return [dict(zip(colnames, item)) for item in result]

def calculate_cart_price(uid, cart_number, locked_number):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT COALESCE(SUM(p.current_price * a.quantity), 0)
            FROM added_to a
            JOIN products p ON a.product_id = p.id
            WHERE a.id = %s AND a.cart_number = %s AND a.locked_number = %s
            """,
            (uid, cart_number, locked_number)
        )
        total = cursor.fetchone()[0]
        
        # Apply discounts
        cursor.execute(
            """
            SELECT dc.amount, dc.discount_type
            FROM applied_to ap
            JOIN discount_code dc ON ap.code = dc.code
            WHERE ap.id = %s AND ap.cart_number = %s AND ap.locked_number = %s
            """,
            (uid, cart_number, locked_number)
        )
        discounts = cursor.fetchall()
        for amount, discount_type in discounts:
            if discount_type == 'percentage':
                total -= total * (amount / 100)
            elif discount_type == 'fixed':
                total -= amount
            total = max(0, total)  # Ensure total doesn't go negative
        return total

def insert_address(uid, province, remainder):
    with connection.cursor() as cursor:
        cursor.execute(
            "INSERT INTO address (id, province, remainer) VALUES (%s, %s, %s)",
            (uid, province, remainder)
        )