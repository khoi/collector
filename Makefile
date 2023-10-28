PLATFORM = iOS
SCHEME = iOS

default: format

format:
	swift-format --in-place --recursive --configuration ./.swift-format.json ./

.PHONY: format
