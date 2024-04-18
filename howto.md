# SysWatch: Resource Monitor & Performance Tracker (WIP)

SysWatch is a handy tool you use on the command line to check how well your computer is running. It gives you updates on important stuff like how much memory your computer is using and how fast it's working. With SysWatch, you can make sure your computer is running smoothly.

SysWatch is your trusted ally in keeping your system's performance and health in check. With SysWatch, you gain access to crucial system details right at your fingertips:

- **Operating System:** Quickly identify the operating system running on your device, providing insights into its core functionality.
- **Host Information:** Gain insight into your device's network configuration, including its hostname and IP address, for seamless connectivity management.
- **Uptime:** Stay informed about how long your system has been running without interruption, enabling proactive maintenance scheduling.
- **Installed Packages:** View a comprehensive list of installed software packages, simplifying package management and updates.
- **Display Resolution:** Check your device's display resolution settings to ensure optimal visual clarity and compatibility.
- **CPU and GPU Statistics:** Monitor the usage, temperature, and performance of your device's CPU and GPU, enabling efficient resource allocation and performance optimization.
- **Memory Usage:** Keep track of your device's memory usage in real-time to prevent slowdowns and ensure optimal performance.
- **Storage Details:** Access detailed information about your device's storage, including available space, usage statistics, and disk partitions.
- **System Temperature:** Monitor your device's temperature sensors to prevent overheating and maintain hardware integrity.

SysWatch provides a user-friendly interface for effortlessly accessing and interpreting these critical system metrics, empowering you to optimize your device's performance and ensure its longevity. Whether you're a system administrator, developer, or casual user, SysWatch is your all-in-one solution for system monitoring and management.

## Firstly, How to make a CLI Tool that would work in C

### To do this we could use [argp](https://www.gnu.org/software/libc/manual/html_node/Argp.html)

# macOS cli commands:

| Task                         | macOS Command                                 |
| ---------------------------- | --------------------------------------------- |
| Operating System Information | `sw_vers`                                     |
| Host Information             | `hostname` or `ifconfig`                      |
| Uptime                       | `uptime`                                      |
| Installed Packages           | `pkgutil --pkgs`                              |
| Display Resolution           | `system_profiler SPDisplaysDataType`          |
| CPU and GPU Stats            | `top` or `system_profiler SPHardwareDataType` |
| Memory Usage                 |                          |
| Storage Details              |                           |
| System Temperature           |          |

# ASCII Art

As it's my first time working on something this big, instead of making it display custom images based on the CPU, I will make it display an ASCII art of the SysWatch.

[How I generated the ASCII Art](https://patorjk.com/software/taag/#p=testall&f=Alpha&t=SysWatch)

The ASCII Art, I chose as of now is as follows:
```
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
```

# The Shell Script
After quite some messing around, I was able to make a simple shell script for this. **AS OF NOW IT'S VERY VERY VERY BASIC.** 

I ran ```neofetch``` and SysWatch side by side and then saw that ```neofetch``` was actually executing much faster. Will figure out how to speed this up.