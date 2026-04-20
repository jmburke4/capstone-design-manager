# Frequently Asked Questions

## Section 1

### Developer Questions

| Question | Answer | 
|---|---| 
| Why can't I see any submitted objects in the appropriate default Django REST Framework location? | All objects in those locations are hidden for security purposes. Try checking that endpoint through the admin panel. | 
| Why is my project alwasy pending? | An administartor can change its status through the admin panel. It shouldn't change otherwise. | 
| How is each object that includes a foreign key linked to the object(s) containing that key? | When an object is created, its id is automatically provided based on the order of object creation. That id is what links each object to the object(s) containing it's foreign key(s). | 
| Why do I keep getting an error about missing authentication credentials? | This error has occured in the past with APIservices and OAuth. If the user's authentication info is retreived and used correctly via API services, see the OAuth documentation for further support. | 
| Why am I getting an error where some of my containers aren't starting? | In the docker-compose.dev.yml file, there are various ports being accessed. Some of these ports may be used by your computer's OS or another program. If this is the case, simply change the port number to an available one and be careful not to push that change to the repo. (example: 9001:9001 => 9101:9001) | 

### Administartor Questions

| Question | Answer | 
|---|---| 
| Where do I login as an admin? | You can assign a sponsor account the admin role through auth0. They can then login as said sponsor and access the admin panel via the sidebar. | 
| Why can't I create a sponsor and/or student account? | The same email cannot be used to create more than one account. If you already have an account but are being prompted to make another one, try running migrations (see main README - setup section). | 
| Is there a way to delete many objects at once in the admin panel? | after selecting all the objects you want to delete, go to the dropdown box above the objects, next to the "go" button. You can drop down the box and select "delete all selected objects". | 
| Where do I find the sponsor's description of themselves? | The sponsor is intended to place that information in the "Sponsor Availability" or "Project Description" text box when they submit or edit a project. | 
| How do I set a due date/deadline for a project? | An admin can set a deadline/due date via the admin panel. | 