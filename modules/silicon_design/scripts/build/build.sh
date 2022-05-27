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

PROJECT_ID=$1
ZONE=$2
COMPUTE_IMAGE=$3
CONTAINER_IMAGE=$4
IMAGE_TAG=$5
NOTEBOOKS_BUCKET=$6
COMPUTE_NETWORK=$7
COMPUTE_SUBNET=$8

gcloud config set project ${PROJECT_ID}
gcloud builds submit . --config ./scripts/build/cloudbuild.yaml --substitutions "_ZONE=${ZONE},_COMPUTE_IMAGE=${COMPUTE_IMAGE},_CONTAINER_IMAGE=${CONTAINER_IMAGE},_IMAGE_TAG=${IMAGE_TAG},_NOTEBOOKS_BUCKET=${NOTEBOOKS_BUCKET},_COMPUTE_NETWORK=${COMPUTE_NETWORK},_COMPUTE_SUBNET=${COMPUTE_SUBNET}"
