
**NOTE** Please read all notes.

---

# Required Technologies 

Basic familiarity with this tech stack is a big bonus and will help deployment go very smoothly.

### For local developement and deployment:

1. git / github account
   - You will have to be able to clone the repository
2. Docker
   - For local developement, Docker will need to be installed.
   - The docker daemon must be running to launch the app locally
3. Postgress instance.

### For cloud hosting:

1. Google cloud account / project setup

2. Domain registration through Google

3. Gcloud CLI
   - This is a must for running the deployment scripts

### Necessary for both local and cloud solutions:

1. Auth0 account and application setup

---

# Local Deployment

**NOTE** It is recommended that a developer ensure a local deployemnt of the app is working before they attempt to host the app on the cloud.

## 0. Ensure you have the required technologies installed:

1. Docker
   Docker desktop can be helpful if you are not familiar with the CLI. However, you will need to run some commands from the terminal in order to get this project running.
2. Git

## 1. General instructions:

0. If on windows, use a unix-like terminal (such as Cygwin)

1. Create environment files

    The ```docker-compose.yml``` scripts require valid ```.env``` and ```.env.db``` files to be in the root directory. See ```env.example``` and ```env.example.db``` for ```.env``` file examples. The default naming conventions for this repositories development environment are ```docker-compose.dev.yml```, ```.env.dev```, and ```.env.deb.db```. In these files you must configure a default username, password, and default database name.

    > Never commit your own development or production environment files to keep secrets protected.

2. Start the Docker engine on your machine

3. Build containers

    > Specify a compose script with ```docker-compose -f <compose script name>```

     ```docker-compose -f <compose script> build```
4. Start containers

    ```docker-compose -f <compose script> up```
5. Run migrations

    ```docker-compose -f <compose script> exec backend python manage.py migrate --noinput```

    > If you have added new models or a new app, run ```docker-compose -f <compose script> exec backend python manage.py makemigrations``` before running the migrate command

6. Create Admin User

    ```docker-compose -f <compose script> exec backend python manage.py createsuperuser ```

    > Setting up an admin will allow you to log in to the Django admin page.

7. Stop containers

    ```docker-compose -f <compose script> stop```



## 2. Example deployment:

These are exactly the steps I followed to get the local developer env working on a new mac-os. 

It is recommended that you follow this guide and substitute the proper instruction translation depending on your system.

1. Install homebrew (or similar package manager. This is completely a mattr of preference. There are many ways to install the tools we need.): https://brew.sh/
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   (This may take awhile)
2. Check if git is already installed
   ```bash
   git --version
   ```

   My system already had git. But if you do not, you will need to install it: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

3. Install docker desktop

   I Used homebrew for this:
   ```bash
   brew install --cask docker-desktop

   # After that runs you should see it installed
   docker --version
   ```

   There are other ways to install docker. See: https://docs.docker.com/desktop/ (Scroll down on this page to install and select your system)

4. Install docker compose

   I Used homebrew for this:

   ```bash
   brew install docker docker-compose

   # After that runs you should see it installed
   docker-compose --version
   ```

3. Clone the repository

   ```bash
   git clone https://github.com/jmburke4/capstone-design-manager.git 
   ```

   For local development, I will use the main branch. Currently, our cloud deployment is managed on the Cloud-V2 branch. For cloud deployment, see the cloud deployment section.

