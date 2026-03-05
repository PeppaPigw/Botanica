.PHONY: test test-integration

test:
	flutter test --timeout 60s

test-integration:
	bash scripts/test_integration.sh

