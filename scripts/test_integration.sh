#!/usr/bin/env bash
set -euo pipefail

# Unit tests
flutter test --timeout 60s

# Integration tests
#
# Requires a running simulator/emulator or an attached device.
#
# Device selection priority:
# 1) BOTANICA_DEVICE_ID (explicit)
# 2) BOTANICA_DEVICE (name or id prefix)
# 3) Auto-pick an available iOS simulator, otherwise Android emulator
#
# By default we only run a quick smoke test to keep runs fast and stable.
# Set BOTANICA_INTEGRATION_ALL=true to run the full `integration_test/` suite.

integration_test_target="${BOTANICA_INTEGRATION_TARGET:-integration_test/app_smoke_test.dart}"
integration_device="${BOTANICA_DEVICE_ID:-${BOTANICA_DEVICE:-}}"

if [[ -z "${integration_device}" ]]; then
  devices_json="$(flutter devices --machine)"
  integration_device="$(
    DEVICES_JSON="${devices_json}" python3 - 2>/dev/null <<'PY' || true
import json
import os
import sys

devices_json = os.environ.get("DEVICES_JSON", "[]")
devices = json.loads(devices_json)

def is_supported(d):
  return bool(d.get("isSupported"))

def target_platform(d):
  return str(d.get("targetPlatform") or "")

def pick(pred):
  for d in devices:
    if is_supported(d) and pred(d):
      return d.get("id")
  return None

order = [
  # Prefer an iOS simulator if available.
  lambda d: target_platform(d) == "ios" and bool(d.get("emulator")),
  # Otherwise, prefer an Android emulator.
  lambda d: target_platform(d).startswith("android") and bool(d.get("emulator")),
  # Fall back to any attached iOS device.
  lambda d: target_platform(d) == "ios",
  # Finally, fall back to any attached Android device.
  lambda d: target_platform(d).startswith("android"),
]

for pred in order:
  device_id = pick(pred)
  if device_id:
    print(device_id)
    sys.exit(0)

sys.exit(1)
PY
  )"
fi

if [[ -z "${integration_device}" ]]; then
  echo "No iOS/Android device found for integration tests."
  echo "Start a simulator/emulator, then re-run:"
  echo "  flutter emulators --launch apple_ios_simulator"
  echo ""
  echo "Detected devices:"
  flutter devices
  exit 1
fi

echo "Running integration tests on device: ${integration_device}"

if [[ "${BOTANICA_INTEGRATION_ALL:-false}" == "true" ]]; then
  flutter test integration_test/ --timeout 60s -d "${integration_device}"
else
  flutter test "${integration_test_target}" --timeout 60s -d "${integration_device}"
fi
