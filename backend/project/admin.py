from django.contrib import admin
from django.urls import path, reverse
from django.utils.html import format_html
from django.http import HttpResponse, Http404
from project.models import Project, Preference, Assignment, Attachment
from project.resources import ProjectResource, PreferenceResource, AssignmentResource, AttachmentResource
from import_export.admin import ImportExportModelAdmin


@admin.register(Project)
class ProjectAdmin(ImportExportModelAdmin):
    resource_classes = [ProjectResource]
    pass


@admin.register(Preference)
class PreferenceAdmin(ImportExportModelAdmin):
    resource_classes = [PreferenceResource]
    pass


@admin.register(Assignment)
class AssignmentAdmin(ImportExportModelAdmin):
    resource_classes = [AssignmentResource]
    pass


@admin.register(Attachment)
class AttachmentAdmin(ImportExportModelAdmin):
    resource_classes = [AttachmentResource]
    list_display = ['id', 'title', 'project', 'content_preview', 'created_at', 'download_link']
    list_filter = ['created_at']
    search_fields = ['title', 'content']
    readonly_fields = ['created_at']
    ordering = ['-created_at']

    def content_preview(self, obj):
        if obj.content:
            return obj.content[:50] + '...' if len(obj.content) > 50 else obj.content
        return '-'
    content_preview.short_description = 'Content Preview'

    def download_link(self, obj):
        if obj.content or obj.file:
            url = reverse('admin:project_attachment_download', args=[obj.id])
            return format_html(f'<a href="{url}" target="_blank">Download</a>')
        return '-'
    download_link.short_description = 'Download'

    def get_urls(self):
        urls = super().get_urls()
        custom_urls = [
            path('<int:pk>/download/', self.admin_site.admin_view(self.download_view), name='project_attachment_download'),
        ]
        return custom_urls + urls

    def download_view(self, request, pk):
        from django.http import HttpResponse
        attachment = self.get_object(request, pk)
        
        if attachment.content:
            content = attachment.content
            if content.startswith('<!DOCTYPE html') or content.startswith('<html'):
                content_type = 'text/html'
                filename = f"{attachment.title or 'email'}.html"
            else:
                content_type = 'message/rfc822'
                filename = f"{attachment.title or 'email'}.eml"
        elif attachment.file:
            content = attachment.file.read()
            content_type = 'application/octet-stream'
            filename = attachment.file.name.split('/')[-1]
        else:
            from django.http import Http404
            raise Http404('No content available')
        
        response = HttpResponse(content, content_type=content_type)
        response['Content-Disposition'] = f'attachment; filename="{filename}"'
        return response
