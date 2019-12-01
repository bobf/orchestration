.PHONY: test

test:
	./bin/rspec
	./bin/rubocop
	./bin/strong_versions

readme:
	markdown-toc -i README.md
