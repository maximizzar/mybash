#!/usr/bin/env bash

# Function to map OS names to package types
get_package_type() {
  case "$1" in
    *Debian*|*Ubuntu*) echo ".deb" ;;
    *Red\ Hat*|*CentOS*|*Fedora*|*RHEL*) echo ".rpm" ;;
    *Arch*) echo ".pkg.tar.zst" ;;
    *Alpine*) echo ".apk" ;;
    *SUSE*) echo ".rpm" ;;
    *) echo "unknown" ;;
  esac
}

# Function to map OS to installation command
install_package() {
  case "$1" in
    *Debian*|*Ubuntu*)
      echo "Installing .deb package..."
      sudo dpkg -i "$2" && sudo apt-get install -f
      ;;
    *Red\ Hat*|*CentOS*|*Fedora*|*RHEL*)
      echo "Installing .rpm package..."
      sudo dnf install "$2" || sudo yum install "$2"
      ;;
    *Arch*)
      echo "Installing .pkg.tar.zst package..."
      sudo pacman -U "$2"
      ;;
    *Alpine*)
      echo "Installing .apk package..."
      sudo apk add --allow-untrusted "$2"
      ;;
    *SUSE*)
      echo "Installing .rpm package..."
      sudo zypper install "$2"
      ;;
    *)
      echo "Unsupported OS or package format!"
      exit 1
      ;;
  esac
}

# get latest release tag from Github
latest_release_api="https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest"
VERSION_REMOTE=$(curl --silent "$latest_release_api" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Function to check if an update / install is needed
check_installation() {
    if command fastfetch &> /dev/null; then
        VERSION_LOCAL="$(fastfetch --version)"
    else
        VERSION_LOCAL="0"
    fi

    if [[ "$VERSION_REMOTE" == "$VERSION_LOCAL" ]]; then
        echo "fastfetch is up to date!"
        exit 0;
    fi
}

check_installation

# determain arch and package type for the OS
kernel_version=$(uname -r)
arch=$(echo "$kernel_version" | grep -oE '[^-]+$')
package_type=$(get_package_type "$(uname -v)")

# download install and execute it
cd /tmp || exit 1;
url="https://github.com/fastfetch-cli/fastfetch/releases/download/$VERSION_REMOTE/fastfetch-linux-$arch$package_type";
wget "$url";
install_package "$(uname -v)" "/tmp/fastfetch-linux-$arch$package_type";
