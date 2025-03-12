# from django.urls import path
# from . import views

# urlpatterns = [
#     path("login/", views.user_login, name="login"),
#     path("register/", views.new_user_signup, name="register"),
#     path("profile/", views.show_profile_info, name="users profile"),
#     path("addresing/", views.insert_address, name="user's new adress"),
#     path('test-profile/', views.test_user_profile, name='test_profile'),
#     # path("vip_profile/", views.get_vip_detail, name="vip user profile"),
#     path("show_cart/", views.get_cart_info, name="cart's informations"),
# ]

# from django.urls import path
# from .views import user_profile

# urlpatterns = [
#     path('profile/', user_profile, name='user-profile'),
# ]



from django.urls import path
from Users import views

urlpatterns = [
    # path("login/", views.login, name="login"),
    path('personal_data/', views.get_user_details, name='get_personal'),
    # path('vip_detail/', views.get_vip_detail, name='vip_detail'),
    # path('discount_detail/', views.get_discount_detail, name='discount_detail'),
    # path('carts_detail/', views.get_carts_detail, name='carts_status'),
    # path('signup/', views.signup, name='signup'),
    # path('add_addresses/', views.add_address, name="add_address")
]