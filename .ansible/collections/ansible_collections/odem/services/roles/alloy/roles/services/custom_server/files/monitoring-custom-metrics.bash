#!/bin/bash
#set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CUSTOM_METRICS_SCRAPE_INTERVAL=1
CONFIG_FILE="${CUSTOM_METRICS_CONFIG_FILE:-/etc/alloy/custom-metrics.json}"
PORT="${CUSTOM_METRICS_PORT:-25000}"
WEB_DIR=/run/custom_metrics
RUNTIME_FILE="$WEB_DIR/metrics"
source "${SCRIPT_DIR}/.env" || source /etc/default/custom-metrics

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[ERROR] Config file $CONFIG_FILE not found" >&2; exit 1
fi
if [[ ! $(id -u) -eq 0 ]]; then
    echo "[ERROR] Must be run as root"
    exit 1
fi

mkdir "$WEB_DIR"
python3 -m http.server "$PORT" --directory "$WEB_DIR" &

echo "[INFO] Running jq..."
jq -e '.[] | (.name, .help, .type, .command)' "$CONFIG_FILE" >/dev/null || {
    echo "[ERROR] Invalid config format in $CONFIG_FILE" >&2; exit 1
}

# trap 'kill 0 2>/dev/null; exit' EXIT
collect() {
    echo "[INFO] Looping collect()"
    rm -rf "${RUNTIME_FILE}".tmp
    jq -c '.[]' "$CONFIG_FILE" | while read -r block; do
        local name help type command value
        name=$(jq -r '.name' <<< "$block")
        help=$(jq -r '.help' <<< "$block")
        type=$(jq -r '.type' <<< "$block")
        command=$(jq -r '.command' <<< "$block")
        value=$(eval "$command" 2>/dev/null | head -1) \
            || { echo "[WARN] Command failed: $command" >&2; continue; }
        [[ -z "$value" ]] && continue
        {
            echo "# HELP $name $help"
            echo "# TYPE $name $type"
            echo "$name $value"
            echo ""
        } >> "$RUNTIME_FILE".tmp
    done
    if [[ ! -s "$RUNTIME_FILE" ]]; then
        echo "# No metrics collected" > "$RUNTIME_FILE"
    fi
    mv "${RUNTIME_FILE}".tmp "${RUNTIME_FILE}"
}

while true; do 
    collect
    sleep "$CUSTOM_METRICS_SCRAPE_INTERVAL"
done
