from rest_framework import viewsets
from .models import Sponsor
from .serializers import SponsorSerializer

class SponsorViewSet(viewsets.ModelViewSet):
    queryset = Sponsor.objects.all()
    serializer_class = SponsorSerializer
