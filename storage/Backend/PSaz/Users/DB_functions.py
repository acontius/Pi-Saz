import random
import logging
import psycopg2.extras
from PSaz import authentication
from django.db import connection

logger = logging.getLogger(__name__)


def find_user(phone_number):
    """Fetches user ID and hashed password using phone number."""
    try:
        with connection.cursor() as c:
            c.execute("""
                SELECT id, userPassword
                FROM CLIENT
                WHERE Phone_number = %s;
            """, [phone_number])
            return c.fetchone()
    except psycopg2.Error as e:
        print(f"Database error: {e}")
        return None

def add_user(phone_number, first_name, last_name, userpassword, referral_code):
    """Adds a user to CLIENT or retrieves the existing user ID."""
    generated_referral = f"{phone_number[2:8]}#{first_name[-1]}${random.randint(0, 100)}"
    final_referral = referral_code if referral_code else generated_referral

    try:
        with connection.cursor() as c:
            c.execute("""
                INSERT INTO CLIENT (Phone_number, First_name, Last_name, userPassword, referral_code) 
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (Phone_number) DO NOTHING
                RETURNING id;
            """, [phone_number, first_name, last_name, userpassword, final_referral])

            user_id = c.fetchone()
            
            if user_id is None:
                c.execute("SELECT id FROM CLIENT WHERE Phone_number = %s;", [phone_number])
                user_id = c.fetchone()

            return user_id[0] if user_id else None

    except psycopg2.Error as e:
        print(f"Database error: {e}")
        return None


def insert_address(user_id, new_province, new_remainer):  
    """Inserts a new address for the user if it does not exist."""
    try:
        with connection.cursor() as c:
            c.execute("""
                INSERT INTO ADDRESS (ID, Province, Remainer)
                VALUES (%s, %s, %s)
                ON CONFLICT (ID, Province, Remainer) DO NOTHING;
            """, [user_id, new_province, new_remainer])

            return c.rowcount > 0 
    except psycopg2.Error as e:
        print(f"Database error: {e}")
        return False


def add_to_referral_code(referrer_code, phone):
    """ Inserts a referral record into the 'REFERS' table, ensuring no duplicates. """
    try:
        with connection.cursor() as c:
            c.execute("SELECT id FROM CLIENT WHERE referral_code = %s;", [referrer_code])
            referrer_row = c.fetchone()
            if not referrer_row:
                return {"error": "Invalid referral code"}, False

            c.execute("SELECT id FROM CLIENT WHERE phone_number = %s;", [phone])
            user_row = c.fetchone()
            if not user_row:
                return {"error": "User with this phone number not found."}, False

            referrer_id, user_id = referrer_row[0], user_row[0]

            c.execute("""
                INSERT INTO REFERS (Refree, Referrer)
                VALUES (%s, %s)
                ON CONFLICT (Refree) DO NOTHING;
            """, [user_id, referrer_id])

            inserted = c.rowcount > 0  

            if inserted:
                logger.info(f"Referral added: {user_id} referred by {referrer_id}")
            else:
                logger.info(f"Referral already exists: {user_id} was already referred by {referrer_id}")

            return {"message": "Referral processed."}, inserted

    except psycopg2.Error as e:
        logger.error(f"Database error: {e}")
        return {"error": "Database error occurred."}, False


def get_user_profile(user_id):
    """Fetches full user profile details including address and referral count."""
    try:
        with connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as c:
            c.execute("""
                SELECT First_name, Last_name, Referal_code, wallet_balance, Time_stamp
                FROM CLIENT 
                WHERE id = %s;
            """, [user_id])
            profile = c.fetchone()
            
            if not profile:
                return {"error": "User not found."}

            c.execute("""
                SELECT province, remainer 
                FROM ADDRESS 
                WHERE id = %s;
            """, [user_id])
            profile["addresses"] = c.fetchall()

            # Fetch referral count
            c.execute("""
                SELECT COUNT(*) AS counter 
                FROM REFERS 
                WHERE Referrer = %s;
            """, [user_id])
            profile["referred_count"] = c.fetchone()["counter"]

            return profile

    except psycopg2.Error as e:
        logger.error(f"Database error: {e}")
        return {"error": "Failed to fetch user profile."}    


def is_vip(user_id):
    """Checks if the user has an active VIP subscription."""
    try:
        with connection.cursor() as c:
            c.execute("""
                SELECT EXISTS(
                    SELECT 1 FROM VIP_CLIENT
                    WHERE id = %s 
                    AND Subscription_expiration_time > NOW()
                ) AS is_vip;
            """, [user_id])
            return c.fetchone()["is_vip"]
    except psycopg2.Error as e:
        logger.error(f"Database error: {e}")
        return False


def users_address(user_id):
    """Fetches all addresses associated with a user."""
    try:
        with connection.cursor() as c:
            c.execute("""
                SELECT province, remainer
                FROM ADDRESS
                WHERE id = %s;
            """, [user_id])
            rows = c.fetchall()
            return [{"province": row[0], "remainer": row[1]} for row in rows] if rows else []
    except psycopg2.Error as e:
        logger.error(f"Database error: {e}")
        return []



def refered_numbers(user_id) : 
    """ Will bring the  count(*) of users that this user_id has refered. """
    with connection.cursor() as c :
        c.execute(""" 
        select count(*) as counter
        from REFERS 
        where Referrer = %s;""",[user_id])
        return c.fetchone()


def get_cart_status(user_id) : 
    with connection.cursor() as c :
        c.execute(""" 
        select STATUS, Number
        from SHOPPING_CART 
        where id = %s;""",[user_id])
        names = ['number', 'stat']
        rows  = c.fetchall()
        return [dict(zip(names, row)) for row in rows]


def recent_shops(user_id) :
    with connection.cursor() as c:
        c.execute(""" 
            SELECT L.Cart_number, L.Number AS locked_number, 
                   T.Timestamp AS transaction_timestamp, T.Tracking_code, 
                   L.Timestamp AS locked_timestamp
            FROM locked_shopping_cart L
            JOIN issued_for IFO ON L.ID = IFO.ID 
                AND L.Cart_number = IFO.Cart_number 
                AND L.Number = IFO.Locked_number
            JOIN transaction T ON IFO.Tracking_code = T.Tracking_code
            WHERE L.ID = %s AND T.STATUS = 'Successful'
            ORDER BY T.Timestamp DESC
            LIMIT 5;""", [user_id])
        return cur.fetchall()

def expiring_private_codes(user_id) : 
    with connection.cursor() as c :
        c.execute(""" 
        SELECT Code
        FROM PRIVATE_CODE NATURAL JOIN DISCOUNT_CODE
        WHERE ID = %s AND Expiration_date <= CURRENT_TIMESTAMP + INTERVAL '7 days';
        """,[user_id])
        rows = c.fetchall()

    return [row[0] for row in rows]

def get_vip_benefits(user_id):
    """ Retrieves the VIP user's remaining subscription time, monthly profit, and cashback percentage. """
    with connection.cursor() as c:
        c.execute("""
            SELECT 
                VC.Subscription_expiration_time - CURRENT_TIMESTAMP AS remaining_time,
                COALESCE(SUM(T.Amount * 0.15), 0) AS monthly_profit,  
                15 AS cashback_percentage
            FROM VIP_CLIENT VC LEFT JOIN TRANSACTION T ON VC.ID = T.ID
            AND T.STATUS = 'Successful'
            AND T.Timestamp >= VC.Subscription_expiration_time
            WHERE VC.ID = %s
            GROUP BY VC.ID, VC.Subscription_expiration_time;
        """, [user_id])

        return c.fetchone()