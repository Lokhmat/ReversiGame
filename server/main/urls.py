from django.urls import path

from . import views

urlpatterns = [
    path('', views.hello, name='hello'),
    path('get_best_score', views.get_best_score, name='get_best'),
    path('post_best_score', views.post_best_score, name='post_best'),
]