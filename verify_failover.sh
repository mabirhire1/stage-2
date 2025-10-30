#!/bin/bash
set -euo pipefail

NGINX_URL="http://localhost:8080/version"
BLUE_CHAOS_URL="http://localhost:8081/chaos/start?mode=error"
BLUE_CHAOS_STOP="http://localhost:8081/chaos/stop"
SAMPLE_COUNT=50        # number of attempts to measure in ~10s
SLEEP_BETWEEN=0.18     # ~0.18 * 50 ≈ 9s
TIMEOUT_CURL=9         # each curl allowed at most 9s

echo "Waiting for services to be up..."
# simple waiting loop for health
for i in {1..30}; do
  if curl -s --max-time 2 http://localhost:8081/healthz >/dev/null && curl -s --max-time 2 http://localhost:8082/healthz >/dev/null ; then
    echo "Both apps healthy"
    break
  fi
  sleep 1
done

echo "Baseline: ensure responses are from active pool (expected: ${ACTIVE_POOL:-blue})"
# baseline check - 10 requests
for i in {1..10}; do
  resp_headers=$(curl -s -D - --max-time $TIMEOUT_CURL -o /dev/null "$NGINX_URL" || true)
  status=$(echo "$resp_headers" | head -n 1 | awk '{print $2}')
  pool=$(echo "$resp_headers" | grep -i '^X-App-Pool:' | awk '{print $2}' | tr -d '\r' || true)
  rel=$(echo "$resp_headers" | grep -i '^X-Release-Id:' | awk '{print $2}' | tr -d '\r' || true)
  if [ "$status" != "200" ]; then
    echo "Baseline failed: got status $status"
    exit 1
  fi
  echo "OK baseline: status=200 pool=$pool release=$rel"
done

echo "Triggering chaos on Blue..."
curl -s -X POST --max-time 5 "$BLUE_CHAOS_URL" || true

echo "Collecting $SAMPLE_COUNT responses within ~10s after inducing chaos..."
count=0
non200=0
green_count=0
for i in $(seq 1 $SAMPLE_COUNT); do
  # capture headers
  headers=$(curl -s -D - --max-time $TIMEOUT_CURL -o /dev/null "$NGINX_URL" || true)
  status=$(echo "$headers" | head -n 1 | awk '{print $2}')
  pool=$(echo "$headers" | grep -i '^X-App-Pool:' | awk '{print $2}' | tr -d '\r' || true)
  if [ "$status" != "200" ]; then
    non200=$((non200+1))
  else
    if [ "$pool" = "green" ]; then
      green_count=$((green_count+1))
    fi
  fi
  count=$((count+1))
  sleep $SLEEP_BETWEEN
done

echo "Stopping chaos on Blue..."
curl -s -X POST --max-time 5 "$BLUE_CHAOS_STOP" || true

echo "Results: total=$count non200=$non200 green_count=$green_count"
if [ "$non200" -ne 0 ]; then
  echo "FAIL: saw $non200 non-200 responses after inducing chaos"
  exit 1
fi

percent_green=$(( 100 * green_count / count ))
echo "Percent responses from green = ${percent_green}%"
if [ "$percent_green" -lt 95 ]; then
  echo "FAIL: percent green $percent_green% < 95%"
  exit 1
fi

echo "PASS: failover successful; all responses 200 and >=95% from green."
exit 0
