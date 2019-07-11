## Build Instructions

#### Building Application Container
The base frappe image creates a frappe application container with a `bench init`ed folder and a site configured when container instance first starts. The applications can create their own containers using this as the base image. `Dockerfile` provides the default behaviour as implemented in the base image.

The base image provides customizations through `entrypoints` directory. The numbered files in this directory are executed in same order as returned by 'ls' at the time of container initialization/startup. These scripts can be updated for installation of more frappe applications in the existing bench instance in the container, to execeute bench migrate or to perform some other activity at the time of container startup. By default, the entrypoints are already defined for following tasks -
1. Set OS level flags
2. Set permissions on sites and logs directories
3. Set configuration values for the bench instance created
4. Create new site, if not already created, and mark it as current site
5. Run `bench migrate` and `bench build` for the configured site.

For any customizations in the base image itself, `Dockerfile` needs to be updated in a forked repository.

##### Default Base Image Behaviour
Base image of frappe as created by the `Dockerfile` in this folder, implements following at **build time** -
* Installs `bench` in python 3.7 alpine-linux base image from default github repository from `master` branch. URL for the git rpository can be overridden using build argument `GIT_BENCH_URL`. Example: _--build-arg GIT_BENCH_URL=engg.elasticrun.in/tredrun/tredrun-core/bench.git_. Branch name cannot be overridden and the source repository for bench must have a branch named `master`. If the git repository needs authentication, same can be provided using build arguments `GIT_AUTH_USER` and `GIT_AUTH_PASSWORD`. Same authentication information is used for both bench and frappe repositories, if provided.
* Installs `frappe` from github repository from master branch by default. This can be overridden using `GIT_FRAPPE_URL` build argument. Example: _--build-arg GIT_FRAPPE_URL=engg.elasticrun.in/tredrun/tredrun-core/frappe.git_. Be default `master` branch is used for frappe Git repository as well. This can be overridden using the build argument `FRAPPE_BRANCH` e.g. _--build-arg FRAPPE_BRANCH=v11.x.x_. If the git repository needs authentication, same can be provided using build arguments `GIT_AUTH_USER` and `GIT_AUTH_PASSWORD`. Same authentication information is used for both bench and frappe repositories, if provided.
* Executes `bench init` to create an instance of `bench` in directory `/home/frappe/docker-bench`.
* Copy `common_site_config_docker.json`, `entrypoint.sh`, `start.sh`, `Procfile` and all `.sh` files from `entrypoints` directory into the new bench instance created.
* Provides an `ONBUILD` hook to copy customizations of `entrypoints` scripts having `.sh` as extension
* Default entry point for the image is `entrypoint.sh` file with working directory as the bench directory (created above). By default, `entrypoint.sh` script loops through all `.sh` files in `entrypoints` directories and executes them one after the other, in same order as returned by the `ls` command.

The file build.sh provides a sample build command that can be used to create a tagged image of the application.

To add more applications (e.g. erpnext) into the image, either update the Dockerfile and build a fresh image, or use image created by this Dockerfile as base image and install more applications as part of the application-specific `Dockerfile`.

The later option is preferred way to create application-specific images, as it ensures that any changes to the base image are automatically inherited in future.

#### Default entrypoint scripts
* `00_entry.sh` - Sets up OS parameters required by frappe
* `10_mkdirs.sh` - Sets up permissions for the `site` and `logs` directories under bench instance
* `20_setvalues.sh` - Updates values in `common_site_config.json` that is used as global configuration file for all sites installed in the bench instance.
* `30_setup_site.sh` - Creates new site if it is not already created. Skips site creation, if existing site folder is detected containing `site_config.json` file.
* `40_install_apps.sh` - Does not perform any action - placeholder for images to override. Ideally, all applications added to image in `Dockerfile` should be `install`ed (using `bench install-app`) as part of this script.
* `50_prepare_bench.sh` - Executes `bench migrate` and `bench build` as part of preparation just before starting the bench processes.

Any application that wishes to override functionality of each of the scripts above, can include only that script under `entrypoints` folder with exact same name. This will override the base image copy of the script as part of the build process. If any additional functonality needs to be introduced in the image, include a new script with appropriate name, such that `ls` command returns it in correct position for execution. No other changes are required by the child image.

#### Default startup script `entrypoint.sh`
The script is part of the base image and should not be overridden as part of the child images. It provides checks to ensure that site creation and bench initialization occurs only once for the given deployment. Subsequent executions of the container will re-use the same configurations.

If the site is already created/initialized, this script ony starts the bench processes within the container.

If the site is not already initialized, this script loops through all the `.sh` files under `entrypoints` folder and executes them sequentially - in the same order as returned by `ls` command.
