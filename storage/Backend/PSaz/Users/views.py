import json
from django.http import JsonResponse
from .authentication import hashing, verify_pass
from django.db import IntegrityError
from Users import DB_functions
from PSaz import authentication

def user_login(request) -> JsonResponse:
    if request.method == "POST":
        try:
            data = json.loads(request.body.decode())
            phone_number = data["phone_number"]
            password = data["password"]
        except (KeyError, json.JSONDecodeError):
            return JsonResponse({"error": "Invalid request"},
            status=400)

        try:
            user = DB_functions.find_user(phone_number)
            if not user or not verify_pass(user[1], password):
                return JsonResponse(
                    {"error": "Invalid credentials"},
                    status=401
                )
        except Exception as e:
            return JsonResponse(
                {"error": "Authentication failed"},
                status=500
            )

        try:
            token = authentication.JWT_generate(user[0])
            return JsonResponse(
                {"jwt": token, "message": "Login successful"},
                status=200
            )
        except Exception as e:
            return JsonResponse(
                {"error": "Token generation failed"},
                status=500
            )

    return JsonResponse(
        {"error": "Method not allowed"},
        status=405
    )


def new_user_signup(request) -> JsonResponse:
    if request.method == "POST":
        try:
            data = json.loads(request.body.decode())
            required_fields = [
                "phone_number", 
                "first_name", 
                "last_name", 
                "password"
            ]
            for field in required_fields:
                if field not in data:
                    raise KeyError(field)
                
            hashed_password = hashing(data["password"])
            referral_code = data.get("referral_code")

        except json.JSONDecodeError:
            return JsonResponse(
                {"error": "Invalid JSON format"}, 
                status=400
            )
        except KeyError as e:
            return JsonResponse(
                {"error": f"Missing required field: {str(e)}"},
                status=400
            )

        try:
            user = DB_functions.add_user(
                phone_number=data["phone_number"],
                first_name=data["first_name"],
                last_name=data["last_name"],
                password=hashed_password,
                referral_code=referral_code
            )

            if referral_code:
                DB_functions.add_to_referral_code(
                    referral_code, 
                    data["phone_number"]
                )

            token = authentication.JWT_generate(user.id)
            return JsonResponse(
                {"jwt": token, "message": "Registration successful"},
                status=201
            )

        except IntegrityError:
            return JsonResponse(
                {"error": "User already exists"},
                status=409
            )
        except Exception as e:
            return JsonResponse(
                {"error": "Registration failed"},
                status=500
            )

    return JsonResponse(
        {"error": "Method not allowed"},
        status=405
    )


def show_profile_info(request):
    if request.method == 'GET':
        user_id = request.user_id
        data = DB_functions.get_user_profile(user_id)
        address = DB_functions.users_address(user_id)
        if address:
            data['adresses'] = address
        VIP = DB_functions.check_vip(user_id)
        data['is_vip'] = bool(VIP[0]) if VIP else False
        refered = DB_functions.refered_numbers(user_id)
        data['counter'] = result[0] if result else 0
        return JsonResponse(data, status=200)        

    return JsonResponse({'error': 'Invalid request method'}, status=405)



def get_cart_info(request) : 
    infos, shops= {}, []
    if request.method =='GET' :
        user_id = request.user_id
        rows = DB_functions.recent_shops(user_id)
        infos['cart_status'] = DB_functions.get_cart_status(user_id)
        
        for locked_cart in rows :
            number        = locked_cart[1]
            locked_number = locked_cart[2]
            Time_stamp    = locked_cart[3]
            tracking_code = locked_cart[4]
            locked_time   = locked_cart[5]

            items  = DB_functions.purchasedItems(user_id, number, locked_number)
            prices = DB_functions.cart_price(user_id, number, locked_number)

            shops.append({'number': number, 'locked_number' : locked_number, 'Time_stamp' : Time_stamp,
                          'tracking_code' : tracking_code, 'locked_time' : locked_time })
        infos['shops'] = shops
        return JsonResponse(infos,status=200)
    return JsonResponse({'error': 'Invalid request method'}, status=405)