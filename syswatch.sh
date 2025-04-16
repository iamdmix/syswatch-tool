#!/bin/bash
# syswatch.sh - Cross-platform system information (macOS, Linux, Windows)
# Designed to display detailed system info similar to fastfetch.

# Function to print ASCII art header in blue
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
    printf "\e[0m\n"
}

# Print header
print_syswatch_ascii

# Determine OS type: macOS, Linux, or Windows (msys/cygwin)
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"

    # ─── MACOS INFORMATION ──────────────────────────────────────────────
    printf "\e[1;31mSystem Information:\e[0m\n"
    printf "\e[1;32m-------------------\e[0m\n"

    # User & Host
    USERNAME=$(whoami)
    HOST_NAME=$(system_profiler SPHardwareDataType 2>/dev/null | awk -F": " '/Model Name/ {print $2; exit}')
    [ -z "$HOST_NAME" ] && HOST_NAME=$(hostname)
    printf "\e[1;33mUser:\e[0m \e[1;34m%s\e[0m\n" "$USERNAME"
    printf "\e[1;33mHost:\e[0m \e[1;34m%s\e[0m\n" "$HOST_NAME"

    # OS Details & Architecture
    OS_NAME=$(sw_vers -productName 2>/dev/null)
    OS_VERSION=$(sw_vers -productVersion 2>/dev/null)
    ARCH=$(uname -m)
    printf "\e[1;33mOS:\e[0m \e[1;34m%s %s %s\e[0m\n" "$OS_NAME" "$OS_VERSION" "$ARCH"

    # Kernel
    KERNEL=$(uname -r)
    printf "\e[1;33mKernel:\e[0m \e[1;34mDarwin %s\e[0m\n" "$KERNEL"

    # Uptime
    UPTIME_SEC=$(sysctl -n kern.boottime | awk '{print $4}' | tr -d ',')
    CURRENT_TIME=$(date +%s)
    UPTIME=$((CURRENT_TIME - UPTIME_SEC))
    DAYS=$((UPTIME / 86400))
    HOURS=$(( (UPTIME % 86400) / 3600 ))
    MINUTES=$(( (UPTIME % 3600) / 60 ))
    UPTIME_STR=""
    [ "$DAYS" -gt 0 ] && UPTIME_STR="$DAYS days, "
    [ "$HOURS" -gt 0 ] && UPTIME_STR="${UPTIME_STR}$HOURS hours, "
    UPTIME_STR="${UPTIME_STR}$MINUTES minutes"
    printf "\e[1;33mUptime:\e[0m \e[1;34m%s\e[0m\n" "$UPTIME_STR"

    # Packages count from Homebrew
    BREW_FORMULAE=$(command -v brew &>/dev/null && brew list --formula 2>/dev/null | wc -l || echo "N/A")
    BREW_CASKS=$(command -v brew &>/dev/null && brew list --cask 2>/dev/null | wc -l || echo "N/A")
    printf "\e[1;33mPackages:\e[0m \e[1;34m%s (brew), %s (brew-cask)\e[0m\n" "$BREW_FORMULAE" "$BREW_CASKS"

    # Shell version
    SHELL_VER=$(zsh --version 2>/dev/null | awk '{print $1, $2}')
    printf "\e[1;33mShell:\e[0m \e[1;34m%s\e[0m\n" "$SHELL_VER"

    # Display Resolution
    RESOLUTION=$(system_profiler SPDisplaysDataType 2>/dev/null | awk -F": " '/Resolution/ {print $2; exit}')
    printf "\e[1;33mDisplay:\e[0m \e[1;34m%s\e[0m\n" "$RESOLUTION"

    # Desktop Environment & Window Manager
    printf "\e[1;33mDE:\e[0m \e[1;34mAqua\e[0m\n"
    printf "\e[1;33mWM:\e[0m \e[1;34mQuartz Compositor\e[0m\n"
    printf "\e[1;33mWM Theme:\e[0m \e[1;34mMulticolor (Dark)\e[0m\n"

    # Font and Cursor
    printf "\e[1;33mFont:\e[0m \e[1;34mAppleSystemUIFont [System], Helvetica\e[0m\n"
    printf "\e[1;33mCursor:\e[0m \e[1;34mFill - Black, Outline - White (32px)\e[0m\n"

    # Terminal & Terminal Font
    if [ "$TERM_PROGRAM" == "iTerm.app" ]; then
        ITERM_VER="iTerm"
    else
        ITERM_VER="Terminal"
    fi
    printf "\e[1;33mTerminal:\e[0m \e[1;34m%s\e[0m\n" "$ITERM_VER"
    printf "\e[1;33mTerminal Font:\e[0m \e[1;34mMonaco (12pt)\e[0m\n"

    # CPU Information
    CPU_INFO=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
    printf "\e[1;33mCPU:\e[0m \e[1;34m%s\e[0m\n" "$CPU_INFO"

    # GPU Information
    GPU_INFO=$(system_profiler SPDisplaysDataType 2>/dev/null | awk -F": " '/Chipset Model/ {print $2; exit}')
    printf "\e[1;33mGPU:\e[0m \e[1;34m%s\e[0m\n" "$GPU_INFO"

    # Memory Information
    TOTAL_MEM_BYTES=$(sysctl -n hw.memsize 2>/dev/null)
    TOTAL_MEM_GiB=$(echo "scale=2; $TOTAL_MEM_BYTES/1073741824" | bc)
    PAGE_SIZE=$(sysctl -n hw.pagesize 2>/dev/null)
    FREE_PAGES=$(vm_stat 2>/dev/null | awk '/Pages free/ {gsub("[^0-9]","",$3); print $3}')
    FREE_MEM_BYTES=$(( FREE_PAGES * PAGE_SIZE ))
    USED_MEM_BYTES=$(( TOTAL_MEM_BYTES - FREE_MEM_BYTES ))
    USED_MEM_GiB=$(echo "scale=2; $USED_MEM_BYTES/1073741824" | bc)
    USED_PCT=$(echo "scale=0; $USED_MEM_BYTES*100 / $TOTAL_MEM_BYTES" | bc)
    printf "\e[1;33mMemory:\e[0m \e[1;34m%s GiB / %s GiB (%s%%)\e[0m\n" "$USED_MEM_GiB" "$TOTAL_MEM_GiB" "$USED_PCT"

    # Swap Information
    SWAP_INFO=$(sysctl vm.swapusage 2>/dev/null | awk '{printf "%s / %s", $3, $7}')
    printf "\e[1;33mSwap:\e[0m \e[1;34m%s\e[0m\n" "${SWAP_INFO:-N/A}"

    # Disk Usage
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}')
    printf "\e[1;33mDisk (/):\e[0m \e[1;34m%s\e[0m\n" "$DISK_USAGE"

    # Local IP
    LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null)
    [ -z "$LOCAL_IP" ] && LOCAL_IP="Unavailable"
    printf "\e[1;33mLocal IP (en0):\e[0m \e[1;34m%s\e[0m\n" "$LOCAL_IP"

    # Battery Information
    BATTERY=$(pmset -g batt 2>/dev/null | grep -Eo "[0-9]+%" | head -1)
    printf "\e[1;33mBattery:\e[0m \e[1;34m%s\e[0m\n" "${BATTERY:-N/A}"

    # Power Adapter
    printf "\e[1;33mPower Adapter:\e[0m \e[1;34m61W USB-C Power Adapter\e[0m\n"

    # Locale Information
    LOCALE=$(locale | grep LANG= | cut -d= -f2)
    printf "\e[1;33mLocale:\e[0m \e[1;34m%s\e[0m\n" "${LOCALE:-en_US.UTF-8}"

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
    # ─── LINUX INFORMATION ───────────────────────────────────────────────
    printf "\e[1;31mSystem Information:\e[0m\n"
    printf "\e[1;32m-------------------\e[0m\n"
    
    # User & Host
    USERNAME=$(whoami)
    HOST_NAME=$(hostname)
    if command -v dmidecode &>/dev/null; then
        HOST_DESC=$(sudo dmidecode -s system-product-name 2>/dev/null)
        [ -n "$HOST_DESC" ] && HOST_NAME="$HOST_DESC"
    fi
    printf "\e[1;33mUser:\e[0m \e[1;34m%s\e[0m\n" "$USERNAME"
    printf "\e[1;33mHost:\e[0m \e[1;34m%s\e[0m\n" "$HOST_NAME"

    # OS Details
    if command -v lsb_release &>/dev/null; then
        OS_DISTRIB=$(lsb_release -d | cut -f2)
    elif [ -f /etc/os-release ]; then
        OS_DISTRIB=$(grep "^PRETTY_NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        OS_DISTRIB="Linux"
    fi
    ARCH=$(uname -m)
    printf "\e[1;33mOS:\e[0m \e[1;34m%s %s\e[0m\n" "$OS_DISTRIB" "$ARCH"

    # Kernel
    KERNEL=$(uname -r)
    printf "\e[1;33mKernel:\e[0m \e[1;34m%s\e[0m\n" "$KERNEL"

    # Uptime
    UPTIME=$(uptime -p 2>/dev/null)
    printf "\e[1;33mUptime:\e[0m \e[1;34m%s\e[0m\n" "${UPTIME:-N/A}"

    # Package Count
    if command -v dpkg &>/dev/null; then
        PKG_COUNT=$(dpkg -l | tail -n +6 | wc -l)
        PKG_TYPE="dpkg"
    elif command -v rpm &>/dev/null; then
        PKG_COUNT=$(rpm -qa | wc -l)
        PKG_TYPE="rpm"
    elif command -v pacman &>/dev/null; then
        PKG_COUNT=$(pacman -Q | wc -l)
        PKG_TYPE="pacman"
    else
        PKG_COUNT="N/A"
        PKG_TYPE=""
    fi
    printf "\e[1;33mPackages:\e[0m \e[1;34m%s (%s)%s\e[0m\n" "$PKG_COUNT" "$PKG_TYPE" ""

    # Shell
    SHELL_NAME=$(basename "$SHELL")
    SHELL_VER=$("$SHELL" --version 2>/dev/null | head -n1 | awk '{print $NF}')
    printf "\e[1;33mShell:\e[0m \e[1;34m%s %s\e[0m\n" "$SHELL_NAME" "${SHELL_VER:-}"

    # Display Resolution
    if command -v xrandr &>/dev/null; then
        RESOLUTION=$(xrandr | grep '*' | head -1 | awk '{print $1}')
    elif command -v xdpyinfo &>/dev/null; then
        RESOLUTION=$(xdpyinfo | grep dimensions | awk '{print $2}')
    else
        RESOLUTION="Unavailable"
    fi
    printf "\e[1;33mDisplay:\e[0m \e[1;34m%s\e[0m\n" "$RESOLUTION"
    
    # Desktop Environment & Window Manager
    DE=${XDG_CURRENT_DESKTOP:-"Unknown"}
    printf "\e[1;33mDE:\e[0m \e[1;34m%s\e[0m\n" "$DE"
    if command -v wmctrl &>/dev/null; then
        WM_NAME=$(wmctrl -m | awk '/Name:/ {print $2}')
    else
        WM_NAME="Unknown"
    fi
    printf "\e[1;33mWM:\e[0m \e[1;34m%s\e[0m\n" "$WM_NAME"
    if command -v gsettings &>/dev/null; then
        WM_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
    else
        WM_THEME="Default"
    fi
    printf "\e[1;33mWM Theme:\e[0m \e[1;34m%s\e[0m\n" "$WM_THEME"

    # Font & Cursor
    printf "\e[1;33mFont:\e[0m \e[1;34mDefault system font\e[0m\n"
    printf "\e[1;33mCursor:\e[0m \e[1;34mFill - Black, Outline - White (32px)\e[0m\n"

    # Terminal & Terminal Font
    TERM_INFO=${TERM:-"Terminal"}
    printf "\e[1;33mTerminal:\e[0m \e[1;34m%s\e[0m\n" "$TERM_INFO"
    printf "\e[1;33mTerminal Font:\e[0m \e[1;34mMonaco (12pt)\e[0m\n"

    # CPU Information
    if command -v lscpu &>/dev/null; then
        CPU_INFO=$(lscpu | grep "Model name" | sed 's/Model name:[ \t]*//')
    else
        CPU_INFO=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2)
    fi
    printf "\e[1;33mCPU:\e[0m \e[1;34m%s\e[0m\n" "${CPU_INFO:-Unavailable}"

    # GPU Information
    if command -v lspci &>/dev/null; then
        GPU_INFO=$(lspci | grep -i 'vga\|3d\|2d' | head -1 | cut -d ':' -f3 | sed 's/^ //')
    else
        GPU_INFO="Unavailable"
    fi
    printf "\e[1;33mGPU:\e[0m \e[1;34m%s\e[0m\n" "$GPU_INFO"

    # Memory Information
    if command -v free &>/dev/null; then
        MEM_LINE=$(free -h | awk '/^Mem:/ {print $3 " / " $2 " (" int($3*100/$2)"% used)"}')
    else
        MEM_LINE="Unavailable"
    fi
    printf "\e[1;33mMemory:\e[0m \e[1;34m%s\e[0m\n" "$MEM_LINE"

    # Swap Information
    if command -v free &>/dev/null; then
        SWAP_LINE=$(free -h | awk '/^Swap:/ {print $3 " / " $2 " (" int($3*100/$2)"% used)"}')
    else
        SWAP_LINE="Unavailable"
    fi
    printf "\e[1;33mSwap:\e[0m \e[1;34m%s\e[0m\n" "$SWAP_LINE"

    # Disk Usage
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}')
    printf "\e[1;33mDisk (/):\e[0m \e[1;34m%s\e[0m\n" "$DISK_USAGE"

    # Local IP
    LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
    [ -z "$LOCAL_IP" ] && LOCAL_IP="Unavailable"
    printf "\e[1;33mLocal IP (eth0):\e[0m \e[1;34m%s\e[0m\n" "$LOCAL_IP"

    # Battery Information
    if command -v acpi &>/dev/null; then
        BATTERY=$(acpi -b | awk '{print $4}' | tr -d ',')
    elif command -v upower &>/dev/null; then
        BATTERY=$(upower -i $(upower -e | grep BAT) | awk '/percentage/ {print $2; exit}')
    else
        BATTERY="Unavailable"
    fi
    printf "\e[1;33mBattery:\e[0m \e[1;34m%s\e[0m\n" "$BATTERY"

    # Power Adapter
    printf "\e[1;33mPower Adapter:\e[0m \e[1;34m61W USB-C Power Adapter\e[0m\n"

    # Locale
    LOCALE=$(locale | grep LANG= | cut -d= -f2)
    printf "\e[1;33mLocale:\e[0m \e[1;34m%s\e[0m\n" "${LOCALE:-en_US.UTF-8}"

elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
    OS="Windows"

    # ─── WINDOWS INFORMATION ─────────────────────────────────────────────
    printf "\e[1;31mSystem Information:\e[0m\n"
    printf "\e[1;32m-------------------\e[0m\n"
    
    # User & Host
    USERNAME=$(whoami | awk -F'\\' '{print $NF}')
    HOST_NAME=$(hostname)
    printf "\e[1;33mUser:\e[0m \e[1;34m%s\e[0m\n" "$USERNAME"
    printf "\e[1;33mHost:\e[0m \e[1;34m%s\e[0m\n" "$HOST_NAME"

    # OS Details
    OS_DETAILS=$(powershell -Command "(Get-CimInstance Win32_OperatingSystem).Caption" 2>/dev/null | tr -d '\r')
    [ -z "$OS_DETAILS" ] && OS_DETAILS="Windows (Unknown)"
    ARCH=$(powershell -Command '$env:PROCESSOR_ARCHITECTURE' 2>/dev/null | tr -d '\r')
    [ -z "$ARCH" ] && ARCH="Unknown"
    printf "\e[1;33mOS:\e[0m \e[1;34m%s %s\e[0m\n" "$OS_DETAILS" "$ARCH"

    # Kernel
    KERNEL=$(powershell -Command "(Get-CimInstance Win32_OperatingSystem).Version" 2>/dev/null | tr -d '\r')
    [ -z "$KERNEL" ] && KERNEL="Unknown"
    printf "\e[1;33mKernel:\e[0m \e[1;34m%s\e[0m\n" "$KERNEL"

    # Uptime
    UPTIME=$(powershell -Command '$ts = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime; $days = $ts.Days; $hours = $ts.Hours; $minutes = $ts.Minutes; $out = ""; if ($days -gt 0) {$out += "$days days, "}; if ($hours -gt 0 -or $days -gt 0) {$out += "$hours hours, "}; $out += "$minutes minutes"; $out' 2>/dev/null | tr -d '\r')
    printf "\e[1;33mUptime:\e[0m \e[1;34m%s\e[0m\n" "${UPTIME:-Unavailable}"

    # Packages
    printf "\e[1;33mPackages:\e[0m \e[1;34mN/A\e[0m\n"

    # Shell
    SHELL_NAME=${SHELL:-"Git Bash"}
    printf "\e[1;33mShell:\e[0m \e[1;34m%s\e[0m\n" "$SHELL_NAME"

    # Display Resolution
    H_RES=$(powershell -Command "(Get-CimInstance Win32_VideoController).CurrentHorizontalResolution" 2>/dev/null | tr -d '\r')
    V_RES=$(powershell -Command "(Get-CimInstance Win32_VideoController).CurrentVerticalResolution" 2>/dev/null | tr -d '\r')
    if [ -n "$H_RES" ] && [ -n "$V_RES" ] && [ "$H_RES" != "0" ] && [ "$V_RES" != "0" ]; then
        RESOLUTION="${H_RES}x${V_RES}"
    else
        RESOLUTION="Unavailable"
    fi
    printf "\e[1;33mDisplay:\e[0m \e[1;34m%s\e[0m\n" "$RESOLUTION"

    # Desktop Environment & Window Manager
    printf "\e[1;33mDE:\e[0m \e[1;34mWindows\e[0m\n"
    printf "\e[1;33mWM:\e[0m \e[1;34mDesktop Window Manager\e[0m\n"
    printf "\e[1;33mWM Theme:\e[0m \e[1;34mDefault\e[0m\n"

    # Font and Cursor
    printf "\e[1;33mFont:\e[0m \e[1;34mDefault Windows Font\e[0m\n"
    printf "\e[1;33mCursor:\e[0m \e[1;34mSystem Default (32px approx.)\e[0m\n"

    # Terminal & Terminal Font
    TERM_INFO=${TERM:-"Git Bash"}
    printf "\e[1;33mTerminal:\e[0m \e[1;34m%s\e[0m\n" "$TERM_INFO"
    printf "\e[1;33mTerminal Font:\e[0m \e[1;34mConsolas (default)\e[0m\n"

    # CPU Information
    CPU_INFO=$(powershell -Command "(Get-CimInstance Win32_Processor).Name" 2>/dev/null | tr -d '\r')
    [ -z "$CPU_INFO" ] && CPU_INFO="Unavailable"
    printf "\e[1;33mCPU:\e[0m \e[1;34m%s\e[0m\n" "$CPU_INFO"

    # GPU Information
    GPU_INFO=$(powershell -Command "(Get-CimInstance Win32_VideoController).Name" 2>/dev/null | tr -d '\r' | head -n1)
    [ -z "$GPU_INFO" ] && GPU_INFO="Unavailable"
    printf "\e[1;33mGPU:\e[0m \e[1;34m%s\e[0m\n" "$GPU_INFO"

    # Memory Information
    TOTAL_MEM=$(powershell -Command "((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize)" 2>/dev/null | tr -d '\r' | tr -d ',')
    FREE_MEM=$(powershell -Command "((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory)" 2>/dev/null | tr -d '\r' | tr -d ',')
    if [ -n "$FREE_MEM" ] && [ -n "$TOTAL_MEM" ] && [ "$TOTAL_MEM" -gt 0 ]; then
        USED_MEM=$(( TOTAL_MEM - FREE_MEM ))
        USED_PCT=$(( USED_MEM * 100 / TOTAL_MEM ))
        # Convert KB to MB, then approximate GiB (divide by 1024 twice, avoiding bc)
        USED_MB=$(( USED_MEM / 1024 ))
        TOTAL_MB=$(( TOTAL_MEM / 1024 ))
        USED_GiB=$(( USED_MB / 1024 ))
        TOTAL_GiB=$(( TOTAL_MB / 1024 ))
        # If remainder is significant, add 1 to GiB for approximation
        [ $(( USED_MB % 1024 )) -gt 512 ] && USED_GiB=$(( USED_GiB + 1 ))
        [ $(( TOTAL_MB % 1024 )) -gt 512 ] && TOTAL_GiB=$(( TOTAL_GiB + 1 ))
        MEM_INFO="${USED_GiB} GiB / ${TOTAL_GiB} GiB (${USED_PCT}%)"
    else
        MEM_INFO="Unavailable"
    fi
    printf "\e[1;33mMemory:\e[0m \e[1;34m%s\e[0m\n" "$MEM_INFO"

    # Swap Information
    SWAP_TOTAL=$(powershell -Command "((Get-CimInstance Win32_PageFileUsage).AllocatedBaseSize)" 2>/dev/null | tr -d '\r' | tr -d ',')
    SWAP_USED=$(powershell -Command "((Get-CimInstance Win32_PageFileUsage).CurrentUsage)" 2>/dev/null | tr -d '\r' | tr -d ',')
    if [ -n "$SWAP_TOTAL" ] && [ -n "$SWAP_USED" ] && [ "$SWAP_TOTAL" -ge 0 ]; then
        # Convert MB to GiB (approximate, avoiding bc)
        SWAP_USED_GiB=$(( SWAP_USED / 1024 ))
        SWAP_TOTAL_GiB=$(( SWAP_TOTAL / 1024 ))
        [ $(( SWAP_USED % 1024 )) -gt 512 ] && SWAP_USED_GiB=$(( SWAP_USED_GiB + 1 ))
        [ $(( SWAP_TOTAL % 1024 )) -gt 512 ] && SWAP_TOTAL_GiB=$(( SWAP_TOTAL_GiB + 1 ))
        SWAP_INFO="${SWAP_USED_GiB} GiB / ${SWAP_TOTAL_GiB} GiB"
    else
        SWAP_INFO="N/A"
    fi
    printf "\e[1;33mSwap:\e[0m \e[1;34m%s\e[0m\n" "$SWAP_INFO"

    # Disk Usage for C: drive
    DISK_INFO=$(powershell -Command '$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID=''C:''"; if ($disk) { "{0} {1}" -f $disk.FreeSpace, $disk.Size } else { "0 0" }' 2>/dev/null | tr -d '\r')
    read FREE_SPACE SIZE <<<"$DISK_INFO"
    FREE_SPACE=$(echo "$FREE_SPACE" | tr -d ',' | tr -d '\r')
    SIZE=$(echo "$SIZE" | tr -d ',' | tr -d '\r')
    if [ -n "$SIZE" ] && [ "$SIZE" -gt 0 ] && [ -n "$FREE_SPACE" ] && [ "$FREE_SPACE" -ge 0 ]; then
        USED=$(( SIZE - FREE_SPACE ))
        USED_PCT=$(( USED * 100 / SIZE ))
        # Convert bytes to GiB (divide by 1024^3, approximate)
        USED_GiB=$(( USED / 1073741824 ))
        TOTAL_GiB=$(( SIZE / 1073741824 ))
        # Adjust for significant remainders
        [ $(( (USED / 1048576) % 1024 )) -gt 512 ] && USED_GiB=$(( USED_GiB + 1 ))
        [ $(( (SIZE / 1048576) % 1024 )) -gt 512 ] && TOTAL_GiB=$(( TOTAL_GiB + 1 ))
        DISK_USAGE="${USED_GiB} GiB / ${TOTAL_GiB} GiB (${USED_PCT}% used)"
    else
        DISK_USAGE="Unavailable"
    fi
    printf "\e[1;33mDisk (C:):\e[0m \e[1;34m%s\e[0m\n" "$DISK_USAGE"

    # Local IP
    LOCAL_IP=$(powershell -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '169.254.*' -and $_.IPAddress -notlike '127.*' }).IPAddress" 2>/dev/null | head -n1 | tr -d '\r')
    [ -z "$LOCAL_IP" ] && LOCAL_IP="Unavailable"
    printf "\e[1;33mLocal IP (Ethernet):\e[0m \e[1;34m%s\e[0m\n" "$LOCAL_IP"

    # Battery Information
    BATTERY=$(powershell -Command '$batt = (Get-CimInstance Win32_Battery).EstimatedChargeRemaining; if ($batt) {"$batt%"} else {"N/A"}' 2>/dev/null | tr -d '\r')
    printf "\e[1;33mBattery:\e[0m \e[1;34m%s\e[0m\n" "$BATTERY"

    # Power Adapter
    printf "\e[1;33mPower Adapter:\e[0m \e[1;34m61W USB-C Power Adapter\e[0m\n"

    # Locale
    LOCALE=${LANG:-"en_US.UTF-8"}
    printf "\e[1;33mLocale:\e[0m \e[1;34m%s\e[0m\n" "$LOCALE"

else
    echo "Unsupported OS: $OSTYPE"
fi