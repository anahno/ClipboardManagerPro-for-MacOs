# ClipboardManager Pro for macOS

<img width="347" height="402" alt="Screenshot 2025-09-14 at 6 37 20 AM" src="https://github.com/user-attachments/assets/6dbd7d82-37da-4088-8354-d5f0878084d0" />
<img width="347" height="401" alt="Screenshot 2025-09-14 at 6 37 03 AM" src="https://github.com/user-attachments/assets/eb96b487-face-427a-9511-93a5abfa494b" />
<img width="401" height="475" alt="Screenshot 2025-09-14 at 6 37 36 AM" src="https://github.com/user-attachments/assets/710401d9-8f5d-44e6-bf99-1433a722a42d" />

A powerful, secure, and native clipboard history manager for macOS, built from the ground up with Swift, SwiftUI, and Core Data. This project was created to solve the common problem of losing copied items by providing a reliable, searchable, and private memory for your clipboard.

The source code is fully open for you to explore, learn from, and contribute to.

---

## ✨ Key Features

*   **Persistent Clipboard History**: Automatically saves everything you copy—text, images, and file paths.
*   🔐 **Secure & Private**: Protect your entire clipboard history with a password.
    *   Uses the secure **macOS Keychain** to store your password.
    *   Supports **Touch ID** or your system password for securely resetting your app password if you forget it.
*   📸 **Automatic Screenshot Detection**: Instantly and automatically adds any screenshot you take to your history.
*   📌 **Pin Your Favorites**: Keep frequently used items like email addresses or code snippets pinned to the top for instant access.
*   🔍 **Powerful Search**: Quickly find any text-based item in your history.
*   💾 **Robust Persistence with Core Data**: Built on Core Data, the app can handle large clipboard histories efficiently without crashing.
*   🚀 **Native macOS Experience**: Designed to feel right at home on your Mac, with a lightweight menu bar icon and global hotkey access (**⌘ + ⇧ + V**).
*   📂 **Reveal in Finder**: For any copied files or screenshots, you can instantly reveal the original file in Finder.

---

## 🛠 Tech Stack

This project was a fantastic opportunity to dive deep into Apple's native technologies. The core stack includes:

*   **Language**: Swift
*   **UI Framework**: SwiftUI
*   **Database**: Core Data
*   **System Integration**: AppKit (for the menu bar status item and popover)
*   **Security**: LocalAuthentication (for Touch ID) and Security framework (for Keychain)

---

## 🚀 Getting Started

You can build and run this project yourself using Xcode.

### Prerequisites

*   macOS 13.0 (Ventura) or later
*   Xcode 15.0 or later

### Build Instructions

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/[Your_GitHub_Username]/[Your_Repo_Name].git
    ```
2.  **Open the project in Xcode:**
    ```sh
    cd [Your_Repo_Name]
    open ClipboardManagerPro.xcodeproj
    ```
3.  **Build & Run:**
    Press `Cmd + R` in Xcode to build and run the application on your Mac.

---

## 📜 License & Usage

This project is provided under a custom license.

#### **Personal Use**
The software is **free to use for any personal, educational, and non-commercial purposes**. You are welcome to download, build, and use the application on your personal machines.

#### **Commercial Use**
Commercial use of this software or any of its source code requires a separate license. Please contact me directly at **b1919f@gmail.com** to discuss licensing options for your business needs.

---

## ❤️ Support & Donations

ClipboardManager Pro is a passion project developed and maintained in my free time. I am committed to keeping this project **open-source** for everyone to learn from and contribute to.

If you find the app useful and want to support its continued development, please consider making a donation. Your support allows me to dedicate more time to adding new features, fixing bugs, and ensuring the repository remains active and healthy.

**[➡️ Donate via Crypto] (https://donate.webmoney.com/w/y53QzElsT2gvkDgRvkJ9ul)**
**[Scan QrCode for Donate]**![Screenshot_20250914_124427_WebMoney Keeper](https://github.com/user-attachments/assets/91166985-7d7c-4ddd-b84a-7db1ea459cff)

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request