4. Configure env files

   Navigate to teh local repository.

   If you are using this as a guide for your own deployment, go to the `Setting up Auth0` section and complete that first. You will not be able to properly configure your env files without an Auth0 tenant.

   Once you have finished setting up Auth0 for local deployment, you can resume at this point.

   Inside your local capstone-design-manager repo, make copie of the following files and name them accordingly
   **THE APP EXPECTS THE FOLLOWING NAMING CONVENTION. IF YOU HAVE ISSUES YOU MAY HAVE TO CHANGE YOUR DOCKER COMPOSE / DOCKER FILES**
      ```bash
      

      cp .env.example .env.dev
      cp .env.example.db .env.db

      # Navigate to the frontend directory to create the frontend env file
      cd frontend
      cp .env.example.local .env.dev.local

      ```
   **NOTE** It is on the backlog to condense the env files into one file. Currently, the frontend env file is especially stupid as it uses the exact same values as the other .env.dev file.

   Then, using a text editor of your choice, change all of the values in the dev folders to the ones you will use in your project.

   **NOTE** since these files start with a '.' they will likely be hidden by default in your file explorer. Refer to your file explorer's guide on how to unhide the files if you need to see the files in order to open and edit them.

   As you can tell, a lot of the environment values are somewhat arbitrary, as they are used by the docker containers. It is recomended that you use strong passwords for deployment. However take note of the following:
    - Your sql user, database, password values in .env.dev must match the corresponding postgres user, passoword and db values in .env.dev.db
    - Your Auth0 values must match the corresponding values found in your Auth0 dashboard. It is perfectly good for multiple developers to use the same Auth0 values, as they should be sharing the tenant. 
    - The following value guid is not syntactically accurate. The format is: ENV_VALUE_NAME=ENV_VALUE_VALUE

   ### Value guide for .env.dev (Not syntactically correct)

   `DEBUG` : Leave this as '1' for local developement. (Change to 0 in production)
   `SECRET_KEY` : substitute for whatever secret key you wish to use
   `DJANGO_ALLOWED_HOSTS` : **LEAVE THIS AS IS** For local deployment, this line should be: 'DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1] backend'
   `APP_BASE_URL` : This is for local deployment of the Cloud-V2 branch. Set it to `http://localhost:5173`
   `AUTH0_DOMAIN` : Get this value from your Auth0 dashboard. See `3.1 Basic setup`
   `AUTH0_CLIENT_ID` : Get this value from your Auth0 dashboard. See `3.1 Basic setup`
   `AUTH0_AUDIENCE` : Get this value from your Auth0 dashboard. See `3.1 Basic setup`
   `SQL_ENGINE` : **LEAVE THIS AS IS**
   `SQL_DATABASE` : Replace with your desired db name (**NOTE** must match correlating value in .env.dev.db)
   `SQL_USER` : Replace with your desired user name (**NOTE** must match correlating value in .env.dev.db)
   `SQL_PASSWORD` : Replace with desired password (**NOTE** must match correlating value in .env.dev.db)
   `SQL_HOST` : **LEAVE THIS AS IS** : 'db'
   `SQL_PORT` : Replace with desired port no. I used 5432.
   `DATABASE` : **LEAVE THIS AS IS**
   `MINIO_ROOT_USER` : Replace with desired username
   `MINIO_ROOT_PASSWORD` : Replace with desired password
   `AWS_STORAGE_BUCKET_NAME` : Replace with desired bucket name

   For the rest of the email values, I simply deleted them. If you have mailhog or gmail smtp setup with credentials, you can fill those feilds in and use them.

   ### Value guide for .env.dev.db
   `POSTGRES_USER`: Replace with your desired user name (**NOTE** must match correlating value in .env.dev.db)
   `POSTGRES_PASSWORD` : Replace with desired password (**NOTE** must match correlating value in .env.dev.db)
   `POSTGRES_DB` :Replace with your desired db name (**NOTE** must match correlating value in .env.dev)

   ### Value guide for frontend/.env.dev.local (See 3.1 Basic setup if you don't know where to acquire these values)
   `VITE_AUTH0_DOMAIN` : You will use the same value as in .env.dev
   `VITE_AUTH0_CLIENT_ID` : You will use the same value as in .env.dev
   `VITE_AUTH0_AUDIENCE` : You will use the same value as in .env.dev

