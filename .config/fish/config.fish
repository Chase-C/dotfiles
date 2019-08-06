source $__fish_config_dir/themes/nord.fish

abbr -a q exit
abbr -a e nvim
abbr -a vim nvim

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
    echo -n '' (set_color $nord9)(prompt_pwd) (set_color $nord12)'❯'(set_color $nord13)'❯'(set_color $nord14)'❯ '
end

function fish_greeting
end
