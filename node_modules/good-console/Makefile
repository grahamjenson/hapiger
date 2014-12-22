test:
	@node node_modules/lab/bin/lab -vLa code
test-cov:
	@node node_modules/lab/bin/lab -t 100 -vLa code
test-cov-html:
	@node node_modules/lab/bin/lab -r html -o coverage.html -La code

.PHONY: test test-cov test-cov-html