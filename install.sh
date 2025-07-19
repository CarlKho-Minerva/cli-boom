#!/bin/bash

# CLI-Boom: The one-line installer for Zsh sound effects.

echo "🚀 Installing CLI-Boom! Let's make your terminal noisy."

# --- Configuration ---
# Using the URLs you provided.
# IMPORTANT: Replace your username with your GitHub username!
KUBECTL_SOUND_URL="https://raw.githubusercontent.com/<YOUR-USERNAME-HERE>/cli-boom/main/vine-boom.mp3"
IMPOSTOR_SOUND_URL="https://raw.githubusercontent.com/<YOUR-USERNAME-HERE>/cli-boom/main/impostor.mp3"

# Paths
ZSHRC_PATH="$HOME/.zshrc"
SOUND_DIR="$HOME/.cli-boom"
KUBECTL_SOUND_PATH="$SOUND_DIR/vine-boom.mp3"
IMPOSTOR_SOUND_PATH="$SOUND_DIR/impostor.mp3"

# The code snippet to be added to .zshrc
# This version combines all logic into a single as-you-type widget.
ZSH_FUNCTION_SNIPPET=$(cat <<'EOF'

# --- CLI-Boom Start ---
# A single widget to handle all as-you-type sound effects.
_cli_boom_widget() {
  # This command performs the normal action of typing the character.
  zle .self-insert

  # Check the full command buffer after the key is pressed.
  case "$BUFFER" in
    "kubectl")
      if command -v afplay &> /dev/null; then # macOS
        afplay "$HOME/.cli-boom/vine-boom.mp3" &!
      elif command -v paplay &> /dev/null; then # Linux (PulseAudio)
        paplay "$HOME/.cli-boom/vine-boom.mp3" &!
      fi
      ;;
    "git push --force")
      if command -v afplay &> /dev/null; then # macOS
        afplay "$HOME/.cli-boom/impostor.mp3" &!
      elif command -v paplay &> /dev/null; then # Linux (PulseAudio)
        paplay "$HOME/.cli-boom/impostor.mp3" &!
      fi
      ;;
  esac
}

# Create a new ZLE widget from the function.
zle -N cli-boom-widget _cli_boom_widget

# Bind this widget to all keys that could be part of the commands.
# This ensures that typing letters, spaces, or hyphens will trigger the check.
for key in {a..z} {A..Z} ' ' '-'; do
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
    echo "❌ Error: Failed to download the kubectl sound. Please check the URL."
    exit 1
fi

curl -fsSL "$IMPOSTOR_SOUND_URL" -o "$IMPOSTOR_SOUND_PATH"
if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to download the impostor sound. Please check the URL."
    exit 1
fi

# A simple uninstaller to run first, ensuring clean updates.
if grep -q "# --- CLI-Boom Start ---" "$ZSHRC_PATH"; then
    echo "-> Found a previous version. Removing it before reinstalling..."
    awk '
        /# --- CLI-Boom Start ---/ { in_block = 1; next }
        /# --- CLI-Boom End ---/ { in_block = 0; next }
        !in_block { print }
    ' "$ZSHRC_PATH" > "${ZSHRC_PATH}.tmp" && mv "${ZSHRC_PATH}.tmp" "$ZSHRC_PATH"
fi

echo "-> Adding CLI-Boom to your .zshrc..."
echo "$ZSH_FUNCTION_SNIPPET" >> "$ZSHRC_PATH"

echo ""
echo "✅ Success! CLI-Boom is installed."
echo "Please restart your terminal or run 'source ~/.zshrc' to bring the noise!"