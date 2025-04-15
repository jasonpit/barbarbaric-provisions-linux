#!/bin/bash

# Check for Bash version 4 or later
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Your Bash version is ${BASH_VERSINFO[0]}. This script requires Bash 4.0 or later."

    # Detect package manager and try to install bash
    if command -v apt >/dev/null 2>&1; then
        echo "Attempting to install newer bash using apt..."
        sudo apt update && sudo apt install -y bash
    elif command -v dnf >/dev/null 2>&1; then
        echo "Attempting to install newer bash using dnf..."
        sudo dnf install -y bash
    elif command -v yum >/dev/null 2>&1; then
        echo "Attempting to install newer bash using yum..."
        sudo yum install -y bash
    else
        echo "Unsupported package manager. Please upgrade bash manually."
        exit 1
    fi

    # Check again
    exec bash "$0" "$@"
fi


### Install NVIDIA Drivers ###

echo "Checking for NVIDIA GPU and installing drivers..."

if lspci | grep -i nvidia > /dev/null; then
    if command -v apt >/dev/null 2>&1; then
        echo "Installing NVIDIA drivers using apt..."
        sudo apt update && sudo apt install -y nvidia-driver
    elif command -v dnf >/dev/null 2>&1; then
        echo "Installing NVIDIA drivers using dnf..."
        sudo dnf install -y akmod-nvidia || sudo dnf install -y kmod-nvidia
    elif command -v yum >/dev/null 2>&1; then
        echo "Installing NVIDIA drivers using yum..."
        sudo yum install -y akmod-nvidia || sudo yum install -y kmod-nvidia
    else
        echo "Unsupported package manager. Please install NVIDIA drivers manually."
    fi
else
    echo "No NVIDIA GPU detected. Skipping driver installation."
fi

### A script to set up a new Linux system ###
### Author: Jason Pittman ###
### Version: 1.3 (Updated 2025-03-31) ###

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

echo "🐧 Time to set up your Linux system! 🐧"
sleep 3

echo "Starting Linux setup script..."
echo "📸 Reminder: Set your screenshot directory manually if needed."

# Create GitHub folder in ~/Documents and create a symlink in ~/ "helps auto sync with iCloud or OneDrive by being in ~/Documents"
GITHUB_DIR="$HOME/Documents/GitHub"
mkdir -p "$GITHUB_DIR"
ln -sfn "$GITHUB_DIR" "$HOME/GitHub"

echo "💾 Reminder: Store important files in OneDrive or cloud storage for easy recovery! 🚀"

# Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew is not installed. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        echo "❌ Homebrew installation failed!"; exit 1;
    }
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
else
    echo "✅ Homebrew is already installed. Updating..."
    brew update && brew upgrade && brew doctor

    # Ensure HashiCorp tap is added for HashiCorp tools
    if ! brew tap | grep -q "hashicorp/tap"; then
        echo "Tapping hashicorp/tap for HashiCorp tools..."
        brew tap hashicorp/tap
    fi
fi

# Backup Finder preferences
FINDER_PLIST=~/Library/Preferences/com.apple.finder.plist
if [ -f "$FINDER_PLIST" ]; then
    cp "$FINDER_PLIST" ~/Desktop/com.apple.finder.plist.backup
    echo "✅ Finder preferences backed up!"
else
    echo "⚠️ Finder preferences not found, skipping backup."
fi

# List of software to install
declare -A SOFTWARE_PACKAGES=(
    ["Development & CLI Tools"]="awscli azure-cli docker gh git php mysql node azcopy terraform"
    ["Web Browsers"]="microsoft-edge google-chrome firefox chromium google-chrome-canary brave-browser"
    ["Design & Media"]="krita inkscape vlc ffmpeg snagit airfoil"
    ["Communication"]="skype whatsapp zoom slack microsoft-teams"
    ["Utilities & System Tools"]="cyberduck balenaetcher the-unarchiver steam transmission"
    ["Android Development"]="android-commandlinetools android-file-transfer android-platform-tools scrcpy"
    ["Terminal & Networking"]="iterm2 nomachine zerotier-one angry-ip-scanner"
    ["Audio & Music"]="native-access"
)



# Function to prompt for confirmation
confirm_install() {
    read -p "Do you want to install $1? (y/n) " choice
    [[ "$choice" =~ ^[Yy]$ ]]
}

# Install software
for category in "${!SOFTWARE_PACKAGES[@]}"; do
    if confirm_install "$category"; then
        for package in ${SOFTWARE_PACKAGES[$category]}; do
            # Check if the package is available as a cask
            if brew info --cask "$package" > /dev/null 2>&1; then
                echo "Installing $package as a cask..."
                brew install --cask "$package"
            else
                echo "Installing $package as a formula..."
                brew install "$package"
            fi
        done
        echo "✅ $category installed!"
    else
        echo "❌ Skipping $category"
    fi
done

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
## list all properly like in Linux.
alias ll='ls -al'
alias la='ls -a'
alias lt='ls -alt'
alias duh='du -sh * | sort -h'

## open my alias file in vim.
alias aliases='vim ~/.oh-my-zsh/custom/aliases.zsh'

## run apple softwareupdates and then run brew updates.
alias update='sudo softwareupdate -ia --verbose && brew upgrade'
alias brewup='brew update && brew upgrade && brew cleanup'

## give me my public IPv4, Ethernet, and Wi-Fi IPs with labels.
alias ip='echo "Public IPv4: $(curl -4 -s ifconfig.co)" && echo "Ethernet (en0): $(ipconfig getifaddr en0 2>/dev/null || echo "Not connected")" && echo "Wi-Fi (en1): $(ipconfig getifaddr en1 2>/dev/null || echo "Not connected")"'
alias pingg='ping -c 4 google.com'
alias ports='lsof -i -P | grep LISTEN'

## give me a random password
alias pw='openssl rand -base64 16'

## SSH and server management - you need to update this with your own servers and SSH keys
alias server1='ssh -i ~/.ssh/.yourSSHKey 10.x.x.x.x' # replace with your server IP  
alias tailserver1='ssh -i ~/.yourSSHKey 10.x.x.x.x' "tail -f /var/log/syslog"' # replace with your server IP  
alias server2='ssh -i ~/.yourSSHKey 10.x.x.x.x''  # replace with your server IP  
alias tailserver2='ssh -i ~/.yourSSHKey 10.x.x.x.x' "tail -f /var/log/syslog"' # replace with your server IP  
alias dockerserver='ssh -i ~/.yourSSHKey 10.x.x.x.x' # replace with your server IP  

## Development
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'

## System utilities
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
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

# Finder Customization  
if confirm_install "Finder Customization"; then
    defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    killall Finder
    echo "✅ Finder customized!"
else
    echo "❌ Skipping Finder customization"
fi

# Dock Customization
if confirm_install "Linux Dock Customization"; then
    # Preserve existing dock items (do not clear them)
    # If you wish to clear the Dock items, uncomment the next line
    # defaults write com.apple.dock persistent-apps -array
    
    # Optionally add spacer tiles without removing current items
    for i in {1..6}; do
        defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'
    done
    defaults write com.apple.dock mineffect -string scale
    killall Dock
    echo "✅ Dock customized!"
else
    echo "❌ Skipping Dock customization"
fi

# Cleanup
if confirm_install "Homebrew Cleanup"; then
    brew cleanup
    echo "✅ Cleanup complete!"
else
    echo "❌ Skipping Cleanup"
fi

echo "🎉 Installation and configuration complete!"
