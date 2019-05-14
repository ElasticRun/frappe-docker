FROM fluent/fluentd:v1.4.2-2.0

# below RUN includes plugin as examples elasticsearch is not required
# you may customize including plugins as you wish

USER root
RUN apk add --no-cache --update --virtual .build-deps \
    sudo build-base ruby-dev \
    && sudo gem install  fluent-plugin-elasticsearch \
    && sudo gem sources --clear-all \
    && apk del .build-deps \
    && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem
