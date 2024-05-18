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

start-debug:
	@$(MAKE) setup
	@npm run start:debug

build:
	@npm run build

clean:
	@rm -rf dist

format:
	@npm run format

lint:
	@npm run lint

test:
	@npm run test

test-coverage:
	@npm run test:cov

test-debug:
	@npm run test:debug

test-e2e:
	@npm run test:e2e

dev-up:
	@docker compose -f docker-compose.dev.yml up -d --build 

dev-down:
	@docker compose -f docker-compose.dev.yml down

dev-logs:
	@docker compose -f docker-compose.dev.yml logs -f

dev-db-load-dump:
	@docker compose -f docker-compose.dev.yml cp prisma/dev_dump.sql db:/tmp/backup.sql
	@docker compose -f docker-compose.dev.yml exec db psql -U root -d sos_rs -f /tmp/backup.sql

# Para ser usado no workflow de build
docker-build:
	@docker build . -t $(DOCKER_IMAGE)

docker-tag:
	@docker tag $(DOCKER_IMAGE) $(DOCKER_REPO):$(GIT_TAG)

docker-push:
	@aws ecr get-login-password --region sa-east-1 | docker login --username AWS --password-stdin $(DOCKER_REPO)
	@docker push $(DOCKER_REPO):$(GIT_TAG)

# Para ser usado no workflow de deploy
prod-up:
	@docker compose -f docker-compose.yml up -d --build --force-recreate

prod-down:
	@docker compose -f docker-compose.yml down --rmi all

