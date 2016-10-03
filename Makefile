.PHONY: test

test:
	docker build -t pgmigrate .
	docker run -t pgmigrate
