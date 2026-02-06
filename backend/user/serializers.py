from rest_framework import serializers
from .models import Sponsor

class SponsorSerializer(serializers.ModelSerializer):

    class Meta:
        model = Sponsor
        fields = ['id', 'first_name', 'last_name', 'organization', 'email', 'phone_number', 'created_at']
