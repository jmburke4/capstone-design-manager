from rest_framework import serializers
from .models import Sponsor
from .models import Student


class SponsorSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(read_only=True)
    
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
    email = serializers.EmailField(read_only=True)
    
    class Meta:
        model = Student
        fields = [
            "id",
            "first_name",
            "last_name",
            "middle_name",
            "preferred_name",
            "email",
            "cwid",
            "class_code",
            "major_code",
            "created_at",
        ]
