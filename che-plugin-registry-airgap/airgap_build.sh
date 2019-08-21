#!/bin/bash
sed -i Dockerfile -e "s%#.*RUN ./fetch_resources.sh%RUN ./fetch_resources.sh%"
if [[ $1 ]]; then
	sed -i Dockerfile -e "s%#.*RUN ./list_containers.sh v3%RUN ./list_containers.sh%"
	sed -i Dockerfile -e "s%myquay.mycorp.com%${1}%"
fi
exit
now=`date +%Y%m%d-%H%M`
docker build . -t quay.io/nickboldt/airgap-che-plugin-registry:nightly --no-cache
docker tag quay.io/nickboldt/airgap-che-plugin-registry:{nightly,$now}
for d in nightly $now; do
	docker push quay.io/nickboldt/airgap-che-plugin-registry:${d} &
done
wait
