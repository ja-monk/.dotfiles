#-----   [[ Env setup script ]]   ------#

# NOTE: programs to be installed and config directory/repo name defined here 
config_dir=".dotfiles"
progs=(
    git
    tmux
    stow
    curl
    unzip
    npm
    ripgrep
    fd-find
    make
    gcc
    xclip
    fontconfig
    fonts-jetbrains-mono
    python3
    python-is-python3
)

# NOTE: if using in remote mode, git_details.txt file is required. See git_details.example for template

help(){
    echo "#-------------------------------------------------------------------------------------------#"
    echo "This script can be used to perform a basic set up of a local or remote environment that"
    echo "uses apt package manager (Debian, Ubuntu, etc.). It acts slightly differently in local vs"
    echo "remote mode."
    echo ""
    echo "Local Mode:"
    echo "  - Script runs on the computer it is configuring."
    echo "  - Assumes that ~/\$config_dir already exists as a collection of config files and this is"
    echo "    structured in the same way config files would be structured in \$HOME."
    echo "      e.g ~/\$config_dir/.bashrc or ~/\$config_dir/.config/{program}/{program.conf}"
    echo "  - Installs the programs defined in the \$progs variable and sym links config files."
    echo ""
    echo "  - USAGE:"
    echo "      ./env_setup.sh [local | l]"
    echo ""
    echo "Remote Mode:"
    echo "  - Script runs locally but is setting up a remote server."
    echo "  - Assumes a config github repo with the repo link and PAT token defined in ./git_details.txt"
    echo "    with the PAT token having SSH key permission to the github account."
    echo "  - Assumes ~/\$config_dir as described above does not already exist on the remote server, this"
    echo "    must match the name of github repo which will be cloned as part of the set up."
    echo "  - Clones the config github repo and sets up SSH keys for the repo using the PAT token."
    echo "  - Installs the programs defined in the \$progs variable and sym links config files."
    echo ""
    echo "  - USAGE:"
    echo "      ./env_setup.sh [remote | r] {IP | hostname}"
    echo "#-------------------------------------------------------------------------------------------#"

}

install_progs(){
    # install programs via apt
    sudo apt-get update
    sudo apt-get install -y "${progs[@]}"

    # install nvim & make it available in /usr/local/bin
    if command -v nvim &> /dev/null; then
        echo "Nvim install already found, skipping."
    else
        echo "Installing nvim."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        sudo rm -rf /opt/nvim-linux-x86_64
        sudo mkdir -p /opt/nvim-linux-x86_64
        sudo chmod a+rX /opt/nvim-linux-x86_64
        sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
        sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/
        rm -f ./nvim-linux-x86_64.tar.gz
    fi

    # install jetbrains mono nerd font as this is used in my config
    if fc-list | grep -q "JetBrainsMonoNerdFont"; then
        echo "JetBrainsMono Nerd Font already installed, skipping."
    else
        echo "Installing JetBrainsMono Nerd Font"
        wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip &&
        unzip ~/.local/share/fonts/JetBrainsMono.zip -d ~/.local/share/fonts &&
        rm ~/.local/share/fonts/JetBrainsMono.zip &&
        fc-cache -fv
    fi
    
    # clone tmux tpm plugin manager
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        echo "Tmux plugin manager found, skipping."
    else
        echo "Cloning tmux plugin manager."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
}

stow_config(){
    # backing up existing shell config files
    # TODO: Test what happens if files are links but file doesnt exist
    shell_config_files=(.bashrc .bash_aliases .profile)
    for file in "${shell_config_files[@]}"; do
        if [[ -f "$file" && ! -L "$file" ]]; then
            echo "$file being moved to $file.bkp to replace with sym links from ~/$config_dir."
            mv "$file" "$file".bkp
        fi
    done

    # stow config files and load .profile file
    echo "Stowing config files."
    cd "$HOME/$config_dir" && stow . && . $HOME/.profile
}

create_control_master_ssh() {
    # establish control master ssh session in background (-f) and with no shell (-N)
    ssh -fN \
        -o ControlMaster=yes \
        -o ControlPath=/tmp/ssh_session_%h_%p_%r \
        -o ControlPersist=10m \
        $host || {
            echo "Could not create ssh session to $host"
            exit
        }
}

