import random
import logging
import psycopg2.extras
from PSaz import authentication
from django.db import connection

logger = logging.getLogger(__name__)



def find_user(phone_number) : 
    """ will take the Id of user who is logging in """
    with connection.cursor() as c :
        c.execute(""" 
        SELECT id , userPassword
        FROM CLIENT C
        WHERE C.Phone_number = %s;""",[phone_number])
        logger = c.fetchone()
        return logger

def add_user(phone_number, first_name, last_name, userpassword, referral_code):
    """ Adds a new user to the Client table, or returns the existing user ID if the phone number already exists. """
    generated_referral = f"{phone_number[2:8]}#{first_name[-1]}${random.randint(0, 100)}"
    final_referral = referral_code if referral_code else generated_referral

    with connection.cursor() as c:
        c.execute("""
            INSERT INTO CLIENT (Phone_number, First_name, Last_name, userPassword, referral_code) 
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (Phone_number) DO NOTHING
            RETURNING id;
        """, [phone_number, first_name, last_name, userpassword, final_referral])
        
        user_id = c.fetchone()

        if not user_id :
            c.execute("SELECT id FROM CLIENT WHERE Phone_number = %s;", [phone_number])
            user_id = c.fetchone()[0]

        return user_id 


def insert_adderes(user_id, new_province, new_remainer):  
    with connection.cursor() as c:
        c.execute("""
            INSERT INTO ADDRESS(ID, Province, Remainer)
            VALUES (%s, %s, %s)
            ON CONFLICT DO NOTHING;
        """, [user_id, new_province, new_remainer])

        return c.rowcount > 0  

def add_to_referral_code(referrer_code, phone):
    """ Inserts a referral record into the 'refer' table, ensuring no duplicates. """
    with connection.cursor() as c:
        c.execute("SELECT id FROM client WHERE referral_code = %s;", [referrer_code])
        referrer_row = c.fetchone()
        if not referrer_row:
            logger.warning(f"Invalid referral code attempted: {referrer_code}")
            raise ValueError("Invalid referral code.")

        referrer_id = referrer_row[0]

        c.execute("SELECT id FROM client WHERE phone_number = %s;", [phone])
        user_row = c.fetchone()
        if not user_row:
            logger.warning(f"Referral attempt failed: User with phone {phone} not found.")
            raise ValueError("User with this phone number was not found.")

        user_id = user_row[0]

        c.execute("""
            INSERT INTO REFERS (Refree, Referrer)
            VALUES (%s, %s)
            ON CONFLICT DO NOTHING;
        """, [user_id, referrer_id])
        # Zero iif exists 
        inserted = c.rowcount > 0  
        
        if inserted:
            logger.info(f"Referral added: {user_id} referred by {referrer_id}")
        else:
            logger.info(f"Referral already exists: {user_id} was already referred by {referrer_id}")

        return inserted



def get_user_profile(id) :
    """ gets all the datas from client(id) table. """
    with connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as c :
        c.execute(""" 
        select First_name, Last_name, Referal_code, wallet_balance, Time_stamp
        from client 
        where id = %s;""",[id])
        return c.fetchone()
        

def is_vip(user_id) : 
    """ Checks if the user is VIP or not. """
    with connection.cursor() as c :
        c.execute(""" 
        select case 
        when exists(
        select 1 from VIP_CLIENT
        where id = %s and Subscription_expiration_time > CURRENT_TIMESTAMP
        ) then 1
        else 0
        end as is_vip;""",[user_id])
        return c.fetchone()

def users_address(user_id) :
    """ Brings all the User's adderess from Adderss table. """
    with connection.cursor() as c : 
        c.execute(""" 
        select province, remainder
        from address
        where id = %s;""",[user_id])

        names = ['province', 'remainder']
        rows  = c.fetchall()
        return [dict(zip(names, row)) for row in rows]

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