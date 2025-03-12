import json
from django.http import JsonResponse
from PSaz.authentication import hashing, verify_pass
from django.db import IntegrityError
from Users import DB_functions
from PSaz import authentication
from django.views.decorators.csrf import csrf_exempt

# @csrf_exempt
# def user_login(request) -> JsonResponse:
#     if request.method == "POST":
#         try:
#             data         = json.loads(request.body.decode())
#             phone_number = data["phone_number"]
#             password     = data["password"]
#         except (KeyError, json.JSONDecodeError):
#             return JsonResponse({"error": "Invalid request"}, status=400)

#         try:
#             user = DB_functions.find_user(phone_number)
#             if not user or not verify_pass(user[1], password):
#                 return JsonResponse({"error": "Invalid credentials"}, status=401)

#             token = authentication.JWT_generate(user[0])
#             return JsonResponse({"jwt": token, "user_id": user[0], "message": "Login successful"}, status=200)

#         except Exception as e:
#             return JsonResponse({"error": "Authentication failed"}, status=500)

#     return JsonResponse({"error": "Method not allowed"}, status=405)

# @csrf_exempt
# def new_user_signup(request) -> JsonResponse:
#     if request.method == "POST":
#         try:
#             data = json.loads(request.body.decode())
#             required_fields = ["phone_number", "first_name", "last_name", "password"]

#             for field in required_fields:
#                 if field not in data:
#                     raise KeyError(field)

#             hashed_password = hashing(data["password"])
#             referral_code = data.get("referral_code")

#         except json.JSONDecodeError:
#             return JsonResponse({"error": "Invalid JSON format"}, status=400)
#         except KeyError as e:
#             return JsonResponse({"error": f"Missing required field: {str(e)}"}, status=400)

#         try:
#             user_id = DB_functions.add_user(
#                 phone_number=data["phone_number"],
#                 first_name=data["first_name"],
#                 last_name=data["last_name"],
#                 userpassword=hashed_password,
#                 referral_code=referral_code
#             )

#             if not user_id:
#                 return JsonResponse({"error": "User already exists"}, status=409)

#             if referral_code:
#                 DB_functions.add_to_referral_code(referral_code, data["phone_number"])

#             # Generate JWT after successful registration
#             token = authentication.JWT_generate(user_id)
#             return JsonResponse({"jwt": token, "user_id": user_id, "message": "Registration successful"}, status=201)

#         except IntegrityError:
#             return JsonResponse({"error": "User already exists"}, status=409)
#         except Exception as e:
#             return JsonResponse({"error": "Registration failed"}, status=500)

#     return JsonResponse({"error": "Method not allowed"}, status=405)


# @csrf_exempt
# def show_profile_info(request):
#     """Fetches user profile including all required information."""
#     if request.method != "GET":
#         return JsonResponse({'error': 'Invalid request method'}, status=405)

#     try:
#         # Authenticate user
#         token = request.headers.get("Authorization")
#         if not token:
#             return JsonResponse({"error": "Unauthorized"}, status=401)

#         user_id = authentication.JWT_decode(token)
#         if not user_id:
#             return JsonResponse({"error": "Invalid token"}, status=401)

#         # Fetch User Profile Data
#         data = DB_functions.get_user_profile(user_id)
#         if not data:
#             return JsonResponse({"error": "User profile not found"}, status=404)

#         # Fetch Addresses
#         addresses = DB_functions.users_address(user_id)
#         data["addresses"] = addresses

#         # Fetch VIP Status & Benefits
#         is_vip = DB_functions.is_vip(user_id)[0]
#         data["is_vip"] = bool(is_vip)

#         if is_vip:
#             vip_benefits = DB_functions.get_vip_benefits(user_id)
#             if vip_benefits:
#                 data["vip_remaining_time"] = vip_benefits["remaining_time"]
#                 data["vip_monthly_profit"] = vip_benefits["monthly_profit"]
#                 data["cashback_percentage"] = vip_benefits["cashback_percentage"]

#         # Fetch Referral Data
#         referral_count = DB_functions.refered_numbers(user_id)["counter"]
#         data["referred_count"] = referral_count

#         # Fetch Expiring Discount Codes
#         expiring_codes = DB_functions.expiring_private_codes(user_id)
#         data["expiring_discount_codes"] = expiring_codes

#         # Fetch Shopping Cart Status
#         cart_status = DB_functions.get_cart_status(user_id)
#         data["cart_status"] = cart_status

#         # Fetch Recent Purchases
#         recent_purchases = DB_functions.recent_shops(user_id)
#         data["recent_purchases"] = recent_purchases

#         return JsonResponse(data, status=200)

#     except Exception as e:
#         return JsonResponse({"error": "Failed to retrieve profile"}, status=500)

# @csrf_exempt
# def insert_address(request):
#     """Allows authenticated users to add an address."""
#     if request.method != "POST":
#         return JsonResponse({"error": "Method not allowed"}, status=405)

#     try:
#         token = request.headers.get("Authoaccsszdc rization")
#         if not token:
#             return JsonResponse({"error": "Unauthorized"}, status=401)

#         user_id = authentication.JWT_decode(token)
#         if not user_id:
#             return JsonResponse({"error": "Invalid token"}, status=401)

#         data = json.loads(request.body.decode())
#         new_province = data.get("province")
#         new_remainer = data.get("remainer")

#         if not new_province or not new_remainer:
#             return JsonResponse({"error": "Missing required fields"}, status=400)

#         success = DB_functions.insert_address(user_id, new_province, new_remainer)
#         if not success:
#             return JsonResponse({"error": "Failed to insert address"}, status=500)

#         return JsonResponse({"message": "Address added successfully"}, status=201)

