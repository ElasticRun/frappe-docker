FROM python:3.7.3-alpine
#FROM python:2.7.16-alpine as intermediate
LABEL MAINTAINER=ElasticRun

USER root
# Generate locale C.UTF-8 for mariadb and general locale dataopenjpeg
ENV LANG C.UTF-8

# RUN echo 'http://151.101.152.249/alpine/v3.9/main' > /etc/apk/repositories \
#   && echo 'http://151.101.152.249/alpine/v3.9/community' >> /etc/apk/repositories

# && pip install --upgrade pip setuptools Click mysqlclient jinja2 virtualenv requests honcho python-crontab \
#   semantic_version GitPython==2.1.11 jmespath docutils "urllib3<1.25,>=1.21.1" python-dateutil botocore s3transfer boto3 chardet \
#   certifi idna requests dropbox gunicorn MarkupSafe jinja2 markdown2 PyMySQL maxminddb maxminddb-geolite2 pytz werkzeug \
#   semantic-version rauth redis selenium babel decorator ipython-genutils traitlets ptyprocess pexpect wcwidth \
#   prompt-toolkit backcall pickleshare pygments parso jedi ipython html2text email-reply-parser click num2words \
#   PyYAML argh pathtools watchdog webencodings html5lib bleach bleach-whitelist Pillow soupsieve beautifulsoup4 rq \
#   schedule asn1crypto pycparser cffi cryptography pyopenssl pyasn1 ndg-httpsclient zxcvbn-python unittest-xml-reporting \
#   oauthlib requests-oauthlib PyJWT PyPDF2 jdcal et-xmlfile openpyxl pyotp pyqrcode pypng cssselect lxml cachetools \
#   cssutils premailer croniter googlemaps braintree future passlib httplib2 rsa pyasn1-modules google-auth \
#   google-auth-httplib2 uritemplate google-api-python-client google-auth-oauthlib text-unidecode faker stripe coverage \
#   smmap2 gitdb2


# Install all pre-requisites
RUN echo '151.101.152.249 dl-cdn.alpinelinux.org' >> /etc/hosts \
  && apk add --update mariadb-dev build-base gcc libxml2-dev libxslt-dev libffi-dev jpeg-dev zlib-dev freetype-dev \
  lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev libwebp-dev mariadb-connector-c-dev redis libldap git wget mysql-client \
  mariadb-common curl nano wkhtmltopdf vim sudo nodejs npm jpeg libxml2 freetype openjpeg tiff busybox-suid gfortran \
  python-dev openblas lapack-dev cython coreutils \
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

RUN pip install ${BENCH_URL}

# Create bench instance
USER frappe
RUN sudo chown -R frappe:frappe /home/frappe && cd /home/frappe && bench init ${BENCH_NAME} --ignore-exist --skip-redis-config-generation \
  --no-procfile --no-backups --no-auto-update --frappe-branch ${FRAPPE_BRANCH:-master} --verbose --frappe-path ${FRAPPE_URL}
RUN mv /home/frappe/${BENCH_NAME}/sites /home/frappe/sites-backup && mkdir -p /home/frappe/${BENCH_NAME}/entrypoints

USER root
# Volume for externalizing the site assets
COPY --chown=frappe:frappe ./common_site_config_docker.json /home/frappe/sites-backup/common_site_config.json
COPY --chown=frappe:frappe ./entrypoints/*.sh /home/frappe/${BENCH_NAME}/entrypoints/
COPY --chown=frappe:frappe ./entrypoint.sh /home/frappe/${BENCH_NAME}/entrypoint.sh

COPY --chown=frappe:frappe ./Procfile_docker /home/frappe/${BENCH_NAME}/Procfile
RUN sudo chmod u+x /home/frappe/${BENCH_NAME}/entrypoints/*.sh

ONBUILD COPY --chown=frappe:frappe ./entrypoints/*.sh /home/frappe/${BENCH_NAME}/entrypoints/
ONBUILD COPY --chown=frappe:frappe ./entrypoint.sh /home/frappe/${BENCH_NAME}/entrypoint.sh
ONBUILD RUN sudo chmod u+x /home/frappe/${BENCH_NAME}/entrypoint.sh && sudo chmod u+x /home/frappe/${BENCH_NAME}/entrypoints/*.sh

# Cleanup
RUN rm -r /root/.cache && rm -r /home/frappe/.cache && rm -rf /home/frappe/${BENCH_NAME}/apps/frappe/.git* \
  && npm cache clean --force && rm -rf /tmp/pip-install* && rm -rf /home/frappe/${BENCH_NAME}/env/src/pdfkit/.git \
  && chmod u+x /home/frappe/${BENCH_NAME}/entrypoint.sh

#Execute
USER frappe
WORKDIR /home/frappe/${BENCH_NAME}
CMD [ "/bin/sh", "-c", "./entrypoint.sh" ]
