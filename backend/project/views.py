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
    filterset_fields = ['sponsor']  # allows ?sponsor=<id>

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
        if isinstance(request.data, dict):
            serializer = PreferenceSerializer(data=request.data)
            logger.debug('Using PreferenceSerializer')
        elif isinstance(request.data, list):
            serializer = PreferenceSerializer(data=request.data, many=True)
            logger.debug('Using PreferenceListSerializer')
        else:
            return Response({'message': f'Request Data was of unexpected type: {type(request.data)}'}, status=status.HTTP_400_BAD_REQUEST)

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
        if isinstance(request.data, dict):
            if not pk and 'id' not in request.data:
                # TODO Add regex to validate the presence of a enough data to construct the pk
                #      Really this should be put requests only without the PK and patch only with the PK url
                if 'student' in request.data and 'project' in request.data:
                    pk = f"{request.data['student']}-{request.data['project']}"
                    logger.debug(f'Constructed PK: {pk}')
                else:
                    return Response({'error': f'Missing student or project info: {request.data}'}, status=status.HTTP_400_BAD_REQUEST)

            if not pk:
                pk = request.data['id']

            preference = get_object_or_404(Preference, pk=pk)
            serializer = PreferenceSerializer(preference, data=request.data, partial=True)

        elif isinstance(request.data, list):
            preferences = []

            for preference in request.data:
                if 'id' not in preference and 'student' not in preference and 'project' not in preference:
                    return Response({'error': f'Missing ID: {request.data}'}, status=status.HTTP_400_BAD_REQUEST)
                elif 'id' not in preference:
                    logger.debug(f'request.data:\n{request.data}')
                    preference['id'] = Preference.generate_id(
                        self=None, student_id=preference['student'], project_id=preference['project'])

                updated = get_object_or_404(Preference, pk=preference['id'])
                updated.rank = preference['rank']
                preferences.append(updated)

            logger.debug(preferences)
            serializer = PreferenceSerializer(preferences, data=request.data, many=True, partial=True)

        else:
            return Response({'error': f'Request Data was of unexpected type: {type(request.data)}'}, status=status.HTTP_400_BAD_REQUEST)

        if serializer.is_valid():
            logger.debug('Serializer reports valid data')
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
