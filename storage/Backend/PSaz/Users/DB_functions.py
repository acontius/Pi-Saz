import random
import logging
import psycopg2.extras
from PSaz import authentication
from django.db import connection


def find_user(phone_number) : 
    """ will take the Id of user who is logging in """
    with connection.cursor() as c :
        c.execute(""" 
        SELECT id , userPassword
        FROM CLIENT C
        WHERE C.Phone_number = %s;""",[phone_number])
        logger = c.fetchone()
        return logger


def add_user(phone_number, first_name, last_name, userpassword, referral_code) :
    """ adding new user to Client table(DataBase) """
    generated_referral = f"{phone_number[2:8]}#{first_name[-1]}${random.randint(0,100)}"
    final_referral = referral_code if referral_code else generated_referral
    with connection.cursor() as c :
        c.execute("""
        insert into client (Phone_number, First_name, Last_name, userPassword, referral_code) 
        values (%s, %s, %s, %s, %s);""", [phone_number, first_name, last_name, userpassword, final_referral])

        return c.fetchone()[0]

def add_to_referral_code(referrer_code, phone):
    """ Inserts a referral record into the 'refer' table. """
    with connection.cursor() as c :
        c.execute(""" 
        select id 
        from client where referral_code = %s;""",[referrer_code])
        referrer_row = c.fetchone()
        if not referrer_row : 
            raise ValueError("Invalid referral code. ")
        referare_id = referrer_row[0]
        c.execute(""" 
        select id 
        from client where phone_number = %s;""", [phone])
        user_row = c.fetchone()
        if not user_row :
            raise ValueError("User with this phone number was not found. ")
        user_id = user_row[0]

        c.execute(""" 
        insert into REFERS(Refree, Referrer) 
        values (%s, %s);""",[user_id, referare_id])


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

def recent_shops(uid):
    with connection.cursor() as c:
        c.execute(""" 
            SELECT lsc.Cart_number, lsc.Number AS locked_number, 
                   trs.Timestamp AS transaction_timestamp, trs.Tracking_code, 
                   lsc.Timestamp AS locked_timestamp
            FROM locked_shopping_cart lsc
            JOIN issued_for isu ON lsc.ID = isu.ID 
                AND lsc.Cart_number = isu.Cart_number 
                AND lsc.Number = isu.Locked_number
            JOIN transaction trs ON isu.Tracking_code = trs.Tracking_code
            WHERE lsc.ID = %s AND trs.STATUS = 'Successful'
            ORDER BY trs.Timestamp DESC
            LIMIT 5;""", [users_id])
        return cur.fetchall()
