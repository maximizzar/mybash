#!/usr/bin/env bash

# Don't use sudo? change the alias
alias sudo='sudo'

# functions
install_common() {
        if ! [ "$(command -v sudo)" ]; then
                apt install -y sudo;
                echo "Restart with sudo"
                exit 0;
        fi
        if ! [ "$(command -v curl)" ]; then
                sudo apt install -y curl;
        fi
        if ! [ "$(command -v gpg)" ]; then
                sudo apt install -y gpg;
        fi
        if ! [ "$(command -v jq)" ]; then
                sudo apt install -y jq;
        fi
        if ! [ "$(command -v btop)" ]; then
                sudo apt install -y btop;
        fi
        if ! [ "$(command -v shellcheck)" ]; then
                sudo apt install -y shellcheck;
        fi
}
install_eza() {
        if ! [ "$(command -v eza)" ]; then
                sudo mkdir -p /etc/apt/keyrings;
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg;
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list;
                sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list;
                sudo apt update;
                sudo apt install -y eza;
        else
                echo "eza: already Installed!"
        fi
}
install_go() {(
        cd /tmp || exit 1
        os="linux"
        arch="$(uname -m)"
        ext="tar.gz"
        go_version=$(curl "https://go.dev/dl/?mode=json" | jq -r '.[0].version');
        curl -LO "go.dev/dl/$go_version.$os-$arch.$ext"

        sudo rm -rf /usr/local/go;
        sudo tar -C /usr/local -xzf "$go_version.$os-$arch.$ext"

        if ! [ "$(command -v go)" ]; then
                export PATH=$PATH:/usr/local/go/bin
        fi

)}
install_maximizzar_scripts() {
          PS3='Install maximizzar-scripts (will replace old ones if present):'
          options=("Install" "Quit")
          select opt in "${options[@]}"
          do
              case $opt in
                  "Install")
                          # convert-wav-to-flac
                          sudo cp scripts/convert-wav-to-flac.sh /usr/local/bin/convert-wav-to-flac;
                          sudo chown root:root /usr/local/bin/convert-wav-to-flac;
                          sudo chmod 755 /usr/local/bin/convert-wav-to-flac;

                          # extract-audiosteams
                          sudo cp scripts/extract-audiosteams.sh /usr/local/bin/extract-audiosteams;
                          sudo chown root:root /usr/local/bin/extract-audiosteams;
                          sudo chmod 755 /usr/local/bin/extract-audiosteams;

                  break;;
                  "Quit") break;;
                  *) echo "invalid option $REPLY";;
              esac
          done
}
install_media_tools() {
          if ! [ "$(command -v ffmpeg)" ]; then
                  sudo apt install ffmpeg;
          fi

          if ! [ "$(command -v mpv)" ]; then
                  sudo apt install mpv;
          fi

          if ! [ "$(command -v loudgain)" ]; then
                  sudo apt install loudgain;
          fi
}
install_downloader() {
        if ! [ "$(command -v pipx)" ]; then
                sudo apt install -y pipx;
                pipx ensurepath
                eval "$(register-python-argcomplete pipx)"
        fi

        pipx install yt-dlp
        pipx install gallery-dl
}
install_nala() {
        if ! [ "$(command -v nala)" ]; then
                curl https://gitlab.com/volian/volian-archive/-/raw/main/install-nala.sh | bash;
        else
                echo "nala: already Installed!";
        fi
}
install_rust() {
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh;
}

setup_desktop() {
        echo "Setup is in Desktop mode."
        install_common; install_eza; install_nala;
        install_rust; install_go;
        install_maximizzar_scripts;
        install_downloader; install_media_tools;

        mkdir .ssh

        if [ -f "$HOME/.ssh/config" ]; then
                echo "Skipping ssh config. It already exists"
        else
                ln -s .ssh/config "$HOME/.ssh/config";
        fi

}
setup_host() {
        echo "Setup is in Host mode."
        install_common; install_eza; install_nala;
}
setup_guest() {
        echo "Setup is in Guest mode."
        install_common; install_eza; install_nala;
}

main() {
        if [ -f "$HOME/.bashrc" ]; then
                echo "Skipping .bashrc. It already exists"
        else
                ln -s "$(pwd)"/.bash/rc "$HOME"/.bashrc;
        fi

        if [ -f "$HOME/.bash_aliases" ]; then
                echo "Skipping .bash_aliases. It already exists"
        else
                ln -s "$(pwd)"/.bash/aliases "$HOME"/.bash_aliases;
        fi

        PS3='Choose system type:'
        options=("Desktop" "Host System" "Guest System" "Quit")
        select opt in "${options[@]}"; do
                case $opt in
                        "Desktop")      setup_desktop; break;;
                        "Host System")  setup_host; break;;
                        "Guest System") setup_guest; break;;
                        "Quit") break;;
                        *) echo "invalid option $REPLY";;
                esac
        done
}

main
