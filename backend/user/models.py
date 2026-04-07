from django.db import models
from django.core.validators import RegexValidator


class Sponsor(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)

    email = models.EmailField()

    first_name = models.CharField(max_length=30)

    last_name = models.CharField(max_length=30)

    organization = models.TextField(max_length=50, blank=True, null=True)

    phone_number = models.CharField(
        max_length=18,
        blank=True,
        null=True,
        validators=[
            RegexValidator(
                regex=r'^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$',
                message='Must be a valid phone number.'
            )
        ]
    )

    def __str__(self):
        return f"{self.first_name} {self.last_name}"

    @property
    def name(self):
        return f"{self.first_name} {self.last_name}"


class Student(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)

    class_code = models.CharField(max_length=9, blank=True, null=True)

    major_code = models.CharField(max_length=3, blank=True, null=True)

    cwid = models.CharField(
        max_length=8,
        unique=True,
        db_index=True,
        validators=[
            RegexValidator(
                regex=r'^\d{8}$',
                message='CWID must be exactly 8 digits.'
            )
        ]
    )

    email = models.EmailField()

    first_name = models.CharField(max_length=30)

    middle_name = models.CharField(max_length=30, blank=True, null=True)

    last_name = models.CharField(max_length=30)

    preferred_name = models.CharField(max_length=30, blank=True, null=True)

    def __str__(self):
        return f"{self.first_name} {self.last_name}"

    @property
    def name(self):
        return f"{self.first_name} {self.last_name}"