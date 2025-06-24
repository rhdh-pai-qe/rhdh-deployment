while [[ $# -gt 0 ]]; do
  key=$1
  case $key in
    --keycloak)
      KEYCLOAK=true
      shift
      ;;
  esac
done

export RHDH_NAMESPACE="${RHDH_NAMESPACE:-rhdh-ns}"
export RHDH_URL="https://rhdh-${RHDH_NAMESPACE}.$(oc get ingress.config.openshift.io/cluster -o jsonpath='{.spec.domain}')"
export GH_PRIVATE_KEY_FILE="${GH_PRIVATE_KEY_FILE:-key.pem}"
export GH_PRIVATE_KEY="$(cat $GH_PRIVATE_KEY_FILE | base64 -w 0)"
export GH_PLACEHOLDER="$(echo -n PLACEHOLDER | base64 -w 0)"
export LIGHTSPEED_IMAGE_TAG="${LIGHTSPEED_IMAGE_TAG:-quay.io/karthik_jk/lightspeed:latest}"
export INSIGHTS_IMAGE_TAG="${INSIGHTS_IMAGE_TAG:-quay.io/jrichter/adoption-insights:test}"

if oc project ${RHDH_NAMESPACE} > /dev/null 2>&1; then
  oc delete project ${RHDH_NAMESPACE}
fi
oc new-project ${RHDH_NAMESPACE}

mode=base
if [ "$KEYCLOAK" = true ]; then
  mode=keycloak
fi

if which kustomize >/dev/null 2>&1; then
  binary=kustomize
elif ./kustomize version >/dev/null 2>&1; then
  binary=./kustomize
else
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
  binary=./kustomize
fi

$binary build $mode | envsubst '${RHDH_NAMESPACE},${RHDH_URL},${LIGHTSPEED_IMAGE_TAG},${INSIGHTS_IMAGE_TAG}' | sed "s/$GH_PLACEHOLDER/$GH_PRIVATE_KEY/" | oc apply -f -

oc rollout status deployment rhdh

echo "RHDH running at: ${RHDH_URL}"
