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
    echo -n (whoami)
    echo -n ' | '
    if [ $PWD != $HOME ]
        echo -n (basename $PWD)
    else
        echo -n '~'
    end
    echo ' ▶ '
end

function fish_greeting
end
