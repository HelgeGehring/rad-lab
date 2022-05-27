#!/bin/bash
#
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
trap "echo DaisyFailure: trapped error" ERR

env
OPENLANE_VERSION=master
PROVISION_DIR=/tmp/provision

echo "DaisyStatus: fetching provisioning script"
DAISY_SOURCES_PATH=$(curl -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/daisy-sources-path)
mkdir -p ${PROVISION_DIR}
gsutil -m rsync ${DAISY_SOURCES_PATH}/provision/ ${PROVISION_DIR}/ || true

echo "DaisyStatus: installing conda-eda environment"
/opt/conda/bin/conda install --yes --prefix /opt/conda/ mamba
/opt/conda/bin/mamba env update --yes --update-all --prefix /opt/conda/ --file ${PROVISION_DIR}/environment.yml

echo "DaisyStatus: installing OpenLane"
git clone --depth 1 -b ${OPENLANE_VERSION} https://github.com/The-OpenROAD-Project/OpenLane /OpenLane

echo "DaisyStatus: patching OpenLane"
mkdir -p /OpenLane/install/build/versions
cp ${PROVISION_DIR}/env.tcl /OpenLane/install/
for tool in yosys netgen
do
  /opt/conda/bin/conda list -c ${tool} > /OpenLane/install/build/versions/${tool}
done
# https://github.com/The-OpenROAD-Project/OpenLane/pull/1027
curl --silent  https://patch-diff.githubusercontent.com/raw/The-OpenROAD-Project/OpenLane/pull/1027.patch | patch -d /OpenLane -p1

echo "DaisyStatus: adding profile hook"
cp ${PROVISION_DIR}/profile.sh /etc/profile.d/silicon-design-profile.sh

echo "DaisyStatus: adding papermill launcher"
cp ${PROVISION_DIR}/papermill-launcher /usr/local/bin/
chmod +x /usr/local/bin/papermill-launcher

echo "DaisySuccess: done"

