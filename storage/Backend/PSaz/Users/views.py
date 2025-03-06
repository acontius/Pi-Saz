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
            return JsonResponse({"error": "Invalid request"}, status=400)

        try:
            user = DB_functions.find_user(phone_number)
            if not user or not verify_pass(user[1], password):
                return JsonResponse({"error": "Invalid credentials"}, status=401)

            token = authentication.JWT_generate(user[0])
            return JsonResponse({"jwt": token, "user_id": user[0], "message": "Login successful"}, status=200)

        except Exception as e:
            return JsonResponse({"error": "Authentication failed"}, status=500)

    return JsonResponse({"error": "Method not allowed"}, status=405)

def new_user_signup(request) -> JsonResponse:
    if request.method == "POST":
        try:
            data = json.loads(request.body.decode())
            required_fields = ["phone_number", "first_name", "last_name", "password"]

            for field in required_fields:
                if field not in data:
                    raise KeyError(field)

            hashed_password = hashing(data["password"])
            referral_code = data.get("referral_code")

        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)
        except KeyError as e:
            return JsonResponse({"error": f"Missing required field: {str(e)}"}, status=400)

        try:
            user_id = DB_functions.add_user(
                phone_number=data["phone_number"],
                first_name=data["first_name"],
                last_name=data["last_name"],
                userpassword=hashed_password,
                referral_code=referral_code
            )

            if not user_id:
                return JsonResponse({"error": "User already exists"}, status=409)

            if referral_code:
                DB_functions.add_to_referral_code(referral_code, data["phone_number"])

            token = authentication.JWT_generate(user_id)
            return JsonResponse({"jwt": token, "user_id": user_id, "message": "Registration successful"}, status=201)

        except IntegrityError:
            return JsonResponse({"error": "User already exists"}, status=409)
        except Exception as e:
            return JsonResponse({"error": "Registration failed"}, status=500)

    return JsonResponse({"error": "Method not allowed"}, status=405)


@csrf_exempt
def show_profile_info(request):
    """Shows user profile only if authenticated."""
    if request.method != "GET":
        return JsonResponse({'error': 'Invalid request method'}, status=405)

    try:
        token = request.headers.get("Authorization")
        if not token:
            return JsonResponse({"error": "Unauthorized"}, status=401)

        user_id = authentication.JWT_decode(token)
        if not user_id:
            return JsonResponse({"error": "Invalid token"}, status=401)

        # Fetch user profile
        data = DB_functions.get_user_profile(user_id)
        if not data:
            return JsonResponse({"error": "User profile not found"}, status=404)

        # Fetch addresses
        address = DB_functions.users_address(user_id)
        if address:
            data["addresses"] = address

        # VIP Status
        VIP = DB_functions.is_vip(user_id)
        data["is_vip"] = bool(VIP[0]) if VIP else False

        # Referral Count
        referred = DB_functions.refered_numbers(user_id)
        data["counter"] = referred["counter"] if referred else 0

        return JsonResponse(data, status=200)

    except Exception as e:
        return JsonResponse({"error": "Failed to retrieve profile"}, status=500)


@csrf_exempt
def insert_address(request):
    """Allows authenticated users to add an address."""
    if request.method != "POST":
        return JsonResponse({"error": "Method not allowed"}, status=405)

    try:
        token = request.headers.get("Authorization")
        if not token:
            return JsonResponse({"error": "Unauthorized"}, status=401)

        user_id = authentication.JWT_decode(token)
        if not user_id:
            return JsonResponse({"error": "Invalid token"}, status=401)

        data = json.loads(request.body.decode())
        new_province = data.get("province")
        new_remainer = data.get("remainer")

        if not new_province or not new_remainer:
            return JsonResponse({"error": "Missing required fields"}, status=400)

        success = DB_functions.insert_address(user_id, new_province, new_remainer)
        if not success:
            return JsonResponse({"error": "Failed to insert address"}, status=500)

        return JsonResponse({"message": "Address added successfully"}, status=201)

    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON format"}, status=400)
    except Exception as e:
        return JsonResponse({"error": "Failed to add address"}, status=500)


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