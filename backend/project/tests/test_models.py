import pytest
from django.db.utils import IntegrityError
from django.utils.text import slugify
from project.models import Project, Preference, Assignment
from user.models import Sponsor, Student


@pytest.fixture
def sample_sponsor(db):
    """Fixture for creating a sample sponsor"""
    return Sponsor.objects.create(
        email="sponsor@example.com",
        first_name="John",
        last_name="Doe",
        organization="Tech Corp",
        phone_number="(123) 456-7890"
    )


@pytest.fixture
def sample_student(db):
    """Fixture for creating a sample student"""
    return Student.objects.create(
        cwid="12345678",
        email="student@example.com",
        first_name="Jane",
        last_name="Smith",
        class_code="SENIOR",
        major_code="CS"
    )


@pytest.mark.django_db
class TestProject:
    def test_project_creation(self, sample_sponsor):
        project = Project.objects.create(
            name="Test Project",
            description="A test project description",
            sponsor=sample_sponsor,
            status=Project.StatusChoices.PENDING,
            website="https://example.com"
        )
        assert project.name == "Test Project"
        assert project.description == "A test project description"
        assert project.sponsor == sample_sponsor
        assert project.status == Project.StatusChoices.PENDING
        assert project.website == "https://example.com"
        assert project.created_at is not None

    def test_project_str(self, sample_sponsor):
        project = Project.objects.create(
            name="Test Project",
            sponsor=sample_sponsor
        )
        assert str(project) == "Test Project"

    def test_project_status_choices(self, sample_sponsor):
        # Test all status choices
        for status, _ in Project.StatusChoices.choices:
            project = Project.objects.create(
                name=f"Project {status}",
                sponsor=sample_sponsor,
                status=status
            )
            assert project.status == status

    def test_project_default_status(self, sample_sponsor):
        project = Project.objects.create(
            name="Default Status Project",
            sponsor=sample_sponsor
        )
        assert project.status == Project.StatusChoices.PENDING

    def test_project_optional_fields(self, sample_sponsor):
        # Test with minimal required fields
        project = Project.objects.create(
            name="Minimal Project",
            sponsor=sample_sponsor
        )
        assert project.description is None
        assert project.website is None

    def test_project_required_fields(self, db):
        # Test that sponsor is required
        with pytest.raises(Exception):  # Should raise IntegrityError or similar
            Project.objects.create(name="No Sponsor Project")


@pytest.mark.django_db
class TestPreference:
    def test_preference_creation(self, sample_student, sample_sponsor):
        project = Project.objects.create(
            name="Test Project",
            sponsor=sample_sponsor
        )
        preference = Preference.objects.create(
            student=sample_student,
            project=project,
            rank=Preference.RankChoices.ONE
        )
        expected_id = slugify(f'{sample_student.id}-{project.id}')
        assert preference.id == expected_id
        assert preference.student == sample_student
        assert preference.project == project
        assert preference.rank == Preference.RankChoices.ONE
        assert preference.created_at is not None

    def test_preference_str(self, sample_student, sample_sponsor):
        project = Project.objects.create(
            name="Test Project",
            sponsor=sample_sponsor
        )
        preference = Preference.objects.create(
            student=sample_student,
            project=project,
            rank=Preference.RankChoices.ONE
        )
        assert str(preference) == f"{sample_student} ({project})"

    def test_preference_id_generation(self, sample_student, sample_sponsor):
        project = Project.objects.create(
            name="Test Project",
            sponsor=sample_sponsor
        )
        preference = Preference(
            student=sample_student,
            project=project,
            rank=Preference.RankChoices.ONE
        )
        # Test generate_id method
        expected_id = slugify(f'{sample_student.id}-{project.id}')
        assert preference.generate_id() == expected_id

        # Test that id is set on save
        preference.save()
        assert preference.id == expected_id

    def test_preference_rank_choices(self, sample_student, sample_sponsor):
        # Test all rank choices
        for rank, _ in Preference.RankChoices.choices:
            project = Project.objects.create(
                name="Test Project",
                sponsor=sample_sponsor
            )
            preference = Preference.objects.create(
                student=sample_student,
                project=project,
                rank=rank
            )
            assert preference.rank == rank

    def test_preference_unique_constraint(self, sample_student, sample_sponsor):
        project = Project.objects.create(
            name="Test Project",
            sponsor=sample_sponsor
        )
        # Create first preference
        Preference.objects.create(
            student=sample_student,
            project=project,
            rank=Preference.RankChoices.ONE
        )
        # Try to create duplicate - should work since id is primary key and auto-generated
        # But let's test that the id is unique
        preference2 = Preference(
            student=sample_student,
            project=project,
            rank=Preference.RankChoices.TWO
        )

        # Only one record for each student/project combo can exist
        with pytest.raises(IntegrityError):
            preference2.save()


