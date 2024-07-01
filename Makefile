# Define variables
SRC_DIR := src/backend
DID_TEMP_DIR := did_temp
OUT_DIR := src/frontend/src/ic-agent/declarations
MOC := $(shell dfx cache show)/moc
MOPS_SOURCES := $(shell mops sources)
DIDC := didc

# Define the list of canisters to reinstall
CANISTERS := stadium teams users players league

# Define environment-specific argument files
LOCAL_ARG_FILE := args.local.json
PROD_ARG_FILE := args.prod.json

build_league:
	dfx build league

process_did_files:
	@mkdir -p $(DID_TEMP_DIR)
	@for dir in .dfx/local/canisters/*; do \
		if [ -d "$$dir" ]; then \
			base=$$(basename $$dir); \
			did_file="$$dir/$$base.did"; \
			if [ -f "$$did_file" ]; then \
				echo "Processing $$did_file..."; \
				cp "$$did_file" "$(DID_TEMP_DIR)/"; \
			fi; \
		fi; \
	done

compile_did_files:
	@for did in $(DID_TEMP_DIR)/*.did; do \
		if [ -f "$$did" ]; then \
			js="$$(echo "$$did" | sed 's|^$(DID_TEMP_DIR)|$(OUT_DIR)|' | sed 's|\.did$$|.js|')"; \
			./didc bind -t js "$$did" > "$$js"; \
			ts="$$(echo "$$js" | sed 's|\.js$$|.d.ts|')"; \
			./didc bind -t ts "$$did" > "$$ts"; \
		fi; \
	done
	rm -rf $(DID_TEMP_DIR)

$(DIDC):
	@echo "Downloading didc..."
	@curl -L -o $(DIDC) https://github.com/dfinity/candid/releases/latest/download/didc-linux64
	@chmod +x $(DIDC)
	@echo "didc downloaded and made executable."

# Cleanup
clean:
	rm -rf $(OUT_DIR)
	@rm -f $(DIDC)

# Function to read JSON argument for a specific canister
define read_json_arg
	$(shell jq -r '.$(1) // empty' $(2))
endef

# Function to generate deploy commands with environment-specific arguments
define deploy_commands
	$(foreach canister,$(CANISTERS),\
		dfx deploy $(canister) $(1) -y \
		$(if $(call read_json_arg,$(canister),$(2)),--argument '$(call read_json_arg,$(canister),$(2))') &&\
	) true
endef

# Function to generate reinstall commands with environment-specific arguments
define reinstall_commands
	$(foreach canister,$(CANISTERS),\
		dfx deploy $(canister) $(1) --mode reinstall -y \
		$(if $(call read_json_arg,$(canister),$(2)),--argument '$(call read_json_arg,$(canister),$(2))') &&\
	) true
endef

# Deploy target for local development
deploy:
	@$(call deploy_commands,--identity anonymous,$(LOCAL_ARG_FILE))
	dfx deps deploy --identity anonymous

# Deploy target for production (IC network)
deploy_prod:
	@$(call deploy_commands,--ic,$(PROD_ARG_FILE))
	dfx deploy frontend --ic -y

# Reinstall target for local development
reinstall:
	@$(call reinstall_commands,--identity anonymous,$(LOCAL_ARG_FILE))
	dfx deps deploy --identity anonymous

# Reinstall target for production (IC network)
reinstall_prod:
	@$(call reinstall_commands,--ic,$(PROD_ARG_FILE))
	dfx deploy frontend --ic --mode reinstall -y

# Default target
generate: $(DIDC) build_league process_did_files compile_did_files

# Phony targets
.PHONY: generate clean build_league process_did_files compile_did_files deploy deploy_prod reinstall reinstall_prod