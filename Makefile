.PHONY: bundle
bundle:
  bundle _1.16.0_ install --path=.bundle/

.PHONY: test
test:
	bundle exec rspec
	bundle exec rubocop
	bundle exec strong_versions

.PHONY: manifest
manifest:
	 git ls-files | GREP_OPTIONS='' grep -v '^spec' > MANIFEST
	 git diff-index --quiet HEAD || (git add MANIFEST && git commit -m "Update manifest" || :)

.PHONY: release
release: manifest
	gem build orchestration.gemspec
