# Create self-signed certs:
# openssl genrsa -out https-server.key 2048
# openssl ecparam -genkey -name secp384r1 -out https-server.key
# openssl req -new -x509 -sha256 -key https-server.key -out https-server.crt -days 3650

# Build with:
# docker kill www; docker rm www; docker build . -t registry:latest --squash

# Test with:
# docker run -d -it --name www registry:latest && TEST_IP=$(docker inspect www | grep IPAddress | grep -v Secondary | tr -d " " | uniq | sed -e "s#\"IPAddress\":\"\(.\+\)\",#\1#") && \
# if [[ ${TEST_IP} ]]; then google-chrome https://${TEST_IP}:8843/v3/plugins/; fi

############################################################
# STEP ONE: BUILD golang webserver
############################################################

# FROM golang:1.12 as builder
FROM registry.access.redhat.com/devtools/go-toolset-rhel7:1.11.13-10 as httpserver
USER 0
ENV PATH=/opt/rh/go-toolset-1.11/root/usr/bin:$PATH \
    GOPATH=/go/ \
    APP_NAME=registry \
    PORT=8080

COPY . /go/src/${APP_NAME}
WORKDIR /go/src/${APP_NAME}
RUN go get ./
RUN OOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${APP_NAME}

############################################################
# STEP TWO: BUILD registry content
############################################################

# https://access.redhat.com/containers/?tab=tags#/registry.access.redhat.com/ubi8/python-36
FROM registry.access.redhat.com/ubi8/python-36:1-47 as builder
USER root

# enable epel 7 content set to resolve jq as rpm (not yet in epel 8)
COPY content_sets_epel7.repo /etc/yum.repos.d/

RUN yum install -y bash yum gzip tar jq python3-six python3-pip && yum -y clean all && \
    # install yq (depends on jq and pyyaml - if jq and pyyaml not already installed, this will try to compile it)
    if [[ -f /tmp/root-local.tgz ]]; then mkdir -p /root/.local && tar xf /tmp/root-local.tgz -C /root/.local/ && rm -fr /tmp/root-local.tgz; fi && \
    /usr/bin/pip3.6 install --user yq jsonschema && \
    # could be installed in /opt/app-root/src/.local/bin or /root/.local/bin
    for d in /opt/app-root/src/.local /root/.local; do \
      if [[ -d ${d} ]]; then \
        cp ${d}/bin/yq ${d}/bin/jsonschema /usr/local/bin/; \
        pushd ${d}/lib/python3.6/site-packages/ >/dev/null; \
          cp -r PyYAML* xmltodict* yaml* yq* jsonschema* /usr/lib/python3.6/site-packages/; \
        popd >/dev/null; \
      fi; \
    done && \
    chmod +x /usr/local/bin/yq && \
    ln -s /usr/bin/python3.6 /usr/bin/python

COPY README.md ./scripts/*.sh ./scripts/meta.yaml.schema /build/
COPY /v3 /build/v3
WORKDIR /build/
RUN ./check_plugins_location.sh v3
RUN ./set_plugin_dates.sh v3
RUN ./check_plugins_viewer_mandatory_fields.sh v3
RUN ./ensure_latest_exists.sh
RUN ./index.sh v3 > /build/v3/plugins/index.json

############################################################
# STEP THREE: RUN golang webserver + registry content
############################################################

# https://access.redhat.com/containers/?tab=tags#/registry.access.redhat.com/ubi8-minimal
# FROM registry.access.redhat.com/ubi8-minimal:8.0-213
FROM scratch 
USER 0
ENV PATH=/www:$PATH \
    APP_NAME=registry \
    PORT=8080

WORKDIR /var/www
COPY --from=httpserver \
    /go/src/${APP_NAME}/${APP_NAME} \
    /go/src/${APP_NAME}/https-server.key \
    /go/src/${APP_NAME}/https-server.crt \
    /var/www/
# COPY --from=httpserver /usr/bin/sh /usr/bin/

COPY --from=builder \
    /build/README.md /build/meta.yaml.schema \
    /var/www/html/
COPY --from=builder \
    /build/v3/ \
    /var/www/html/v3/
RUN chmod -R g+rwX /var/www/html/

EXPOSE ${PORT}/tcp
ENTRYPOINT ["/var/www/registry"]
