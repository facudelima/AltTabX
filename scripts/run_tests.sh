#!/usr/bin/env bash

set -ex

xcodebuild -version
xcodebuild -project AltTabNeo.xcodeproj -scheme Release -showBuildSettings | grep SWIFT_VERSION

set -o pipefail && xcodebuild test -project AltTabNeo.xcodeproj -scheme Test -configuration Release | scripts/xcbeautify
