#!/usr/bin/env bash
set -euo pipefail

# Unit tests
flutter test --timeout 60s

# Integration tests
#
# Requires a running simulator/emulator or an attached device.
# You can override the device via BOTANICA_DEVICE, e.g.:
#   BOTANICA_DEVICE="iPhone 16 Pro" scripts/test_integration.sh
flutter test integration_test/ --timeout 60s -d "${BOTANICA_DEVICE:-iPhone 16 Pro}"