5. Build and launch docker containers. 

   **NOTE** check if docker compose is installed. If you try the second version, make sure it says 'Docker compose` in the output. If it just says Docker, you need to install docker compose: https://docs.docker.com/compose/install/
      ```bash
      docker-compose --version
      docker compose --version
      ```

   **NOTE** ensure the docker daemon is running: 
      ```bash
         open -a Docker
      ```

      For my mac, I had to walk through the installation process. This required giving docker proper permissions on my system.

      You can also open the docker desktop app/dashboard and this will start the daemon.

      **NOTE** My docker was configured based on my account that I had already previously created long ago. If issues arise using docker, refer to the documentation provided by docker, or simply paste this entire script into an LLM, and tell it what step you are having issues with and what error message you are receiving and it will hopefully give you good debugging advice.

   After checking to ensure compose was installed, and the daemon was running, I ran the following:
   ```bash
   docker-compose -f docker-compose.dev.yml up --build -d
   ```

   Running this script for the first time, I had to allow a lot of permissions. If at all prompted, just continue hitting `Allow`

   **NOTE** The first spin up for me took around 1 minute.

   **NOTE** If you get a mailhog error message, just ignore it. Unless you are tyring to use mailhog, it is not important.

   After the script has finished, you should be able to see the docker containers running in docker desktop (or run 'docker ps' in CLI). If not, there should be error messages in docker desktop that can guide you toward debugging the situation. The most likely cause is improper env setup.

6. Verify app

   After successuflly spinningn up your docker containers with the compose script, you should be able to navigate to the frontend deployed at localhost:5173. You can either open a browser and paste in `http://localhost:5173` or navigate to the landing page through docker desktop.

   At this point I was able to navigate to the app homepage and signup as a sponsor using the auth0 tenant.

7. Create a django super user

   This is necessary for importing data to your system, as well as having admin access to the app.

   Run the following command in the root directory of the project
   ```bash
   docker-compose -f docker-compose.dev.yml exec backend python manage.py createsuperuser
   ```

   Answer the prompts accordingly. I always leave email blank, but this is likely a poor decision if you are deploying.

   **NOTE** you will need to remember these credentials in order to log into the django admin panel. It is best that you make a note of them somwhere. Password manager is recommended for deployment.

8. Verify django admin panel is accessible and working

   Navigate to the backend through a browser using the following: `http://localhost:8000/admin/login/?next=/admin/` (The django backend should be deployed at prot 8000)

   Login using the same credentials you used when creating a super user.

   You should see the admin panel.

   **NOTE** For cloud deployment, we have greater security around admin access. To access the admin panel in a cloud deployed setup, you will need to create a spnosor-admin account 

9. Verify that student account creation is working

   For developers wishing to access the frontend as a student user, you will need to add an entry in the student table with their crimson email. After this, a user will be able to create a student account following these general actions: landing page->signup->I am a student->Email-password option with their crimson account->verify email -> login

   **NOTE** Student account creation and the rest of the user and admin workflows are covered in the rest of our documentation.

   The rest of the steps are for verifying the Cloud-V2 branch can be deployed locally for local development.

10. Spin down docker containers

   I used the following command:
      ```bash
      docker-compose -f docker-compose.dev.yml down
      ```
   
   You can also use docker desktop.

11. Checkout the `Cloud-V2` branch

   I used hte following command:
   ```bash
   git checkout Cloud-V2

   # To verify you are on the cloud branch:
   git branch
   ```

12. Spin up containers

   You should not have to reconfigure environment files. If you run into issues, you can try running with the --no-cache flag. This will give 

   ```bash
   docker-compose -f docker-compose.dev.yml up --build -d
   ```

13. Verify admin panel functionality

   Admin access works differently on the cloud branch. We need to create an admin sponsor account. This is covered in more depth in the documentaiton video, starting at around the 10:25 minute mark: https://www.youtube.com/watch?v=FEcXGf6hiFY&feature=youtu.be

   For this, I created a sponsor account using the google.

   I then navigated to the Auth0 dashboard to User Management->Users

   I then selected the three dots to the right of the sponsor accoutn I created using google sso, and selected more Actions->Assing Roles->admin

   Hit `Assign`

   I then refreshed my sponsor's homepage, and the admin panel button appeared on the sidepanel.

   Clicking this, I was directed to the Django admin panel login page, where login was successful.

   **NOTE** With local deployment, the admin login guard might not work as expected. This is because of browsing cache and is fixed in the cloud deployment version of the app.

14. Spin down containers

---

# Setting up Auth0

