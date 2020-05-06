# Frappe Docker Image
This project contains the docker image for Frappe that can be used for any frappe based implementation (including erpnext). This is intended as a starting point for frappe applications, so that they can benefit from both docker world and frappe world.

For users who need to start from scratch with frappe, this docker image provides an easy way to get started. What's more, the `compose` folder in this project, also provides a docker-compose way of starting a frappe instance locally, without any installation - except, of course, docker and docker-compose!

## Dependencies
To be able to build and run this frappe image, following pre-requisites need to be present/installed -
1.  Docker
2.  Docker Compose (optional)
2.  Mysql/Mariadb instance (optional)

## Getting Started
Easiest way to get started is to install docker and docker-compose on your machine, and run `docker-compose up -d` from `compose` directory of this project. More details are available in the README included in the `compose` directory.
