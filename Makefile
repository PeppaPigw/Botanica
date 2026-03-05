.PHONY: test test-integration

test:
\tflutter test --timeout 60s

test-integration:
\tbash scripts/test_integration.sh

