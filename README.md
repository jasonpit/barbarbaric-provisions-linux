Quick Linux Setup Script 🐧

This script is designed to quickly configure a fresh Linux system (Debian or RHEL-based) with essential tools, drivers, and developer utilities.

Features
	•	Checks for and installs Bash 4+ if missing
	•	Installs NVIDIA drivers if an NVIDIA GPU is detected
	•	Offers optional installation of:
	•	Developer CLI tools (Azure CLI, AWS CLI, Docker, Git, etc.)
	•	Web browsers (Firefox, Chrome, Edge, etc.)
	•	Design and media tools (Krita, VLC, ffmpeg, etc.)
	•	Communication apps (Zoom, Slack, Microsoft Teams, etc.)
	•	Utilities and Android dev tools
	•	Terminal and music tools
	•	Supports Homebrew-based software installation
	•	Sets up a GitHub folder structure
	•	Optionally installs Oh My Zsh and custom aliases

Usage
	1.	Clone this repo:

sudo apt update && sudo apt install -y git curl wget gpg && git clone https://github.com/jasonpit/barbarbaric-provisions-linux.git ~/GitHub/barbarbaric-provisions-linux && chmod +x ~/GitHub/barbarbaric-provisions-linux/setup-debian.sh && ~/GitHub/barbarbaric-provisions-linux/setup-debian.sh

	2.	Run the setup script:

chmod +x quickLinuxSetup.sh
./quickLinuxSetup.sh

	3.	Follow the prompts to install software by category.

Notes
	•	Make sure you have sudo access before running the script.
	•	Some features rely on Homebrew being installed or will attempt to install it.
	•	The script includes macOS-specific fallback options which are ignored if not detected.

⸻

Made with ☕ by Jason Pittman