- For the following guide, I will be providing all values that I used when creating my Auth0 tenant. Some values it would be unwise to change. Others can likely be changed with little to no consequences (such as 'application name'). Simply use your best disgression.
- Additionally, I'd advise reading everything carefully and not skimming over these instructions.

## 1. Create an account

- For long term account, I would recommend using email regisration instead of SSO. I have found the auth0 SSO login options sometimes a pain to navigate to. Additionally, if you sign up with an email, you will always know what email is associated with that Auth0 account.
- Navigate to: https://auth0.com/signup?place=header&type=button&text=sign%20up
- Create an account
   - Personal account type
   - Do not check advanced settings (This likely does not matter)

## 2. Create a new application

- Directly after signing up, you will be prompted with creating a new application.
- Fill in the name value: `capstone-design-manager`
   - Select `Vue` for the technology (Unless you know what you are doing, select this option.).
- Select `Single-paged application` for the application type.
- Hit `Create Application`


## 3. First integration phase (local deployment)



### 3.1 Basic setup 
- Many options will appear after click `Create Application` However, most of the Auth0 setup has already been taken care of.
- First, we will test with configuring our Auth0 tenant for local deployment / development
- In the Vue quickstart, the `Application Origin` field should be: `http://localhost:5173`
   - Hit `Continue`
- The `Callback` , `Logout` URLs, and `Web Origin` values should all be/contiain `http://localhost:5173`
- Hit `Update Required Settings`
- DO NOT TRY TO INTEGRATE WITH AI
- Navigate from the `Quickstart` tab to the `Settings` Tab (to its direct right)
- You must take note of two fields from the Basic information section: `Domain` and `Client ID`. You will need to update your environment scripts with these values in order for Auth0 to work. The Auth0 section of your .env.dev file shoudl look something like this:
   ```bash
   AUTH0_DOMAIN=dev-qjyd077ykn3qqq7v.us.auth0.com   # This value is found in Auth0 dashboard, in your applicaiotn, in the settings tab under basic information, it is the `domain` field
   AUTH0_CLIENT_ID=WMPr5zJLNFI0j9A8iUymDfAsP2mUXsn3 # This value is found in Auth0 dashboard, in your applicaiotn, in the settings tab under basic information, it is the `Client ID` field
   AUTH0_AUDIENCE=https://backend-api-capstone/ # We have not set this up yet at this point in the integration. We will get to it soon
   ```
   Do not update your env files yet. We will finish configuring Auth0 first.
- 

### 3.2 Create the triggers
- For this step, you will need access to the Auth0 scripts stored on the repository in `capstone-design-manager/Auth0-Scripts/`
   - It is therefore recommended that you either navigate to the github repository at: https://github.com/jmburke4/capstone-design-manager
   - Or clone the repo and reference it on your local machine
- On your Auth0 dashboard, using the veritcal navigaiton pane on the left, select Actions->Triggers

For the pre-user-registration trigger:
- Under `Triggers` Under `Sign Up & Login` Select `pre-user-registration`
- In the middle-topish right, select the `Add action` button (Should be a + symbol)
   - Selet `Create Custom Action`
   - Name the action: `ValidateRole&Domain`
   - Leave the other feilds as their defaults (Trigger: Pre User Registration & Runtime: Node 22)
   - select `Create`
- Delete the template code
- Copy the code in `post-login.txt` (capstone-design-manager/Auth0-Scripts/post-login.txt)
- Paste the code into the workspace
- In the topish-right, select `Deploy` (this will also save your changes)
- Navigate `Back To Triggers`
   - You should see the action we just created on the right
- Drag the newly made `ValidateRole&Domain` action between `Start` and `Complete` To set the trigger
- Hit `Apply`
   - The action should now be apart of your sign-up/login flow

For the post-login trigger:
- Under `Triggers` Under `Sign Up & Login` Select `post-login`
- In the middle-topish right, select the `Add action` button (Should be a + symbol)
   - Selet `Create Custom Action`
   - Name the action: `AssignRole&EnforceAccess`
   - Leave the other feilds as their defaults (Trigger: Login / Post Login & Runtime: Node 22)
   - select `Create`
