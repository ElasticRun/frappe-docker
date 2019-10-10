FROM python:3.7.3-alpine
#FROM python:2.7.16-alpine as intermediate
LABEL MAINTAINER=ElasticRun

USER root
# Generate locale C.UTF-8 for mariadb and general locale dataopenjpeg
ENV LANG C.UTF-8

# Install all pre-requisites
RUN apk add --update mariadb-dev build-base gcc libxml2-dev libxslt-dev libffi-dev jpeg-dev zlib-dev freetype-dev \
  lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev libwebp-dev mariadb-connector-c-dev redis libldap git wget mysql-client \
  mariadb-common curl nano wkhtmltopdf vim sudo nodejs npm jpeg libxml2 freetype openjpeg tiff busybox-suid gfortran \
  python-dev openblas lapack-dev cython coreutils ca-certificates git bash nginx jq supervisor less dhclient \
  && npm install -g yarn

# Add librdkafka - required for spine that connects to kafka
RUN git clone https://github.com/edenhill/librdkafka.git && cd librdkafka && ./configure --prefix /usr && make && make install

ARG GIT_AUTH_USER
ARG GIT_AUTH_PASSWORD
ARG FRAPPE_BRANCH=version-11
ARG GIT_BENCH_URL=github.com/frappe/bench.git
ARG GIT_FRAPPE_URL=github.com/frappe/frappe.git
ARG KAFKA_CONFIG='{}'

ENV KAFKA_CONFIG=${KAFKA_CONFIG}
ENV BENCH_URL=git+https://${GIT_AUTH_USER}${GIT_AUTH_PASSWORD:+:}${GIT_AUTH_PASSWORD}${GIT_AUTH_USER:+@}${GIT_BENCH_URL}@master
ENV FRAPPE_URL=https://${GIT_AUTH_USER}${GIT_AUTH_PASSWORD:+:}${GIT_AUTH_PASSWORD}${GIT_AUTH_USER:+@}${GIT_FRAPPE_URL}
ENV SPINE_URL=https://${GIT_AUTH_USER}${GIT_AUTH_PASSWORD:+:}${GIT_AUTH_PASSWORD}${GIT_AUTH_USER:+@}engg.elasticrun.in/platform-foundation/spine.git
RUN echo "BENCH_URL = ${BENCH_URL}"
RUN echo "FRAPPE URL = ${FRAPPE_URL}"

ENV DB_HOST=mariadb
ENV BENCH_NAME=docker-bench

# OS User Setup
RUN addgroup -g 1001 -S frappe && adduser -u 1001 -S frappe -G frappe && printf '# User rules for frappe\nfrappe ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN pip install ${BENCH_URL}

# Create bench instance
USER frappe
RUN sudo chown -R frappe:frappe /home/frappe && cd /home/frappe && bench init ${BENCH_NAME} --ignore-exist \
  --skip-redis-config-generation --no-procfile --no-backups --no-auto-update --frappe-branch ${FRAPPE_BRANCH:-master} \
  --verbose --frappe-path ${FRAPPE_URL} && cd /home/frappe/${BENCH_NAME}

RUN cd /home/frappe/${BENCH_NAME} && ./env/bin/pip install gevent watchgod

RUN mkdir -p /home/frappe/${BENCH_NAME}/entrypoints && chown -R frappe:frappe /home/frappe/${BENCH_NAME}/config
#RUN mv /home/frappe/${BENCH_NAME}/sites /home/frappe/sites-backup && mkdir -p /home/frappe/${BENCH_NAME}/entrypoints

USER root
COPY --chown=frappe:frappe ./common_site_config_docker.json /home/frappe/docker-bench/common_site_config_docker.json
COPY --chown=frappe:frappe ./entrypoints/*.sh /home/frappe/${BENCH_NAME}/entrypoints/
COPY --chown=frappe:frappe ./boot_scripts/*.sh /home/frappe/${BENCH_NAME}/boot_scripts/
COPY --chown=frappe:frappe ./postboot_scripts/*.sh /home/frappe/${BENCH_NAME}/postboot_scripts/
COPY --chown=frappe:frappe ./entrypoint.sh /home/frappe/${BENCH_NAME}/entrypoint.sh
COPY --chown=frappe:frappe ./run.sh /home/frappe/${BENCH_NAME}/run.sh
COPY --chown=frappe:frappe ./migrate.sh /home/frappe/${BENCH_NAME}/migrate.sh
COPY --chown=frappe:frappe ./checkjobhealth.sh /home/frappe/${BENCH_NAME}/checkjobhealth.sh
COPY --chown=frappe:frappe ./setenv.sh /home/frappe/${BENCH_NAME}/setenv.sh
COPY --chown=frappe:frappe ./bench.default.env /home/frappe/${BENCH_NAME}/bench.default.env
#COPY --chown=frappe:frappe ./Procfile_docker /home/frappe/${BENCH_NAME}/Procfile
COPY --chown=frappe:frappe ./supervisord.conf /etc/supervisord.conf
COPY --chown=frappe:frappe ./supervisor-docker.conf /home/frappe/${BENCH_NAME}/config/supervisor.conf
COPY --chown=frappe:frappe ./nginx-docker.conf /home/frappe/${BENCH_NAME}/config/nginx.conf
COPY --chown=frappe:frappe ./nginx-startup.conf /home/frappe/${BENCH_NAME}/config/nginx-startup.conf
COPY --chown=frappe:frappe ./site_config_docker.json /home/frappe/${BENCH_NAME}/site_config_docker.json
RUN chmod u+x /home/frappe/${BENCH_NAME}/entrypoints/*.sh && chmod u+x /home/frappe/${BENCH_NAME}/*.sh \
  && chmod u+x /home/frappe/${BENCH_NAME}/bench.default.env \
  && chmod u+x /home/frappe/${BENCH_NAME}/boot_scripts/*.sh && chmod u+x /home/frappe/${BENCH_NAME}/postboot_scripts/*.sh \
  && ln -s /home/frappe/${BENCH_NAME}/config/nginx.conf /etc/nginx/conf.d/nginx.conf && mkdir -p /run/nginx \
  && mkdir -p /etc/supervisor.d && mkdir -p /var/run && mkdir -p /var/log/supervisor \
  && ln -s /home/frappe/${BENCH_NAME}/config/supervisor.conf /etc/supervisor.d/frappe.conf

ONBUILD COPY --chown=frappe:frappe ./entrypoints/*.sh /home/frappe/${BENCH_NAME}/entrypoints/
ONBUILD RUN sudo chmod u+x /home/frappe/${BENCH_NAME}/*.sh && sudo chmod u+x /home/frappe/${BENCH_NAME}/entrypoints/*.sh

# Cleanup
RUN rm -r /root/.cache && rm -r /home/frappe/.cache && rm -rf /home/frappe/${BENCH_NAME}/apps/frappe/.git* \
  && rm -rf /home/frappe/${BENCH_NAME}/apps/spine/.git* \
  && npm cache clean --force && rm -rf /tmp/pip-install* && rm -rf /home/frappe/${BENCH_NAME}/env/src/pdfkit/.git

#Execute
RUN mkdir -p /home/frappe/docker-bench/config/env
WORKDIR /home/frappe/${BENCH_NAME}
CMD [ "/bin/sh", "-c", "./entrypoint.sh" ]
