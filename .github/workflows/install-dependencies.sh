#!/usr/bin/env bash

################################################################################################################
#   DESCRIPTION:
#         The SHELL SCRIPT WOULD TEST
#                  - The script would install linux dependencies
#   INPUTS:
#         You can use the ENVIRONMENT VARIABLES to enable/disable any installation.
#         By default all the installations are set to false
################################################################################################################



ENV_INSTALL_BINARY_DIRECTORY_LINUX="$HOME/bin"


ENV_INSTALL_KUBESEAL=${ENV_INSTALL_KUBESEAL:=false}
ENV_KUBESEAL_VERSION=${ENV_KUBESEAL_VERSION:=0.18.1}
ENV_KUBESEAL_TAR_BINARY_SHA=${ENV_KUBESEAL_TAR_BINARY_SHA:=78875afdbfa958d06b4fe6e7ea63bdea8c7e944fda6425769e2a0394ac33899e}
ENV_KUBESEAL_TAR_BINARY_DOWNLOAD_URL=${ENV_KUBESEAL_TAR_BINARY_DOWNLOAD_URL:="https://github.com/bitnami-labs/sealed-secrets/releases/download/v${ENV_KUBESEAL_VERSION}/kubeseal-${ENV_KUBESEAL_VERSION}-linux-amd64.tar.gz"}
ENV_SCRIPT_FAILURE_EXIT_CODE=127

ENV_INSTALL_GOMPLATE=${ENV_INSTALL_GOMPLATE:=false}
ENV_GOMPLATE_VERSION="v3.11.2"
ENV_GOMPLATE_DOWNLOAD_URL="https://github.com/hairyhenderson/gomplate/releases/download/${ENV_GOMPLATE_VERSION}/gomplate_linux-amd64"
ENV_GOMPLATE_SHA_256_SUM="53858f4c6b68a0bea0a66430760eb0948c7745f6d3052a395507e6bb9c6964a9"

ENV_INSTALL_KUBEVAL=${ENV_INSTALL_KUBEVAL:=false}
ENV_KUBEVAL_VERSION="v0.16.1"
ENV_KUBEVAL_DOWNLOAD_URL="https://github.com/instrumenta/kubeval/releases/download/${ENV_KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz"
ENV_KUBEVAL_SHA_256_SUM=${ENV_KUBEVAL_SHA_256_SUM:="2d6f9bda1423b93787fa05d9e8dfce2fc1190fefbcd9d0936b9635f3f78ba790"}

ENV_INSTALL_KUBESCORE=${ENV_INSTALL_KUBESCORE:=false}
ENV_KUBESCORE_VERSION="1.14.0"
ENV_KUBESCORE_DOWNLOAD_URL="https://github.com/zegl/kube-score/releases/download/v${ENV_KUBESCORE_VERSION}/kube-score_${ENV_KUBESCORE_VERSION}_linux_amd64"
ENV_KUBESCORE_SHA_256_SUM="6bb7a74c77642620f1c7c23a5eb3b5334fc086ff385ae5b8dfe9ec1ddc223a80"


ENV_INSTALL_OCI=${ENV_INSTALL_OCI:=false}
#ENV_OCI_VERSION="3.5.3"
#ENV_OCI_DOWNLOAD_URL="https://github.com/oracle/oci-cli/releases/download/v${ENV_OCI_VERSION}/oci-cli-${ENV_OCI_VERSION}-Ubuntu-20.04-Offline.zip"
#ENV_OCI_SHA_256_SUM="e200484f1b6c1bcc98b58f5f45178ace308431dcbfec4cdd32ef467da17eec82"
ENV_OCI_VERSION="3.54.3"
ENV_OCI_DOWNLOAD_URL="https://github.com/oracle/oci-cli/releases/download/v3.54.3/oci-cli-3.54.3.zip"
ENV_OCI_SHA_256_SUM="57642993d5d36daf4614017c8298e7c43e3e5e6e42b0eb1d0c5c83ddba4418ea"

ENV_INSTALLED_MODULE=false





############################################################################
#      DESCRIPTION:
#              Function to Install the tar binary in required path
#      INPUTS:
#                $1: The absolute path where the binary needs to be installed
#                $2: The URL from where the tar version will be downloaded
#                $3: The name of the binary to be installed
#                $4: required_sha of the downloaded file
############################################################################
function download_And_Install_Tar_Binary() {
  local binary_name="$3";
  local binary_installation_path="$1";
  local binary_url="$2";
  local required_sha="$4";
  echo "********* Downloading and installing binary for $binary_name"
  curl -sLo /tmp/new_tar_binary.tgz "$binary_url";
  echo "$required_sha /tmp/new_tar_binary.tgz"  | sha256sum --check || exit $ENV_SCRIPT_FAILURE_EXIT_CODE
  tar -C /tmp/ -xf /tmp/new_tar_binary.tgz
  mv "/tmp/$binary_name" "$binary_installation_path/$binary_name"  || exit $ENV_SCRIPT_FAILURE_EXIT_CODE
  chmod +x "$binary_installation_path/$binary_name"  || exit $ENV_SCRIPT_FAILURE_EXIT_CODE
}



