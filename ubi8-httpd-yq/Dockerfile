# Copyright (c) 2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#

# https://access.redhat.com/containers/?tab=tags#/registry.access.redhat.com/ubi8-minimal
FROM registry.access.redhat.com/ubi8-minimal:8.0

USER root

# enable epel 7 content set to resolve jq as rpm
COPY content_sets_epel7.repo /etc/yum.repos.d/

RUN microdnf install -y bash yum gzip tar findutils jq python3-six python3-pip && microdnf -y clean all && \
    # install yq (depends on jq and pyyaml - if jq and pyyaml not already installed, this will try to compile it)
    /usr/bin/pip3.6 install --user yq && \
    # could be installed in /opt/app-root/src/.local/bin or /root/.local/bin
    for d in /opt/app-root/src/.local /root/.local; do \
      if [[ -d ${d} ]]; then \
        cp ${d}/bin/yq /usr/local/bin/; \
        pushd ${d}/lib/python3.6/site-packages/ >/dev/null; \
          cp -r PyYAML* xmltodict* yaml* yq* /usr/lib/python3.6/site-packages/; \
        popd >/dev/null; \
      fi; \
    done && \
    chmod +x /usr/local/bin/yq && \
    ln -s /usr/bin/python3.6 /usr/bin/python

# for debugging only
# RUN microdnf install -y util-linux && whereis python pip jq yq && python --version && jq --version && yq --version

#### BEGIN PARTIAL COPY FROM https://access.redhat.com/containers/?architecture=AMD64&tab=docker-file#/registry.access.redhat.com/rhel8/httpd-24/images/1-42
ENV HTTPD_VERSION=2.4

EXPOSE 8080
EXPOSE 8443

RUN yum -y module enable httpd:$HTTPD_VERSION && \
    # TODO: can't find mod_auth_mellon -- do we need it?
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

# finish setting up httpd
RUN adduser --gid 0 jboss && mkdir -p /home/jboss /data /logs && \
    chown -c jboss:root /home/jboss && chmod -c 0775 /home/jboss && \
    chgrp -c -R 0     /home/jboss /data /logs && \
    chmod -c -R g+rwX /home/jboss /data /logs && \
    chmod -c -R a+rwX  /etc/httpd/conf /run/httpd /var/log/httpd && \
    chmod -c 666 /etc/passwd && \
    microdnf remove -y yum && microdnf -y clean all && \
    sed -e "s,80,8080," \
        -e "s,logs/error_log,/dev/stderr," \
        -e "s,logs/access_log,/dev/stdout," \
        -e "s,AllowOverride None,AllowOverride All," \
        -i /etc/httpd/conf/httpd.conf && \
    sed -e "s,443,8443," -i /etc/httpd/conf.d/ssl.conf && \
    # generate missing self-signed cert
    for i in {1..7}; do echo "" >> /tmp/dots; done && \
    cat /tmp/dots | openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/pki/tls/private/localhost.key -out /etc/ssl/certs/localhost.crt && \
    chmod -c g+rwX /etc/pki/tls/private/localhost.key && \
    rm -f /tmp/dots

# do we need these 2 ports?
EXPOSE 80
EXPOSE 443

STOPSIGNAL SIGWINCH

ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]
