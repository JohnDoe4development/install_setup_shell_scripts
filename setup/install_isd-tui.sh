#!/bin/bash

# reference
# https://github.com/isd-project/isd
# https://isd-project.github.io/isd/#installation
# https://github.com/isd-project/isd/issues/10

get_latest_ver() {
    local target_repo=$2
    local latest_ver=$(curl -s "https://api.github.com/repos/${target_repo}/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
    eval "$1=${latest_ver}"
}

check_url() {
    curl -f --head -s $1 > /dev/null
}

echo "インストール方法を選択してください."
select install_method in "uv" "AppImage"; do
    case $install_method in
        "uv")
            python_version=3.12
            # pythonのパッケージマネージャであるuvのインストール
            curl -LsSf https://astral.sh/uv/install.sh | sh
            # isdのインストール
            uv tool install --python=${python_version} isd-tui
            break
            ;;
        "AppImage")
            target_repo="isd-project/isd"
            target_name="isd"
            get_latest_ver LATEST_VER "${target_repo}"
            target_url="https://github.com/${target_repo}/releases/download/v${LATEST_VER}/${target_name}.x86_64-linux.AppImage"
            if $(check_url "${target_url}"); then
                curl ${target_url} -Lo isd-tui.AppImage 
            else
                echo "Error: ${target_name} download URL does not exist: ${target_url}"
                exit 1
            fi
            chmod +x isd-tui.AppImage
            sudo mv isd-tui.AppImage /home/${USER}/.local/bin/isd-tui
            
            sudo tee /etc/apparmor.d/isd-appimage <<- EOF > /dev/null

			# This profile allows everything and only exists to give the
			# application a name instead of having the label "unconfined"

			abi <abi/4.0>,
			include <tunables/global>

			profile isd-tui /home/${USER}/.local/bin/isd-tui flags=(unconfined) {
			  userns,

			  # Site-specific additions and overrides.  See local/README for details.
			  include if exists <local/isd-tui>
			}
			EOF
            sudo apparmor_parser -r /etc/apparmor.d/isd-appimage
            break
            ;;
        *) 
            echo "1または2を選択してください."
            ;;
    esac
done
