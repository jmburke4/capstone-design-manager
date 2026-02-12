from django.db import models
from django.core.validators import RegexValidator

# The user app will handle the user related tables:

# NOTE Does this have to be defined inside a model class?
phone_regex = RegexValidator(
    regex=r"^\+?1?\d{10,11}$",
    message="Phone number must be entered in the format: '9999999999'. Up to 11 digits allowed.",
)


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
        validators=[phone_regex], max_length=17, blank=True, null=True
    )

    def __str__(self):
        return f"{self.first_name} {self.last_name}"


class Student(models.Model):
    # [Default] Tracks when the Student record was created
    created_at = models.DateTimeField(auto_now_add=True)

    # [Required] The email address for the student
    email = models.EmailField()

    # [Required] The Student last name
    first_name = models.CharField(max_length=30)

    # [Required] The Student last name
    last_name = models.CharField(max_length=30)

    # Organi     woudl be redundant? Since everyone is through UA....
    # I think we will forgo phone numbers for students for now...

    def __str__(self):
        return f"{self.first_name} {self.last_name}"
