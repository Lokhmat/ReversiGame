from django.shortcuts import render
from django.http import HttpResponse, JsonResponse, HttpResponseBadRequest
from .models import BestScore
import json as simplejson

# Create your views here.

def hello(request):
    return HttpResponse("Hello world")


def get_best_score(request):
    best = BestScore.objects.filter(username=request.GET.get("username", "")).order_by("userScore")
    if len(best) == 0:
        return JsonResponse({"User": None, "Iphone": None})
    else:
        return JsonResponse({"User": best.last().userScore, "Iphone": best.last().phoneScore})


def post_best_score(request):
    if "phone_score" not in request.GET or "user_score" not in request.GET or "username" not in request.GET:
        return HttpResponseBadRequest("Invalid parameters")
    best = BestScore(username=request.GET.get("username", ""), userScore=request.GET["user_score"], phoneScore=request.GET["phone_score"])
    best.save()
    return HttpResponse("Ok")
