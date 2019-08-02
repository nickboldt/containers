#
# Copyright (c) 2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
FROM registry.access.redhat.com/ubi8-minimal:8.0

# enable epel 7 content set to resolve jq as rpm
COPY content_sets_epel7.repo /etc/yum.repos.d/

# NOTE: if you can't install jq and pyyaml as rpms, you may need pip to compile them for you.
# Install these rpms to allow compilation: gcc automake make autoconf libtool platform-python-devel python3 python3-devel
RUN microdnf install -y bash gzip tar jq python3-six python3-pip && microdnf -y clean all && \
    \
    # install yq (depends on jq and pyyaml - if jq and pyyaml not already installed, this will try to compile it)
    /usr/bin/pip3.6 install --user yq && \
    # could be installed in /opt/app-root/src/.local/bin or /root/.local/bin
    if [[ -f /opt/app-root/src/.local/bin/yq ]]; then cp /opt/app-root/src/.local/bin/yq /usr/local/bin/; \
    elif [[ -f /root/.local/bin/yq ]]; then cp /root/.local/bin/yq /usr/local/bin/; fi && \
    chmod +x /usr/local/bin/yq && \
    ln -s /usr/bin/python3.6 /usr/bin/python

# for debugging only
# RUN microdnf install -y util-linux && whereis python pip jq yq && python --version && jq --version && yq --version
