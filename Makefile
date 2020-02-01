.PHONY: test
test:
	bundle exec rspec
	bundle exec rubocop
	bundle exec strong_versions

.PHONY: manifest
manifest:
	 git ls-files | GREP_OPTIONS='' grep -v '^spec' > MANIFEST

.PHONY: release
release: manifest
	git diff-index --quiet HEAD || (git add MANIFEST && git commit -m "Update manifest" || :)
	gem build orchestration.gemspec
