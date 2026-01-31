from django.db import models

# The project app will handle project, preference, and assignment objects

class Project(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    sponsor_id = models.IntegerField()
    website = models.TextField(blank=True, null=True)
    # FIXME Update default year to be the current year
    # year_began = models.SmallIntegerField(default=2026)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name
