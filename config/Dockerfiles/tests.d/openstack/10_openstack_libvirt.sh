#!/bin/bash

# Verify the libvirt inside openstack provisioning
# distros.exclude: fedora29 fedora30 
# providers.include: openstack
# providers.exclude: none

DISTRO=${1}
PROVIDER=${2}

TARGET="libvirt-server"
TEMPLATE_DATA="{\"distro\": \"distro-\"}"
TMP_FILE=$(mktemp)

function clean_up {
    set +e
    linchpin -w . -p "${PINFILE}" --template-data "${TEMPLATE_DATA}" -v destroy "${TARGET}"
}
trap clean_up EXIT SIGHUP SIGINT SIGTERM

echo "${TMP_FILE}"

echo "compressing linchpin folder"
tar -czf /tmp/linchpin.tar.gz .

pushd docs/source/examples/workspaces/openstack-libvirt/
linchpin -w . --creds-path ./credentials/ --template-data "${TEMPLATE_DATA}" --output-pinfile "${TMP_FILE}" -v up "${TARGET}"


IP_ADDR=$(grep -Po '"public_v4":.*?[^\\]",' resources/linchpin.latest |  grep -E -o -m1 "([0-9]{1,3}[\.]){3}[0-9]{1,3}")

echo "IP ADDR is ${IP_ADDR}"

popd 

pushd docs/source/examples/workspaces/${PROVIDER}
