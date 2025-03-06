from django.db import connection


def validate_referral_code(referrer_code : str) :
    with connection.cursor() as c : 
        c.execute("SELECT 1 FROM client WHERE referral_code = %s;", (referrer_code,)) 
        if not c.fetchone():
            raise ValueError('The referal code does not exist !')