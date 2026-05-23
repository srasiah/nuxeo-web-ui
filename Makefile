.PHONY: help install clean build test ftest lint format start docker-build docker-up docker-down mvn-install mvn-clean mvn-test prepare

# Default target
.DEFAULT_GOAL := help

# Variables
NODE_VERSION := $(shell node --version 2>/dev/null)
NPM := npm
MVN := mvn
DOCKER_COMPOSE := docker-compose

# Help target
help: ## Show this help message
	@echo "Nuxeo Web UI - Makefile Commands"
	@echo "================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Installation targets
install: ## Install npm dependencies
	@echo "Installing npm dependencies..."
	$(NPM) install

check-node: ## Check if Node.js is installed and version is correct
	@echo "Checking Node.js version..."
ifdef NODE_VERSION
	@echo "Node.js version: $(NODE_VERSION)"
else
	@echo "Error: Node.js is not installed"
	@exit 1
endif

# Development targets
start: ## Start development server
	@echo "Starting development server..."
	$(NPM) run start

start-build: ## Start HTTP server with built files
	@echo "Starting HTTP server with built files..."
	$(NPM) run start:build

# Build targets
prepare: ## Prepare build environment (i18n, workbox, etc.)
	@echo "Preparing build environment..."
	$(NPM) run prepare:i18n
	$(NPM) run prepare:workbox

build: ## Build the project for production
	@echo "Building project..."
	$(NPM) run build

build-analyze: ## Build and analyze bundle size
	@echo "Building and analyzing bundle..."
	$(NPM) run build:analyze

# Testing targets
test: ## Run unit tests
	@echo "Running unit tests..."
	$(NPM) run test

ftest: ## Run functional tests
	@echo "Running functional tests..."
	$(NPM) run ftest

# Code quality targets
lint: ## Run linting (ESLint + Prettier)
	@echo "Running linters..."
	$(NPM) run lint

lint-eslint: ## Run ESLint only
	@echo "Running ESLint..."
	$(NPM) run lint:eslint

lint-prettier: ## Run Prettier check only
	@echo "Running Prettier check..."
	$(NPM) run lint:prettier

format: ## Format code with Prettier and ESLint
	@echo "Formatting code..."
	$(NPM) run format

format-eslint: ## Format code with ESLint
	@echo "Formatting with ESLint..."
	$(NPM) run format:eslint

format-prettier: ## Format code with Prettier
	@echo "Formatting with Prettier..."
	$(NPM) run format:prettier

# Clean targets
clean: ## Clean build artifacts and node_modules
	@echo "Cleaning build artifacts..."
	rm -rf dist/
	rm -rf .tmp/
	rm -rf node_modules/
	rm -rf target/

clean-dist: ## Clean dist directory only
	@echo "Cleaning dist directory..."
	rm -rf dist/

clean-tmp: ## Clean temporary directory only
	@echo "Cleaning temporary directory..."
	rm -rf .tmp/

# Maven targets
mvn-clean: ## Clean Maven build
	@echo "Running Maven clean..."
	$(MVN) clean

mvn-install: ## Build marketplace package with Maven
	@echo "Building marketplace package..."
	$(MVN) clean install

mvn-install-ftest: ## Build marketplace package with functional tests
	@echo "Building marketplace package with functional tests..."
	$(MVN) clean install -Pftest

mvn-install-skip: ## Build marketplace package (skip tests)
	@echo "Building marketplace package (skipping tests)..."
	$(MVN) clean install -DskipTests

# Docker targets
docker-build: ## Build Docker image
	@echo "Building Docker image..."
	$(DOCKER_COMPOSE) build

docker-up: ## Start Docker Compose services
	@echo "Starting Docker Compose services..."
	$(DOCKER_COMPOSE) up

docker-up-build: ## Build and start Docker Compose services
	@echo "Building and starting Docker Compose services..."
	$(DOCKER_COMPOSE) up --build

docker-up-detached: ## Start Docker Compose services in detached mode
	@echo "Starting Docker Compose services (detached)..."
	$(DOCKER_COMPOSE) up -d

docker-down: ## Stop Docker Compose services
	@echo "Stopping Docker Compose services..."
	$(DOCKER_COMPOSE) down

docker-logs: ## Show Docker Compose logs
	@echo "Showing Docker logs..."
	$(DOCKER_COMPOSE) logs -f

docker-clean: ## Remove Docker containers, volumes, and images
	@echo "Cleaning Docker resources..."
	$(DOCKER_COMPOSE) down -v --rmi all

# Combined targets
all: clean install build ## Clean, install dependencies, and build

full-build: install build mvn-install ## Full build (npm + maven)

dev: install start ## Install dependencies and start development server

ci-build: install lint test build ## CI pipeline: install, lint, test, and build

# Info targets
info: ## Display project information
	@echo "Project: Nuxeo Web UI"
	@echo "Version: $(shell cat package.json | grep version | head -1 | awk -F: '{ print $$2 }' | sed 's/[",]//g' | tr -d '[[:space:]]')"
	@echo "Node.js: $(NODE_VERSION)"
	@echo "NPM: $(shell npm --version 2>/dev/null)"
	@echo "Maven: $(shell mvn --version 2>/dev/null | head -1)"
	@echo "Docker Compose: $(shell docker-compose --version 2>/dev/null)"
