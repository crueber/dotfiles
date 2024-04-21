
right_aligned() {
    local terminal_width=$(tput cols)
    local padding=$((terminal_width - ${#1} - 8))

    for ((i=0; i<$padding; i++))
    do 
        printf ' '
    done
    echo "*** $1 ***"
}
