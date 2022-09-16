#!/bin/bash
# provide path to spec.json from ht_tanka

tk_path=$1
repository=$2
environment=$3

if [[ -z "$tk_path" || -z "$repository" || ! -d $tk_path ]];
then cat <<EOT
Usage: $0 /path/to/tanka/environment organization/repository [environment]

If github_env isn't given, it will set repository secrets rather than
environment secrets. If you need to set multiple sets of repository secrets,
edit this script to change the name of the secrets it creates.
EOT
exit 1;
fi

tk_status=$(tk status $tk_path | sed 's/^ \+//')

tk_status_val () {
  echo "$tk_status" | grep "$1: " | cut -f 2 -d ' '
}

context=$(tk_status_val Context)
apiserver=$(tk_status_val APIServer)
namespace=$(tk_status_val Namespace)
github_token_secret=$(kubectl -n $namespace get -o jsonpath={.secrets[0].name} serviceaccount/github)

# if $github_token_secret IS null
if [[ -z "$github_token_secret" ]]; then
  echo "Can't find github service account secret in namespace $namespace";
  exit 1;
fi

echo "Context: $context"
echo "APIServer: $apiserver"
echo "Namespace: $namespace"
echo "Repository: $repository"
echo "Environment: $environment"
echo "GitHub secret: $github_token_secret"
echo 
echo "Press enter to continue or ctrl-C to abort"
read



# echo "Github token: $github_token"
# echo
# echo "CA cert"
# echo "$ca_cert"

# If $envirnoment IS NOT null
if [[ ! -z "$environment" ]]; then
  environment="-e $environment"
fi

set_secret () {
  bundle exec ruby set_secret.rb $environment "$repository" "$@"
}

source $(dirname $(realpath $0))/.env
export GITHUB_PAT

#if GITHUB_PAT env var is not set
if [[ -z "${GITHUB_PAT}" ]]; then
  echo "Can't find GITHUB_PAT environment variable. Set it in your .env file.";
  exit 1;
fi

kubectl --context $context --namespace $namespace get secret $github_token_secret -o jsonpath="{.data.token}" | set_secret KUBERNETES_TOKEN

# Could also get this from kubectl config
kubectl --context $context --namespace $namespace get secret $github_token_secret -o jsonpath='{.data.ca\.crt}' | set_secret KUBERNETES_CA

echo -n $apiserver | set_secret KUBERNETES_SERVER
echo -n $namespace | set_secret KUBERNETES_NAMESPACE
