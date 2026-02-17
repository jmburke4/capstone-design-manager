from import_export import resources, fields
from user import models


class SponsorResource(resources.ModelResource):
    class Meta:
        model = models.Sponsor


class StudentResource(resources.ModelResource):
    # This class uses import_export.fields to map the CSV field names that come from Blackboard to the field
    # names of the model that we defined in Django
    # This does not prevent importing lists that already use the same attribute naming conventions

    email = fields.Field(
        column_name='EMAIL',
        attribute='email'
    )

    first_name = fields.Field(
        column_name='FIRST_NAME',
        attribute='first_name'
    )

    middle_name = fields.Field(
        column_name='MIDDLE_NAME',
        attribute='middle_name'
    )

    last_name = fields.Field(
        column_name='LAST_NAME',
        attribute='last_name'
    )

    preferred_name = fields.Field(
        column_name='PREF_NAME',
        attribute='preferred_name'
    )

    cwid = fields.Field(
        column_name='CWID',
        attribute='cwid'
    )

    class_code = fields.Field(
        column_name='STU_CLASS_CODE',
        attribute='class_code'
    )

    major_code = fields.Field(
        column_name='MAJR_1_CODE',
        attribute='major_code'
    )

    class Meta:
        model = models.Student
