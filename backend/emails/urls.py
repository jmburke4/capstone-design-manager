from django.urls import path
from emails import views

urlpatterns = [
    path('send', views.send_email, name='send_email'),
    path('sponsor-outreach', views.send_sponsor_outreach, name='send_sponsor_outreach'),
    path('project-presentation', views.send_project_presentation, name='send_project_presentation'),
]
