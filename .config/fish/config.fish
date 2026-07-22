abbr -a q exit
abbr -a e nvim
abbr -a vim nvim

# Delete one path component (rather than the entire argument) with Alt-Backspace.
bind alt-backspace backward-kill-path-component

abbr -a pac sudo pacman --color=auto
abbr -a pacman sudo pacman --color=auto
abbr -a yay yay --color=auto

# Add to PATH
set -U fish_user_paths $fish_user_paths \
  ~/bin \
  ~/.cargo/bin \
  ~/.npm-global/bin \
  ~/.local/bin \
  ~/.bun/bin

# Set environment variables
set -g -x EDITOR nvim
set -g -x MOZ_ENABLE_WAYLAND 1
set -g -x NOTMUCH_CONFIG ~/.config/notmuch/config
set -g -x ECS_CLUSTER_PREFIX '^'
set -g -x _JAVA_AWT_WM_NONREPARENTING 1
set -g -x STUDIO_JDK /usr/lib/jvm/java-11-openjdk/
set -g -x XDG_CURRENT_DESKTOP sway
set -g -x NPM_CREDS_USER npm-deploy
set -g -x NPM_CREDS_PW UGFzc3dvcmQ3Jg==
set -g -x DOCKER_BUILDKIT 1

if command -v bat > /dev/null
    abbr -a cat bat
end

if command -v eza > /dev/null
    abbr -a l eza
    abbr -a ls eza
    abbr -a ll eza -l
    abbr -a la eza -la
else
    abbr -a l ls
    abbr -a ll ls -l
    abbr -a la ls -la
end

function fish_prompt
    # '❯' = \u276f
    # '' = \ue216
    set -l directory 7aa2f7
    set -l red f7768e
    set -l yellow e0af68
    set -l green 9ece6a
    #echo -n '' (set_color $directory)(prompt_pwd) (set_color $red)'❯'(set_color $yellow)'❯'(set_color $green)'❯ '
    echo -n '' (set_color $directory)(prompt_pwd) (set_color $red)''(set_color $yellow)''(set_color $green)' '
end

function fish_greeting
end
