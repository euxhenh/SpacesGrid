.PHONY: build run install clean universal dmg

APP       = SpacesGrid
BUILD_DIR = build
APP_BUNDLE = $(BUILD_DIR)/$(APP).app

## Build for the current machine's native architecture (default target).
build:
	@bash build.sh

## Build a universal arm64 + x86_64 binary.
universal:
	@bash build.sh --universal

## Build and immediately open the app.
run: build
	@open "$(APP_BUNDLE)"

## Build and copy the app bundle to /Applications.
install: build
	@cp -r "$(APP_BUNDLE)" /Applications/
	@echo "Installed to /Applications/$(APP).app"

## Create a distributable DMG from the current build.
## Pass VERSION=x.y.z to set the filename: make dmg VERSION=1.0.0
dmg: build
	@bash scripts/create_dmg.sh $(or $(VERSION),$(shell date +%Y%m%d))

## Remove the build/ directory.
clean:
	@rm -rf "$(BUILD_DIR)"
	@echo "Cleaned $(BUILD_DIR)/"
