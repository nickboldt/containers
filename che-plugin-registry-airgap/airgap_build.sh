#!/bin/bash
sed -i Dockerfile -e "s%# RUN ./fetch_resources.sh%RUN ./fetch_resources.sh%"
now=`date +%Y%m%d-%H%M`
docker build . -t quay.io/nickboldt/airgap-che-plugin-registry:nightly --no-cache
docker tag quay.io/nickboldt/airgap-che-plugin-registry:{nightly,$now}
for d in nightly $now; do
	docker push quay.io/nickboldt/airgap-che-plugin-registry:${d} &
done
wait
