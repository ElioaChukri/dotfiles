export ZDOTDIR="$HOME/.config/zsh"
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway

# Enable Wayland support in Firefox
export MOZ_ENABLE_WAYLAND=1

# To fix Java GUI apps on Wayland
export _JAVA_AWT_WM_NONREPARENTING=1

# Save screenshots to ~/Pictures/Screenshots
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_SCREENSHOTS_DIR="$XDG_PICTURES_DIR/Screenshots"

# Dark mode for QT apps
export QT_QPA_PLATFORM=wayland
export QT_STYLE_OVERRIDE=Adwaita-dark
