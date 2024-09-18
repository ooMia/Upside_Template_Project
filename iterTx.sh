#!/bin/bash

# Script Name: script_name.sh
# Description: Brief description of what the script does
# Author: Your Name
# Date: YYYY-MM-DD

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help    Display this help message"
    # Add more options here
}

# Parse command line arguments
while [[ "$1" != "" ]]; do
    case $1 in
        -h | --help )
            usage
            exit 0
            ;;
        # Add more options here
        * )
            echo "Invalid option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

# Main script logic
main() {
    for i in $(seq -w 1 32); do
        forge script -f exam2 Rw2 --optimize --optimizer-runs 999 --broadcast --slow    
        forge script -f exam2 Withd --optimize --optimizer-runs 999 --broadcast --slow   
    done

    # 반복할 인덱스 목록
    # indexes=(1 2 15 22 4 5 7)

    # for i in "${indexes[@]}"; do
    #     export RW1_ID=0x$(printf "%02x" $i)
    #     echo "Index : $i"
    #     echo $RW1_ID
    #     forge script -f rw1 RW1 --optimize --optimizer-runs 999 --broadcast --slow
    # done

}

# Execute main function
main