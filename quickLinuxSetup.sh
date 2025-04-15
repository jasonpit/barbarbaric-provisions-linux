#!/bin/bash

# Check for Bash version 4 or later
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Your Bash version is ${BASH_VERSINFO[0]}. This script requires Bash 4.0 or later."
    echo "Attempting to install newer bash using apt..."
    sudo apt update && sudo apt install -y bash
    exec bash "$0" "$@"
fi

### A script to set up a new Debian system ###
### Author: Jason Pittman ###
### Version: 1.8 (Updated 2025-04-15) ###

clear
cat << "EOF"

              a8888b.
             d888888b.
             8P"YP"Y88
             8|o||o|88
             8'    .88
             8`._.' Y8.
            d/      `8b.
           dP   .    Y8b.
          d8:'  "  `::88b
         d8"         'Y88b
        :8P    '      :888
         8a.   :     _a88P
       ._/"Yaa_:   .| 88P|
       \    YP"    `| 8P  `.
       /     \.___.d|    .'
       `--..__)8888P`._.'


EOF

echo "🐧 Time to set up your Debian system with Tux! 🐧"
sleep 3

echo "Starting Debian setup script..."

# Install prerequisites for repository setup
sudo apt update
sudo apt install -y curl wget gpg

# Set custom screenshot location
SCREENSHOT_DIR="$HOME/Pictures/ScreenShots"
mkdir -p "$SCREENSHOT_DIR"
gsettings set org.gnome.gnome-screenshot auto-save-directory "file://$SCREENSHOT_DIR"

# Create GitHub folder in ~/Documents and create a symlink in ~/
GITHUB_DIR="$HOME/Documents/GitHub"
mkdir -p "$GITHUB_DIR"
ln -sfn "$GITHUB_DIR" "$HOME/GitHub"

echo "💾 Reminder: Store important files in cloud storage for easy recovery! 🚀"

# Configure Debian mirror (deb.debian.org for GeoIP-based mirror selection)
echo "Configuring Debian mirror..."
sudo bash -c 'cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian bookworm main contrib non-free
deb-src http://deb.debian.org/debian bookworm main contrib non-free
deb http://deb.debian.org/debian-security bookworm-security main contrib non-free
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
EOF'
sudo apt update

# Install NVIDIA drivers if applicable
echo "Checking for NVIDIA GPU and installing drivers..."
if lspci | grep -i nvidia > /dev/null; then
    echo "Installing NVIDIA drivers using apt..."
    sudo apt install -y nvidia-driver
else
    echo "No NVIDIA GPU detected. Skipping driver installation."
fi

# Add external repositories
add_repositories() {
    # Microsoft Edge
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-edge.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list

    # Google Chrome
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/chrome.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

    # Brave Browser
    curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/brave-browser.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/brave-browser.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

    # HashiCorp (Terraform)
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com bookworm main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

    # GitHub CLI
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/githubcli.list

    # Slack
    curl -fsSL https://packagecloud.io/slacktechnologies/slack/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/slack.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/slack.gpg] https://packagecloud.io/slacktechnologies/slack/debian jessie main" | sudo tee /etc/apt/sources.list.d/slack.list

    # ZeroTier
    curl -fsSL https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg | sudo gpg --dearmor -o /usr/share/keyrings/zerotier.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/zerotier.gpg] http://download.zerotier.com/debian/bookworm bookworm main" | sudo tee /etc/apt/sources.list.d/zerotier.list

    # Azure CLI
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ bookworm main" | sudo tee /etc/apt/sources.list.d/azure-cli.list

    sudo apt update
}

# Install manual .deb packages
install_manual_deb() {
    # WhatsApp
    echo "Installing WhatsApp..."
    curl -fsSL -o whatsapp.deb https://www.whatsapp.com/android/WhatsApp.apk # Note: WhatsApp for Linux is unofficial; adjust URL if official .deb exists
    sudo dpkg -i whatsapp.deb || sudo apt install -f -y
    rm whatsapp.deb

    # Zoom
    echo "Installing Zoom..."
    curl -fsSL -o zoom.deb https://zoom.us/client/latest/zoom_amd64.deb
    sudo dpkg -i zoom.deb || sudo apt install -f -y
    rm zoom.deb

    # Balena Etcher
    echo "Installing Balena Etcher..."
    curl -fsSL -o etcher.deb https://github.com/balena-io/etcher/releases/latest/download/balena-etcher-electron_amd64.deb
    sudo dpkg -i etcher.deb || sudo apt install -f -y
    rm etcher.deb

    # NoMachine
    echo "Installing NoMachine..."
    curl -fsSL -o nomachine.deb https://www.nomachine.com/free/linux/64/deb
    sudo dpkg -i nomachine.deb || sudo apt install -f -y
    rm nomachine.deb
}

