#!/bin/sh

# Creates a new task definition based of the latest active one. Deregisters
# the latest on success
#
# Required variables:
#   TaskFamily
#   ContainerName
#   NewTag

set -e

TASK_DEFINITION_JSON=`aws ecs describe-task-definition --task-definition $TaskFamily --region eu-west-2`
TASK_DEFINITION_ARN=`echo "${TASK_DEFINITION_JSON}" | jq --raw-output '.taskDefinition.taskDefinitionArn'`

IMAGE=`echo "${TASK_DEFINITION_JSON}" | jq --raw-output '.taskDefinition.containerDefinitions[] | select(.name=="'${ContainerName}'").image'`
IMAGE_BASE=`echo $IMAGE | sed -E 's/(.*):(.*)/\1/'`

NEW_TASK_DEFINITION_JSON=`echo $TASK_DEFINITION_JSON | jq '(.taskDefinition.containerDefinitions[] | select(.name=="'${ContainerName}'")).image |= "'${IMAGE_BASE}':'${NewTag}'"'`

CONTAINER_DEFINTIONS=`echo $NEW_TASK_DEFINITION_JSON | jq '.taskDefinition.containerDefinitions'`
EXECUTION_ROLE_ARN=`echo $NEW_TASK_DEFINITION_JSON | jq --raw-output '.taskDefinition.executionRoleArn'`
CPU=`echo $NEW_TASK_DEFINITION_JSON | jq --raw-output '.taskDefinition.cpu'`
MEMORY=`echo $NEW_TASK_DEFINITION_JSON | jq --raw-output '.taskDefinition.memory'`
NETWORK_MODE=`echo $NEW_TASK_DEFINITION_JSON | jq --raw-output '.taskDefinition.networkMode'`
REQUIRES_COMPATIBILITIES=`echo $NEW_TASK_DEFINITION_JSON | jq '.taskDefinition.requiresCompatibilities'`
VOLUMES=`echo $NEW_TASK_DEFINITION_JSON | jq '.taskDefinition.volumes'`

aws ecs register-task-definition \
	--family $TaskFamily \
	--region eu-west-2 \
	--container-definitions "${CONTAINER_DEFINTIONS}" \
	--execution-role-arn "${EXECUTION_ROLE_ARN}" \
	--cpu "${CPU}" \
	--memory "${MEMORY}" \
	--network-mode "${NETWORK_MODE}" \
	--requires-compatibilities "${REQUIRES_COMPATIBILITIES}" \
	--volumes "${VOLUMES}"

# We don't deregister the old task defintion, so Terraform still sees
# the old one and doesn't try to recreate
