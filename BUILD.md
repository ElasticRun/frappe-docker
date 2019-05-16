## Build Instructions
#### Building Fluentd Container
Typically, the fluentd container is re-usable sidecar container and does not need to be built for each of the applications. However, if any application intends to customize this container, `fluentd/Dockerfile` can be updated to reflect required customizations.

By default, the Dockerfile creates a fluentd container with elasticsearch plugin installed.

#### Building Application Container
The base frappe image creates a frappe application container with a `bench init`ed folder and a site already configured. The applications can create their own containers using this as the base image. `Dockerfile` provides the default behaviour as implemented in the base image.

The base image provides customizations through `entrypoints` directory. The numbered files in this directory are executed in same order as returned by 'ls' at the time of container initialization/startup. These scripts can be updated for installation of more frappe applications in the existing bench instance in the container, to execeute bench migrate or to perform some other activity at the time of container startup.

For any customizations in the base image itself, `Dockerfile` needs to be updated in a forked repository.

##### Default Base Image Behaviour
Base image of frappe as created by the `Dockerfile` in this folder, implements following at **build time** -
* Installs `bench` in python 3.7 alpine-linux base image from default github repository from `master` branch. URL for the git rpository can be overridden using build argument `GIT_BENCH_URL`. Example: _--build-arg GIT_BENCH_URL=engg.elasticrun.in/tredrun/tredrun-core/bench.git_. Branch name cannot be overridden and the source repository for bench must have a branch named `master`. If the git repository needs authentication, same can be provided using build arguments `GIT_AUTH_USER` and `GIT_AUTH_PASSWORD`. Same authentication information is used for both bench and frappe repositories, if provided.
* Installs `frappe` from github repository from master branch by default. This can be overridden using `GIT_FRAPPE_URL` build argument. Example: _--build-arg GIT_FRAPPE_URL=engg.elasticrun.in/tredrun/tredrun-core/frappe.git_. Branch name cannot be overridden and the source repository for frappe must have a branch named `master`. If the git repository needs authentication, same can be provided using build arguments `GIT_AUTH_USER` and `GIT_AUTH_PASSWORD`. Same authentication information is used for both bench and frappe repositories, if provided.
* Executes `bench init` to create an instance of `bench`. Default name of the bench directory created is `docker-bench`. This can be overridden using build argument with name `BENCH_NAME`
* Copy `common_site_config_docker.json`, `entrypoint.sh`, `Procfile` and all `.sh` files from `entrypoints` directory into the new bench instance created.
* Default entry point for the image is `entrypoint.sh` file with working directory as the bench directory (created above). By default, `entrypoint.sh` script loops through all `.sh` files in `entrypoints` directories and executes them one after the other, in same order as returned by the `ls` command.

File `common_site_config_docker.json` can be updated to match your application's deployment design, to ensure that application points to correct instances of the redis-queue and mariadb. Note that root password value will be updated at the time of container startup.

The file build.sh provides a sample build command that can be used to create a tagged image of the application.

To add more applications (e.g. erpnext) into the image, either update the Dockerfile and build a fresh image, or use image created by this Dockerfile as base image and install more applications as part of the application-specific `Dockerfile`. 

The later option is preferred way to create application-specific images, as it ensures that any changes to the base image are automatically inherited in future.