# List of software to install via apt
declare -A SOFTWARE_PACKAGES=(
    ["Development & CLI Tools"]="awscli azure-cli docker.io gh git php mariadb-client nodejs terraform"
    ["Web Browsers"]="firefox chromium microsoft-edge-stable google-chrome-stable brave-browser"
    ["Design & Media"]="krita inkscape vlc ffmpeg shutter"
    ["Communication"]="skypeforlinux slack-desktop teams"
    ["Utilities & System Tools"]="filezilla unar steam transmission-gtk"
    ["Android Development"]="android-tools-adb android-tools-fastboot mtp-tools scrcpy"
    ["Terminal & Networking"]="gnome-terminal zerotier-one nmap"
)

# Function to prompt for confirmation
confirm_install() {
    read -p "Do you want to install $1? (y/n) " choice
    [[ "$choice" =~ ^[Yy]$ ]]
}

# Add repositories
add_repositories

# Install azcopy manually (not in apt)
if confirm_install "azcopy"; then
    echo "Installing azcopy..."
    curl -fsSL -o azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux
    tar -xzf azcopy.tar.gz
    sudo mv azcopy_linux_amd64_*/azcopy /usr/bin/
    rm -rf azcopy.tar.gz azcopy_linux_amd64_*
    echo "✅ azcopy installed!"
else
    echo "❌ Skipping azcopy"
fi

# Install software via apt
for category in "${!SOFTWARE_PACKAGES[@]}"; do
    if confirm_install "$category"; then
        for package in ${SOFTWARE_PACKAGES[$category]}; do
            echo "Installing $package..."
            sudo apt install -y "$package"
        done
        echo "✅ $category installed!"
    else
        echo "❌ Skipping $category"
    fi
done

# Install manual .deb packages
if confirm_install "Manual .deb Packages (WhatsApp, Zoom, Etcher, NoMachine)"; then
    install_manual_deb
    echo "✅ Manual .deb packages installed!"
else
    echo "❌ Skipping manual .deb packages"
fi

# Oh My Zsh installation
if confirm_install "Oh My Zsh" && [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh installed!"
else
    echo "❌ Skipping Oh My Zsh installation"
fi

# Custom Aliases
if confirm_install "Custom Aliases"; then
    ALIAS_FILE="$HOME/.oh-my-zsh/custom/aliases.zsh"
    mkdir -p "$(dirname "$ALIAS_FILE")"
    cat > "$ALIAS_FILE" <<EOF
## List commands
alias ll='ls -al'
alias la='ls -a'
alias lt='ls -alt'
alias duh='du -sh * | sort -h'

## Open alias file in vim
alias aliases='vim ~/.oh-my-zsh/custom/aliases.zsh'

## System updates
alias update='sudo apt update && sudo apt upgrade -y'
alias ports='ss -tuln'

## Network utilities
alias ip='ip addr show | grep inet'
alias pingg='ping -c 4 google.com'

## Random password generator
alias pw='openssl rand -base64 16'

## SSH and server management - update with your own servers and SSH keys
alias server1='ssh -i ~/.ssh/yourSSHKey 10.x.x.x' # replace with your server IP
alias tailserver1='ssh -i ~/.ssh/yourSSHKey 10.x.x.x tail -f /var/log/syslog' # replace with your server IP
alias server2='ssh -i ~/.ssh/yourSSHKey 10.x.x.x' # replace with your server IP
alias tailserver2='ssh -i ~/.ssh/yourSSHKey 10.x.x.x tail -f /var/log/syslog' # replace with your server IP
alias dockerserver='ssh -i ~/.ssh/yourSSHKey 10.x.x.x' # replace with your server IP

## Development
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'

## System utilities
alias cleanup='find . -type f -name "*.DS_Store" -delete'

## Productivity
alias weather='curl -s wttr.in'
alias timestamp='date +%Y%m%d%H%M%S'
EOF
    echo "source $ALIAS_FILE" >> "$HOME/.zshrc"
    echo "✅ Custom Aliases configured!"
else
    echo "❌ Skipping Custom Aliases setup"
fi

# GNOME Customization
if confirm_install "GNOME Customization"; then
    # Show hidden files in Nautilus
    gsettings set org.gnome.nautilus.preferences show-hidden-files true
    # Enable pathbar
    gsettings set org.gnome.nautilus.preferences always-use-location-entry true
    # Set list view
    gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
    echo "✅ GNOME customized!"
else
    echo "❌ Skipping GNOME customization"
fi

# GNOME Dock Customization
if confirm_install "GNOME Dock Customization"; then
    # Enable dock autohide
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    # Set click action
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
    # Add spacers (simulate macOS Dock spacers)
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
    echo "✅ GNOME Dock customized!"
else
    echo "❌ Skipping GNOME Dock customization"
fi

# Cleanup
if confirm_install "System Cleanup"; then
    sudo apt autoremove -y && sudo apt autoclean
    echo "✅ Cleanup complete!"
else
    echo "❌ Skipping Cleanup"
fi

echo "🎉 Installation and configuration complete!"