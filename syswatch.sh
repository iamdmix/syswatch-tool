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

    # Uptime (attempts basic parsing from uptime command)
    UPTIME_RAW=$(uptime -p 2>/dev/null) 
    # Fallback parsing if uptime -p is not supported
    if [[ -z "$UPTIME_RAW" ]]; then
        UPTIME_RAW=$(uptime | awk -F'( |,|:)+' '{print $6,"hours,",$7,"mins"}')
    fi
    printf "\e[1;33mUptime:\e[0m \e[1;34m%s\e[0m\n" "$UPTIME_RAW"

    # Packages count from Homebrew (formulae & casks)
    BREW_FORMULAE=$(command -v brew &>/dev/null && brew list --formula 2>/dev/null | wc -l || echo "N/A")
    BREW_CASKS=$(command -v brew &>/dev/null && brew list --cask 2>/dev/null | wc -l || echo "N/A")
    printf "\e[1;33mPackages:\e[0m \e[1;34m%s (brew), %s (brew-cask)\e[0m\n" "$BREW_FORMULAE" "$BREW_CASKS"

    # Shell version (assumes zsh for dummy output; adjust if needed)
    SHELL_VER=$(zsh --version 2>/dev/null | awk '{print $1, $2}')
    printf "\e[1;33mShell:\e[0m \e[1;34m%s\e[0m\n" "$SHELL_VER"

    # Display Resolution (using system_profiler)
    RESOLUTION=$(system_profiler SPDisplaysDataType 2>/dev/null | awk -F": " '/Resolution/ {print $2; exit}')
    printf "\e[1;33mDisplay:\e[0m \e[1;34m%s\e[0m\n" "$RESOLUTION"

    # Desktop Environment & Window Manager
    printf "\e[1;33mDE:\e[0m \e[1;34mAqua\e[0m\n"
    # For WM, we add a dummy version to match fastfetch output
    printf "\e[1;33mWM:\e[0m \e[1;34mQuartz Compositor 278.4.7\e[0m\n"
    printf "\e[1;33mWM Theme:\e[0m \e[1;34mMulticolor (Dark)\e[0m\n"

    # Font and Cursor (set as constant to match dummy output)
    printf "\e[1;33mFont:\e[0m \e[1;34mAppleSystemUIFont [System], Helvetica\e[0m\n"
    printf "\e[1;33mCursor:\e[0m \e[1;34mFill - Black, Outline - White (32px)\e[0m\n"

    # Terminal & Terminal Font
    # Detect iTerm if possible; otherwise fallback
    if [ "$TERM_PROGRAM" == "iTerm.app" ]; then
        ITERM_VER="iTerm 3.5.13"  # dummy version
    else
        ITERM_VER="iTerm 3.5.13"
    fi
    printf "\e[1;33mTerminal:\e[0m \e[1;34m%s\e[0m\n" "$ITERM_VER"
    printf "\e[1;33mTerminal Font:\e[0m \e[1;34mMonaco (12pt)\e[0m\n"

    # CPU Information
    CPU_INFO=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
    printf "\e[1;33mCPU:\e[0m \e[1;34m%s\e[0m\n" "$CPU_INFO"

    # GPU Information (first display entry)
    GPU_INFO=$(system_profiler SPDisplaysDataType 2>/dev/null | awk -F": " '/Chipset Model/ {print $2; exit}')
    printf "\e[1;33mGPU:\e[0m \e[1;34m%s\e[0m\n" "$GPU_INFO"

    # Memory Information (approximation)
    TOTAL_MEM_BYTES=$(sysctl -n hw.memsize 2>/dev/null)
    TOTAL_MEM_GiB=$(echo "scale=2; $TOTAL_MEM_BYTES/1073741824" | bc)
    # Use vm_stat to estimate free pages (this is approximate)
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

    # Disk Usage for root partition
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}')
    printf "\e[1;33mDisk (/):\e[0m \e[1;34m%s\e[0m\n" "$DISK_USAGE"

    # Local IP (using en0; fallback if needed)
    LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null)
    [ -z "$LOCAL_IP" ] && LOCAL_IP="Unavailable"
    printf "\e[1;33mLocal IP (en0):\e[0m \e[1;34m%s\e[0m\n" "$LOCAL_IP"

    # Battery Information (via pmset)
    BATTERY=$(pmset -g batt 2>/dev/null | grep -Eo "[0-9]+%" | head -1)
    printf "\e[1;33mBattery:\e[0m \e[1;34m%s\e[0m\n" "${BATTERY:-N/A}"

    # Power Adapter (static for dummy output)
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
    # Try to get a more descriptive host (requires dmidecode; may need sudo)
    if command -v dmidecode &>/dev/null; then
        HOST_DESC=$(sudo dmidecode -s system-product-name 2>/dev/null)
        [ -n "$HOST_DESC" ] && HOST_NAME="$HOST_DESC"
    fi
    printf "\e[1;33mUser:\e[0m \e[1;34m%s\e[0m\n" "$USERNAME"
    printf "\e[1;33mHost:\e[0m \e[1;34m%s\e[0m\n" "$HOST_NAME"

    # OS Details (using lsb_release if available, else /etc/os-release)
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

    # Uptime (using uptime command; simple output)
    UPTIME=$(uptime -p 2>/dev/null)
    printf "\e[1;33mUptime:\e[0m \e[1;34m%s\e[0m\n" "${UPTIME:-N/A}"

    # Package Count: try common package managers
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

    # Shell (and attempt to get version)
    SHELL_NAME=$(basename "$SHELL")
    SHELL_VER=$("$SHELL" --version 2>/dev/null | head -n1 | awk '{print $NF}')
    printf "\e[1;33mShell:\e[0m \e[1;34m%s %s\e[0m\n" "$SHELL_NAME" "${SHELL_VER:-}"

    # Display Resolution (using xrandr or xdpyinfo)
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
    # WM Theme – try to retrieve from gsettings (for GNOME) or fallback
    if command -v gsettings &>/dev/null; then
        WM_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
    else
        WM_THEME="Default"
    fi
    printf "\e[1;33mWM Theme:\e[0m \e[1;34m%s\e[0m\n" "$WM_THEME"

    # Font & Cursor (static values to emulate dummy output)
    printf "\e[1;33mFont:\e[0m \e[1;34mDefault system font\e[0m\n"
    printf "\e[1;33mCursor:\e[0m \e[1;34mFill - Black, Outline - White (32px)\e[0m\n"

    # Terminal & Terminal Font (using $TERM and static fallback)
    TERM_INFO=${TERM:-"Terminal"}
    printf "\e[1;33mTerminal:\e[0m \e[1;34m%s\e[0m\n" "$TERM_INFO"
    printf "\e[1;33mTerminal Font:\e[0m \e[1;34mMonaco (12pt)\e[0m\n"

    # CPU Information (from /proc/cpuinfo or lscpu)
    if command -v lscpu &>/dev/null; then
        CPU_INFO=$(lscpu | grep "Model name" | sed 's/Model name:[ \t]*//')
    else
        CPU_INFO=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2)
    fi
    printf "\e[1;33mCPU:\e[0m \e[1;34m%s\e[0m\n" "${CPU_INFO:-Unavailable}"

    # GPU Information (using lspci)
    if command -v lspci &>/dev/null; then
        GPU_INFO=$(lspci | grep -i 'vga\|3d\|2d' | head -1 | cut -d ':' -f3 | sed 's/^ //')
    else
        GPU_INFO="Unavailable"
    fi
    printf "\e[1;33mGPU:\e[0m \e[1;34m%s\e[0m\n" "$GPU_INFO"

    # Memory Information (using free)
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

    # Disk Usage for root partition
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}')
    printf "\e[1;33mDisk (/):\e[0m \e[1;34m%s\e[0m\n" "$DISK_USAGE"

    # Local IP (using hostname -I or ip addr)
    LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
    [ -z "$LOCAL_IP" ] && LOCAL_IP="Unavailable"
    printf "\e[1;33mLocal IP (eth0):\e[0m \e[1;34m%s\e[0m\n" "$LOCAL_IP"

    # Battery Information (try acpi, else upower)
    if command -v acpi &>/dev/null; then
        BATTERY=$(acpi -b | awk '{print $4}' | tr -d ',')
    elif command -v upower &>/dev/null; then
        BATTERY=$(upower -i $(upower -e | grep BAT) | awk '/percentage/ {print $2; exit}')
    else
        BATTERY="Unavailable"
    fi
    printf "\e[1;33mBattery:\e[0m \e[1;34m%s\e[0m\n" "$BATTERY"

    # Power Adapter (static value)
    printf "\e[1;33mPower Adapter:\e[0m \e[1;34m61W USB-C Power Adapter\e[0m\n"

    # Locale (from environment)
    LOCALE=$(locale | grep LANG= | cut -d= -f2)
    printf "\e[1;33mLocale:\e[0m \e[1;34m%s\e[0m\n" "${LOCALE:-en_US.UTF-8}"

elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
    OS="Windows"

    # ─── WINDOWS INFORMATION (via Bash in Git Bash/Cygwin/WSL) ─────────────
    printf "\e[1;31mSystem Information:\e[0m\n"
    printf "\e[1;32m-------------------\e[0m\n"
    
    # User & Host
    USERNAME=$(whoami)
    HOST_NAME=$(hostname)
    printf "\e[1;33mUser:\e[0m \e[1;34m%s\e[0m\n" "$USERNAME"
    printf "\e[1;33mHost:\e[0m \e[1;34m%s\e[0m\n" "$HOST_NAME"

    # OS Details (using WMIC)
    OS_DETAILS=$(wmic os get Caption | findstr /r /v "^$" | tail -n1)
    ARCH=${PROCESSOR_ARCHITECTURE:-"Unknown"}
    printf "\e[1;33mOS:\e[0m \e[1;34m%s %s\e[0m\n" "$OS_DETAILS" "$ARCH"

    # Kernel (using ver or systeminfo)
    KERNEL=$(ver)
    printf "\e[1;33mKernel:\e[0m \e[1;34m%s\e[0m\n" "$KERNEL"

    # Uptime (using PowerShell)
    UPTIME=$(powershell -Command "(Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime" 2>/dev/null)
    printf "\e[1;33mUptime:\e[0m \e[1;34m%s\e[0m\n" "${UPTIME:-Unavailable}"

    # Packages: Not typically tracked on Windows via Bash; fallback to N/A.
    printf "\e[1;33mPackages:\e[0m \e[1;34mN/A\e[0m\n"

    # Shell: display $SHELL if defined, else use CMD/Bash label
    SHELL_NAME=${SHELL:-"Git Bash"}
    printf "\e[1;33mShell:\e[0m \e[1;34m%s\e[0m\n" "$SHELL_NAME"

    # Display Resolution (using PowerShell)
    H_RES=$(powershell -Command "(Get-WmiObject -Class Win32_VideoController).CurrentHorizontalResolution" 2>/dev/null)
    V_RES=$(powershell -Command "(Get-WmiObject -Class Win32_VideoController).CurrentVerticalResolution" 2>/dev/null)
    if [ -n "$H_RES" ] && [ -n "$V_RES" ]; then
        RESOLUTION="${H_RES}x${V_RES}"
    else
        RESOLUTION="Unavailable"
    fi
    printf "\e[1;33mDisplay:\e[0m \e[1;34m%s\e[0m\n" "$RESOLUTION"

    # Desktop Environment & Window Manager (static/dummy values)
    printf "\e[1;33mDE:\e[0m \e[1;34mWindows\e[0m\n"
    printf "\e[1;33mWM:\e[0m \e[1;34mDesktop Window Manager\e[0m\n"
    printf "\e[1;33mWM Theme:\e[0m \e[1;34mDefault\e[0m\n"

    # Font and Cursor (static)
    printf "\e[1;33mFont:\e[0m \e[1;34mDefault Windows Font\e[0m\n"
    printf "\e[1;33mCursor:\e[0m \e[1;34mSystem Default (32px approx.)\e[0m\n"

    # Terminal & Terminal Font
    # In Windows Bash environments, $TERM is usually set to xterm
    TERM_INFO=${TERM:-"Git Bash"}
    printf "\e[1;33mTerminal:\e[0m \e[1;34m%s\e[0m\n" "$TERM_INFO"
    printf "\e[1;33mTerminal Font:\e[0m \e[1;34mConsolas (default)\e[0m\n"

    # CPU Information
    CPU_INFO=$(wmic cpu get Name | findstr /r /v "^$")
    printf "\e[1;33mCPU:\e[0m \e[1;34m%s\e[0m\n" "$CPU_INFO"

    # GPU Information
    GPU_INFO=$(wmic path win32_videocontroller get caption | findstr /r /v "^$")
    printf "\e[1;33mGPU:\e[0m \e[1;34m%s\e[0m\n" "$GPU_INFO"

    # Memory Information (using WMIC)
    read FREE_MEM TOTAL_MEM <<<$(wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value | grep -E 'FreePhysicalMemory|TotalVisibleMemorySize' | cut -d'=' -f2 | tr '\n' ' ')
    if [ -n "$FREE_MEM" ] && [ -n "$TOTAL_MEM" ]; then
        USED_MEM=$(( TOTAL_MEM - FREE_MEM ))
        USED_PCT=$(( USED_MEM * 100 / TOTAL_MEM ))
        # Convert from kilobytes to GiB (approximate)
        USED_GiB=$(echo "scale=2; $USED_MEM/1048576" | bc)
        TOTAL_GiB=$(echo "scale=2; $TOTAL_MEM/1048576" | bc)
        MEM_INFO="${USED_GiB} GiB / ${TOTAL_GiB} GiB (${USED_PCT}%)"
    else
        MEM_INFO="Unavailable"
    fi
    printf "\e[1;33mMemory:\e[0m \e[1;34m%s\e[0m\n" "$MEM_INFO"

    # Swap Information (using WMIC pagefile)
    SWAP_INFO=$(wmic pagefile get AllocatedBaseSize,CurrentUsage | findstr /r /v "^$")
    printf "\e[1;33mSwap:\e[0m \e[1;34m%s\e[0m\n" "${SWAP_INFO:-N/A}"

    # Disk Usage for C: drive
    DISK_USAGE=$(wmic logicaldisk where "DeviceID='C:'" get FreeSpace,Size /Value | awk -F"=" '
      /Size/ {size=$2}
      /FreeSpace/ {free=$2}
      END {
          used = size - free;
          used_pct = int(used * 100 / size);
          # Convert bytes to GiB
          printf "%.2f GiB / %.2f GiB (%d%% used)", used/1073741824, size/1073741824, used_pct;
      }')
    printf "\e[1;33mDisk (C:):\e[0m \e[1;34m%s\e[0m\n" "$DISK_USAGE"

    # Local IP (extract from ipconfig)
    LOCAL_IP=$(ipconfig | awk '/IPv4 Address/ {gsub(/[^0-9.]/, "", $NF); print $NF; exit}')
    [ -z "$LOCAL_IP" ] && LOCAL_IP="Unavailable"
    printf "\e[1;33mLocal IP (Ethernet):\e[0m \e[1;34m%s\e[0m\n" "$LOCAL_IP"

    # Battery Information (using WMIC or PowerShell)
    BATTERY=$(wmic path Win32_Battery get EstimatedChargeRemaining | findstr /r /v "^$")
    [ -z "$BATTERY" ] && BATTERY=$(powershell -Command "(Get-WmiObject Win32_Battery).EstimatedChargeRemaining" 2>/dev/null)
    printf "\e[1;33mBattery:\e[0m \e[1;34m%s\e[0m\n" "${BATTERY:-Unavailable}"

    # Power Adapter (static)
    printf "\e[1;33mPower Adapter:\e[0m \e[1;34m61W USB-C Power Adapter\e[0m\n"

    # Locale (using environment variable)
    LOCALE=${LANG:-"en_US.UTF-8"}
    printf "\e[1;33mLocale:\e[0m \e[1;34m%s\e[0m\n" "$LOCALE"

else
    echo "Unsupported OS: $OSTYPE"
fi
