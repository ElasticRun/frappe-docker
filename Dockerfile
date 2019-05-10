FROM python:3.7.3-alpine
#FROM python:2.7.16-alpine as intermediate
LABEL MAINTAINER=ElasticRun

USER root
# Generate locale C.UTF-8 for mariadb and general locale dataopenjpeg
ENV LANG C.UTF-8

# Install all pre-requisites
RUN apk add --update mariadb-dev build-base gcc libxml2-dev libxslt-dev libffi-dev jpeg-dev zlib-dev freetype-dev \
  lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev libwebp-dev mariadb-connector-c-dev redis libldap git wget mysql-client \
  mariadb-common curl nano wkhtmltopdf vim sudo nodejs npm jpeg libxml2 freetype openjpeg tiff busybox-suid \
  && npm install -g yarn

ARG BENCH_NAME=docker-bench
ARG GIT_AUTH_USER
ARG GIT_AUTH_PASSWORD
ARG FRAPPE_BRANCH
ARG GIT_BENCH_URL=github.com/frappe/bench.git
ARG GIT_FRAPPE_URL=github.com/frappe/frappe.git

ENV BENCH_URL=git+https://${GIT_AUTH_USER}:${GIT_AUTH_PASSWORD}${GIT_AUTH_USER:+@}${GIT_BENCH_URL}@master
ENV FRAPPE_URL=https://${GIT_AUTH_USER}:${GIT_AUTH_PASSWORD}${GIT_AUTH_USER:+@}${GIT_FRAPPE_URL}
RUN echo "BENCH_URL = ${BENCH_URL}"
RUN echo "FRAPPE URL = ${FRAPPE_URL}"

ENV DB_HOST=mariadb
ENV BENCH_NAME=${BENCH_NAME}

# OS User Setup
RUN addgroup -S frappe && adduser -S frappe -G frappe && printf '# User rules for frappe\nfrappe ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ONBUILD RUN pip install ${BENCH_URL}

# Create bench instance
USER frappe
ONBUILD RUN sudo chown -R frappe:frappe /home/frappe && cd /home/frappe && bench init ${BENCH_NAME} --ignore-exist --skip-redis-config-generation \
  --no-procfile --no-backups --no-auto-update --frappe-branch ${FRAPPE_BRANCH:-master} --verbose --frappe-path ${FRAPPE_URL}
ONBUILD RUN mv /home/frappe/${BENCH_NAME}/sites /home/frappe/sites-backup

USER root
# Volume for externalizing the site assets
VOLUME [ "/home/frappe/${BENCH_NAME}/sites" ]
ONBUILD COPY ./common_site_config_docker.json /home/frappe/sites-backup/common_site_config.json
ONBUILD COPY ./start-bench.sh /home/frappe/${BENCH_NAME}/start-bench.sh
ONBUILD COPY ./Procfile_docker /home/frappe/${BENCH_NAME}/Procfile
ONBUILD RUN chown frappe:frappe /home/frappe/sites-backup/common_site_config.json \
  && chown frappe:frappe /home/frappe/${BENCH_NAME}/start-bench.sh && chown frappe:frappe /home/frappe/${BENCH_NAME}/Procfile

# Cleanup
ONBUILD RUN rm -r /root/.cache && rm -r /home/frappe/.cache && rm -rf /home/frappe/${BENCH_NAME}/apps/frappe/.git* \
  && npm cache clean --force && rm -rf /tmp/pip-install* && rm -rf /home/frappe/${BENCH_NAME}/env/src/pdfkit/.git \
  && sudo chmod u+x /home/frappe/${BENCH_NAME}/start-bench.sh

#Execute
USER frappe
WORKDIR /home/frappe/${BENCH_NAME}
CMD [ "/bin/sh", "-c", "./start-bench.sh" ]
