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
    
    ```docker-compose -f <compose script> exec web python manage.py migrate --noinput```

6. Stop containers

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
