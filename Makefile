.PHONY: test
test:
	./bin/rspec
	./bin/rubocop
	./bin/strong_versions

.PHONY: manifest
manifest:
	 git ls-files | GREP_OPTIONS='' grep -v '^spec' > MANIFEST
