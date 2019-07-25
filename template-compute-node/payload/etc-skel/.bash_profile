## Interactive bash shells source this at login.

if [[ -f ~/.bashrc ]] ; then
    . ~/.bashrc
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/bin" ]] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/.local/bin" ]] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

echo "Setting up passwordless cluster access..."

if [[ ! -d ~/.ssh ]] ; then
    mkdir ~/.ssh
fi

if [[ ! -f ~/.ssh/id_ed25519 ]]; then
    ssh-keygen -o -a 256 -t ed25519  -N '' -f ~/.ssh/id_ed25519
    if [[ ! -f ~/.ssh/authorized_keys ]]; then
        cp ~/.ssh/id_ed25519.pub ~/.ssh/authorized_keys
    fi
fi

eval "$(ssh-agent -s)"
ssh-add

if [[ $(hostname -s) == "head" ]]; then
    echo ""
    echo "** Remember: do NOT run compute jobs on the head node."
    echo ""
fi
