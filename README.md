# Capstone Design Project Management

## Introduction

This Computer Science Capstone project is sponsored by Dr. Monica Anderson Herzog. The purpose of this project is to create a platform for Dr. Anderson to manage new and ongoing senior design projects.

Read more on this project's [Github Pages](https://jmburke4.github.io/capstone-design-manager/).

## Setup

    If on Windows, use a Unix-like terminal (Such as Cygwin)

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

## Repository Structure

## Docker Commands

| Command | Description |
|--|--|
|```docker-compose build```| Builds an image using the docker-compose.yml in the cwd |
|```docker-compose up -d```| Starts a container from the build image(s), ```-d``` detaches the process from your terminal |
|```docker-compose up -d --build```| Starts containers after rebuilding them |
|```docker-compose stop```| Stops the running containers |
|```docker-compose down -v```| Stops running containers and removes them, ```-v``` also removes volumes |
|```docker-compose exec <service> <command>```| Execute a command inside the specified container |

Quick psql [reference](google.com/search?smstk=ChhCWU5MUDBsODdkNUFLM3BaK1hxRnpvdz0QBA%3D%3D&smstidx=0&q=quick+and+dirty+psql+commands&udm=50&csuir=1&aep=34&kgs=9e62baadf59f9e95&shem=bdsle,epsdc&shndl=37&shmd=H4sIAAAAAAAA_3WNOw7CMBAFSZsjICG5RiImDQXiLtbGttYr4k92HQWOR8upMDWinac307-6_rCsZO8KklOOuD5VkWVWNsfYkOxvodYiV623bRtQKlSyQ1u1eGAbToVzzBooGgnA3tSwxikBzUNJeNy9O_NPQBHQi564dSihxpxx9miQwZFPVY-PH2baPzlgZ8bL2ZVv4wMhIaRZxAAAAA&shmds=v1_ATWGeePY93TdMuXM0BfH7IdnnF4SioeAjgHOXkjlgJovPO_njw&source=sh/x/aio/m1/1)


## Setting Up Oauth (Shared dev tenant)

- **Auth0 Tenant:** `dev-qjyd077ykn3qqq7v.us.auth0.com`
- **Client ID:** `WMPr5zJLNFI0j9A8iUymDfAsP2mUXsn3`
- **API Identifier:** `https://backend-api-capstone/`

Instructions:
1. Perform clean build (You may need to remove/delete cotainers and volumes. This is easily done via the docker desktop GUI dashboard or CLI.)
2. Copy and paste the following values int /.env.dev **AND** /frontend/.env.local (if /frontend/.env.local dne, create it and add the env variables):

    AUTH0_DOMAIN=dev-qjyd077ykn3qqq7v.us.auth0.com
    AUTH0_CLIENT_ID=WMPr5zJLNFI0j9A8iUymDfAsP2mUXsn3
    AUTH0_AUDIENCE=https://backend-api-capstone/

(These are front public variables and it is fine to include them in the readme and upload to repo. These values are subject to change.)
