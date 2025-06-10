# rhdh-deployment

Minimal RHDH 1.6 deployment with pre-installed plugins. Uses either github (default), or keycloak for authentication.

## Requirements
 - `oc` command line tool
 - `kustomize` command line tool
 - openshift cluster (4.16 onwards recommended)
 - github organization with an installed application
 - model service for lightspeed plugin
 - (optional) keycloak as another authentication option

## Setup

Make a copy of `base/template.env` file called `private.env` and fill out all the empty variables for the github application and lightspeed setup.
Do not override the `PLACEHOLDER` value. Any `DUMMY` value is not strictly necessary for this deployment and only serves to satisfy RHDH to not have empty config fields.

Download the private key file from your github application, and store its location into `GH_PRIVATE_KEY_FILE` env variable (or simply copy it into the root of this project and call it `key.pem`).

Edit any RHDH configuration in `base/app-config.yaml` and `base/dynamic-plugins.yaml` as desired.

`oc login` to your cluster.

Select which project to deploy into by editing `RHDH_NAMESPACE` env variable, or use the default `rhdh-ns`. **!!Note that this namespace will be wiped before deploying the resources!!**

Run the `apply.sh` file in your shell.

### Keycloak as auth provider

Make sure you have a properly set up instance of keycloak with a realm and a client running.

The following variables in the env file are tied to keycloak setup and can be left empty if keycloak is not being used:
 - `KEYCLOAK_CLIENT_ID` name of the client, get this from your keycloak admin console
 - `KEYCLOAK_CLIENT_SECRET` get this from the client details => credentials in keycloak console
 - `KEYCLOAK_BASE_URL` URL to `https://<your-keycloak-route>/auth`
 - `KEYCLOAK_METADATA_URL` equals to `${KEYCLOAK_BASE_URL}/realms/${KEYCLOAK_REALM}`
 - `KEYCLOAK_REALM` name of the realm, get in your keycloak admin console
 - `BACKEND_SECRET` session secret for RHDH, set as desired

Running `apply.sh --keycloak` will deploy RHDH with keycloak auth config.