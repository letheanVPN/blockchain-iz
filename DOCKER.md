# Building with Docker

Build and run project and return a interactive shell for testing

`docker build -t lthn . &&  docker run -it --entrypoint /bin/bash  --env-file .env lthn:latest`

Bring up a daemon 

`docker compose up --build`
