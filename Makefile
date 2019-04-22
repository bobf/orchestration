.PHONY: test
test:
	./bin/rspec
	./bin/rubocop
	./bin/strong_versions

.PHONY: readme
readme:
	markdown-toc -i README.md

.PHONY: build
build:
	git ls-files | sed '/^\(test\|spec\|features\)/d' > 'MANIFEST'
	git archive --format tar -o docker/.context.tar HEAD
	docker build -t rubyorchestration/toolkit docker/

.PHONY: push
push:
	docker push rubyorchestration/toolkit
