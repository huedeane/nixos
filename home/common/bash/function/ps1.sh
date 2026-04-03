hex_to_rgb() {
  hex="${1#'#'}"
  r=$((16#${hex:0:2}))
  g=$((16#${hex:2:2}))
  b=$((16#${hex:4:2}))
  echo "$r;$g;$b"
}

parse_git_branch() {
  # Get the current Git branch name
  local branch_name=$(git branch 2>/dev/null | grep '\*' | sed 's/* //')

  # Echo the branch name so it can be captured
  echo "$branch_name"
}

calculate_command_length() {
  # Get the current command line number
  local command_length=$(echo -n '\#' | wc -m)

  # Echo the command length so it can be captured
  echo ${command_length}
}

# Function to calculate directory length
caculate_directory_length() {
  # Replace HOME with ~, and replace '/' with your special character sequence
  local pwd2=$(echo "$PWD" | sed -e "s:$HOME:~:" -e "s:\([^/]\)/:\1$(printf ' \356\202\261 '):g")

  # Get the length of the transformed path
  local prompt_length=$(echo -n "$pwd2" | wc -m)

  # Calculate how much space is left after the prompt
  local directory_length=$((prompt_length)) # Adjusted for "$ " at the end

  # Echo the directory length so it can be captured
  echo ${directory_length}
}

# Function to calculate git length
caculate_git_length() {
  # Get the git branch name
  local branch_name=$(parse_git_branch)

  # Get the lenght of the branch name
  local branch_length=$(echo -n "$branch_name" | wc -m)

  # If git_length is greater than 0, track extra character
  if [ $branch_length -gt 0 ]; then
    local branch_length=$((branch_length + 7))
  fi

  # Echo the branch length so it can be captured
  echo ${branch_length}
}

# Function to calculate line length
calculate_line_length() {
  # Set static length left-side
  local leftover_length_left=13
  # Set static length right-side
  local leftover_length_right=13

  # Get Caculated Length
  local directory_length=$(caculate_directory_length)
  local git_length=$(caculate_git_length)
  local command_length=$(calculate_command_length)

  # Get terminal width
  local term_width=$(tput cols)

  local term_filler=0
  if [[ !"$TERM" == "xterm-kitty" ]]; then
    term_filler=1
  fi

  # Calculate line length
  local line_length=$((
    term_width
    - ${directory_length}
    - ${git_length}
    - ${command_length}
    - ${leftover_length_left}
    - ${leftover_length_right}
    + ${term_filler}
  ))

  # Echo the line length so it can be captured
  echo ${line_length}
}

set_ps1() {
  # Color
  local color_rosewater=$(hex_to_rgb "#f2d5cf")
  local color_flamingo=$(hex_to_rgb "#eebebe")
  local color_pink=$(hex_to_rgb "#f4b8e4")
  local color_mauve=$(hex_to_rgb "#ca9ee6")
  local color_red=$(hex_to_rgb "#e78284")
  local color_maroon=$(hex_to_rgb "#ea999c")
  local color_peach=$(hex_to_rgb "#ef9f76")
  local color_yellow=$(hex_to_rgb "#e5c890")
  local color_green=$(hex_to_rgb "#a6d189")
  local color_teal=$(hex_to_rgb "#81c8be")
  local color_sky=$(hex_to_rgb "#99d1db")
  local color_sapphire=$(hex_to_rgb "#85c1dc")
  local color_blue=$(hex_to_rgb "#8caaee")
  local color_lavender=$(hex_to_rgb "#babbf1")
  local color_black=$(hex_to_rgb "#303446")
  local color_white=$(hex_to_rgb "#dce0e8")

  # Unicode
  local icon_upper_left_quadrant_circular_arc='\342\225\255'      #U+25DC (◜)
  local icon_box_drawings_light_arc_down_and_right='\342\225\255' #U+256D (╭)
  local icon_box_drawings_light_arc_down_and_left='\342\225\256'  #U+256D (╮)
  local icon_box_drawings_light_arc_up_and_right='\342\225\260'   #U+2570 (╰)
  local icon_box_drawings_light_arc_up_and_left='\342\225\257'    #U+2570 (╯)
  local icon_box_drawings_light_horizontal='\342\224\200'         #U+2500 (─)
  local icon_left_half_black_circle='\342\227\226'                #U+25D6 (◖)
  local icon_right_half_black_circle='\342\227\227'               #U+25D7 (◗)
  local icon_segment_seperator='\356\202\260'                     #U+E0B0 ()

  # NerdFont Icon
  local icon_right='\357\201\224'     #nf-fa-chevron_right
  local icon_left='\357\201\223'      #nf-fa-chevron_left
  local icon_linux_tux='\356\257\206' #nf-cod-terminal_linux
  local icon_git='\356\234\245'       #nf-oct-git_branch
  local icon_window='\356\230\252'    #nf-dev-windows11
  local space=' '

  # Info
  local info_command_number='#\#'
  local info_date='\d'
  local info_time='\t'

  # Command
  local end_color='\e[0m'
  local begin='\['
  local end='\]'
  local next_line='\n'
  local foreground=38
  local background=48
  local symbol='\$'

  local git=$(
    printf "%s" "" \
      "${begin}\e[${background};2;${color_green}m\e[${foreground};2;${color_white}m${end}${icon_segment_seperator}${end_color}" \
      "${begin}\e[${background};2;${color_green}m\e[${foreground};2;${color_black}m${end}${space}${icon_git}${space}($(parse_git_branch))${space}${end_color}" \
      "${begin}\e[${background};2;${color_blue}m\e[${foreground};2;${color_green}m${end}${icon_segment_seperator}${end_color}"
  )

  local no_git=$(
    printf "%s" "" \
      "${begin}\e[${background};2;${color_blue}m\e[${foreground};2;${color_white}m${end}${icon_segment_seperator}${end_color}"
  )

  # Function to draw top line
  draw_line() {
    # Get the calculated line length
    local line_length=$(calculate_line_length)

    # Create line based on length
    if [ $line_length -gt 0 ]; then
      line=""
      for ((i = 0; i < $line_length; i++)); do
        line+="$icon_box_drawings_light_horizontal"
      done
      echo "$line"
    fi
  }

  generate_right_align_text() {
    # Set static length left-side
    local leftover_length_left="9"

    # Set static length left-side
    local leftover_length_right="16"

    # Set align text
    local right_text="${icon_left}${space}${icon_box_drawings_light_horizontal}${space}${info_time}${space}${icon_box_drawings_light_horizontal}${icon_box_drawings_light_horizontal}${icon_box_drawings_light_arc_up_and_left}${space}" # Replace with the text you want

    # Get Terminal Width
    local terminal_width=$(tput cols)

    # Calculate the padding for right alignment
    local right_space=$(((terminal_width + 6) - ${leftover_length_right} - ${leftover_length_right}))

    # If there is room, print the right-aligned text
    if [ $right_space -gt 0 ]; then
      tput sc # Save the cursor position
      tput ed # Clear from the cursor to the end of the line
      printf "%${right_space}s%s" "" "$right_text"
      tput rc # Restore the cursor position
    fi
  }

  local pwd2=$(echo "$PWD" | sed -e "s:$HOME:~:" -e "s:\([^/]\)/:\1$(printf ' \356\202\261 '):g")

  if [[ "$TERM" == "xterm-kitty" ]]; then
    PS1=$(
      printf "%s" "\n" \
        "${begin}\e[${foreground};2;${color_lavender}m${end}${icon_box_drawings_light_arc_down_and_right}${icon_box_drawings_light_horizontal}${icon_left_half_black_circle}${end_color}" \
        "${begin}\e[${background};2;${color_lavender}m\e[${foreground};2;${color_black}m${end}${info_command_number}${space}${end_color}" \
        "${begin}\e[${background};2;${color_white}m\e[${foreground};2;${color_lavender}m${end}${icon_segment_seperator}${end_color}" \
        "${begin}\e[${background};2;${color_white}m\e[${foreground};2;${color_black}m${end}${space}${icon_linux_tux}${space}${end_color}" \
        "$(if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then echo -e "${git}"; else echo -e "${no_git}"; fi)" \
        "${begin}\e[${background};2;${color_blue}m\e[${foreground};2;${color_black}m${end}${space}${pwd2}${space}${end_color}" \
        "${begin}\e[${foreground};2;${color_blue}m${end}${icon_right_half_black_circle}${end_color}" \
        "${begin}\e[${foreground};2;${color_lavender}m${end}$(draw_line)${end_color}" \
        "${begin}\e[${foreground};2;${color_lavender}m${end}${icon_left_half_black_circle}${end_color}" \
        "${begin}\e[${background};2;${color_lavender}m\e[${foreground};2;${color_black}m${end}${info_date}${end_color}" \
        "${begin}\e[${foreground};2;${color_lavender}m${end}${icon_right_half_black_circle}${end_color}" \
        "${next_line}" \
        "${begin}\e[${foreground};2;${color_lavender}m${end}${icon_box_drawings_light_arc_up_and_right}${icon_box_drawings_light_horizontal}${space}${icon_right}${icon_right}${icon_right}${space}${symbol}${space}"
    )
  else
    PS1=$(
      printf "%s" "\n" \
        "${begin}\e[${foreground};2;${color_lavender}m${end}${icon_box_drawings_light_arc_down_and_right}${icon_box_drawings_light_horizontal}${end_color}" \
        "${begin}\e[${background};2;${color_lavender}m\e[${foreground};2;${color_black}m${end}${space}${info_command_number}${space}${end_color}" \
        "${begin}\e[${background};2;${color_white}m\e[${foreground};2;${color_lavender}m${end}${icon_segment_seperator}${end_color}" \
        "${begin}\e[${background};2;${color_white}m\e[${foreground};2;${color_black}m${end}${space}${icon_window}${space}${end_color}" \
        "$(if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then echo -e "${git}"; else echo -e "${no_git}"; fi)" \
        "${begin}\e[${background};2;${color_blue}m\e[${foreground};2;${color_black}m${end}${space}${pwd2}${space}${end_color}" \
        "${begin}\e[${foreground};2;${color_lavender}m${end}$(draw_line)${end_color}" \
        "${begin}\e[${background};2;${color_lavender}m\e[${foreground};2;${color_black}m${end}${space}${info_date}${space}${end_color}" \
        "${next_line}" \
        "${begin}\e[${foreground};2;${color_lavender}m${end}${icon_box_drawings_light_arc_up_and_right}${icon_box_drawings_light_horizontal}${space}${icon_right}${icon_right}${icon_right}${space}${symbol}${space}"
    )
  fi
}

PROMPT_COMMAND="set_ps1"
