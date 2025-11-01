from django.urls import path
from .api import api


urlpatterns: list = [
    path("", api.urls),  # This will include all Ninja API endpoints
]
