from django.db import models
from user.models import Sponsor
from user.models import Student

# The project module will handle project, preference, and assignment objects

class Project(models.Model):

    # [Default] Tracks when the Project record was created
    created_at = models.DateTimeField(auto_now_add=True)

    # [Optional] Description of project
    description = models.TextField(blank=True, null=True)

    # [Required] Project name
    name = models.CharField(max_length=100)

    # [Required] FK to a Sponsor, this field is required, which means a valid Sponsor must first exist
    sponsor = models.ForeignKey(
        Sponsor,
        on_delete=models.PROTECT
    )

    # Available choices for the status field
    class StatusChoices(models.TextChoices):
        IN_PROGRESS = 'IP'
        CANCELLED = 'CNCL'
        COMPLETE = 'CMPL'
        PENDING = 'PNDG'

    # [Required] The current status of the project
    status = models.CharField(
        max_length=4,
        choices=StatusChoices.choices,
        default=StatusChoices.PENDING
    )

    # [Optional] A website related to the project
    # TODO Adapt this field to be allowed to support multiple URLs
    website = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.name

class Preference(models.Model):

    # [Default] Tracks when the Preference record was created
    created_at = models.DateTimeField(auto_now_add=True)

    # [Required] FK to a Student, this field is required, which means a valid Student must first exist
    student = models.ForeignKey(
        Student,
        on_delete=models.PROTECT
    )

    # [Required] FK to a Project, this field is required, which means a valid Project must first exist
    project = models.ForeignKey(
        Project,
        on_delete=models.PROTECT
    )

    # Available choices for the rank field (lower number = higher rank)
    class RankChoices(models.IntegerChoices):
        ONE = 1, '1'
        TWO = 2, '2'
        THREE = 3, '3'
        
    # [Required] Number rank of student's preference toward project
    rank = models.PositiveSmallIntegerField(
        choices=RankChoices.choices
    )

    def __str__(self):
        return f"{self.student} {self.project}"
      
class Assignment(models.Model):
    class PersonType(models.TextChoices):
        SPONSOR = "sponsor", "Sponsor"
        STUDENT = "student", "Student"

    class Semester(models.TextChoices):
        FALL = "fall", "Fall"
        SPRING = "spring", "Spring"
        SUMMER = "summer", "Summer"

    project = models.ForeignKey(
        "project.Project",
        related_name="assignments",
        on_delete=models.CASCADE,
    )

    person_id = models.PositiveIntegerField()

    person_type = models.CharField(
        max_length=10,
        choices=PersonType.choices,
    )

    semester = models.CharField(
        max_length=10,
        choices=Semester.choices,
    )

    year = models.PositiveIntegerField()

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.person_type} {self.person_id} → {self.project} ({self.semester} {self.year})"
