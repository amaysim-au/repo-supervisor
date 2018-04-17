VERSION = 1.1.4
IMAGE_NAME ?= amaysim/repo-supervisor:$(VERSION)
TAG = $(VERSION)

ifdef AWS_ROLE
	ASSUME_REQUIRED?=assumeRole
endif
ifdef DOTENV
	DOTENV_TARGET=dotenv
else
	DOTENV_TARGET=.env
endif

deploy: $(DOTENV_TARGET) $(ASSUME_REQUIRED)
	docker-compose down
	docker-compose run --rm ecs make -f /scripts/Makefile deploy
	docker-compose down

cutover: $(DOTENV_TARGET) $(ASSUME_REQUIRED)
	docker-compose down
	docker-compose run --rm ecs make -f /scripts/Makefile cutover
	docker-compose down

cleanup: $(DOTENV_TARGET) $(ASSUME_REQUIRED)
	docker-compose down
	docker-compose run --rm ecs make -f /scripts/Makefile cleanup
	docker-compose down

gitTag:
	-git tag -d $(TAG)
	-git push origin :refs/tags/$(TAG)
	git tag $(TAG)
	git push origin $(TAG)

.env:
	@echo "Create .env with .env.template"
	cp .env.template .env
	echo "" >> .env
	echo "BUILD_VERSION=$(VERSION)" >> .env

# Create/Overwrite .env with $(DOTENV)
dotenv:
	@echo "Overwrite .env with $(DOTENV)"
	cp $(DOTENV) .env
	echo "BUILD_VERSION=$(VERSION)" >> .env
