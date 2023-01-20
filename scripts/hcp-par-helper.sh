#! /usr/bin/env bash

set -eEuo pipefail

usage() {
  cat <<EOF
This script allows easy interaction with the HCP Packer Artifact Registry

Usage:
   $(basename "$0") <resource> <action> <args>

Examples:
 > $(basename "$0") buckets get
 > $(basename "$0") buckets get <bucket_slug>
 > $(basename "$0") iterations get <bucket_slug>
 > $(basename "$0") iterations get <bucket_slug>  -i <iteration_id>
 > $(basename "$0") iterations get <bucket_slug>  --iteration_id <iteration_id>
 > $(basename "$0") iterations get <bucket_slug> -f <fingerprint>
 > $(basename "$0") iterations get <bucket_slug> --fingerprint <fingerprint>
 > $(basename "$0") builds get <bucket_slug> <iteration_id>
 > $(basename "$0") channels create <bucket_slug> <channel_name>
 > $(basename "$0") channels get <bucket_slug>
 > $(basename "$0") channels get <bucket_slug> <channel_name>
 > $(basename "$0") channels get-iteration <bucket_slug> <channel_name>
 > $(basename "$0") channels set-iteration <bucket_slug> <channel_name> <iteration_id>
 > $(basename "$0") channels set-iteration <bucket_slug> <channel_name> -f <fingerprint>
 > $(basename "$0") channels set-iteration <bucket_slug> <channel_name> --fingerprint <fingerprint>

---

Requires the following environment variables to be set:
 - HCP_CLIENT_ID
 - HCP_CLIENT_SECRET
 - HCP_ORGANIZATION_ID
 - HCP_PROJECT_ID
EOF
  exit 1
}

base_url="https://api.cloud.hashicorp.com/packer/2021-04-30/organizations/$HCP_ORGANIZATION_ID/projects/$HCP_PROJECT_ID"

###################
#     helpers     #
###################

auth() {
  token=$(curl --request POST --silent \
    --url 'https://auth.hashicorp.com/oauth/token' \
    --data grant_type=client_credentials \
    --data client_id="$HCP_CLIENT_ID" \
    --data client_secret="$HCP_CLIENT_SECRET" \
    --data audience="https://api.hashicorp.cloud")
  echo "$token" | jq -r '.access_token'
}

# https://superuser.com/questions/590099/can-i-make-curl-fail-with-an-exitcode-different-than-0-if-the-http-status-code-i
curlf() {
  OUTPUT_FILE=$(mktemp)
  HTTP_CODE=$(curl --silent -L --output "$OUTPUT_FILE" --write-out "%{http_code}" "$@")
  if [[ ${HTTP_CODE} -lt 200 || ${HTTP_CODE} -gt 299 ]] ; then
    >&2 cat "$OUTPUT_FILE"
    exit 1
  fi
  cat "$OUTPUT_FILE"
  rm "$OUTPUT_FILE"
}

###################
#     buckets     #
###################

buckets_handler() {
  bearer="$1"
  action="$2"
  bucket_slug="${3-}" # optional

  case "$action" in
    "get")
      buckets_get "$bearer" "$bucket_slug"
      ;;

    *)
      echo "Unknown action \"${action}\", valid options are: get"
      exit 1
      ;;
  esac
}

buckets_get() {
  bearer="$1"
  bucket_slug="${2-}" # optional

  url="$base_url/images"
  if [[ -n "$bucket_slug" ]]; then
    url="$url/$bucket_slug"
  fi

  res=$(curlf --request GET \
    --url "$url" \
    --header "authorization: Bearer $bearer")

  if [[ -z "$bucket_slug" ]]; then
    echo "$res" | jq -r '.buckets'
  else
    echo "$res" | jq -r '.bucket'
  fi
}

###################
#   iterations    #
###################

iterations_handler() {
  bearer="$1"
  action="$2"
  bucket_slug="$3"
  select_arg="${4-}" # optional
  select_id="${5-}" # optional

  case "$action" in
    "get")
      iterations_get "$bearer" "$bucket_slug" "$select_arg" "$select_id"
      ;;

    *)
      echo "Unknown action \"${action}\", valid options are: get"
      exit 1
      ;;
  esac
}

iterations_get() {
  bearer="$1"
  bucket_slug="$2"
  select_arg="${3-}" # optional
  select_id="${4-}" # optional

  url="$base_url/images/$bucket_slug/iterations"

  res=$(curlf --request GET \
    --url "$url" \
    --header "authorization: Bearer $bearer")
  
  if [[ "$select_arg" == "--fingerprint" || "$select_arg" == "-f" ]]; then
    echo "$res" | jq -r '.iterations[] | select(.fingerprint == "'"$select_id"'")'
  elif [[ "$select_arg" == "--iteration_id" || "$select_arg" == "-i" ]]; then
    echo "$res" | jq -r '.iterations[] | select(.id == "'"$select_id"'")'
  else
    echo "$res" | jq -r '.iterations'
  fi
}

