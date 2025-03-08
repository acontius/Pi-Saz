import jwt
from argon2 import PasswordHasher
from PSaz.settings import JWT_SECRET_KEY
from argon2.exceptions import VerifyMismatchError
from datetime import datetime, timedelta, timezone

pHasher = PasswordHasher()

def hashing(password : str) -> str :
    """ hashes the password with argone2 """
    return pHasher.hash(password)


def verify_pass(hashed_pass : str, password : str) -> bool :
    """ compare password with its hash and if they were compatibel, it returns True """
    try :
        return pHasher.verify(hashed_pass, password)
    except VerifyMismatchError :
        return False

def JWT_generate(user_id : int) -> str :
    payload = {
        'user_id' : user_id,
        'exp'     : datetime.now(timezone.utc) + timedelta(hours=12)
    }
    return jwt.encode(payload, JWT_SECRET_KEY, algorithm = 'HS256')

def JWT_decode(token : str) -> dict :
    try :
        return jwt.decode(token, JWT_SECRET_KEY, algorithm = 'HS256')
    except jwt.ExpiredSignatureError : 
        raise ValueError('Token has expired !')
    except jwt.InvalidTokenError:
        raise ValueError('Invalid token !')


# user_id = 1
# token = JWT_generate(user_id)
# print(token)