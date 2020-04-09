source $__fish_config_dir/themes/nord.fish

abbr -a q exit
abbr -a e nvim
abbr -a vim nvim

abbr -a pac sudo pacman --color=auto
abbr -a pacman sudo pacman --color=auto
abbr -a aur pacaur --color=auto

# Add to PATH
set -U fish_user_paths $fish_user_paths ~/bin

# Set environment variables
set -g -x MOZ_ENABLE_WAYLAND 1
set -g -x EDITOR nvim
set -g -x ECS_CLUSTER_PREFIX '^'
set -g -x _JAVA_AWT_WM_NONREPARENTING 1

if command -v bat > /dev/null
    abbr -a cat bat
end

if command -v exa > /dev/null
    abbr -a l exa
    abbr -a ls exa
    abbr -a ll exa -l
    abbr -a la exa -la
else
    abbr -a l ls
    abbr -a ll ls -l
    abbr -a la ls -la
end

function fish_prompt
    # '❯' = \u276f
    echo -n '' (set_color $nord9)(prompt_pwd) (set_color $nord12)'❯'(set_color $nord13)'❯'(set_color $nord14)'❯ '
end

function fish_greeting
end
