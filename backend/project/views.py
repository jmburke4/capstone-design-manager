from rest_framework import viewsets, status
from rest_framework.views import APIView
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import Project, Assignment, Preference
from .serializers import ProjectSerializer, AssignmentSerializer, PreferenceSerializer
import logging

logger = logging.getLogger(__name__)


class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer


class PreferenceAPIView(APIView):

    def get(self, request, pk=None, format=None):
        if pk:
            preference = get_object_or_404(Preference, pk=pk)
            serializer = PreferenceSerializer(preference)
            return Response(serializer.data)
        else:
            preferences = Preference.objects.all()
            serializer = PreferenceSerializer(preferences, many=True)
            return Response(serializer.data)

    def post(self, request, *args, **kwargs):
        serializer = PreferenceSerializer(data=request.data)

        try:
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            else:
                logger.debug(serializer.errors)
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as ex:
            logger.warning(ex)
            return Response({'exception': str(ex)}, status=status.HTTP_400_BAD_REQUEST)

    def patch(self, request, pk=None, *args, **kwargs):
        if not pk:
            # TODO Add regex to validate the presence of a enough data to construct the pk
            #      Really this should be put requests only without the PK and patch only with the PK url

            if 'student' in request.data and 'project' in request.data['project']:
                pk = f"{request.data['student']}-{request.data['project']}"
                logger.debug(f'Constructed PK: {pk}')
            else:
                return Response({'error': f'Missing student or project info: {request.data}'}, status=status.HTTP_400_BAD_REQUEST)

        preference = get_object_or_404(Preference, pk=pk)
        serializer = PreferenceSerializer(preference, data=request.data, partial=True)

        if serializer.is_valid():

            # TODO Check if any fields actually changed and return 400 if not

            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk=None, *args, **kwargs):
        if not pk:
            return Response({'error': f'Missing id of preference to delete!'}, status=status.HTTP_400_BAD_REQUEST)

        preference = get_object_or_404(Preference, pk=pk)
        preference.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class AssignmentViewSet(viewsets.ModelViewSet):
    queryset = Assignment.objects.all()
    serializer_class = AssignmentSerializer
