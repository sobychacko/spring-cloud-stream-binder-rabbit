#!/bin/bash

#SYSTEM_PROPS="-DRABBIT_HOST=${HEALTH_HOST} -Dspring.rabbitmq.port=9672"


function netcat_port() {
    local PASSED_HOST="${2:-$HEALTH_HOST}"
    local READY_FOR_TESTS=1
    for i in $( seq 1 "${RETRIES}" ); do
        sleep "${WAIT_TIME}"
        nc -v -w 1 ${PASSED_HOST} $1 && READY_FOR_TESTS=0 && break
        echo "Fail #$i/${RETRIES}... will try again in [${WAIT_TIME}] seconds"
    done
    return ${READY_FOR_TESTS}
}

export -f netcat_port
SHOULD_START_RABBIT="${SHOULD_START_RABBIT:-yes}"

dockerComposeFile="docker-compose-RABBITMQ.yml"
docker-compose -f $dockerComposeFile kill
docker-compose -f $dockerComposeFile build

if [[ "${SHOULD_START_RABBIT}" == "yes" ]] ; then
    echo -e "\n\nBooting up RabbitMQ"
    docker-compose -f $dockerComposeFile up -d rabbitmq
fi

READY_FOR_TESTS="no"
PORT_TO_CHECK=5672

HEALTH_HOST="${HEALTH_HOST:-localhost}"
WAIT_TIME="${WAIT_TIME:-5}"
RETRIES="${RETRIES:-70}"

echo "Waiting for RabbitMQ to boot for [$(( WAIT_TIME * RETRIES ))] seconds"
netcat_port $PORT_TO_CHECK && READY_FOR_TESTS="yes"

if [[ "${READY_FOR_TESTS}" == "no" ]] ; then
    echo "RabbitMQ failed to start..."
    exit 1
fi

