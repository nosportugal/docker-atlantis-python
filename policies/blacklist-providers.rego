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