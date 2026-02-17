from django.db import models
from django.core.validators import RegexValidator

# The user app will handle the user related tables:


class Sponsor(models.Model):
    # [Default] Tracks when the Sponsor record was created
    created_at = models.DateTimeField(auto_now_add=True)

    # [Required] The email address for the sponsor
    email = models.EmailField()

    # [Required] The sponsors last name
    first_name = models.CharField(max_length=30)

    # [Required] The sponsors last name
    last_name = models.CharField(max_length=30)

    # [Optional] A company, school, or other organization the sponsor may be attached to
    # TODO Add an Organization model, and make this field an FK to an Organization record
    organization = models.TextField(max_length=50, blank=True, null=True)

    # [Optional] A phone number for the sponsor
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


class Student(models.Model):
    # [Default] Tracks when the Student record was created
    created_at = models.DateTimeField(auto_now_add=True)

    # [Optional] Student class code - not sure what the values are
    class_code = models.CharField(max_length=9, blank=True, null=True)

    # [Optional] Major code (CYS/CS?)
    major_code = models.CharField(max_length=3, blank=True, null=True)

    # [Required] Student's CWID
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

    # [Required] The email address for the student
    email = models.EmailField()

    # [Required] The Student first name
    first_name = models.CharField(max_length=30)

    # [Optional] The Student middle name
    middle_name = models.CharField(max_length=30, blank=True, null=True)

    # [Required] The Student last name
    last_name = models.CharField(max_length=30)

    # [Optional] A students preferred name
    preferred_name = models.CharField(max_length=30, blank=True, null=True)

    # Organization would be redundant? Since everyone is through UA....
    # I think we will forgo phone numbers for students for now...

    def __str__(self):
        return f"{self.first_name} {self.last_name}"
