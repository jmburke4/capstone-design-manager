from rest_framework import viewsets
from .models import Sponsor
from .serializers import SponsorSerializer
from .models import Student
from .serializers import StudentSerializer


class SponsorViewSet(viewsets.ModelViewSet):
    queryset = Sponsor.objects.all()
    serializer_class = SponsorSerializer


class StudentViewSet(viewsets.ModelViewSet):
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
