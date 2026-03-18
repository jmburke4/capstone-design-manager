from datetime import timedelta
import datetime

import pytest
from django.core.exceptions import ValidationError
from django.db.utils import IntegrityError
from django.utils import timezone
from django.utils.text import slugify

from project.models import Assignment, Preference, Project, Semester
from user.models import Sponsor, Student


@pytest.fixture
def sample_sponsor(db):
    return Sponsor.objects.create(
        email="sponsor@example.com",
        first_name="John",
        last_name="Doe",
        organization="Tech Corp",
        phone_number="(123) 456-7890",
    )


@pytest.fixture
def sample_student(db):
    return Student.objects.create(
        cwid="12345678",
        email="student@example.com",
        first_name="Jane",
        last_name="Smith",
        class_code=Student.Class.SENIOR,
        major_code="CS",
    )


@pytest.fixture
def sample_semester(db):
    return Semester.objects.create(
        semester=Semester.Semester.FALL,
        year=2024,
        assignment_date=timezone.now() + timedelta(days=7),
    )


@pytest.fixture
def sample_project(db, sample_sponsor):
    return Project.objects.create(
        name="Test Project",
        description="A test project description",
        sponsor=sample_sponsor,
        status=Project.StatusChoices.PENDING,
        website="https://example.com",
    )


@pytest.mark.django_db
class TestProject:
    def test_project_creation(self, sample_project, sample_sponsor):
        assert sample_project.name == "Test Project"
        assert sample_project.description == "A test project description"
        assert sample_project.sponsor == sample_sponsor
        assert sample_project.status == Project.StatusChoices.PENDING
        assert sample_project.website == "https://example.com"
        assert sample_project.created_at is not None

    def test_project_str(self, sample_project):
        assert str(sample_project) == "Test Project"

    def test_project_status_choices(self, sample_sponsor):
        for status, _ in Project.StatusChoices.choices:
            project = Project.objects.create(
                name=f"Project {status}",
                sponsor=sample_sponsor,
                status=status,
            )
            assert project.status == status

    def test_project_default_status(self, sample_sponsor):
        project = Project.objects.create(
            name="Default Status Project",
            sponsor=sample_sponsor,
        )
        assert project.status == Project.StatusChoices.PENDING

    def test_project_optional_fields(self, sample_sponsor):
        project = Project.objects.create(
            name="Minimal Project",
            sponsor=sample_sponsor,
        )
        assert project.description is None
        assert project.website is None

    def test_project_required_fields(self):
        with pytest.raises(IntegrityError):
            Project.objects.create(name="No Sponsor Project")


@pytest.mark.django_db
class TestSemester:
    def test_semester_creation(self, sample_semester):
        assert sample_semester.semester == Semester.Semester.FALL
        assert sample_semester.year == 2024
        assert sample_semester.assignment_date is not None
        assert sample_semester.created_at is not None

    def test_semester_str(self, sample_semester):
        assert str(sample_semester) == "Fall 2024"

    def test_semester_choices(self):
        for value, _ in Semester.Semester.choices:
            semester = Semester.objects.create(
                semester=value,
                year=2024,
                assignment_date=timezone.now() + timedelta(days=1),
            )
            assert semester.semester == value

    def test_semester_year_too_low_validation(self):
        semester = Semester(
            semester=Semester.Semester.SPRING,
            year=1899,
            assignment_date=timezone.now() + timedelta(days=1),
        )
        with pytest.raises(ValidationError):
            semester.full_clean()

    def test_semester_year_too_high_validation(self):
        semester = Semester(
            semester=Semester.Semester.SUMMER,
            year=datetime.date.today().year + 1,
            assignment_date=timezone.now() + timedelta(days=1),
        )
        with pytest.raises(ValidationError):
            semester.full_clean()

    def test_semester_projects_empty_by_default(self, sample_semester):
        assert sample_semester.projects.count() == 0

    def test_semester_projects_add_single_project(self, sample_semester, sample_project):
        sample_semester.projects.add(sample_project)

        assert sample_semester.projects.count() == 1
        assert sample_semester.projects.first() == sample_project

    def test_semester_projects_add_and_remove_multiple_projects(self, sample_semester, sample_sponsor):
        first_project = Project.objects.create(
            name="First Semester Project",
            sponsor=sample_sponsor,
        )
        second_project = Project.objects.create(
            name="Second Semester Project",
            sponsor=sample_sponsor,
        )

        sample_semester.projects.add(first_project, second_project)
        assert set(sample_semester.projects.all()) == {first_project, second_project}

        sample_semester.projects.remove(first_project)
        assert list(sample_semester.projects.all()) == [second_project]


