#!/bin/sh
set -eu
LINKERD2_VERSION=${LINKERD2_VERSION:-edge-24.8.2}
INSTALLROOT=${INSTALLROOT:-"$(eval echo ~$SUDO_USER)/.linkerd2"}
happyexit() {
  echo ""
  echo "Add the linkerd CLI to your path with:"
  echo ""
  echo "  export PATH=\$PATH:${INSTALLROOT}/bin"
  echo ""
  echo "Now run:"
  echo ""
  echo "  linkerd check --pre                     # validate that Linkerd can be installed"
  echo "  linkerd install --crds | kubectl apply -f - # install the Linkerd CRDs"
  echo "  linkerd install | kubectl apply -f -    # install the control plane into the 'linkerd' namespace"
  echo "  linkerd check                           # validate everything worked!"
  echo ""
  echo "You can also obtain observability features by installing the viz extension:"
  echo ""
  echo "  linkerd viz install | kubectl apply -f -  # install the viz extension into the 'linkerd-viz' namespace"
  echo "  linkerd viz check                         # validate the extension works!"
  echo "  linkerd viz dashboard                     # launch the dashboard"
  echo ""
  echo "Looking for more? Visit https://linkerd.io/2/tasks"
  echo ""
  exit 0
}
OS=$(uname -s)
arch=$(uname -m)
cli_arch=""
case $OS in
  CYGWIN* | MINGW64*)
    OS=windows.exe
    ;;
  Darwin)
    case $arch in
      x86_64)
         cli_arch=""
        ;;
      arm64)
        cli_arch=$arch
        ;;
      *)
        echo "There is no linkerd $OS support for $arch. Please open an issue with your platform details."
        exit 1
        ;;
    esac
    ;;
  Linux)
    case $arch in
      x86_64)
        cli_arch=amd64
        ;;
      armv8)
        cli_arch=arm64
        ;;
      aarch64*)
        cli_arch=arm64
        ;;
      armv*)
        cli_arch=arm
        ;;
      amd64|arm64)
        cli_arch=$arch
        ;;
      *)
        echo "There is no linkerd $OS support for $arch. Please open an issue with your platform details."
        exit 1
        ;;
    esac
    ;;
  *)
    echo "There is no linkerd support for $OS/$arch. Please open an issue with your platform details."
    exit 1
    ;;
esac
dstfile="$(pwd)/linkerd2-cli-edge-24.8.2-linux-amd64"
(
  mkdir -p "${INSTALLROOT}/bin"
  chmod +x "${dstfile}"
  rm -f "${INSTALLROOT}/bin/linkerd"
  ln -s "${dstfile}" "${INSTALLROOT}/bin/linkerd"
)
rm -r "$tmpdir"
echo "Linkerd ${LINKERD2_VERSION} was successfully installed 🎉"
echo ""
happyexit
finally,
linkerd check --pre                     
linkerd install --crds | kubectl apply -f -
linkerd install --set proxyInit.runAsRoot=true | kubectl apply -f -    
linkerd check                           
linkerd viz install | kubectl apply -f -
linkerd viz check
