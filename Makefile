.PHONY: *

GIT_TAG      := $(shell git tag -l | tail -n1)
DOCKER_IMAGE  = sos-rs-backend
DOCKER_REPO   = 923013710130.dkr.ecr.sa-east-1.amazonaws.com/sos-rs-freetier-backend

install:
	@npm install

prisma:
	@npx prisma generate 
	@npx run migrations:dev 

setup:
	@$(MAKE) install
	@$(MAKE) prisma

start:
	@$(MAKE) setup
	@npm run start:dev

dev-up:
	@docker compose -f docker-compose.dev.yml up -d --build 

dev-down:
	@docker compose -f docker-compose.dev.yml down

dev-logs:
	@docker compose -f docker-compose.dev.yml logs -f

dev-db-load-dump:
	@docker compose -f docker-compose.dev.yml cp prisma/dev_dump.sql db:/tmp/backup.sql
	@docker compose -f docker-compose.dev.yml exec db psql -U root -d sos_rs -f /tmp/backup.sql