check_preexisitng_config() {
    # check for preexisitng $config_dir
    local file_check=$(ssh -o ControlPath=/tmp/ssh_session_%h_%p_%r $host \
        "[[ -d \$HOME/$config_dir ]] && echo 'true' || echo 'false'")

    if [[ $file_check == "true" ]];then 
        echo "Existing config directory identified. Try to run locally instead."
        exit
    fi
}

check_ssh_keys() {
    # check if ssh keys already exist
    local key_check=$(ssh -o ControlPath=/tmp/ssh_session_%h_%p_%r $host \
        '[[ -f "$HOME"/.ssh/id_rsa.pub ]] && echo "true" || echo "false"')

    if [[ "$key_check" == "true" ]]; then
        echo "Confirmed ssh key exists."
        return 0
    elif [[ "$key_check" == "false" ]]; then
        echo "Could not find ssh keys."
        return 1
    else 
        echo "Issue with ssh key check."
        exit
    fi
}

create_ssh_keys() {
    echo "creating ssh keys."
    ssh -o ControlPath=/tmp/ssh_session_%h_%p_%r $host \
        'ssh-keygen -b 4096'
}

add_ssh_key_to_git() {
    echo "Adding remote ssh keys to GitHub profile."
    ssh -o ControlPath=/tmp/ssh_session_%h_%p_%r $host \
        "key=\$(cat \$HOME/.ssh/id_rsa.pub); \
        req='{\"title\":\"'\$USER@\$HOSTNAME'\",\"key\":\"'\$key'\"}'; \
        curl -L \
        -X POST \
        -H 'Authorization: Bearer $token' \
        https://api.github.com/user/keys \
        -d \"\$req\""
}

clone_config_repo() {
    echo "Cloning $config_repo to home directory."
    ssh -o ControlPath=/tmp/ssh_session_%h_%p_%r $host \
    "git clone $config_repo \$HOME/$config_dir"

    # check clone worked
    local file_check=$(ssh -o ControlPath=/tmp/ssh_session_%h_%p_%r $host \
        "[[ -d \$HOME/$config_dir ]] && echo 'true' || echo 'false'")

    if [[ $file_check == "false" ]]; then
        echo "Could not clone config repo. Exiting"
        exit
    fi
}

remote_install_stow() {
    # install programs remotely
    ssh -o ControlPath=/tmp/ssh_session_%h_%p_%r $host "\
    sudo apt-get update; \
    sudo apt-get install -y ${progs[@]}"

    ssh -o ControlPath=/tmp/ssh_session_%h_%p_%r $host "\
    config_dir=$config_dir; \
    $(declare -f install_progs); \
    $(declare  -f stow_config); \
    install_progs; \
    stow_config"
}

#-----   [[ Main ]]   -----#
if [[ ! "$1" == "remote" && ! "$1" == "r" && ! "$1" == "local" && ! "$1" == "l" ]]; then
    help
    exit
fi

if [[ "$1" == "local" || "$1" == "l" ]]; then
    [[ -d $HOME/$config_dir ]] || {
        echo "Cannot find $config_dir directory in home."
        exiting
    }
    echo "Installing programs and stowing config files."
    install_progs
    stow_config
    exit
fi

if [[ "$1" == "remote" || "$1" == "r" ]]; then
    host="$2"
    [[ -z $host ]] && {
        echo "Please provide hostname/IP of remote server."
        exit
    }

    # TODO: check that github repo name matches $config_dir
    
    echo "Creating ssh session to $host"
    create_control_master_ssh

    check_preexisitng_config

    echo "Confirming ssh keys exist and creating if not."
    check_ssh_keys || create_ssh_keys
    check_ssh_keys || {
        echo "Could not create ssh keys. Exiting"
        exit
    }

    # source git details from file
    . ./git_details.txt
    
    # add ssh key to git repo & clone
    add_ssh_key_to_git
    clone_config_repo

    echo "Installing programs and stowing config files."
    remote_install_stow
fi
