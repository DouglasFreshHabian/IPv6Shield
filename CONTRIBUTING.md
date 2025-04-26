# Contributing to IPv6Shield™

Thank you for considering contributing to the **IPv6Shield™** project! Contributions are welcome and appreciated. This guide will help you understand how to contribute in an efficient and structured way.

## Table of Contents
1. [Reporting Issues](#reporting-issues)
2. [Forking the Repo](#forking-the-repo)
3. [Submitting Changes](#submitting-changes)
4. [Coding Guidelines](#coding-guidelines)
5. [Code of Conduct](#code-of-conduct)

---

## Reporting Issues

If you find a bug or have an issue with the script, please open an issue in the [Issues section](https://github.com/DouglasFreshHabian/IPv6Shield/issues) of the repository. When creating an issue, please provide the following information to help us understand and resolve the problem efficiently:

- **Description of the issue**: What is happening? What do you expect to happen?
- **Steps to reproduce**: Please include clear steps to reproduce the issue.
- **Logs and error messages**: If available, include any relevant logs or error messages.
- **Environment details**: Which operating system and version are you using? (e.g., Ubuntu 20.04, Fedora 34, etc.)

---

## Forking the Repo

To contribute to the project, you will need to **fork** the repository:

1. Click on the "Fork" button in the top-right corner of the repository.
2. Clone your forked repository to your local machine:
   ```bash
   git clone https://github.com/your-username/IPv6Shield.git
2. Create a new branch for your changes:
   ```bash
      git checkout -b feature-branch-name
   ```

## 📬 Submitting Changes
After making changes, follow these steps to submit your changes:

1. Commit your changes with a clear message:

   ```bash
      git add .
      git commit -m "Add feature or fix bug"
   ```
2. Push your changes:
   ```bash
      git push origin feature-branch-name
   ```
    
3. Create a pull request (PR): 

* Go to the pull requests page, 
* click "New pull request," and select your branch. 
* Please provide a clear description of what your changes do and why they are being proposed.

## 💡 Coding Guidelines
Please ensure that your code follows these general guidelines:

### 🧼 Bash Script Formatting

* Use 2 spaces for indentation.

* Keep code readable with spacing and comments.

* Comment any complex logic for clarity.

* Avoid hardcoding paths – use variables or allow user input.

### ⚠️  Error Handling

* Always check for errors and exit gracefully with proper codes (exit 1, etc.).

### 🧪 Testing

* Test your changes on a supported distro before submitting a PR.

* Ensure it works without breaking existing functionality.

### 🐧 Compatibility

* Maintain compatibility with major distros:

  * Debian, Ubuntu, Fedora, Kali, Parrot, Raspberry Pi, etc.

## 🤝 Code of Conduct

By participating in this project, you agree to abide by the Code of Conduct.

We want to maintain a welcoming and respectful community. Please be respectful to others, be open to feedback, and engage in discussions in a positive way.
Thank You!

Your contributions help make IPv6Shield™ better for everyone. Thank you for being part of this open-source project and contributing to its growth!
