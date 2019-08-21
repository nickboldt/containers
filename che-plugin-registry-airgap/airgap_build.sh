#!/bin/bash
sed -i Dockerfile -e "s%#.*RUN ./fetch_resources.sh%RUN ./fetch_resources.sh%"
if [[ $1 ]]; then
	sed -i Dockerfile -e "s%#.*RUN ./list_containers.sh%RUN ./list_containers.sh%"
	sed -i Dockerfile -e "s%myquay.mycorp.com%${1}%"
	nightly="${1%%.*}" # first section of the URL replacement
	now="${nightly}-`date +%Y%m%d-%H%M`" # append timestamp
else
	nightly="nightly"
	now=`date +%Y%m%d-%H%M`
fi

now=`date +%Y%m%d-%H%M`
docker build . -t quay.io/nickboldt/airgap-che-plugin-registry:${nightly} --no-cache
docker tag quay.io/nickboldt/airgap-che-plugin-registry:{${nightly},${now}}
for d in ${nightly} ${now}; do
	docker push quay.io/nickboldt/airgap-che-plugin-registry:${d} &
done
wait
