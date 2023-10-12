#!/bin/bash

url="${WEB_HEALTHCHECK_PROTOCOL:-http}://${WEB_HOST:-localhost}:${WEB_PORT:-8080}${WEB_HEALTHCHECK_PATH:-/healthcheck}"
curl_options="--max-time ${WEB_HEALTHCHECK_READ_TIMEOUT:-10} --connect-timeout ${WEB_HEALTHCHECK_OPEN_TIMEOUT:-10} --silent --output /dev/null --write-out %{http_code}"
status_code="$(curl ${curl_options} "${url}")"

echo "Status Code: ${status_code} (${url})"

if [[ "${WEB_HEALTHCHECK_SUCCESS_CODES:-200,201,202,204}" =~ (^|,)"${status_code}"(,|$) ]]
then
  echo 'Healthcheck SUCCESS'
  exit 0
else
  echo 'Healthcheck FAILURE'
  exit 1
fi
