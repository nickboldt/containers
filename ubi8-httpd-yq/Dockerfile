#
# Copyright (c) 2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
FROM registry.access.redhat.com/ubi8/s2i-core:1-80

# enable epel 7 content set to resolve jq as rpm
COPY content_sets_epel7.repo /etc/yum.repos.d/

RUN yum install -y bash gzip tar jq python3-six python3-pip && yum -y clean all && \
    \
    # install yq (depends on jq and pyyaml - if jq and pyyaml not already installed, this will try to compile it)
    /usr/bin/pip3.6 install --user yq && \
    # could be installed in /opt/app-root/src/.local/bin or /root/.local/bin
    if [[ -f /opt/app-root/src/.local/bin/yq ]]; then cp /opt/app-root/src/.local/bin/yq /usr/local/bin/; \
    elif [[ -f /opt/app-root/src/.local/bin/yq ]]; then cp /opt/app-root/src/.local/bin/yq /usr/local/bin/; fi && \
    chmod +x /usr/local/bin/yq && \
    ln -s /usr/bin/python3.6 /usr/bin/python

# for debugging only
# RUN yum install -y util-linux && whereis python pip jq yq && python --version && jq --version && yq --version

#### BEGIN PARTIAL COPY FROM https://access.redhat.com/containers/?architecture=AMD64&tab=docker-file#/registry.access.redhat.com/rhel8/httpd-24/images/1-42
ENV HTTPD_VERSION=2.4

EXPOSE 8080
EXPOSE 8443

RUN yum -y module enable httpd:$HTTPD_VERSION && \
    # can't find mod_auth_mellon
    INSTALL_PKGS="gettext hostname nss_wrapper bind-utils httpd mod_ssl" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*'

ENV HTTPD_CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/httpd/ \
    HTTPD_APP_ROOT=${APP_ROOT} \
    HTTPD_CONFIGURATION_PATH=${APP_ROOT}/etc/httpd.d \
    HTTPD_MAIN_CONF_PATH=/etc/httpd/conf \
    HTTPD_MAIN_CONF_MODULES_D_PATH=/etc/httpd/conf.modules.d \
    HTTPD_MAIN_CONF_D_PATH=/etc/httpd/conf.d \
    HTTPD_VAR_RUN=/var/run/httpd \
    HTTPD_DATA_PATH=/var/www \
    HTTPD_DATA_ORIG_PATH=/var/www \
    HTTPD_LOG_PATH=/var/log/httpd
#### END PARTIAL COPY FROM registry.access.redhat.com/rhel8/httpd-24

RUN sed -e "s,Listen 80,Listen 8080," \
        -e "s,logs/error_log,/dev/stderr," \
        -e "s,logs/access_log,/dev/stdout," \
        -e "s,AllowOverride None,AllowOverride All," \
        -i /etc/httpd/conf/httpd.conf && \
    # the htpasswd file may be periodically replaced during run
    chmod a+rwX  /etc/httpd/conf /run/httpd && \
    # generate missing self-signed cert
    for i in {1..7}; do echo "" >> /tmp/dots; done && \
    cat /tmp/dots | openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/pki/tls/private/localhost.key -out /etc/ssl/certs/localhost.crt

EXPOSE 80

STOPSIGNAL SIGWINCH

ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]