###################
#     builds      #
###################

builds_handler() {
  bearer="$1"
  action="$2"
  bucket_slug="$3"
  iteration_id="$4"
  build_id="${5-}" # optional

  case "$action" in
    "get")
      builds_get "$bearer" "$bucket_slug" "$iteration_id" "$build_id"
      ;;

    *)
      echo "Unknown action \"${action}\", valid options are: get"
      exit 1
      ;;
  esac
}

builds_get() {
  bearer="$1"
  bucket_slug="$2"
  iteration_id="$3"
  build_id="${4-}" # optional

  url="$base_url/images/$bucket_slug/iterations/$iteration_id/builds"

  res=$(curlf --request GET \
    --url "$url" \
    --header "authorization: Bearer $bearer")
  
  if [[ -z "$build_id" ]]; then
    echo "$res" | jq -r '.builds'
  else
    echo "$res" | jq -r '.builds[] | select(.id == "'"$build_id"'")'
  fi
}

###################
#    channels     #
###################

channels_handler() {
  bearer="$1"
  action="$2"
  bucket_slug="$3"
  channel_name="${4-}" # optional


  # quick and dirty check for "--fingerprint" or "-f"
  id_type=iteration_id
  if [[ "${5-}" == "--fingerprint" || ${5-} == "-f" ]]; then
    id_type=fingerprint
    shift
  fi
  iteration_id="${5-}" # optional

  case "$action" in
    "get")
      channels_get "$bearer" "$bucket_slug" "$channel_name"
      ;;

    "create")
      channels_create "$bearer" "$bucket_slug" "$channel_name"
      ;;

    "get-iteration")
      channels_get_iteration "$bearer" "$bucket_slug" "$channel_name"
      ;;

    "set-iteration")
      channels_set_iteration "$bearer" "$bucket_slug" "$channel_name" "$id_type" "$iteration_id"
      ;;

    *)
      echo "Unknown action \"${action}\", valid options are: get, get-iteration, set-iteration"
      exit 1
      ;;
  esac
}

channels_get() {
  bearer="$1"
  bucket_slug="$2"
  channel_name="${3-}" # optional

  url="$base_url/images/$bucket_slug/channels"
  if [[ -n "$channel_name" ]]; then
    url="$url/$channel_name"
  fi

  res=$(curlf --request GET \
    --url "$url" \
    --header "authorization: Bearer $bearer")

  if [[ -z "$channel_name" ]]; then
    echo "$res" | jq -r '.channels'
  else
    echo "$res" | jq -r '.channel'
  fi
}

channels_create() {
  bearer="$1"
  bucket_slug="$2"
  channel_name="$3"

  url="$base_url/images/$bucket_slug/channels"

  body='{"'"slug"'":"'"$channel_name"'"}'

  res=$(curlf --request POST \
    --url "$url" \
    --data-raw "$body" \
    --header "authorization: Bearer $bearer")

  echo $res | jq .
}

channels_get_iteration() {
  bearer="$1"
  bucket_slug="$2"
  channel_name="$3"

  url="$base_url/images/$bucket_slug/channels/$channel_name"

  res=$(curlf --request GET \
    --url "$url" \
    --header "authorization: Bearer $bearer")

  echo "$res" | jq -r '.channel.pointer.iteration.id'
}

channels_set_iteration() {
  bearer="$1"
  bucket_slug="$2"
  channel_name="$3"
  id_type="$4"
  iteration_id="$5"

  url="$base_url/images/$bucket_slug/channels/$channel_name"

  body='{"'"$id_type"'":"'"$iteration_id"'"}'

  res=$(curlf --request PATCH \
    --url "$url" \
    --data-raw "$body" \
    --header "authorization: Bearer $bearer")

  echo "$res" | jq '.'
}


###################
#   entry point   #
###################

resource="${1-}"
IFS=" " read -r -a args <<< "${*:2}"

bearer=$(auth)

## Route handler
case "$resource" in
  "buckets")
    buckets_handler "$bearer" "${args[@]}"
    ;;

  "iterations")
    iterations_handler "$bearer" "${args[@]}"
    ;;

  "builds")
    builds_handler "$bearer" "${args[@]}"
    ;;

  "channels")
    channels_handler "$bearer" "${args[@]}"
    ;;

  *)
    usage
    ;;
esac
