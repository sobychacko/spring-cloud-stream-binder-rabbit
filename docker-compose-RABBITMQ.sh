#!/bin/bash

SYSTEM_PROPS="-DRABBIT_HOST=${HEALTH_HOST} -Dspring.rabbitmq.port=9672"

dockerComposeFile="docker-compose-${WHAT_TO_TEST}.yml"
docker-compose -f $dockerComposeFile kill
docker-compose -f $dockerComposeFile build

if [[ "${SHOULD_START_RABBIT}" == "yes" ]] ; then
    echo -e "\n\nBooting up RabbitMQ"
    docker-compose -f $dockerComposeFile up -d rabbitmq
fi

READY_FOR_TESTS="no"
PORT_TO_CHECK=9672
echo "Waiting for RabbitMQ to boot for [$(( WAIT_TIME * RETRIES ))] seconds"
netcat_port $PORT_TO_CHECK && READY_FOR_TESTS="yes"

if [[ "${READY_FOR_TESTS}" == "no" ]] ; then
    echo "RabbitMQ failed to start..."
    exit 1
fi