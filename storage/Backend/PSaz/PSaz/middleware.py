# pcsaz_back/middleware.py
import json
from django.http import JsonResponse
from Users import DB_functions as qs
from Users import DB_functions as user_qs
from PSaz.authentication import decode_jwt
from PSaz.DB_functions import validate_referral_code

class JWTAuthentication:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        public_paths = ['/user/login/', '/user/signup/', '/sazgaryab/products/']
        if request.path in public_paths:
            return self.get_response(request)

        token = request.META.get('HTTP_AUTHORIZATION')
        if not token:
            return JsonResponse({'error': 'JWT is required!'}, status=401)
        try:
            payload = JWT_decode(token)
        except ValueError as e:
            return JsonResponse({'error': str(e)}, status=401)

        # Taking users id for fututre uses
        request.user_id = payload.get('user_id')
        return self.get_response(request)

class SignupCheckData:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.path == '/user/signup/':
            try:
                data = json.loads(request.body)
                for field in ['first_name', 'last_name', 'phone', 'password']:
                    if field not in data:
                        raise KeyError(field)
                ref_code = data.get('referrer_code')
                if ref_code:
                    validate_referral_code(ref_code)
            except Exception:
                return JsonResponse({'error': 'Signup data is missing or invalid!'}, status=400)
        return self.get_response(request)

class CheckVipMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        vip_paths = ['/user/vip_detail/', '/sazgaryab/find_compatibles/']
        if request.path in vip_paths:
            user_id = getattr(request, 'user_id', None)
            if not user_id:
                return JsonResponse({'error': 'User not authenticated'}, status=401)
            is_vip = qs.check_vip(user_id)
            if not is_vip or is_vip[0] != 1:
                return JsonResponse({'error': 'Your account is not VIP and cannot access this section'}, status=401)
        return self.get_response(request)
