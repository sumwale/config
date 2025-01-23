#!/bin/sh

set -e

LIMIT=100
LEAD="$1"
if [ -z "$LEAD" ]; then
  echo "Usage: <script> <lead-host>:port [no of running jobs to search]"
  exit 1
fi
if [ -n "$2" ]; then
  LIMIT="$2"
fi

if [ -n "$SNAPPY_JOB_SCRIPT" ]; then
  if ! [ -x "$SNAPPY_JOB_SCRIPT" ]; then
    echo "SNAPPY_JOB_SCRIPT=$SNAPPY_JOB_SCRIPT does not exist or cannot be executed."
    exit 1
  fi
else
  if type snappy-job.sh 2>/dev/null >/dev/null; then
    SNAPPY_JOB_SCRIPT="snappy-job.sh"
  elif [ -x "./snappy-job.sh" ]; then
    SNAPPY_JOB_SCRIPT="./snappy-job.sh"
  else
    echo "snappy-job.sh should be in PATH or current directory or set in SNAPPY_JOB_SCRIPT environment variable."
    exit 1
  fi
fi

if ! type jq 2>/dev/null >/dev/null; then
  echo "This script needs jq command-line JSON processor to be installed."
  exit 1
fi

for streamContextId in `$SNAPPY_JOB_SCRIPT listcontexts --lead localhost:8090 2>/dev/null | jq -r '.[]' | grep 'snappyStreamingContext[0-9]'`; do
  echo Stopping streaming context $streamContextId
  $SNAPPY_JOB_SCRIPT stopcontext $streamContextId
done

for jobId in `curl -sS -X GET "http://$LEAD/jobs?limit=$LIMIT" | jq -r '.[] | select(.status=="RUNNING") | .jobId'`; do
  echo Stopping job $jobId
  $SNAPPY_JOB_SCRIPT stop --lead $LEAD --job-id $jobId
done
