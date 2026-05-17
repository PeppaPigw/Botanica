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
devices_json="$(flutter devices --machine)"
integration_device_id="${BOTANICA_DEVICE_ID:-}"
integration_device_query="${BOTANICA_DEVICE:-}"

set +e
integration_device="$(
  DEVICES_JSON="${devices_json}" \
  BOTANICA_DEVICE_ID="${integration_device_id}" \
  BOTANICA_DEVICE="${integration_device_query}" \
  python3 - <<'PY'
import json
import os
import sys

devices_json = os.environ.get("DEVICES_JSON", "[]")
requested_id = os.environ.get("BOTANICA_DEVICE_ID", "").strip()
requested_query = os.environ.get("BOTANICA_DEVICE", "").strip()

try:
  devices = json.loads(devices_json)
except json.JSONDecodeError as exc:
  print(f"ERROR: failed to parse `flutter devices --machine` output: {exc}", file=sys.stderr)
  sys.exit(2)

def is_supported(d):
  return bool(d.get("isSupported"))

def target_platform(d):
  return str(d.get("targetPlatform") or "")

def is_mobile(d):
  platform = target_platform(d)
  return platform == "ios" or platform.startswith("android")

supported = [d for d in devices if is_supported(d) and is_mobile(d)]

def fmt(d):
  kind = "emulator" if d.get("emulator") else "device"
  return f"{d.get('name')} • {d.get('id')} • {target_platform(d)} • {kind}"

def print_supported():
  if not supported:
    return
  print("Detected supported devices:", file=sys.stderr)
  for d in supported:
    print(f"- {fmt(d)}", file=sys.stderr)

if requested_id:
  if any(str(d.get("id") or "") == requested_id for d in supported):
    print(requested_id)
    sys.exit(0)

  print(f"ERROR: BOTANICA_DEVICE_ID='{requested_id}' not found.", file=sys.stderr)
  print_supported()
  sys.exit(1)

if requested_query:
  q = requested_query.lower()

  matches = []
  for d in supported:
    did = str(d.get("id") or "")
    name = str(d.get("name") or "")
    if did == requested_query or did.startswith(requested_query):
      matches.append(d)
      continue
    if q in name.lower():
      matches.append(d)

  # De-duplicate by id.
  unique = []
  seen = set()
  for d in matches:
    did = d.get("id")
    if did and did not in seen:
      seen.add(did)
      unique.append(d)
  matches = unique

  if len(matches) == 1:
    print(matches[0].get("id"))
    sys.exit(0)

  if len(matches) == 0:
    print(f"ERROR: BOTANICA_DEVICE='{requested_query}' did not match any supported device.", file=sys.stderr)
  else:
    print(f"ERROR: BOTANICA_DEVICE='{requested_query}' is ambiguous (matched {len(matches)} devices).", file=sys.stderr)

  print_supported()
  sys.exit(1)

def pick(pred):
  for d in supported:
    if pred(d):
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
  picked_id = pick(pred)
  if picked_id:
    print(picked_id)
    sys.exit(0)

sys.exit(1)
PY
)"
integration_device_exit=$?
set -e

if [[ $integration_device_exit -ne 0 ]]; then
  if [[ -n "${integration_device_id}" || -n "${integration_device_query}" ]]; then
    exit "${integration_device_exit}"
  fi
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
