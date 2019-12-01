.PHONY: test

test:
	./bin/rspec
	./bin/rubocop
	./bin/strong_versions
