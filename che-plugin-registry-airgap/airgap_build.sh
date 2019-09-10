#!/bin/bash
#
# Builds this container, including locally fetched plugins and replaces references to docker/quay/RHCC with specified container registry

sed -i Dockerfile -e "s%#.*RUN ./fetch_resources.sh%RUN ./fetch_resources.sh%"
if [[ $1 == "nightly" ]]; then
	nightly="nightly"
	now=`date +%Y%m%d-%H%M`
elif [[ $1 ]]; then
	sed -i Dockerfile -e "s%#.*RUN ./list_containers.sh%RUN ./list_containers.sh%"
	sed -i Dockerfile -e "s%myquay.mycorp.com%${1}%"
	nightly="${1%%.*}" # first section of the URL replacement
	now="${nightly}-`date +%Y%m%d-%H%M`" # append timestamp
else
	echo "Must specify URL of internal registry to use, eg., $0 myquay.mycorp.com"
	echo "To do no substitutions & not fetch plugins, use $0 nightly"
	exit 1
fi

now=`date +%Y%m%d-%H%M`
docker build . -t quay.io/nickboldt/airgap-che-plugin-registry:${nightly} --no-cache --squash
docker tag quay.io/nickboldt/airgap-che-plugin-registry:{${nightly},${now}}
for d in ${nightly} ${now}; do
	docker push quay.io/nickboldt/airgap-che-plugin-registry:${d} &
done
wait
