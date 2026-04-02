VPS_IP  = 103.181.143.73
VPS_USER= nunuadmin
VPS     = $(VPS_USER)@$(VPS_IP)
APP_NAME= free-api-news
DEPLOY_DIR=/home/$(VPS_USER)/apps/$(APP_NAME)
BINARY  = bin/$(APP_NAME)

.PHONY: run build tidy migrate-local deploy

## ── Local ────────────────────────────────────────────────────────────────────

run:
	go run ./cmd/api/main.go

build:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o $(BINARY) ./cmd/api/main.go

tidy:
	go mod tidy

## ── Local DB ─────────────────────────────────────────────────────────────────

migrate-local:
	psql -U postgres -d free_api_news -f migrations/001_create_users_table.sql
	psql -U postgres -d free_api_news -f migrations/002_create_tokens_table.sql

## ── Deploy ───────────────────────────────────────────────────────────────────

deploy: build
	@echo "📦 Deploying $(APP_NAME) to $(VPS)..."
	ssh $(VPS) "mkdir -p $(DEPLOY_DIR)/migrations $(DEPLOY_DIR)/public/uploads && sudo systemctl stop $(APP_NAME) || true"
	scp $(BINARY)           $(VPS):$(DEPLOY_DIR)/$(APP_NAME)
	scp .env.example        $(VPS):$(DEPLOY_DIR)/.env.example
	scp -r migrations/*     $(VPS):$(DEPLOY_DIR)/migrations/
	scp deploy/$(APP_NAME).service $(VPS):/tmp/$(APP_NAME).service
	ssh $(VPS) "sudo mv /tmp/$(APP_NAME).service /etc/systemd/system/ && \
	            sudo systemctl daemon-reload && \
	            sudo systemctl enable $(APP_NAME) && \
	            sudo systemctl restart $(APP_NAME)"
	@echo "✅ Deployed! Check: ssh $(VPS) 'sudo systemctl status $(APP_NAME)'"

deploy-migrate:
	@echo "🗃  Running migrations on VPS..."
	ssh $(VPS) "sudo -u postgres psql -d free_api_news -f $(DEPLOY_DIR)/migrations/001_create_users_table.sql && \
	            sudo -u postgres psql -d free_api_news -f $(DEPLOY_DIR)/migrations/002_create_tokens_table.sql && \
	            sudo -u postgres psql -d free_api_news -f $(DEPLOY_DIR)/migrations/003_create_categories_table.sql && \
	            sudo -u postgres psql -d free_api_news -f $(DEPLOY_DIR)/migrations/004_create_articles_table.sql && \
	            sudo -u postgres psql -d free_api_news -f $(DEPLOY_DIR)/migrations/005_add_role_to_users.sql && \
	            sudo -u postgres psql -d free_api_news -f $(DEPLOY_DIR)/migrations/009_add_profile_fields.sql"

logs:
	ssh $(VPS) "sudo journalctl -u $(APP_NAME) -f"

status:
	ssh $(VPS) "sudo systemctl status $(APP_NAME)"
