from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from emails.utils import email_client
from emails.serializers import EmailSerializer


@api_view(['GET', 'POST'])
def send_email(request):
    if request.method == 'GET':
        serializer = EmailSerializer()
        return Response(serializer.data)
    
    serializer = EmailSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    subject = serializer.validated_data['subject']
    message = serializer.validated_data['message']
    recipient_list = serializer.validated_data['recipients']
    html_message = serializer.validated_data.get('html_message')

    try:
        email_client.send_email(
            subject=subject,
            message=message,
            recipient_list=recipient_list,
            html_message=html_message,
        )
        return Response({'status': 'email sent successfully'})
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
def send_sponsor_outreach(request):
    recipients = request.data.get('recipients')

    if not recipients:
        return Response(
            {'error': 'recipients are required'},
            status=status.HTTP_400_BAD_REQUEST
        )

    if isinstance(recipients, str):
        recipients = [r.strip() for r in recipients.split(',') if r.strip()]

    try:
        email_client.send_sponsor_outreach(recipients)
        return Response({'status': 'sponsor outreach email sent successfully'})
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
