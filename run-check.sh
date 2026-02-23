#!/bin/bash
exec 3>&1
xcodebuild -scheme "🔍 Check" build > /dev/null 2>&1
/Users/nearbe/Library/Developer/Xcode/DerivedData/Chat-cpfexcnvwheubjfivmviimoteein/Build/Products/Debug/scripts check >&3
