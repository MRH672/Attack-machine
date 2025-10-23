#!/usr/bin/env zsh

katana_endpoints(){
    local subdomains=$1
    echo $subdomains

    local katana_output=$(echo "$subdomains" | katana)

    echo "$katana_output"
}

waybackurls_endpoints(){
    local subdomains=$1

    local waybackurls_urls=$(echo "$subdomains" | waybackurls)

    echo "$waybackurls_urls"
}

main(){
    file="$1"   # first argument

    if [ -z "$file" ]; then
        echo "Error: No file provided."
        exit 1
    fi

    if [ ! -f "$file" ]; then
        echo "Error: File '$file' not found."
        exit 1
    fi

    local data=$(cat "$file")

    echo "Starting katana..."
    local katana_out=$(katana_endpoints "$data")

    echo "Starting waybackurls..."
    local wayback_out=$(waybackurls_endpoints "$data")

    local endpoints_raw="$katana_out$wayback_out"

    local endpoints=$(echo "$endpoints_raw" | anew)

    echo "$endpoints_raw"

    echo "$endpoints" | grep -E "\.js" > js.txt &
    echo "$endpoints" | grep -E "\.php" > php.txt &

    echo "Results saved js.txt, php.txt"
}

main "$@"
