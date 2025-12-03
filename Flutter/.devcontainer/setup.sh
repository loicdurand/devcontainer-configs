#!/bin/bash

sudo useradd -m -s /bin/bash vscode

# Mise à jour et paquets de base
sudo apt-get update && sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa wget

# Installation Flutter (stable 3.24.5)
FLUTTER_VERSION="3.24.5-stable"
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz
tar xf flutter_linux_${FLUTTER_VERSION}.tar.xz
sudo mv flutter /opt/flutter
sudo chown -R vscode:vscode /opt/flutter
echo 'export PATH="$PATH:/opt/flutter/bin:/opt/android-sdk/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"' >> /home/vscode/.bashrc
source /home/vscode/.bashrc

# Installation Android SDK CLI (manuel, sans feature)
export ANDROID_HOME=/opt/android-sdk
mkdir -p $ANDROID_HOME/cmdline-tools
cd $ANDROID_HOME/cmdline-tools

# Télécharge SDK Tools stable (34.0.5)
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
unzip cmdline-tools.zip
mv cmdline-tools latest
chmod +x $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager

# Acceptation licences
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses

# Installation paquets essentiels (stable, récents)
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "cmake;3.22.1"

# Installation Node.js 22.x LTS
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Installation Firebase CLI 13.7.0
sudo npm install -g firebase-tools@13.7.0

# Config Flutter
flutter precache
flutter doctor --android-licenses

echo "Environnement CLI prêt ! Android SDK installé manuellement."
echo "Vérifiez: 'flutter doctor' et 'adb version'."