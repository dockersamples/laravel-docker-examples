#!/usr/bin/env bash

waitForDocker () {
    # wait until we see the required logs
    WAIT_LOG=$1

    MAX_ATTEMPTS=150
    ATTEMPTS=0
    while [ $ATTEMPTS -le $MAX_ATTEMPTS ]; do
        ATTEMPTS=$(( ATTEMPTS + 1 ))

        echo "Waiting for container log FRASE $WAIT_LOG - (attempt: $ATTEMPTS)..."
        DOCKER_LOGS=$(docker compose -f compose.dev.yaml logs )
        if grep -q "$WAIT_LOG" <<< "$DOCKER_LOGS" ; then
          echo "Containers are Ready!"
          break
        else
          echo "Containers NOT Ready!"
        fi
        sleep 2
    done

    # https://github.com/koalaman/shellcheck/wiki/SC2181
    if ! grep -q "$WAIT_LOG" <<< "$DOCKER_LOGS" ; then
      echo "Containers are not ready, tests will not run!"
      exit 1
    fi
}

waitForDocker "$@"
