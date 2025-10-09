#!/bin/bash

read -p "Have you used this tool before? (y/n) " used_before

if [ "$used_before" = "y" ] || [ "$used_before" = "Y" ]; then
    read -p "Please enter the file name containing subdomains: " input_file
    if [ -f "$input_file" ]; then
        cat "$input_file" | anew >> allsubs.txt
        cat allsubs.txt | httpx -o httpx.txt -fc 200
        echo "Processing complete. Results saved in httpx.txt"
    else
        echo "Error: File $input_file does not exist."
        exit 0
    fi
else
    read -p "Please enter your Domain or Wildcard: " wild
    subfinder -d "$wild" -all -o subs.txt
    echo "$wild" | assetfinder --subs-only >> subs.txt
    cat subs.txt | anew >> allsubs.txt
    cat allsubs.txt | httpx -o httpx.txt -fc 200
    echo "Processing complete. Results saved in httpx.txt"
fi