- Delete the template code
- Copy the code in `post-login.txt` (capstone-design-manager/Auth0-Scripts/post-login.txt)
- Paste the code into the trigger workspace
- In the topish-right, select `Deploy` (this will also save your changes)
- Navigate `Back To Triggers`
   - You should see the action we just created on the right
- Drag the newly made `AssignRole&EnforceAccess` action between `Start` and `Complete` To set the trigger
- Hit `Apply`
   - The action should now be apart of your sign-up/login flow

### 3.3 Create the Atuh0 backend-api app

First, you must create the backend API

- On your Auth0 dashboard, using the veritcal navigaiton pane on the left, select Applications->APIs
- Hit `+ Create API`
   - Fill out the `name` field as: `backend-api`
      # NOTE: This may not be the best naming convention. But if we change it we need to update documentation
   -  Fill in the `Identifier`field as: `https://backend-api-capstone/`
      **DON'T CHANGE THIS VALUE UNLESS YOU KNOW WHAT YOU'RE DOING!**
      # NOTE: this may not be the best naming convention. But if we change it we need to update documentation and the env templates + deployment scripts
   - Leave the rest of the values as default
   - Hit `Create`
- Next, while still in your backend-api Navigate to `Application Access`
   - You will see a grid of sorts with `backend-api (Test Application)`, `capstone-design-manager` and `Default App` as row entries
   - Currently, the `capstone-design-manager` row has `UNATHORIZED` for both `User Access` and `Client Access.` We must authorize these
   - In the `capstone-design-manager` row, hit `Edit`
      - Under `User Access` change `Authorization` to `Authorized`
         - Hit `Save`
      - Navigate to `Client Access`
      - Change `Authorization` to `Authorized`
         - Hit `Save`
- This finishes the auth0 backend API creation

Next, you must create the backend application

- On your Auth0 dashboard, using the veritcal navigaiton pane on the left, select Applications->Applications
- Select `+ Create Application`
   - Name the application: `backend-api`
      # NOTE: there may be a better naming convention than this. 
   - Under `Choose an application type` Select `Machine to Machine Application`
   - Hit `Create`
- When prompted with selecting an API, select the `backend-api` We just created (with audience `https://backend-api-capstone/`)
   - Select `Authorize`
- This completes the backend-api app setup

### 3.4 Create the admin role

This step is not strictly necessary for local deployemnt. **NOTE** It is necessary, however, for a local deployment of the Cloud-V2 branch.

- On your Auth0 dashboard, using the veritcal navigaiton pane on the left, select User Management->Roles
- Hit `+ Create Role`
   - Name the role `admin` **DO NOT CHANGE THIS VALUE** The app expects the admin role to be named 'admin'. This is necessary for admin auth on the cloud branch
   - Description: This does not matter. I put 'Gives user access to Django admin acces on cloud branch'
   - Hit `Save`

### This concludes the Auth0 setup for local deployment

You may now return to the local / cloud deployment setup. You will need to update your environment variables as specified by the local/cloud deployment instructions.


## 4 Integrating cloud deployment with your Auth0 tenant

There is not much in the way of required steps for this part.

- On the Auth0 dashboard, navigate to Application->applicaitons
- Select your application (`capstone-design-manager`)
   - Add your domain (`https://ua-capstone-projects.com`, `https://www.ua-capstone-projects.com`) to the following fields:
      - Allowed Callback URLs
      - Allowed Logout URLs
      - Allowed Web Origins
   - Each value box should looks something like this:
      http://localhost:5173/, https://www.ua-capstone-projects.com/, https://ua-capstone-projects.com/
- THat should do it

---

# For Cloud Deployment

**NOTE** Please read all notes.

**NOTE** Currently, our repo has the cloud configuration setup on a branch seperate from main: `Cloud-V2`. It is the desire of the team to consolidate these changes to the main branch, but currently this is a backlog item. For cloud deployment, it is best that everything be done on the Cloud-V2 branch.

**NOTE** Before attempting to deploy to the cloud, it is highly recommended that you correctly deploy the app locally so you are familiar with the general developer workflow.

