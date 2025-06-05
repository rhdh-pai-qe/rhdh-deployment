export RHDH_NAMESPACE="${RHDH_NAMESPACE:-rhdh-ns}"
export RHDH_URL="https://rhdh-${RHDH_NAMESPACE}.$(oc get ingress.config.openshift.io/cluster -o jsonpath='{.spec.domain}')"
export GH_PRIVATE_KEY_FILE="${GH_PRIVATE_KEY_FILE:-key.pem}"
export GH_PRIVATE_KEY="$(cat $GH_PRIVATE_KEY_FILE | base64 -w 0)"
export GH_PLACEHOLDER="$(echo -n PLACEHOLDER | base64 -w 0)"

if oc project ${RHDH_NAMESPACE} > /dev/null 2>&1; then
  oc delete project ${RHDH_NAMESPACE}
fi
oc new-project ${RHDH_NAMESPACE}

kustomize build base | envsubst '${RHDH_NAMESPACE},${RHDH_URL}' | sed "s/$GH_PLACEHOLDER/$GH_PRIVATE_KEY/" | oc apply -f -

oc rollout status deployment rhdh

echo "RHDH running at: ${RHDH_URL}"