############################################################################
#      DESCRIPTION:
#              Function to Install the binary in required path
#      INPUTS:
#                $1: The absolute path where the binary needs to be installed
#                $2: The URL from where the binary will be downloaded
#                $3: The name of the binary to be installed
#                $4: required_sha of the downloaded file
############################################################################
function download_And_Install_Binary() {
  local binary_installation_path=$1;
  local binary_name=$3;
  local binary_url=$2;
  local required_sha=$4;
  echo "********* Downloading and installing binary for $binary_name"
  # curl -sLo "$binary_installation_path/$binary_name" "$binary_url";
  curl -L --retry 3 -sLo "$binary_installation_path/$binary_name" "$binary_url"
  echo "$required_sha $binary_installation_path/$binary_name" | sha256sum --check || exit $ENV_SCRIPT_FAILURE_EXIT_CODE
  chmod +x "$binary_installation_path/$binary_name" || exit $ENV_SCRIPT_FAILURE_EXIT_CODE
}


if [ "$(uname)" == "Linux" ]; then
## Flow to check if Build is fine, k8s kubescore and kubeval
  echo "Running on Linux...."

  ## Set path where binaries would be installed
  echo "******* Setting binary path to $ENV_INSTALL_BINARY_DIRECTORY_LINUX on linux ***********"
  mkdir -p "$ENV_INSTALL_BINARY_DIRECTORY_LINUX" || exit $ENV_SCRIPT_FAILURE_EXIT_CODE
  export PATH="$ENV_INSTALL_BINARY_DIRECTORY_LINUX:$PATH" || exit $ENV_SCRIPT_FAILURE_EXIT_CODE
else
  echo "Unrecognized OS....Exiting......."
  exit $ENV_SCRIPT_FAILURE_EXIT_CODE
fi




if $ENV_INSTALL_KUBESEAL; then
  download_And_Install_Tar_Binary $ENV_INSTALL_BINARY_DIRECTORY_LINUX $ENV_KUBESEAL_TAR_BINARY_DOWNLOAD_URL "kubeseal" $ENV_KUBESEAL_TAR_BINARY_SHA
  kubeseal --version
  ENV_INSTALLED_MODULE=true
fi

if $ENV_INSTALL_KUBEVAL; then
  download_And_Install_Tar_Binary $ENV_INSTALL_BINARY_DIRECTORY_LINUX $ENV_KUBEVAL_DOWNLOAD_URL "kubeval" $ENV_KUBEVAL_SHA_256_SUM
  kubeval --version
  ENV_INSTALLED_MODULE=true
fi

if $ENV_INSTALL_KUBESCORE; then
  download_And_Install_Binary     $ENV_INSTALL_BINARY_DIRECTORY_LINUX $ENV_KUBESCORE_DOWNLOAD_URL "kube-score" $ENV_KUBESCORE_SHA_256_SUM
  kube-score version
  ENV_INSTALLED_MODULE=true
fi

if $ENV_INSTALL_GOMPLATE; then
  download_And_Install_Binary     $ENV_INSTALL_BINARY_DIRECTORY_LINUX $ENV_GOMPLATE_DOWNLOAD_URL "gomplate" $ENV_GOMPLATE_SHA_256_SUM
  gomplate -v
  ENV_INSTALLED_MODULE=true
fi

# if $ENV_INSTALL_OCI; then
#   curl -sLo "$ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci.zip" "$ENV_OCI_DOWNLOAD_URL";
#   unzip -qq "$ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci.zip" -d "$ENV_INSTALL_BINARY_DIRECTORY_LINUX"
#   echo "$ENV_OCI_SHA_256_SUM $ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci.zip"  | sha256sum --check || exit $ENV_SCRIPT_FAILURE_EXIT_CODE
#   #echo "$ENV_OCI_SHA_256_SUM $ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci.zip" | sha256sum --quiet --check || echo "Checksum validation skipped..."
#   cd $ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci-cli-installation && chmod +x install.sh && ./install.sh --offline-install --accept-all-defaults
#   cd -
#   oci --version
# fi

if $ENV_INSTALL_OCI; then
  echo "Installing OCI CLI for v3.54.3 ..."
  curl -sLo "$ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci.zip" "$ENV_OCI_DOWNLOAD_URL"
  unzip -qq "$ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci.zip" -d "$ENV_INSTALL_BINARY_DIRECTORY_LINUX"
  echo "$ENV_OCI_SHA_256_SUM $ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci.zip" | sha256sum --check || exit $ENV_SCRIPT_FAILURE_EXIT_CODE
  ls -lh $ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci.zip
  ls -lh $ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci-cli
  #python3 -m pip install --user "$ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci-cli/oci_cli-3.54.3-py3-none-any.whl" || exit $ENV_SCRIPT_FAILURE_EXIT_CODE
  python3 -m pip install --user "$ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci-cli/oci_cli-3.54.3-py3-none-any.whl" || { echo "err in installing dependency oci-cli v3.54.3" >&2; exit 1; }
  export PATH="$HOME/.local/bin:$PATH"
  echo "PATH:" $PATH
  #cd $ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci-cli || exit $ENV_SCRIPT_FAILURE_EXIT_CODE
  #export PATH="$ENV_INSTALL_BINARY_DIRECTORY_LINUX/oci-cli/bin:$PATH"
  oci --version || exit $ENV_SCRIPT_FAILURE_EXIT_CODE
fi

if ! $ENV_INSTALLED_MODULE; then
  echo "No modules were installed. Please check if appropriate ENVs were passed to the script"
fi

