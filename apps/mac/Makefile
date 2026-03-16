APP_NAME=HON
APP_BUNDLE=$(APP_NAME).app
BUILD_DIR=build/Release
APP_DIR=$(BUILD_DIR)/$(APP_BUNDLE)
MACOS_DIR=$(APP_DIR)/Contents/MacOS
RESOURCES_DIR=$(APP_DIR)/Contents/Resources

SWIFTC=swiftc
SWIFT_FILES=$(shell find Sources -name "*.swift")
SDK=$(shell xcrun --show-sdk-path --sdk macosx)

all: app dmg

app:
	mkdir -p $(MACOS_DIR)
	mkdir -p $(RESOURCES_DIR)
	cp Info.plist $(APP_DIR)/Contents/
	$(SWIFTC) $(SWIFT_FILES) -o $(MACOS_DIR)/$(APP_NAME) -target x86_64-apple-macosx13.0 -sdk $(SDK) -O -parse-as-library

dmg: app
	hdiutil create -volname "$(APP_NAME)" -srcfolder "$(BUILD_DIR)/$(APP_BUNDLE)" -ov -format UDZO $(APP_NAME)-2.0.0.dmg

clean:
	rm -rf build
	rm -f $(APP_NAME)-2.0.0.dmg
