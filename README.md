# qemu-img-windows-x64

Minimal set of files to run [`qemu-img`](https://qemu-project.gitlab.io/qemu/tools/qemu-img.html) on Windows without installing the full QEMU suite.

For Windows 64-bit only.



## How to use

### Option 1: Automated download (Recommended)

Option 1: Automated Download (Recommended)

Run the [`download-qemu-img.ps1`](./download-qemu-img.ps1) script to automatically download the latest version to a temporary directory and add it to your PATH (for the current session only).

To execute it directly, run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fdcastel/qemu-img-windows-x64/master/download-qemu-img.ps1'))
```



### Option 2: Manual Installation

Download the ZIP archive from the [latest release](https://github.com/fdcastel/qemu-img-windows-x64/releases/latest) and extract it.

All necessary files are included.



## Development Notes

To identify the required files from the official QEMU build, use [Dependencies](https://github.com/lucasg/Dependencies):


```powershell
# Install via Chocolatey
choco install Dependencies -y

# List required DLLs for qemu-img.exe
Dependencies.exe -depth 5 -modules './qemu-img.exe' |
    Select-String '\[ApplicationDirectory\]\s+(\S+)' |
        ForEach-Object { $_.Matches.Groups[1].Value }
```