**NOTE** It is additionally recommended that, after deploying the main branch version of our app, that you deploy the Cloud-V2 version of our app local, and verifying its local functionality before attempting to deploy to the cloud. Again, this is not strictly necessary, but will likely help you to debug / develop if you are able to deploy the cloud branch locally. Currently, local deployment of Cloud-V2 merely differs from main in how it handles admin acces to the Django admin panel.

**NOTE** To bring any changes over to the cloud deployment from local developement do the following:
   1. PR local changes into main
   2. Ensure changes are working
   3. Create a local backup of Cloud-V2 in case something goes horribly wrong
   4. On your local version of Cloud-V2 that is up to date, rebase onto main.
   5. Test the rebased version of Cloud-V2 locally. (NOTE: admin access will be different on a local version of Cloud-V2. To access it, you will have to create a sponsor account)

**COMPLETE THESE BEFORE RUNNING ANY SCRIPTS**

## 0. Review config.sh

If you are planning to change any of the values specified in this prerequisites guide, you will need to change the correlating value in the config.sh script, as the other deployment scripts depend on it to run. This script is located at: scripts/config.sh .

---

## 1. GCP Project Setup

### Create Project

1. **Go to**: https://console.cloud.google.com/projectcreate

2. **Fill in**:
   - Project name: `Capstone Design App Prod`
   - Project ID: `capstone-design-app-prod` (scripts/config.sh)
   - Organization: No organization

3. **Click**: "CREATE"

### Enable Billing

1. **Go to**: https://console.cloud.google.com/billing/linkedaccount?project=capstone-design-app-prod

2. **Click**: "Link a billing account"

3. **Select**: Your billing account (with $300 free credits)

4. **Click**: "SET ACCOUNT"

5. **Verify**: Billing shows as "Active" with green checkmark

---

## 2. Clone the repo

**CRITICAL**: Scripts will clone from GitHub's Cloud-V2 branch.

### Run the command

```bash
git clone https://github.com/jmburke4/capstone-design-manager 
```

### Checkout the cloud branch

```bash
git checkout Cloud-V2
# You should now be on the cloud branch
```

---

## 3. Gcloud CLI

1. **Install Gcloud CLI:** https://docs.cloud.google.com/sdk/docs/install-sdk

2. **Ensure your account is configured and authenticated with the Gcloud CLI on your device**

---

## 4. SSH Key Setup (Optional)

The script requires an SSH connection to your Gcloud Compute VM. If you want to avoid typing in a password multiple times:

### Option A: Remove Passphrase

```bash
# Remove existing SSH keys
rm ~/.ssh/google_compute_engine ~/.ssh/google_compute_engine.pub

# Clear SSH config
gcloud compute config-ssh --remove

# Next time you SSH, gcloud will regenerate keys
# When prompted for passphrase, just press ENTER (no passphrase)
```

**Next time you run `gcloud compute ssh`**:
```
Generating SSH key...
Enter passphrase (empty for no passphrase): [PRESS ENTER]
Enter same passphrase again: [PRESS ENTER]
```

### Option B: Use SSH Agent

If you want to keep your passphrase but avoid typing it repeatedly:

```bash
# Start SSH agent
eval $(ssh-agent)

# Add your key
ssh-add ~/.ssh/google_compute_engine

# Enter passphrase: [TYPE YOUR PASSPHRASE]
# Identity added: /Users/cwk/.ssh/google_compute_engine
```

**Then**: Run all deployment scripts in the same terminal session.

---

## 5. Authenticate with GCP (If not yet done)

```bash
# Login to gcloud
gcloud auth login
# Opens browser, login with your Google account

# Set default project
gcloud config set project capstone-design-app-prod

# Verify
gcloud config get-value project
# Should output: capstone-design-app-prod
```

## 6. Acquire google domain 


## Begin deployment

If you want to run each script individually (Helpful for debugging issues):

```bash
# Start deployment
./scripts/01-create-vm.sh
# The script will guide you with what steps to take next.
```




The script will validate prerequisites automatically and warn you if anything is missing.



Helpful commands:



