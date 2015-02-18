#!/usr/bin/env bash
#     __                             ____        _      __      _____ __             __ 
#    / /   ____ ___  _____  _____   / __ \__  __(_)____/ /__   / ___// /_____ ______/ /_
#   / /   / __ `/ / / / _ \/ ___/  / / / / / / / / ___/ //_/   \__ \/ __/ __ `/ ___/ __/
#  / /___/ /_/ / /_/ /  __/ /     / /_/ / /_/ / / /__/ ,<     ___/ / /_/ /_/ / /  / /_  
# /_____/\__,_/\__, /\___/_/      \___\_\__,_/_/\___/_/|_|   /____/\__/\__,_/_/   \__/  
#             /____/                                                                    
#
# This is the Layer Quick Start install script for iOS
#
#    Install the Quick Start project by running this command:
#    curl -L https://raw.githubusercontent.com/layerhq/quick-start-ios/master/install.sh | bash -s "<YOUR_APP_ID>"
#
# Files will be installed in ~/Downloads/ folder.
# 
# This script requires that 'git' and 'cocoapods' are already installed.
echo "Welcome to the Layer Quick Start install script for iOS"
echo "This script will:"
echo "1. Download the latest Quick Start project"
echo "2. Inject your app id"
echo "3. Grab the latest LayerKit (via cocoapods)"
echo "4. Launch XCode"

# Check to see if the script is running on OS X

UNAME=$(uname)
if [ "$UNAME" != "Darwin" ] ; then
    echo "Sorry, this OS is not supported."
    exit 1
fi

# Grab the current timestamp and create a folder (This is to avoid clobbering any existing folders)

current_time=$(date "+%Y.%m.%d-%H.%M.%S")
INSTALL_DIR="$HOME/Downloads/quick-start-ios".$current_time
mkdir -p "$INSTALL_DIR"

# Download the latest Quick Start project from Github
echo "##########################################"
echo "1. Downloading Latest Layer Quickstart app"
hash git >/dev/null 2>&1 && env git clone --depth=1 https://github.com/layerhq/quick-start-ios.git $INSTALL_DIR || {
  echo "You need to install git to continue: http://git-scm.com/download/mac"
  exit 1
}
echo "QuickStart has been installed in your home directory (~/Downloads/quick-start-ios)."

# Update the generic XCode project with your App ID

APP_ID="LAYER_APP_ID"		
if [ "$1" ] ; then
	APP_ID=$1
	echo "2. Injecting App ID: $APP_ID in the project"	
	if [ "$APP_ID" != "APP ID" ]; then
		sed -i '' -e "s/LQSLayerAppIDString \= \@\"LAYER_APP_ID\"/LQSLayerAppIDString = \@\"$APP_ID\"/" $INSTALL_DIR/QuickStart/LQSAppDelegate.m
	fi
else
	echo "2: Skipping Step - No App ID provided."	
fi

# Install the latest LayerKit using Cocoapods

cd $INSTALL_DIR
echo "3: Running 'pod install' to download latest LayerKit via cocoapods (This may take a few minutes)."
hash pod >/dev/null && /usr/bin/env pod install || {
      echo "You need to install cocoapods to continue: http://cocoapods.org"
      exit 1
}

# Launch XCode

echo "4. Congrats, you're finished! Now opening XCode. Press CMD-R to run the Project"
open "$INSTALL_DIR/QuickStart.xcworkspace"
open "https://developer.layer.com/docs/quick-start/ios"

