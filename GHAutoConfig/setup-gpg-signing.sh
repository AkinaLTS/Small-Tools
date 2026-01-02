#!/bin/bash
# copyright (c) 2026 Arkria
# GPG Commit Signing One-click Configuration Script
# Applicable to: WSL + Remote VS Code environment (Arch Linux)

set -e

echo "==========================================" 
echo "GPG Commit Signing Configuration Script (Arch Linux)"
echo "========================================="
echo ""

# Check and install dependencies
echo "[1/6] Checking and installing dependencies..."

REQUIRED_PACKAGES=("gnupg" "git")
MISSING_PACKAGES=()

for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" &> /dev/null; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo "Need to install the following packages: ${MISSING_PACKAGES[*]}"
    echo "Execute: sudo pacman -S ${MISSING_PACKAGES[*]}"
    sudo pacman -S --noconfirm "${MISSING_PACKAGES[@]}"
    echo "✓ Dependencies installed"
else
    echo "✓ All dependencies are already installed"
fi
echo ""

# Check if GPG is installed
echo "[2/6] Verifying GPG installation..."
if ! command -v gpg &> /dev/null; then
    echo "❌ Error: GPG installation failed"
    exit 1
fi
echo "✓ GPG installed: $(gpg --version | head -n 1)"
echo ""

# List existing GPG keys
echo "[3/6] Listing existing GPG keys..."
KEYS=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep "^sec" | awk '{print $2}' | cut -d'/' -f2)

if [ -z "$KEYS" ]; then
    echo "❌ Error: No GPG keys found"
    echo "   Please generate a GPG key first:"
    echo "   gpg --gen-key"
    exit 1
fi

echo "Found the following GPG keys:"
echo "$KEYS" | nl
echo ""

# Let user select a key
read -p "Please select the key number to use (default is 1): " KEY_NUM
KEY_NUM=${KEY_NUM:-1}
SIGNING_KEY=$(echo "$KEYS" | sed -n "${KEY_NUM}p")

if [ -z "$SIGNING_KEY" ]; then
    echo "❌ Error: Invalid key number"
    exit 1
fi

echo "✓ Key selected: $SIGNING_KEY"
echo ""

# Configure GPG
echo "[4/6] Configuring GPG..."
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg

cat > ~/.gnupg/gpg.conf << 'EOF'
use-agent
pinentry-mode loopback
EOF
chmod 600 ~/.gnupg/gpg.conf

cat > ~/.gnupg/gpg-agent.conf << 'EOF'
default-cache-ttl 28800
max-cache-ttl 28800
allow-loopback-pinentry
EOF
chmod 600 ~/.gnupg/gpg-agent.conf

echo "✓ GPG configuration completed"
echo ""

# Restart GPG Agent
echo "[5/6] Restarting GPG Agent..."
gpgconf --kill all 2>/dev/null || true
sleep 1
echo "✓ GPG Agent restarted"
echo ""

# Configure Git
echo "[6/6] Configuring Git..."

# Check if in a git repository
if [ ! -d ".git" ]; then
    echo "⚠ Warning: Current directory is not a Git repository, using global configuration"
    git config --global user.signingkey "$SIGNING_KEY"
    git config --global commit.gpgsign true
    git config --global gpg.program /usr/sbin/gpg
    SCOPE="Global"
else
    git config user.signingkey "$SIGNING_KEY"
    git config commit.gpgsign true
    git config gpg.program /usr/sbin/gpg
    SCOPE="Repository"
fi

echo "✓ Git configuration completed ($SCOPE)"
echo ""

# Verify configuration
echo "========================================="
echo "Configuration Verification"
echo "========================================="
echo ""
echo "Git Configuration:"
if [ ! -d ".git" ]; then
    git config --global --list | grep -E "user.signingkey|commit.gpgsign|gpg.program"
else
    git config --list | grep -E "user.signingkey|commit.gpgsign|gpg.program"
fi
echo ""

# Cache password
echo "========================================="
echo "Cache GPG Password"
echo "========================================="
echo ""
echo "Now you need to cache your GPG password (valid for 8 hours)"
echo "Please enter your GPG key password..."
echo ""

if echo "test" | gpg --sign --armor --detach-sign > /dev/null 2>&1; then
    echo "✓ GPG password cached"
else
    echo "⚠ Password caching failed, please run the following command manually to cache the password:"
    echo "   echo 'test' | gpg --sign --armor --detach-sign"
fi

echo ""
echo "========================================="
echo "✓ Configuration complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Restart VS Code to reload the configuration"
echo "2. When committing code in VS Code, the commit will automatically use GPG signing"
echo "3. Verify the signature: git log --show-signature -1"
echo ""
echo "To clear the password cache, run:"
echo "   gpg-connect-agent 'RELOADAGENT' /bye"
echo ""
