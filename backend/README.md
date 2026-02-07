# Backend via Django REST Framework and PostgreSQL

## Manipulating Objects

The web API can be interacted with by using ```curl```, the [Django Browsable API](https://www.django-rest-framework.org/topics/browsable-api/), or any other software that can send REST requests via HTTP (including your code).

| Action | Request | Route |
| - | - | - |
| Create | PUT | ```/api/v1/projects/create/``` |
| Read | GET | ```/api/v1/projects/``` or ```/api/v1/projects/<id>``` |
| Update | PATCH | ```/api/v1/projects/<id>``` |
| Delete | DELETE | ```/api/v1/projects/<id>``` |

## Creating New Models (w/ associated tables)

Currently only the ```Project``` model has been created in ```backend/project/models.py```. The ```project``` subdirectory of the ```backend``` directory represents a standalone Python module, that is used by the ```core``` module. The ```Project``` module will hold and route models relating to non-user related objects, and the ```User``` module will hold user models and user-related models. Each model in ```models.py``` requires an entry in the associated ```serializers.py```, ```views.py```, and ```urls.py``` classes.

Use the Python files in the ```backend/project/``` directory to see the ```Project``` model as an example. Please follow the [Django Coding style](https://docs.djangoproject.com/en/dev/internals/contributing/writing-code/coding-style/#model-style).

1. RUN MIGRATIONS BEFORE MAKING EDITS TO THE CODEBASE:

    1. ```docker-compose -f <compose script> exec web python manage.py migrate```

2. Define the model for your table in ```backend/<module>/models.py```
    > Django automatically creates and assigns primary key ID fields to every model, so you do not need to add your own ID fields

    > Project, Preference, and Assignment objects should go under the ```Project``` module, while Sponsors, Students, Admins, login info and other user related info should go under the ```User``` module

3. Add a class in ```backend/<module>/serializers.py```

4. Create a ```ViewSet``` for the new model in ```backend/<module>/views.py```

5. Register a route for the new model in ```backend/<module>/urls.py```

6. Spin up the containers and run migrations

    <!-- # TODO double check this is the right command -->
    1. ```docker-compose -f <compose script> exec web python manage.py makemigrations```

    2. ```docker-compose -f <compose script> exec web python manage.py migrate```

7. Test CRUD operations at ```http://localhost:8000/api/v1/<your new object>/```

## Tables to be added

### Project Module

- [x] project
- [ ] preference?
- [ ] assignment?

### User Module

- [x] sponsor
- [x] student
- [ ] admin
- [ ] login info?
