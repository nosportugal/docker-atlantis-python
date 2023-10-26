#!/bin/bash

## Retrieve providers downloaded by terraform init
providers_output=$(terraform providers)

## Parse result to output only the provider names
provider_names=$(echo "$providers_output" | grep -o 'provider\[.*\]' | awk -F ']' '{print $1"]"}' | sed 's/provider\[//;s/\]//')

## Eliminate duplicate providers
unique_provider_names=$(echo "$provider_names" | awk '!seen[$0]++')

## Set policy directory
POLICY_DIR="/policies/blacklist-providers.rego"

## Loop through identified providers to run a conftest agains the blacklist-providers policy
violated=false
for provider in $unique_provider_names; do
    json="{\"providers\": \"$provider\"}"
    if ! conftest test -p "$POLICY_DIR" - <<< "$json" >/dev/null; then
        violated=true
        echo "$json" | conftest test -p "$POLICY_DIR" -
    fi
done

## Check if the any provider was identified in the loop and exit with according error
if [ "$violated" = true ]; then
    exit 1
else
    exit 0
fi