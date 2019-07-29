#
# Copyright (c) 2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
FROM registry.redhat.io/ubi8-minimal:8.0

# to get all the python deps pre-fetched so we can build in Brew:
# 1. 
#   mkdir -p /tmp/root-local && docker run -it -v /tmp/root-local/:/tmp/root-local/ quay.io/nickboldt/ubi8-yq
# 2. then in the container: 
#   cd ~/.local/ && cp -r bin/ lib/ /tmp/root-local/
# 3. then back on your own machine
#   cd /tmp/root-local && tar cvzf root-local.tgz lib/ bin/
# 4. then move that tarball into this folder so it can be added to future builds with COPY
# 5. then add it to dist-git so it's part of this repo
# TODO script the above

# built in Brew, use tarball in lookaside cache
# COPY root-local.tgz /tmp/root-local.tgz

RUN INSTALL_PKGS="gzip tar python3-devel platform-python-devel gcc automake make autoconf libtool" && \
    microdnf install -y dnf bash python3 ${INSTALL_PKGS} && \
    # microdnf install -y util-linux && whereis python pip && \
    \
    # if we copied the tarball above, we can use it here
    # mkdir -p /root/.local/ && tar xzf /tmp/root-local.tgz -C /root/.local/ && \
    \
    # compile & install yq (depends on jq)
    /usr/bin/pip3.6 install --user yq jq && \
    # remove packages we don't need anymore
    dnf remove -y python3-devel platform-python-devel gcc automake make autoconf libtool && microdnf remove -y dnf && \
    microdnf clean all && \
    cp /root/.local/bin/* /usr/local/bin/
