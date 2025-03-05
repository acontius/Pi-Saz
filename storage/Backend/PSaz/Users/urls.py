from django.urls import path
from . import views

urlpatterns = [
    path("login/", views.login, name="login"),
    path("register/", views.signup, name="register"),
    path("profile/", views.get_personal, name="users profile"),
    path("addresing/", views.add_address, name="user's new adress"),
    path("vip_profile/", views.get_vip_detail, name="vip user profile"),
    path("show_cart/", views.get_carts_detail, name="cart's informations"),
]