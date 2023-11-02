# Atlantis with Python and REGO Policies

Original Base Image of Atlantis that uses Python Libraries and a REGO policy to block unwanted terraform providers.

## About the Project

Upon using lambda functions in a repository, using the base image of Atlantis would run into errors since these functions use python. Therefore, this project was designed to get the latest image from Atlantis and adding python to the image in order to run these specific cases.

As already described in the documentation, https://github.com/runatlantis/atlantis/blob/v0.17.5/runatlantis.io/docs/security.md#protect-terraform-planning, protecting terraform apply from malicious code is not enough. It's possible to inject arbitrary code at plan phase using the external data source or a malicious provider, so we also recognized the importance of Atlantis provider blacklisting to prevent unintended execution of Terraform plans and avoid exposing sensitive information, through a security check mechanism before plan.

Given the diversity of providers used across the projects, we opted for a blacklist approach to this solution, ensuring that only approved providers could be utilized. This approach involved a three-step process:

1. Script for Terraform Provider Parsing: We developed a script that parses the results of the 'terraform providers' command, eliminates duplicates, and then systematically loops through a Conftest validation for each of these providers.

```bash

   #!/bin/bash

   ## Retrieve providers downloaded by terraform init
   providers_output=$(terraform providers)

   ## Parse result to output only the provider names
   provider_names=$(echo "$providers_output" | grep -o 'provider\[.*\]' | awk -F ']' '{print $1"]"}' | sed 's/provider\[//;s/\]//')

   ## Eliminate duplicate providers
   unique_provider_names=$(echo "$provider_names" | awk '!seen[$0]++')

   ## Set policy directory
   POLICY_DIR="/path/to/rego/policy"

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
   ```

2. REGO Policy for Blacklisting: We crafted a REGO policy that cataloged all the providers we intended to blacklist. This policy served as the foundation for our provider control mechanism, allowing us to explicitly block any undesired provider.

```bash

   package main

   ##Blacklisted providers

   not_allowed_providers := {x | x := split(opa.runtime()["env"]["BLACKLIST_PROVIDERS"], ",")[_]}

   blacklist_providers[provider]{
    provider := input.providers
    not_allowed_providers[provider]
   }

   deny[msg] {
    count(blacklist_providers) > 0
    msg := sprintf("Module %s is not authorized", [blacklist_providers[_]])
   }
   ```
3. Workflow Adaptation: To seamlessly integrate the provider blacklisting into our development pipeline, we adapted our workflow by introducing a pre-step to the default workflow in the 'repos.yaml' configuration. This pre-step enforced the REGO policy, ensuring that only whitelisted providers were permitted for Terraform plans and respective deployments.

```bash
    workflows:
      default:
        plan:
          steps:
          - init
          - run:
              command: bash path/to/script
              output: show
          - plan
   ```

In the end, if a blacklisted provider is identified, we get the following PR in the comment:

![image](https://github.com/nosportugal/docker-atlantis-python/assets/98830742/c1b22503-8c01-40b7-a539-a03958cc6207)

⚠ To implement provider blacklisting within the Atlantis image, we introduced a dynamic solution. By utilizing Atlantis `custom_environment_variables` input as "BLACKLIST_PROVIDERS", we can now specify one or more blacklisted providers as values. For example, we might set the value as follows: 
 - "registry.terraform.io/hashicorp/external,registry.terraform.io/hashicorp/null,registry.terraform.io/hashicorp/xxx,..."

 ```bash
  custom_environment_variables = [
    {
      name : "BLACKLIST_PROVIDERS",
      value : "registry.terraform.io/hashicorp/external"
    }
  ]
   ```

In resume, this comprehensive approach not only addressed the Python compatibility issue but also bolstered our security and compliance efforts, ensuring that your infrastructure remained robust and protected against unauthorized or risky provider usage.

## Built With

This project uses:

- [Atlantis](https://github.com/runatlantis/atlantis)
- [Github Packages](https://github.com/features/packages)

## Getting Started

We suggest you create a specific repository where you can edit your terraform files and call the module from this [repository](https://github.com/terraform-aws-modules/terraform-aws-atlantis).

One of the arguments is `atlantis_image` and this is where we can specify the image from our packages. While Base Atlantis doesn't update a minor version (p.e from v0.19 to v0.20), you will have no need to update the image since this project will be in charge of the updates for the patches and the latest image will always point to the latest stable version.

   ```bash

   module "atlantis" {
    source = "git@github.com:nosportugal/terraform-aws-atlantis?ref=github-app-support"

    name = "atlantis"

    atlantis_image = "ghcr.io/nosportugal/docker-atlantis-python:0.19"

   }
   ```

As an alternative, you can always choose to create your own Dockerfile and point to the image.

```bash
FROM ghcr.io/nosportugal/docker-atlantis-python:0.19
```

You can check the packages [here](https://github.com/nosportugal/docker-atlantis-python/pkgs/container/docker-atlantis-python).

## Contributing

Contributions are what make the open source community awesome! Any contributions you make are **greatly appreciated**.

1. Fork the Project

2. Create your Feature Branch

   ```bash
   git checkout -b feature/my-feature
   ```

3. Commit your Changes

   ```bash
   git commit -m 'Add some feature'
   ```

4. Push to the Branch

   ```bash
   git push origin feature/my-feature
   ```

5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.
