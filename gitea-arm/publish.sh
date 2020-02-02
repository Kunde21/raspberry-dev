#! /bin/bash

set -euo pipefail

if [[ -z "$1" ]] ; then
	echo "enter a release version to publish 'vx.x.x'";
	exit 1;
fi

semver=( ${1//./ } )
if [[ -z "${semver[0]}" || -z "${semver[1]}" || -z "${semver[2]}" ]] ; then
	echo "invalid semver %1";
	exit 1;
fi

declare -a VERS=("$1" "${1%.*}" "${1%%.*}")
if [[ ${2-} == "latest"  ]] ; then
	VERS+=("latest")
fi

if [ ${1#*-} != $1 ] ; then
	echo "publishing pre-release version $1";
	# exit 0;
	docker manifest create kunde21/gitea-arm:$1 kunde21/gitea-arm:{amd64,armv6,armv7,arm64}-$1; 
	docker manifest annotate kunde21/gitea-arm:$1 kunde21/gitea-arm:armv6-$1 --variant=6;
	docker manifest annotate kunde21/gitea-arm:$1 kunde21/gitea-arm:armv7-$1 --variant=7;
	docker manifest push -p kunde21/gitea-arm:$1;
	exit 0;
fi

declare -a VERS=("$1" "${1%.*}" "${1%%.*}")
if [[ ${2-} == "latest"  ]] ; then
	VERS+=("latest")
fi

for v in "${VERS[@]}" ; do
	echo "publishing release version $v";
	# exit 0;
	docker manifest create kunde21/gitea-arm:$v kunde21/gitea-arm:{amd64,armv6,armv7,arm64}-$1; 
	docker manifest annotate kunde21/gitea-arm:$v kunde21/gitea-arm:armv6-$1 --variant=6;
	docker manifest annotate kunde21/gitea-arm:$v kunde21/gitea-arm:armv7-$1 --variant=7;
	docker manifest push -p kunde21/gitea-arm:$v;
done
exit 0;
