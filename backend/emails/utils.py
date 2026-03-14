from django.conf import settings
from django.core.mail import send_mail
from django.core.mail.backends.base import BaseEmailBackend


class EmailClient:
    def __init__(self):
        self.default_from_email = getattr(settings, 'DEFAULT_FROM_EMAIL', 'noreply@example.com')
    
    def send_email(self, subject, message, recipient_list, from_email=None, html_message=None):
        from_email = from_email or self.default_from_email
        
        return send_mail(
            subject=subject,
            message=message,
            from_email=from_email,
            recipient_list=recipient_list if isinstance(recipient_list, list) else [recipient_list],
            html_message=html_message,
            fail_silently=getattr(settings, 'EMAIL_FAIL_SILENTLY', False),
        )

    def send_templated_email(self, subject, recipient_list, template_name, context=None):
        from django.template.loader import render_to_string
        
        context = context or {}
        text_content = render_to_string(f'emails/{template_name}.txt', context)
        html_content = render_to_string(f'emails/{template_name}.html', context)
        
        return self.send_email(
            subject=subject,
            message=text_content,
            recipient_list=recipient_list,
            html_message=html_content,
        )

    def send_sponsor_outreach(self, recipient_list, semester='spring', collection_date='Spring 2025 (1/14/25)'):
        return self.send_templated_email(
            subject=f"UA CS Capstone Project Opportunity - {semester.capitalize()} 2025",
            recipient_list=recipient_list,
            template_name="sponsor_outreach",
            context={
                'semester': semester.lower(),
                'collection_date': collection_date,
            },
        )

    def send_project_presentation(
        self,
        recipient_list,
        date,
        time,
        project_name,
        project_description,
        contact_name,
        contact_email,
        zoom_details,
    ):
        return self.send_templated_email(
            subject=f"Project Presentation: {project_name}",
            recipient_list=recipient_list,
            template_name="project_presentation",
            context={
                'date': date,
                'time': time,
                'project_name': project_name,
                'project_description': project_description,
                'contact_name': contact_name,
                'contact_email': contact_email,
                'zoom_details': zoom_details,
            },
        )


email_client = EmailClient()
