from django.db import models
from django.core.validators import RegexValidator

# The user module will handle the user-related objects
# Fields are ordered by importance descending


class Sponsor(models.Model):
    """Model representing a project sponsor"""

    first_name = models.CharField(max_length=30)
    """[Required] The sponsors first name"""

    last_name = models.CharField(max_length=30)
    """[Required] The sponsors last name"""

    email = models.EmailField()
    """[Required] The email address for the sponsor"""

    # TODO Add an Organization model, and make this field an FK to an Organization record
    organization = models.TextField(max_length=50, blank=True, null=True)
    """[Optional] A company, school, or other organization the sponsor may be attached to"""

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
    """[Optional] A phone number for the sponsor"""

    created_at = models.DateTimeField(auto_now_add=True)
    """[Default] Tracks when the record was created"""

    updated_at = models.DateTimeField(auto_now=True)
    """[Default] Tracks when the record was last updated"""

    def name(self):
        """Returns first and last name"""
        return f"{self.first_name} {self.last_name}"

    def __str__(self):
        return f"{self.first_name} {self.last_name}"


class Student(models.Model):
    """Model representing a student to be assigned to a project"""

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
    """[Required] The student's CWID"""

    first_name = models.CharField(max_length=30)
    """[Required] The student's first name"""

    middle_name = models.CharField(max_length=30, blank=True, null=True)
    """[Optional] The student's middle name"""

    last_name = models.CharField(max_length=30)
    """[Required] The student's last name"""

    preferred_name = models.CharField(max_length=30, blank=True, null=True)
    """[Optional] A students preferred name"""

    email = models.EmailField()
    """[Required] The student's email address"""

    # TODO Convert to enum for Freshman, Sophomore, Faculty, Staff etc.
    class_code = models.CharField(max_length=9, blank=True, null=True)
    """[Optional] The student's class code, such as Freshman, Sophomore..."""

    major_code = models.CharField(max_length=3, blank=True, null=True)
    """[Optional] The student's major code, such as CS for Computer Science, CYS for Cybersecurity"""

    created_at = models.DateTimeField(auto_now_add=True)
    """[Default] Tracks when the record was created"""

    updated_at = models.DateTimeField(auto_now=True)
    """[Default] Tracks when the record was last updated"""

    def name(self):
        """Returns first and last name"""
        return f"{self.first_name} {self.last_name}"

    def __str__(self):
        return f"{self.first_name} {self.last_name}"
