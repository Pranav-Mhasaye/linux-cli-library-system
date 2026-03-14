# 📚 Linux CLI Library Management System

![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=flat-square&logo=linux&logoColor=black)

## 📌 Overview
A robust, purely CLI-based Library Management System designed to operate entirely within the Linux terminal. This project bypasses traditional SQL engines, utilizing Linux flat-file data structures and core text processing utilities (`grep`, `awk`, `cut`) to manage inventory and user transactions. 

## ✨ Key Features
* **Flat-File Database:** Custom CRUD operations without external database engines.
* **Hardware Integration:** Driver-less barcode scanner integration via `stdin` for rapid student ID scanning.
* **Automated Logging:** Immutable transaction logs for all checkouts and returns.

## 🚀 Quick Start
```bash
# Clone the repository
git clone [https://github.com/Pranav-Mhasaye/linux-cli-library-system.git](https://github.com/Pranav-Mhasaye/linux-cli-library-system.git)

# Navigate to the directory
cd linux-cli-library-system

# Make the script executable
chmod +x library_pro.sh

# Run the system
./library_pro.sh
