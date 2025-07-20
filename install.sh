# CLI-Boom: The one-line installer for Zsh sound effects.

echo "🚀 Installing CLI-Boom! Let's make your terminal noisy."

# --- Configuration ---
# Raw URLs from the GitHub repository
KUBECTL_SOUND_URL="https://raw.githubusercontent.com/YOUR-USERNAME/cli-boom/main/vine-boom.mp3"
IMPOSTOR_SOUND_URL="https://raw.githubusercontent.com/YOUR-USERNAME/cli-boom/main/impostor.mp3"

# Paths
ZSHRC_PATH="$HOME/.zshrc"
SOUND_DIR="$HOME/.cli-boom"
KUBECTL_SOUND_PATH="$SOUND_DIR/vine-boom.mp3"
IMPOSTOR_SOUND_PATH="$SOUND_DIR/impostor.mp3"

# The code snippet to be added to .zshrc
ZSH_FUNCTION_SNIPPET=$(cat <<'EOF'

# --- CLI-Boom Start ---
# As-you-type sound effects
_cli_boom_widget() {
    zle .self-insert

    # Check for kubectl
    if [[ "$BUFFER" == "kubectl" ]]; then
        if command -v afplay &> /dev/null; then # macOS
            afplay "$HOME/.cli-boom/vine-boom.mp3" &!
        elif command -v paplay &> /dev/null; then # Linux (PulseAudio)
            paplay "$HOME/.cli-boom/vine-boom.mp3" &!
        fi
    fi

    # Check for git push --force
    if [[ "$BUFFER" == "git push --force" ]]; then
        if command -v afplay &> /dev/null; then # macOS
            afplay "$HOME/.cli-boom/impostor.mp3" &!
            (sleep 2; echo "⚠️ Warning: You are about to force push! This can overwrite changes on the remote repository.") &!
        elif command -v paplay &> /dev/null; then # Linux (PulseAudio)
            paplay "$HOME/.cli-boom/impostor.mp3" &!
        fi
    fi
}

zle -N cli-boom-widget _cli_boom_widget
for key in {a..z} {A..Z} {0..9} ' ' '-'; do
    bindkey "$key" cli-boom-widget
done
# --- CLI-Boom End ---

EOF
)

# --- Installation Logic ---
echo "-> Creating sound directory at $SOUND_DIR..."
mkdir -p "$SOUND_DIR"

echo "-> Downloading sound effects..."
curl -fsSL "$KUBECTL_SOUND_URL" -o "$KUBECTL_SOUND_PATH"
if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to download the kubectl sound. Please check your URL."
        exit 1
fi

curl -fsSL "$IMPOSTOR_SOUND_URL" -o "$IMPOSTOR_SOUND_PATH"
if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to download the impostor sound. Please check your URL."
        exit 1
fi

echo "-> Adding CLI-Boom to your .zshrc..."
if grep -q "# --- CLI-Boom Start ---" "$ZSHRC_PATH"; then
        echo "-> CLI-Boom already exists. Updating..."
        # Create a backup
        cp "$ZSHRC_PATH" "$ZSHRC_PATH.backup.$(date +%Y%m%d_%H%M%S)"
        # Remove existing CLI-Boom section
        sed -i.tmp '/# --- CLI-Boom Start ---/,/# --- CLI-Boom End ---/d' "$ZSHRC_PATH"
        rm -f "$ZSHRC_PATH.tmp"
fi

# Add the new section
echo "$ZSH_FUNCTION_SNIPPET" >> "$ZSHRC_PATH"

echo ""
echo "✅ Success! CLI-Boom is installed/updated."
echo "Please restart your terminal or run 'source ~/.zshrc' to bring the noise!"
