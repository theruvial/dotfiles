#!/bin/bash

# Initialize kbdbrightness if not already set, default to 3
kbdbrightness=${kbdbrightness:-3}

# Function to increase kbdbrightness by 1, up to a maximum of 3
increase_kbdbrightness() {
    if (( kbdbrightness < 3 )); then
        kbdbrightness=$((kbdbrightness + 1))
    fi
    export kbdbrightness
    echo "kbdbrightness increased to $kbdbrightness"

    # Apply brightness with rogauracore
    rogauracore brightness "$kbdbrightness"
}

# Function to decrease kbdbrightness by 1, down to a minimum of 0
decrease_kbdbrightness() {
    if (( kbdbrightness > 0 )); then
        kbdbrightness=$((kbdbrightness - 1))
    fi
    export kbdbrightness
    echo "kbdbrightness decreased to $kbdbrightness"

    # Apply brightness with rogauracore
    rogauracore brightness "$kbdbrightness"
}

# Function to get the current value of kbdbrightness
get_kbdbrightness() {
    echo "Current kbdbrightness is $kbdbrightness"
}

# Check command-line argument to determine which function to call
if [[ $1 == "increase" ]]; then
    increase_kbdbrightness
elif [[ $1 == "decrease" ]]; then
    decrease_kbdbrightness
elif [[ $1 == "get" ]]; then
    get_kbdbrightness
else
    echo "Usage: $0 {increase|decrease|get}"
    echo "kbdbrightness is currently set to $kbdbrightness"
fi
