.PHONY: test

test:
	docker-compose build
	docker-compose run --rm pgmigrate
	docker-compose stop