#     except json.JSONDecodeError:
#         return JsonResponse({"error": "Invalid JSON format"}, status=400)
#     except Exception as e:
#         return JsonResponse({"error": "Failed to add address"}, status=500)


# def get_cart_info(request) : 
#     infos, shops= {}, []
#     if request.method =='GET' :
#         user_id = request.user_id
#         rows = DB_functions.recent_shops(user_id)
#         infos['cart_status'] = DB_functions.get_cart_status(user_id)
        
#         for locked_cart in rows :
#             number        = locked_cart[1]
#             locked_number = locked_cart[2]
#             Time_stamp    = locked_cart[3]
#             tracking_code = locked_cart[4]
#             locked_time   = locked_cart[5]

#             items  = DB_functions.purchasedItems(user_id, number, locked_number)
#             prices = DB_functions.cart_price(user_id, number, locked_number)

#             shops.append({'number': number, 'locked_number' : locked_number, 'Time_stamp' : Time_stamp,
#                           'tracking_code' : tracking_code, 'locked_time' : locked_time })
#         infos['shops'] = shops
#         return JsonResponse(infos,status=200)
#     return JsonResponse({'error': 'Invalid request method'}, status=405)


# from .DB_functions import get_user_profile



# def test_user_profile(request):
#     phone_number = request.GET.get('phone_number')
#     if not phone_number:
#         logger.error("Phone number is required.")
#         return JsonResponse({"error": "Phone number is required."}, status=400)

#     logger.info(f"Fetching profile for phone number: {phone_number}")
#     try:
#         profile = get_user_profile(phone_number)
#         logger.info(f"Profile data: {profile}")
#         return JsonResponse(profile)
#     except Exception as e:
#         logger.error(f"Error fetching profile: {e}")
#         return JsonResponse({"error": "Internal server error."}, status=500)



# # from django.http import JsonResponse
# # from .DB_functions import get_user_profile

# # def user_profile(request):
# #     """Endpoint: /users/profile/?phone_number=09180048517"""
# #     phone_number = request.GET.get('phone_number')
    
# #     if not phone_number:
# #         return JsonResponse({'error': 'Phone number required'}, status=400)

# #     try:
# #         profile = get_user_profile(phone_number)
# #         if not profile:
# #             return JsonResponse({'error': 'User not found'}, status=404)
        
# #         return JsonResponse(profile)

# #     except Exception as e:
#         return JsonResponse({'error': str(e)}, status=500)


from django.http import JsonResponse
from django.db import connection

def get_user_details(request):
    if request.method == 'GET':
        user_id = request.GET.get('user_id')
        if not user_id:
            return JsonResponse({'error': 'User ID required'}, status=400)

        with connection.cursor() as cursor:
            # Fetch personal data
            cursor.execute(
                """
                SELECT first_name, last_name, phone_number, wallet_balance, time_stamp
                FROM client
                WHERE id = %s
                """,
                (user_id,)
            )
            personal_data = cursor.fetchone()
            if not personal_data:
                return JsonResponse({'error': 'User not found'}, status=404)

            personal_data_dict = {
                'first_name': personal_data[0],
                'last_name': personal_data[1],
                'phone_number': personal_data[2],
                'wallet_balance': personal_data[3],
                'time_stamp': str(personal_data[4]).replace("T", " ")
            }

            # Fetch addresses
            cursor.execute(
                "SELECT province, remainer FROM address WHERE id = %s",
                (user_id,)
            )
            addresses = [{'province': row[0], 'remainder': row[1]} for row in cursor.fetchall()]

            # Check VIP status and expiration
            cursor.execute(
                """
                SELECT EXISTS (
                    SELECT 1 FROM vip_client
                    WHERE id = %s AND subscription_expiration_time > CURRENT_TIMESTAMP
                ) AS is_vip
                """,
                (user_id,)
            )
            is_vip = cursor.fetchone()[0]
            vip_expiration = None
            if is_vip:
                cursor.execute(
                    "SELECT subscription_expiration_time FROM vip_client WHERE id = %s",
                    (user_id,)
                )
                vip_expiration = str(cursor.fetchone()[0]).replace("T", " ")

            # Fetch referral count
            cursor.execute(
                "SELECT COUNT(*) FROM refers WHERE referrer = %s",
                (user_id,)
            )
            referral_count = cursor.fetchone()[0]

            # Fetch recent purchases
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
                (user_id,)
            )
            recent_purchases = []
            for row in cursor.fetchall():
                cart_number, locked_number, transaction_time, tracking_code, locked_time = row
                cursor.execute(
                    """
                    SELECT p.id, p.category, p.brand, p.model, a.quantity, p.current_price
                    FROM added_to a
                    JOIN products p ON a.product_id = p.id
                    WHERE a.id = %s AND a.cart_number = %s AND a.locked_number = %s
                    """,
                    (user_id, cart_number, locked_number)
                )
                products = [
                    {
                        'product_id': p[0],
                        'category': p[1],
                        'brand': p[2],
                        'model': p[3],
                        'quantity': p[4],
                        'price': p[5]
                    } for p in cursor.fetchall()
                ]
                recent_purchases.append({
                    'cart_number': cart_number,
                    'locked_number': locked_number,
                    'transaction_time': str(transaction_time).replace("T", " "),
                    'tracking_code': tracking_code,
                    'locked_time': str(locked_time).replace("T", " "),
                    'products': products
                })

            # Combine all user details
            user_details = {
                'personal_data': personal_data_dict,
                'addresses': addresses,
                'is_vip': is_vip,
                'vip_expiration': vip_expiration,
                'referral_count': referral_count,
                'recent_purchases': recent_purchases
            }

            return JsonResponse(user_details, status=200)

    return JsonResponse({'error': 'Invalid request method'}, status=405)
