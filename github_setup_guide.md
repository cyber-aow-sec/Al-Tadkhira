# GitHub Setup Guide

Follow these steps to connect your local project to GitHub.

## 1. Configure Git Identity
First, tell Git who you are. Open your terminal and run:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 2. Create a Repository on GitHub
1.  Log in to [GitHub](https://github.com).
2.  Click the **+** icon in the top-right and select **New repository**.
3.  Name your repository (e.g., `Al-Tadkhira`).
4.  **Important**: Do *not* initialize with README, .gitignore, or License (since you already have code locally).
5.  Click **Create repository**.

## 3. Link and Push Your Code
Copy the repository URL provided by GitHub (e.g., `https://github.com/username/Al-Tadkhira.git`).

Then, run the following commands in your project terminal:

```bash
# 1. Commit your current files (if you haven't already)
git add .
git commit -m "Initial commit"

# 2. Rename the branch to 'main' (standard practice)
git branch -M main

# 3. Add the remote repository (replace URL with yours)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# 4. Push your code
git push -u origin main
```

## 4. Authentication
When you push, Git will ask for a username and password.
-   **Username**: Your GitHub username.
-   **Password**: This is **NOT** your login password. You must use a **Personal Access Token (PAT)**.

### How to generate a Personal Access Token (PAT):
1.  Go to GitHub **Settings** > **Developer settings** > **Personal access tokens** > **Tokens (classic)**.
2.  Click **Generate new token (classic)**.
3.  Give it a note (e.g., "Laptop").
4.  Select the **repo** scope (this is required to push code).
5.  Click **Generate token**.
6.  **Copy the token** and paste it when Git asks for your password.

---
> [!TIP]
> If you have the GitHub CLI (`gh`) installed later, you can simply run `gh auth login` to handle authentication automatically.
