# Backend via Django and PostgreSQL

## Manipulating Objects

The web API can be interacted with by using ```curl```, the [Django Browsable API](https://www.django-rest-framework.org/topics/browsable-api/), or any other software that can send REST requests via HTTP (including your code).

| Action | Request | Route |
| - | - | - |
| Create | PUT | ```/api/v1/projects/create/``` | 
| Read | GET | ```/api/v1/projects/``` or ```/api/v1/projects/<id>``` |
| Update | PATCH | ```/api/v1/projects/<id>``` |
| Delete | DELETE | ```/api/v1/projects/<id>``` |

## Creating New Models (w/ associated tables)

Currently only the ```Project``` model has been created in ```app/project/models.py```. The ```project``` subdirectory of the ```app``` directory represents a standalone Python module, that is used by the ```core``` module. The ```Project``` module will hold and route models relating to non-user related objects, and the ```User``` module will hold user models and user-related models. Each model in ```models.py``` requires an entry in the associated ```serializers.py```, ```views.py```, and ```urls.py``` classes. 

Use the Python files in the ```app/project/``` directory to see the ```Project``` model as an example.

1. Define the model for your table in ```app/<module>/models.py```
    > Django automatically creates and assigns primary key ID fields to every model, so you do not need to add your own ID fields
    
    > Project, Preference, and Assignment objects should go under the ```Project``` module, while Sponsors, Students, Admins, login info and other user related info should go under the ```User``` module

2. Add a class in ```app/<module>/serializers.py```

3. Create a ```ViewSet``` for the new model in ```app/<module>/views.py```

4. Register a route for the new model in ```app/<module>/urls.py```

5. Spin up the containers and test CRUD operations at ```http://localhost:8000/api/v1/<your new object>/```

## Tables to be added
### Project Module

- [x] project
- [ ] preference?
- [ ] assignment?

### User Module

- [ ] sponsor
- [ ] student
- [ ] admin
- [ ] login info?
    