# Hospital Management System

A comprehensive, console-based application written entirely in x86 Assembly Language using the MASM compiler and Irvine32 library. This project manages hospital administration tasks through direct memory manipulation, system interrupts, and low-level file I/O operations.

## 🌟 Key Features
* **Admin Security:** Requires an admin setup on launch and enforces a secure login system with a maximum of 3 attempts before locking out.
* **Patient & Doctor Management:** Allows administrators to add new patients and doctors, ensuring unique IDs to prevent duplication.
* **Appointment Logic:** Features a robust assignment system that links patients to specific doctors. It enforces capacity constraints, ensuring no doctor exceeds their maximum limit of 3 patients.
* **Data Persistence:** Automatically saves and loads database arrays (patient lists, doctor details, and assignments) to local text files (`patients.txt` and `doctors.txt`) to maintain state between sessions.
* **Search & Reporting:** Includes functionality to search for specific patient records by ID and generate aggregate hospital reports.

## 🛠️ Tech Stack
* **Language:** x86 Assembly Language
* **Assembler/Library:** MASM (Microsoft Macro Assembler) / `Irvine32.inc`
* **Core Concepts:** Arrays, File Handling (Read/Write to `.txt`), String Manipulation, Procedural Logic (Macros/Procedures)

## 📁 Repository Structure
* `main.asm`: The core source code containing the `.data` segment (variables, strings, arrays) and `.code` segment (procedures for login, menus, filing, and data manipulation).

## 🚀 How to Run Locally

1. **Prerequisites:** Ensure you have Visual Studio installed with MASM enabled, and the Irvine32 library configured in your environment.
2. **Clone the repository:**
   ```bash
   git clone [https://github.com/FarisDosani/Hospital-Management-System.git](https://github.com/FarisDosani/Hospital-Management-System.git)
