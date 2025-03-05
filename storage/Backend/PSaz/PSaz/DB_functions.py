from django.db import connection


def validate_referral_code(referrer_code : str) :
    with connection.cursor() as c : 
        c.execute("select 1 from client where referral_code = %s",(referral_code))
        if not c.fetchone():
            raise ValueError('The referal code does not exist !')