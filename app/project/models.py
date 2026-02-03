from django.db import models
from user.models import Sponsor

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
    website = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.name
