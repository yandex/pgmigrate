TOX                     := tox


.PHONY: test
test:
	docker build -t pgmigrate .
	docker run -t pgmigrate

.PHONY: lint
lint:
	$(TOX) -e yapf -e flake8 -e pylint
