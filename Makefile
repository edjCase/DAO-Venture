# Define variables
SRC_DIR := src/backend
DID_TEMP_DIR := did_temp
OUT_DIR := src/frontend/src/ic-agent/declarations
MOC := $(shell dfx cache show)/moc
MOPS_SOURCES := $(shell mops sources)
DIDC := didc

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
	
# Default target
generate: $(DIDC) build_league process_did_files compile_did_files

# Phony targets
.PHONY: generate clean build_league process_did_files compile_did_files
