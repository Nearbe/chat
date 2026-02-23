#!/bin/bash
set -e

create_color() {
  local name=$1
  local red=$2
  local green=$3
  local blue=$4
  mkdir -p "Resources/Assets.xcassets/$name.colorset"
  cat <<EOF > "Resources/Assets.xcassets/$name.colorset/Contents.json"
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "$blue",
          "green" : "$green",
          "red" : "$red"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
}

# PrimaryOrange (#FF9F0A) R: 255, G: 159, B: 10
create_color "PrimaryOrange" "0xFF" "0x9F" "0x0A"

# PrimaryBlue (#007AFF) R: 0, G: 122, B: 255
create_color "PrimaryBlue" "0x00" "0x7A" "0xFF"

# Success (#34C759) R: 52, G: 199, B: 89
create_color "Success" "0x34" "0xC7" "0x59"

# Error (#FF3B30) R: 255, G: 59, B: 48
create_color "Error" "0xFF" "0x3B" "0x30"

# Warning (#FF9500) R: 255, G: 149, B: 0
create_color "Warning" "0xFF" "0x95" "0x00"

# Info (#5AC8FA) R: 90, G: 200, B: 250
create_color "Info" "0x5A" "0xC8" "0xFA"

echo "Assets created successfully"
