#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="${1:-android/baselineprofile/build}"
THRESHOLD_MS="${2:-1800}"

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required to evaluate benchmark results." >&2
  exit 2
fi

if [[ ! "$THRESHOLD_MS" =~ ^[0-9]+$ ]]; then
  echo "ERROR: threshold must be an integer number of milliseconds, got '$THRESHOLD_MS'." >&2
  exit 2
fi

mapfile -t BENCH_FILES < <(find "$BUILD_DIR" -type f -name "benchmarkData.json" | sort)

if [[ "${#BENCH_FILES[@]}" -eq 0 ]]; then
  echo "ERROR: no benchmarkData.json files found under $BUILD_DIR" >&2
  exit 2
fi

LATEST_FILE="${BENCH_FILES[-1]}"
echo "Using benchmark report: $LATEST_FILE"

declare -a RAW_RESULTS
mapfile -t RAW_RESULTS < <(
  jq -r '
    .benchmarks[]?
    | select((.name // "") | test("measureColdStartup|Startup"; "i"))
    | .name as $name
    | .metrics as $metrics
    | [
        {key: "startupMs", value: ($metrics.startupMs.median // $metrics.startupMs.p50 // empty)},
        {key: "timeToInitialDisplayMs", value: ($metrics.timeToInitialDisplayMs.median // $metrics.timeToInitialDisplayMs.p50 // empty)},
        {key: "timeToFullDisplayMs", value: ($metrics.timeToFullDisplayMs.median // $metrics.timeToFullDisplayMs.p50 // empty)}
      ]
    | .[]
    | select(.value != null)
    | "\($name)|\(.key)|\(.value)"
  ' "$LATEST_FILE"
)

if [[ "${#RAW_RESULTS[@]}" -eq 0 ]]; then
  echo "ERROR: no startup metrics found in $LATEST_FILE" >&2
  exit 2
fi

echo "Startup metrics (median/p50):"
FAIL=0
MAX_VALUE=0
for row in "${RAW_RESULTS[@]}"; do
  IFS='|' read -r benchmark metric value <<< "$row"
  value_int=$(printf '%.0f' "$value")
  echo "- $benchmark :: $metric = ${value_int}ms (threshold ${THRESHOLD_MS}ms)"
  echo "STARTUP_METRIC|$benchmark|$metric|$value_int"
  if (( value_int > MAX_VALUE )); then
    MAX_VALUE=$value_int
  fi
  if (( value_int > THRESHOLD_MS )); then
    FAIL=1
  fi
done

RECOMMENDED_THRESHOLD=$(( (MAX_VALUE * 115 + 99) / 100 ))
echo "STARTUP_GATE_INPUT|threshold_ms|$THRESHOLD_MS"
echo "STARTUP_GATE_OBSERVED|max_ms|$MAX_VALUE"
echo "STARTUP_GATE_RECOMMENDED|threshold_ms|$RECOMMENDED_THRESHOLD"

if (( FAIL == 1 )); then
  echo "ERROR: startup threshold exceeded." >&2
  exit 1
fi

echo "Startup threshold gate passed."
