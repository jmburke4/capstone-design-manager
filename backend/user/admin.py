from django.contrib import admin
from django.shortcuts import render, redirect
from django.urls import reverse
from django.utils.html import format_html
from django.utils.http import urlencode
from django.contrib import messages
from django.http import HttpResponse
from import_export.admin import ImportExportModelAdmin
from project.models import Project
from user.models import Sponsor, Student
from user.resources import SponsorResource, StudentResource
from emails.utils import email_client


@admin.register(Sponsor)
class SponsorAdmin(ImportExportModelAdmin):
    resource_classes = [SponsorResource]
    list_display = ['name', 'email', 'projects', 'organization']
    list_display_links = ['name']
    list_filter = ['organization']
    search_fields = ['last_name', 'first_name', 'organization', 'email']
    ordering = ['last_name', 'first_name', 'organization', 'id']
    actions = ['send_sponsor_outreach', 'send_project_presentation', 'export_sponsor_outreach_email', 'export_project_presentation_email']
    
    def send_sponsor_outreach(self, request, queryset):
        emails = [sponsor.email for sponsor in queryset]
        
        if 'semester' in request.POST:
            semester = request.POST.get('semester', 'Spring')
            collection_date = request.POST.get('collection_date', '')
            from_email = request.POST.get('from_email') or None
            smtp_host = request.POST.get('smtp_host') or None
            smtp_port = request.POST.get('smtp_port') or None
            smtp_username = request.POST.get('smtp_username') or None
            smtp_password = request.POST.get('smtp_password') or None
            
            try:
                email_client.send_sponsor_outreach(
                    recipient_list=emails,
                    semester=semester,
                    collection_date=collection_date,
                    from_email=from_email,
                    smtp_host=smtp_host,
                    smtp_port=smtp_port,
                    smtp_username=smtp_username,
                    smtp_password=smtp_password
                )
                self.message_user(request, f'Successfully sent outreach email to {len(emails)} sponsor(s).', messages.SUCCESS)
            except Exception as e:
                self.message_user(request, f'Failed to send email: {str(e)}', messages.ERROR)
            return
        
        context = {
            'queryset': queryset,
            'action_checkbox_name': admin.helpers.ACTION_CHECKBOX_NAME,
        }
        return render(request, 'admin/sponsor_outreach_action.html', context)
    
    send_sponsor_outreach.short_description = 'Send Sponsor Outreach Email'

    def export_sponsor_outreach_email(self, request, queryset):
        if 'semester' in request.GET:
            semester = request.GET.get('semester', 'spring')
            collection_date = request.GET.get('collection_date', 'TBD')
            
            from django.template.loader import render_to_string
            
            context = {
                'semester': semester.lower(),
                'collection_date': collection_date,
            }
            
            html_content = render_to_string('emails/sponsor_outreach.html', context)
            
            response = HttpResponse(html_content, content_type='text/html')
            response['Content-Disposition'] = 'attachment; filename="sponsor_outreach_email.html"'
            return response
        
        return render(request, 'admin/export_sponsor_outreach.html', {
            'queryset': queryset,
            'action_checkbox_name': admin.helpers.ACTION_CHECKBOX_NAME,
        })
    
    export_sponsor_outreach_email.short_description = 'Export Sponsor Outreach as HTML'

    def send_project_presentation(self, request, queryset):
        emails = [sponsor.email for sponsor in queryset]
        
        if 'date' in request.POST:
            date = request.POST.get('date', 'TBD')
            time = request.POST.get('time', 'TBD')
            project_name = request.POST.get('project_name', 'TBD')
            project_description = request.POST.get('project_description', 'TBD')
            contact_name = request.POST.get('contact_name', 'TBD')
            contact_email = request.POST.get('contact_email', 'TBD')
            zoom_details = request.POST.get('zoom_details', 'TBD')
            from_email = request.POST.get('from_email') or None
            smtp_host = request.POST.get('smtp_host') or None
            smtp_port = request.POST.get('smtp_port') or None
            smtp_username = request.POST.get('smtp_username') or None
            smtp_password = request.POST.get('smtp_password') or None
            
            try:
                for email in emails:
                    email_client.send_project_presentation(
                        recipient_list=[email],
                        date=date,
                        time=time,
                        project_name=project_name,
                        project_description=project_description,
                        contact_name=contact_name,
                        contact_email=contact_email,
                        zoom_details=zoom_details,
                        from_email=from_email,
                        smtp_host=smtp_host,
                        smtp_port=smtp_port,
                        smtp_username=smtp_username,
                        smtp_password=smtp_password
                    )
                self.message_user(request, f'Successfully sent presentation email to {len(emails)} sponsor(s).', messages.SUCCESS)
            except Exception as e:
                self.message_user(request, f'Failed to send email: {str(e)}', messages.ERROR)
            return
        
        context = {
            'queryset': queryset,
            'action_checkbox_name': admin.helpers.ACTION_CHECKBOX_NAME,
        }
        return render(request, 'admin/project_presentation_action.html', context)
    
    send_project_presentation.short_description = 'Send Project Presentation Email'

    def export_project_presentation_email(self, request, queryset):
        if 'date' in request.GET:
            from django.template.loader import render_to_string
            
            context = {
                'date': request.GET.get('date', 'TBD'),
                'time': request.GET.get('time', 'TBD'),
                'project_name': request.GET.get('project_name', 'TBD'),
                'project_description': request.GET.get('project_description', 'TBD'),
                'contact_name': request.GET.get('contact_name', 'TBD'),
                'contact_email': request.GET.get('contact_email', 'TBD'),
                'zoom_details': request.GET.get('zoom_details', 'TBD'),
            }
            
            html_content = render_to_string('emails/project_presentation.html', context)
            
            response = HttpResponse(html_content, content_type='text/html')
            response['Content-Disposition'] = 'attachment; filename="project_presentation_email.html"'
            return response
        
        return render(request, 'admin/export_project_presentation.html', {
            'queryset': queryset,
            'action_checkbox_name': admin.helpers.ACTION_CHECKBOX_NAME,
        })
    
    export_project_presentation_email.short_description = 'Export Project Presentation as HTML'

    def projects(self, obj):
        url = (
            reverse('admin:project_project_changelist')
            + '?'
            + urlencode({'sponsor__id__exact': obj.id})
        )
        count = Project.objects.filter(sponsor=obj).count()
        return format_html(f'<a href="{url}">{count}</a>')


@admin.register(Student)
class StudentAdmin(ImportExportModelAdmin):
    resource_classes = [StudentResource]

    list_display = ['cwid', 'name', 'email', 'major_code', 'class_code']
    list_display_links = ['cwid', 'name']
    list_filter = ['major_code', 'class_code']
    search_fields = ['last_name', 'first_name', 'cwid', 'email']
    ordering = ['last_name', 'first_name', 'cwid']
