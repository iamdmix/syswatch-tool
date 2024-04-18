#!/bin/bash

# Function to print the macOS ASCII art with blue text
print_syswatch_ascii() {
    printf "\e[1;34m"
    cat << "EOF"
  ______                       __       __              __                __       
 /      \                     /  |  _  /  |            /  |              /  |      
/$$$$$$  | __    __   _______ $$ | / \ $$ |  ______   _$$ |_     _______ $$ |____  
$$ \__$$/ /  |  /  | /       |$$ |/$  \$$ | /      \ / $$   |   /       |$$      \ 
$$      \ $$ |  $$ |/$$$$$$$/ $$ /$$$  $$ | $$$$$$  |$$$$$$/   /$$$$$$$/ $$$$$$$  |
 $$$$$$  |$$ |  $$ |$$      \ $$ $$/$$ $$ | /    $$ |  $$ | __ $$ |      $$ |  $$ |
/  \__$$ |$$ \__$$ | $$$$$$  |$$$$/  $$$$ |/$$$$$$$ |  $$ |/  |$$ \_____ $$ |  $$ |
$$    $$/ $$    $$ |/     $$/ $$$/    $$$ |$$    $$ |  $$  $$/ $$       |$$ |  $$ |
 $$$$$$/   $$$$$$$ |$$$$$$$/  $$/      $$/  $$$$$$$/    $$$$/   $$$$$$$/ $$/   $$/ 
          /  \__$$ |                                                               
          $$    $$/                                                                
           $$$$$$/                                                                 
EOF
    printf "\e[0m\n\n"
}

# Print syswatch ASCII art
print_syswatch_ascii

# Display system information
printf "\e[1;31mSystem Information:\e[0m\n"
printf "\e[1;31m-------------------\e[0m\n"
printf "\e[1;31mHost:\e[0m $(system_profiler SPHardwareDataType | awk '/Model Name/ {print $3,$4,$5}')\n"
printf "\e[1;31mOS Details:\e[0m $(sw_vers -productName) $(sw_vers -productVersion)\n"
printf "\e[1;31mUser:\e[0m $(whoami)\n"
printf "\e[1;31mUptime:\e[0m $(system_profiler SPSoftwareDataType | awk '/Time since boot/ {print $4,$5,$6,$7,$8,$9}')\n"
printf "\e[1;31mShell:\e[0m $(zsh --version | awk '{print $1}') $(zsh --version | awk '{print $2}')\n"
printf "\e[1;31mCPU Name:\e[0m $(system_profiler SPHardwareDataType | awk '/Processor Name/ {print substr($0, index($0, $3))}')\n"
printf "\e[1;31mCPU Cores:\e[0m $(system_profiler SPHardwareDataType | awk '/Total Number of Cores/ {print $5}')\n"
printf "\e[1;31mGPU Name:\e[0m $(system_profiler SPDisplaysDataType | awk '/Chipset Model/ {print substr($0, index($0, $3))}')\n"
printf "\e[1;31mScreen Resolution:\e[0m $(system_profiler SPDisplaysDataType | awk '/Resolution:/ {print $2 "x" $4}')\n"
