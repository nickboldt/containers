# Create self-signed certs:
# openssl genrsa -out https-server.key 2048
# openssl ecparam -genkey -name secp384r1 -out https-server.key
# openssl req -new -x509 -sha256 -key https-server.key -out https-server.crt -days 3650

# Build with:
# docker kill www; docker rm www; docker build . -t registry:latest --squash

# Test with:
# docker run -d -it --name www registry:latest && \
# TEST_IP=$(docker inspect www | grep IPAddress | grep -v Secondary | tr -d " " | uniq | sed -e "s#\"IPAddress\":\"\(.\+\)\",#\1#")
# if [[ ${TEST_IP} ]]; then google-chrome https://${TEST_IP}:8843/v3/plugins/; fi

# FROM golang:1.12 as builder
FROM registry.access.redhat.com/devtools/go-toolset-rhel7:1.11.13-10 as builder
ENV PATH=/opt/rh/go-toolset-1.11/root/usr/bin:$PATH \
    GOPATH=/go/
USER 0

ENV APP_NAME registry
ENV PORT 8843

COPY . /go/src/${APP_NAME}
WORKDIR /go/src/${APP_NAME}

RUN go get ./
RUN OOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${APP_NAME}

# https://access.redhat.com/containers/?tab=tags#/registry.access.redhat.com/ubi8-minimal
FROM registry.access.redhat.com/ubi8-minimal:8.0-213

ENV APP_NAME registry
ENV PORT 8843

WORKDIR /www
COPY --from=builder \
    /go/src/${APP_NAME}/${APP_NAME} \
    /go/src/${APP_NAME}/https-server.key \
    /go/src/${APP_NAME}/https-server.crt \
    /www/
COPY --from=builder /go/src/${APP_NAME}/v3 /www/v3 

COPY /v3 /www/html/v3 

# RUN microdnf clean all && rm -rf /var/cache/yum && echo "Installed Packages" && rpm -qa | sort -V && echo "End Of Installed Packages"

EXPOSE ${PORT}/tcp
CMD ["/www/registry"]
