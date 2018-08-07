# Binaries installation, searching, etc.

# Variables.
# Required binaries. Form: "binname:level". Level can be "warn",
# "fatal" and "superfatal".
BINARIES_REQUIRED=("curl:superfatal" "git:superfatal" "kubectl:fatal" "minikube:fatal" "sudo:superfatal" "tar:warn" "VBoxManage:warn" "unzip:fatal")
# Binaries not found.
# As string because it's easier to substring a string than search
# in array.
BINARIES_NOT_FOUND=""

#####################################################################
# Checks for requires binaries presence.
# If binary isn't present - check "fatality" level. On "warn" it
# just prints a message (e.g. optional dependency), on "fatal" it
# will exit immediately after printing a message (yet this can
# be fixed with --install-tools CLI parameter). "superfatal" means
# that this tool should be installed manually and DevSHOK will
# exit if this binary isn't present in system's PATH.
#####################################################################
function binaries_check_presence() {
    logger_log 0 "Checking required binaries presence..."

    # ToDo: which command/binary checks.

    for bin in ${BINARIES_REQUIRED[@]}; do
        local binary=$(echo ${bin} | awk -F":" {' print $1 '})
        local level=$(echo ${bin} | awk -F":" {' print $2 '})
        logger_log 1 "Checking for ${binary}..."
        local data=$(which ${binary})
        if [ "${#data}" != "0" ]; then
            logger_log 2 "\tFound ${binary} at '${data}'"
        else
            logger_error 0 "Required binary ${binary} wasn't found!"
            BINARIES_NOT_FOUND="${BINARIES_NOT_FOUND},${binary}"
            if [ "${level}" == "fatal" -a "${INSTALL_TOOLS}" != "true" ]; then
                logger_error 0 "This is a fatal error. Please fix it before proceeding!"
                logger_error 0 "For kubernetes tools (kubectl, minikube, all OSes) and VirtualBox (macOS only) this can be fixed by specifying '--install-tools true' CLI parameter."
                exit 2
            elif [ "${level}" == "superfatal" ]; then
                logger_error 0 "This binary is essential for DevSHOK. Install it manually before proceeding!"
                exit 2
            fi
        fi
    done

    if [ "${#BINARIES_NOT_FOUND}" != "0" ]; then
        logger_log 0 "Some binaries wasn't found, will install them now."
        _binaries_install
    else 
        logger_log 1 "All required binaries was found."
    fi
}

#####################################################################
# Launches OS-specific dependency installation function.
#####################################################################
function _binaries_install() {
    if [ "${OS}" == "Darwin" ]; then
        _binaries_install_macos
    elif [ "${OS}" == "Linux" ]; then
        _binaries_install_linux
    else
        logger_error 0 "Unsupported platform: ${OS}"
        exit 13
    fi
}

#####################################################################
# Installs dependencies on Linux.
#####################################################################
function _binaries_install_linux() {
    logger_log 1 "Linux detected, installing binaries from site..."

    # Due to different package managers this script is unable to detect
    # if VirtualBox is installed via PM, so we will check binary path.
    # If binary is missing - we will show notification about installation
    # neccessarity.
    if [ ! -f "/usr/bin/VBoxManage" ]; then
        logger_error 0 "VirtualBox isn't installed! Please install it using your package manager!"
        exit 15
    fi

    if [ ! -f /usr/local/bin/minikube ]; then
        logger_log 0 "Downloading minikube..."
        curl -Lo /tmp/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        logger_log 0 "Moving binary to /usr/local/bin with sudo, your account's password might be requested."
        sudo mv /tmp/minikube /usr/local/bin && sudo chmod +x /usr/local/bin/minikube
    else
        logger_log 1 "minikube binary found, will not install it. If you want to reinstall minikube - please delete it from /usr/local/bin!"
    fi

    if [ ! -f /usr/local/bin/kubectl ]; then
        logger_log 0 "Downloading kubectl..."
        curl -Lo /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl
        logger_log 0 "Moving binary to /usr/local/bin with sudo, your account's password might be requested."
        sudo mv /tmp/kubectl /usr/local/bin && sudo chmod +x /usr/local/bin/kubectl
    else
        logger_log 1 "kubectl binary found, will not install it. If you want to reinstall kubectl - please delete it from /usr/local/bin!"
    fi

}

#####################################################################
# Installs dependencies on macOS.
#####################################################################
function _binaries_install_macos() {
    logger_log 1 "macOS detected, will install dependencies via brew."
    if [ ! -f /usr/local/bin/brew ]; then
        logger_error 0 "Brew is not installed!"
        logger_log 0 "Will attempt to install Brew now. It will ask you for your password."
        common_execute /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        logger_log 1 "Brew is installed"
    fi

    logger_log 0 "Part 1 - kubectl package..."
    common_execute brew install kubectl

    logger_log 0 "Part 2 - virtualbox and minikube casks..."
    common_execute brew cask install minikube virtualbox virtualbox-extension-pack

    logger_log 0 "Required binaries was installed."
    logger_log 0 "NOTE: there might be installation error for VirtualBox. Ignore it and DO NOT PRESS CTRL+C HERE! Just allow kext to be loaded from security settings of your Mac!"
}