@pytest.mark.django_db
class TestAssignment:
    def test_assignment_creation(self, sample_sponsor):
        project = Project.objects.create(
            name="Test Project",
            sponsor=sample_sponsor
        )
        assignment = Assignment.objects.create(
            project=project,
            person_id=1,
            person_type=Assignment.PersonType.STUDENT,
            semester=Assignment.Semester.FALL,
            year=2024
        )
        assert assignment.project == project
        assert assignment.person_id == 1
        assert assignment.person_type == Assignment.PersonType.STUDENT
        assert assignment.semester == Assignment.Semester.FALL
        assert assignment.year == 2024
        assert assignment.created_at is not None

    def test_assignment_str(self, sample_sponsor):
        project = Project.objects.create(
            name="Test Project",
            sponsor=sample_sponsor
        )
        assignment = Assignment.objects.create(
            project=project,
            person_id=123,
            person_type=Assignment.PersonType.SPONSOR,
            semester=Assignment.Semester.SPRING,
            year=2025
        )
        expected_str = f"{Assignment.PersonType.SPONSOR} 123 → {project} ({Assignment.Semester.SPRING} 2025)"
        assert str(assignment) == expected_str

    def test_assignment_person_type_choices(self, sample_sponsor):
        project = Project.objects.create(
            name="Test Project",
            sponsor=sample_sponsor
        )
        # Test all person types
        for person_type, _ in Assignment.PersonType.choices:
            assignment = Assignment.objects.create(
                project=project,
                person_id=1,
                person_type=person_type,
                semester=Assignment.Semester.FALL,
                year=2024
            )
            assert assignment.person_type == person_type

    def test_assignment_semester_choices(self, sample_sponsor):
        project = Project.objects.create(
            name="Test Project",
            sponsor=sample_sponsor
        )
        # Test all semesters
        for semester, _ in Assignment.Semester.choices:
            assignment = Assignment.objects.create(
                project=project,
                person_id=1,
                person_type=Assignment.PersonType.STUDENT,
                semester=semester,
                year=2024
            )
            assert assignment.semester == semester

    def test_assignment_year_validation(self, sample_sponsor):
        project = Project.objects.create(
            name="Test Project",
            sponsor=sample_sponsor
        )
        # Test positive integer year
        assignment = Assignment.objects.create(
            project=project,
            person_id=1,
            person_type=Assignment.PersonType.STUDENT,
            semester=Assignment.Semester.FALL,
            year=2024
        )
        assert assignment.year == 2024

    def test_assignment_required_fields(self, sample_sponsor):
        project = Project.objects.create(
            name="Test Project",
            sponsor=sample_sponsor
        )
        # Test that all required fields are enforced
        with pytest.raises(Exception):
            Assignment.objects.create(
                project=project,
                person_id=1,
                person_type=Assignment.PersonType.STUDENT,
                semester=Assignment.Semester.FALL
                # Missing year
            )

    def test_sponsor_created_at_auto_set(self):
        sponsor = Sponsor.objects.create(
            email="sponsor@example.com",
            first_name="John",
            last_name="Doe"
        )
        assert sponsor.created_at is not None
