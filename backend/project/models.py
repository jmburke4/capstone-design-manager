import datetime
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils.text import slugify
from django.utils.translation import gettext_lazy as _
from user.models import Sponsor, Student

# Models are orded by chronological appearance
# Fields are ordered by importance descending


class Project(models.Model):
    """Model representing a senior design project that students can be assigned to"""

    name = models.CharField(max_length=100)
    """[Required] Project name"""

    description = models.TextField(blank=True, null=True)
    """[Optional] A description of the project"""

    sponsor = models.ForeignKey(
        Sponsor,
        on_delete=models.PROTECT
    )
    """[Required] FK to a Sponsor (on_delete=PROTECT)"""

    sponsor_availability = models.TextField(blank=True, null=True)
    """[Optional] A text field for the sponsor of the project to describe when they are available to meet with the design team"""

    # TODO Convert to a read only field that is based on whether it is assigned during a semester or not
    class StatusChoices(models.TextChoices):
        IN_PROGRESS = 'IP', _('In Progress')
        CANCELLED = 'CNCL', _('Cancelled')
        COMPLETE = 'CMPL', _('Complete')
        PENDING = 'PNDG', _('Pending')

    status = models.CharField(
        max_length=4,
        choices=StatusChoices.choices,
        default=StatusChoices.PENDING
    )
    """[Required] The current status of the project"""

    # TODO Adapt this field to be allowed to support multiple URLs
    #      Remove this field and make it an attachment type
    website = models.URLField(blank=True, null=True)
    """[Optional] A URL field for the project's website"""

    created_at = models.DateTimeField(auto_now_add=True)
    """[Default] Tracks when the record was created"""

    updated_at = models.DateTimeField(auto_now=True)
    """[Default] Tracks when the record was last updated"""

    def __str__(self):
        return self.name


class Semester(models.Model):
    """Model representing a particular semester over the course of senior design"""

    class Semester(models.TextChoices):
        FALL = 'Fall'
        SPRING = 'Spring'
        SUMMER = 'Summer'

    semester = models.CharField(
        max_length=10,
        choices=Semester.choices,
    )
    """[Required] Fall, Spring, or Summer"""

    year = models.PositiveIntegerField(
        validators=[MinValueValidator(1900), MaxValueValidator(datetime.date.today().year)],
        help_text='Enter a four-digit year between 1900 and the current year'
    )
    """[Required] The year of the semester"""

    assignment_date = models.DateTimeField()
    """[Required] Students must have their preferences submitted by this time"""

    projects = models.ManyToManyField(Project)
    """[Optional] The projects that will be assigned during the semester"""

    created_at = models.DateTimeField(auto_now_add=True)
    """[Default] Tracks when the record was created"""

    updated_at = models.DateTimeField(auto_now=True)
    """[Default] Tracks when the record was last updated"""

    def __str__(self):
        return f'{self.semester} {self.year}'

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['semester', 'year'], name='unique_semester_year')
        ]


class Preference(models.Model):
    """Model representing a student's ranked preference for a project"""

    id = models.SlugField(max_length=64, primary_key=True, editable=False)
    """[Calculated] A slug field that serves as the PK for the model, this is generated from the student and project FKs"""

    student = models.ForeignKey(
        Student,
        on_delete=models.CASCADE
    )
    """[Required] Foreign key to a student"""

    project = models.ForeignKey(
        Project,
        on_delete=models.CASCADE
    )
    """[Required] Foreign key to a project"""

    class RankChoices(models.IntegerChoices):
        ONE = 1, '1'
        TWO = 2, '2'
        THREE = 3, '3'

    rank = models.PositiveSmallIntegerField(
        choices=RankChoices.choices
    )
    """[Required] Number rank of student's preference toward project, 1 being the first choice"""

    created_at = models.DateTimeField(auto_now_add=True)
    """[Default] Tracks when the record was created"""

    updated_at = models.DateTimeField(auto_now=True)
    """[Default] Tracks when the record was last updated"""

    def generate_id(self, student_id=None, project_id=None):
        """Generates a slug from the student and project FKs, this is used as the PK for the model"""
        if (not student_id or not project_id) and self:
            student_id = self.student.id
            project_id = self.project.id
        return slugify(f'{student_id}-{project_id}')

    # Override the model save method to compute the slug from the fields on saving to DB
    def save(self, *args, **kwargs):
        if not self.id:
            self.id = self.generate_id()
        super().save(*args, **kwargs)

    def __str__(self):
        return f'{self.student} ({self.project})'


class Assignment(models.Model):
    """Records a student that has been assigned to a project during a semester"""

    id = models.SlugField(max_length=64, primary_key=True, editable=False)
    """[Calculated] A slug field that serves as the PK for the model, this is generated from the student and semester FKs"""

    student = models.ForeignKey(
        Student,
        on_delete=models.PROTECT
    )
    """[Required] Foreign key to a student"""

    semester = models.ForeignKey(
        Semester,
        on_delete=models.CASCADE
    )
    """[Required] Foreign key to a semester"""

    project = models.ForeignKey(
        Project,
        on_delete=models.CASCADE
    )
    """[Required] Foreign key to a project"""

    created_at = models.DateTimeField(auto_now_add=True)
    """[Default] Tracks when the record was created"""

    updated_at = models.DateTimeField(auto_now=True)
    """[Default] Tracks when the record was last updated"""

    def generate_id(self, student_id=None, semester_id=None):
        """Generates a slug from the student and semester FKs, this is used as the PK for the model"""
        if (not student_id or not semester_id) and self:
            student_id = self.student.id
            semester_id = self.semester.id
        return slugify(f'{student_id}-{semester_id}')

    # Override the model save method to compute the slug from the fields on saving to DB
    def save(self, *args, **kwargs):
        if not self.id:
            self.id = self.generate_id()
        super().save(*args, **kwargs)

    def __str__(self):
        return f'{self.student} ({self.semester})'
