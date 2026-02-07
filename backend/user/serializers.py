from rest_framework import serializers
from .models import Sponsor
from .models import Student


class SponsorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Sponsor
        fields = [
            "id",
            "first_name",
            "last_name",
            "organization",
            "email",
            "phone_number",
            "created_at",
        ]


class StudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Student
        fields = [
            "id",
            "first_name",
            "last_name",
            "email",
            "created_at",
        ]
