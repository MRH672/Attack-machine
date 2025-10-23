#!/usr/bin/env zsh

get_subdomains() {
    local domain=$1

    local subfinder_output=$(subfinder -d "$domain")
    local subdomains="$subfinder_output"

    local assetfinder_output=$(echo "$domain" | assetfinder --subs-only)
    subdomains+="$assetfinder_output"

    local anew_output=$(echo "$subdomains" | anew)
    subdomains="$anew_output"

    echo "$subdomains"
}

test_subdomains(){
    local domain=$1

    local subdomains=$(get_subdomains "$domain")

    local httpx_output=$(echo "$subdomains" | httpx -fc 200)

    echo "$httpx_output"
}

main(){
    local domain=$1

    if [ -z "$domain" ]; then
        echo "Error: Domain is required."
        exit 1
    fi

    test_subdomains "$domain"
}

main "$@"
