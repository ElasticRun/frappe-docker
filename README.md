# frappe-docker

This project aims to provide a generic, pure frappe docker image that can be used as-is (very unlikely) or as base image for adding custom applications using the frappe framework. The image provides a ready-to-use environment setup that has bench installed and a bench instance initialized. It also provides certain hooks that are commonly required by any frappe based deployments - e.g. creation of a site, `bench migrate` execeution after code changes, etc.

To build the image, please refer to build-frappe11.sh as a sample.