@pytest.mark.django_db
class TestPreference:
    def test_preference_creation(self, sample_student, sample_project):
        preference = Preference.objects.create(
            student=sample_student,
            project=sample_project,
            rank=Preference.RankChoices.ONE,
        )
        expected_id = slugify(f"{sample_student.id}-{sample_project.id}")

        assert preference.id == expected_id
        assert preference.student == sample_student
        assert preference.project == sample_project
        assert preference.rank == Preference.RankChoices.ONE
        assert preference.created_at is not None

    def test_preference_str(self, sample_student, sample_project):
        preference = Preference.objects.create(
            student=sample_student,
            project=sample_project,
            rank=Preference.RankChoices.ONE,
        )
        assert str(preference) == f"{sample_student} ({sample_project})"

    def test_preference_id_generation(self, sample_student, sample_project):
        preference = Preference(
            student=sample_student,
            project=sample_project,
            rank=Preference.RankChoices.ONE,
        )
        expected_id = slugify(f"{sample_student.id}-{sample_project.id}")

        assert preference.generate_id() == expected_id

        preference.save()
        assert preference.id == expected_id

    def test_preference_rank_choices(self, sample_student, sample_sponsor):
        for rank, _ in Preference.RankChoices.choices:
            project = Project.objects.create(
                name=f"Project Rank {rank}",
                sponsor=sample_sponsor,
            )
            preference = Preference.objects.create(
                student=sample_student,
                project=project,
                rank=rank,
            )
            assert preference.rank == rank

    def test_preference_unique_constraint(self, sample_student, sample_project):
        Preference.objects.create(
            student=sample_student,
            project=sample_project,
            rank=Preference.RankChoices.ONE,
        )
        duplicate = Preference(
            student=sample_student,
            project=sample_project,
            rank=Preference.RankChoices.TWO,
        )

        with pytest.raises(IntegrityError):
            duplicate.save()


@pytest.mark.django_db
class TestAssignment:
    def test_assignment_creation(self, sample_student, sample_semester, sample_project):
        assignment = Assignment.objects.create(
            student=sample_student,
            semester=sample_semester,
            project=sample_project,
        )
        expected_id = slugify(f"{sample_student.id}-{sample_semester.id}")

        assert assignment.id == expected_id
        assert assignment.student == sample_student
        assert assignment.semester == sample_semester
        assert assignment.project == sample_project
        assert assignment.created_at is not None

    def test_assignment_str(self, sample_student, sample_semester, sample_project):
        assignment = Assignment.objects.create(
            student=sample_student,
            semester=sample_semester,
            project=sample_project,
        )
        assert str(assignment) == f"{sample_student} ({sample_semester})"

    def test_assignment_generate_id(self, sample_student, sample_semester, sample_project):
        assignment = Assignment(
            student=sample_student,
            semester=sample_semester,
            project=sample_project,
        )
        expected_id = slugify(f"{sample_student.id}-{sample_semester.id}")

        assert assignment.generate_id() == expected_id

    def test_assignment_unique_student_semester(self, sample_student, sample_semester, sample_project, sample_sponsor):
        Assignment.objects.create(
            student=sample_student,
            semester=sample_semester,
            project=sample_project,
        )
        other_project = Project.objects.create(
            name="Another Project",
            sponsor=sample_sponsor,
        )
        duplicate = Assignment(
            student=sample_student,
            semester=sample_semester,
            project=other_project,
        )

        with pytest.raises(IntegrityError):
            duplicate.save()

    def test_assignment_required_fields(self, sample_student, sample_semester):
        with pytest.raises(IntegrityError):
            Assignment.objects.create(
                student=sample_student,
                semester=sample_semester,
            )
