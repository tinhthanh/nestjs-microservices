.PHONY: help setup dev-start dev-stop dev-run dev-logs dev-clean test test-auth test-post docker-up docker-down docker-logs

# Colors
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

help: ## Show this help message
	@echo "$(CYAN)=========================================$(NC)"
	@echo "$(CYAN)🚀 NestJS Microservices - Make Commands$(NC)"
	@echo "$(CYAN)=========================================$(NC)"
	@echo ""
	@echo "$(GREEN)Development Environment:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

setup: ## Initial setup - install dependencies and prepare environment
	@echo "$(CYAN)Running initial setup...$(NC)"
	@chmod +x dev-setup.sh && ./dev-setup.sh

dev-start: ## Start development infrastructure (PostgreSQL, Redis, Traefik)
	@echo "$(CYAN)Starting development infrastructure...$(NC)"
	@chmod +x dev-start.sh && ./dev-start.sh

dev-stop: ## Stop development infrastructure
	@echo "$(CYAN)Stopping development infrastructure...$(NC)"
	@chmod +x dev-stop.sh && ./dev-stop.sh

dev-run: ## Start local services (Auth & Post)
	@echo "$(CYAN)Starting local services...$(NC)"
	@chmod +x dev-run-services.sh && ./dev-run-services.sh

dev-logs: ## View infrastructure logs
	@echo "$(CYAN)Viewing logs...$(NC)"
	@chmod +x dev-logs.sh && ./dev-logs.sh

dev-clean: ## Clean development environment (remove volumes)
	@echo "$(YELLOW)Cleaning development environment...$(NC)"
	@docker-compose -f docker-compose.dev.yml down -v
	@echo "$(GREEN)✅ Development environment cleaned$(NC)"

dev-restart: dev-stop dev-start ## Restart development infrastructure

switch-dev: ## Switch to development mode
	@chmod +x switch-to-dev.sh && ./switch-to-dev.sh

switch-prod: ## Switch to production mode
	@chmod +x switch-to-prod.sh && ./switch-to-prod.sh

doctor: ## Run health check
	@chmod +x dev-doctor.sh && ./dev-doctor.sh

dev-ps: ## Show running containers
	@docker-compose -f docker-compose.dev.yml ps

test: ## Run all tests
	@echo "$(CYAN)Running all tests...$(NC)"
	@chmod +x test-scripts/verify-all.sh && ./test-scripts/verify-all.sh

test-auth: ## Run Auth service tests
	@echo "$(CYAN)Running Auth service tests...$(NC)"
	@cd auth && npm test

test-post: ## Run Post service tests
	@echo "$(CYAN)Running Post service tests...$(NC)"
	@cd post && npm test

test-unit: ## Run unit tests only
	@echo "$(CYAN)Running unit tests...$(NC)"
	@cd auth && npm test && cd .. && cd post && npm test

test-cov: ## Run tests with coverage
	@echo "$(CYAN)Running tests with coverage...$(NC)"
	@cd auth && npm run test:cov && cd .. && cd post && npm run test:cov

docker-up: ## Start full Docker stack (production mode)
	@echo "$(CYAN)Starting full Docker stack...$(NC)"
	@docker-compose up -d

docker-down: ## Stop full Docker stack
	@echo "$(CYAN)Stopping full Docker stack...$(NC)"
	@docker-compose down

docker-logs: ## View Docker stack logs
	@docker-compose logs -f

docker-clean: ## Clean Docker stack (remove volumes)
	@echo "$(YELLOW)Cleaning Docker stack...$(NC)"
	@docker-compose down -v
	@echo "$(GREEN)✅ Docker stack cleaned$(NC)"

docker-rebuild: ## Rebuild and restart Docker stack
	@echo "$(CYAN)Rebuilding Docker stack...$(NC)"
	@docker-compose up -d --build

install: ## Install dependencies for all services
	@echo "$(CYAN)Installing dependencies...$(NC)"
	@cd auth && npm install && cd .. && cd post && npm install
	@echo "$(GREEN)✅ Dependencies installed$(NC)"

migrate: ## Run database migrations
	@echo "$(CYAN)Running migrations...$(NC)"
	@cd auth && npx prisma migrate deploy && npx prisma generate && cd ..
	@cd post && npx prisma migrate deploy && npx prisma generate && cd ..
	@echo "$(GREEN)✅ Migrations completed$(NC)"

migrate-dev: ## Create new migration
	@echo "$(CYAN)Creating new migration...$(NC)"
	@echo "$(YELLOW)Which service? (auth/post):$(NC)"
	@read service; cd $$service && npx prisma migrate dev

studio: ## Open Prisma Studio
	@echo "$(CYAN)Which service? (auth/post):$(NC)"
	@read service; cd $$service && npx prisma studio

lint: ## Run linter
	@echo "$(CYAN)Running linter...$(NC)"
	@cd auth && npm run lint && cd .. && cd post && npm run lint

format: ## Format code
	@echo "$(CYAN)Formatting code...$(NC)"
	@cd auth && npm run format && cd .. && cd post && npm run format

clean: ## Clean all node_modules and build artifacts
	@echo "$(YELLOW)Cleaning project...$(NC)"
	@rm -rf auth/node_modules auth/dist
	@rm -rf post/node_modules post/dist
	@rm -rf logs/*.log
	@echo "$(GREEN)✅ Project cleaned$(NC)"

status: ## Show status of all services
	@echo "$(CYAN)=========================================$(NC)"
	@echo "$(CYAN)📊 Service Status$(NC)"
	@echo "$(CYAN)=========================================$(NC)"
	@echo ""
	@echo "$(GREEN)Infrastructure (Docker):$(NC)"
	@docker-compose -f docker-compose.dev.yml ps
	@echo ""
	@echo "$(GREEN)Service Health:$(NC)"
	@echo -n "  PostgreSQL: "; curl -s http://localhost:5435 > /dev/null 2>&1 && echo "$(GREEN)✅$(NC)" || echo "$(YELLOW)❌$(NC)"
	@echo -n "  Redis: "; docker-compose -f docker-compose.dev.yml exec -T redis redis-cli ping > /dev/null 2>&1 && echo "$(GREEN)✅$(NC)" || echo "$(YELLOW)❌$(NC)"
	@echo -n "  Traefik: "; curl -s http://localhost:8001 > /dev/null 2>&1 && echo "$(GREEN)✅$(NC)" || echo "$(YELLOW)❌$(NC)"
	@echo -n "  Auth Service: "; curl -s http://localhost:3001/health > /dev/null 2>&1 && echo "$(GREEN)✅$(NC)" || echo "$(YELLOW)❌$(NC)"
	@echo -n "  Post Service: "; curl -s http://localhost:3002/health > /dev/null 2>&1 && echo "$(GREEN)✅$(NC)" || echo "$(YELLOW)❌$(NC)"
	@echo ""

