#!/bin/sh

xcodebuild archive \
-destination generic/platform=iOS \
-scheme AcousticContentSDK \
-archivePath outputs/platform_device \
SKIP_INSTALL=NO

xcodebuild archive \
-destination 'platform=iOS Simulator,OS=13.4,name=iPhone 11' \
-scheme AcousticContentSDK \
-archivePath outputs/platform_simulator \
-sdk iphonesimulator \
SKIP_INSTALL=NO

xcodebuild -create-xcframework \
-framework outputs/platform_device.xcarchive/Products/Library/Frameworks/AcousticContentSDK.framework \
-framework outputs/platform_simulator.xcarchive/Products/Library/Frameworks/AcousticContentSDK.framework \
-output outputs/AcousticContentSDK.xcframework

# Workaround required because of Apple bug described here:
# https://forums.developer.apple.com/thread/123253
find outputs -name "*.swiftinterface" -exec sed -i -e 's/AcousticContentSDK\.//g' {} \;

