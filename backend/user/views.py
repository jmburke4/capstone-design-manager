from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import Sponsor
from .serializers import SponsorSerializer
from .models import Student
from .serializers import StudentSerializer
from .authentication import Auth0Authentication


class SponsorViewSet(viewsets.ModelViewSet):
    queryset = Sponsor.objects.all()
    serializer_class = SponsorSerializer


class StudentViewSet(viewsets.ModelViewSet):
    queryset = Student.objects.all()
    serializer_class = StudentSerializer


@api_view(['GET', 'POST', 'PUT'])
@authentication_classes([Auth0Authentication])
@permission_classes([IsAuthenticated])
def profile_view(request):
    """
    Handle profile CRUD operations.
    - GET: Return profile if exists (sponsor or student)
    - POST: Create new profile
    - PUT: Update existing profile
    """
    user = request.user
    email = user.email
    
    if request.method == 'GET':
        sponsor = Sponsor.objects.filter(email=email).first()
        if sponsor:
            return Response({
                'type': 'sponsor',
                'data': SponsorSerializer(sponsor).data
            })
        
        student = Student.objects.filter(email=email).first()
        if student:
            return Response({
                'type': 'student',
                'data': StudentSerializer(student).data
            })
        
        return Response({
            'type': None,
            'data': None
        })
    
    if request.method == 'POST':
        role = user.get_role()
        
        if role == 'sponsor':
            if Sponsor.objects.filter(email=email).exists():
                return Response(
                    {'error': 'Profile already exists'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            serializer = SponsorSerializer(data=request.data)
            if serializer.is_valid():
                serializer.save(email=email)
                return Response({
                    'type': 'sponsor',
                    'data': serializer.data
                }, status=status.HTTP_201_CREATED)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        elif role == 'student':
            if Student.objects.filter(email=email).exists():
                return Response(
                    {'error': 'Profile already exists'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            serializer = StudentSerializer(data=request.data)
            if serializer.is_valid():
                serializer.save(email=email)
                return Response({
                    'type': 'student',
                    'data': serializer.data
                }, status=status.HTTP_201_CREATED)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        return Response(
            {'error': 'No role assigned'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    if request.method == 'PUT':
        role = user.get_role()
        
        if role == 'sponsor':
            sponsor = Sponsor.objects.filter(email=email).first()
            if not sponsor:
                return Response(
                    {'error': 'Profile does not exist'},
                    status=status.HTTP_404_NOT_FOUND
                )
            serializer = SponsorSerializer(sponsor, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response({
                    'type': 'sponsor',
                    'data': serializer.data
                })
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        elif role == 'student':
            student = Student.objects.filter(email=email).first()
            if not student:
                return Response(
                    {'error': 'Profile does not exist'},
                    status=status.HTTP_404_NOT_FOUND
                )
            serializer = StudentSerializer(student, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response({
                    'type': 'student',
                    'data': serializer.data
                })
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        return Response(
            {'error': 'No role assigned'},
            status=status.HTTP_400_BAD_REQUEST
        )
