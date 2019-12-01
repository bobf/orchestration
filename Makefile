.PHONY: test
test:
	bundle exec rspec
	bundle exec rubocop
	bundle exec strong_versions

.PHONY: manifest
manifest:
	 git ls-files | GREP_OPTIONS='' grep -v '^spec' > MANIFEST
