# Gemini CLI 🧠💻

**Gemini CLI** is a lightweight, terminal-based interface that leverages Google's Gemini Generative AI models to generate text responses directly from your command line. Designed for developers and enthusiasts, it offers a seamless way to interact with AI models without leaving the terminal.

---

## 📌 Key Features

* 🔥 **Fast and Lightweight**: Minimal dependencies ensure quick setup and execution.
* 🎛️ **Configurable Parameters**: Adjust temperature, model type, and output length to suit your needs.
* 🌐 **Environment Variable Support**: Securely manage your API keys using `.env` files.
* 💻 **Cross-Platform Compatibility**: Works on both Linux and macOS systems.
* 🧹 **Modular Design**: Easily extend or integrate into larger projects.

---

## 🛠️ Requirements

Before installing and running Gemini CLI, ensure you have:

* **Python 3.9 or higher** installed. [Download Python](https://www.python.org/downloads/)
* **A Gemini API Key** from [Google AI Studio](https://aistudio.google.com/app/apikey).
* **pip** for managing Python packages.

---

## 📁 Project Structure Overview

```
gemini-cli/
├── gemini_cli/
│   ├── __init__.py
│   ├── cli.py           # Command-line interface logic
│   ├── config.py        # Configuration settings and constants
│   └── main.py          # Core functionality to interact with Gemini API
├── scripts/
│   └── install.sh       # Installation script for setting up the CLI
├── .env                 # Environment variables (e.g., API keys)
├── requirements.txt     # Python dependencies
└── README.md            # Project documentation
```

---

## 🔧 Installation Guide

### 1. Clone the Repository

```bash
git clone https://github.com/NamlessChokko/gemini-cli.git
cd gemini-cli
```

### 2. Run the Installation Script

Execute the provided `install.sh` script to set up a virtual environment, install dependencies, and create a launcher script:

```bash
bash scripts/install.sh
```

This script will:

* Check for necessary system dependencies.
* Create a Python virtual environment in `~/.local/share/gemini-cli-venv`.
* Install required Python packages from `requirements.txt`.
* Generate a launcher script named `gem` in `~/.local/bin`.

> **Note**: Ensure that `~/.local/bin` is in your system's `PATH` to use the `gem` command globally.

### 3. Configure Your API Key

Create a `.env` file in the root directory of the project and add your Gemini API key:

```
GOOGLE_API_KEY=your-gemini-api-key-here
```

Alternatively, you can set the environment variable globally:

```bash
export GOOGLE_API_KEY=your-gemini-api-key-here
```

---

## 🚀 Usage

Once installed, you can start using Gemini CLI as follows:

```bash
gem "Your prompt here"
```

### Available Options:

* `-t`, `--temperature`: Set the randomness of the output (default: 0.7).
* `-m`, `--model`: Specify the Gemini model to use (default: gemini-2.0-flash).
* `-o`, `--max-output`: Define the maximum number of output tokens (default: 2048).

**Example:**

```bash
gem "Explain the theory of relativity" -t 0.5 -m gemini-2.0-pro -o 1024
```

---

## 🧪 Example Interaction

```bash
$ gem "Summarize the plot of 'Inception' in one sentence."
Generating response...

A skilled thief enters people's dreams to steal secrets but faces challenges when tasked with planting an idea instead.
```

---

## ⚙️ Configuration

The `config.py` file allows you to modify system-level instructions and default settings. Adjust the `SYSTEM_INSTRUCTIONS` variable to change the behavior or persona of the AI model.

---

## 🧹 Uninstallation

To remove Gemini CLI from your system:

1. Delete the virtual environment:

   ```bash
   rm -rf ~/.local/share/gemini-cli-venv
   ```

2. Remove the launcher script:

   ```bash
   rm ~/.local/bin/gem
   ```

3. Optionally, remove the cloned repository:

   ```bash
   rm -rf ~/path-to/gemini-cli
   ```

---

## 📜 License

This project is licensed under the **Apache 2.0 License**. See the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any enhancements or bug fixes.

---

## 📢 Contact

For questions or support, please open an issue on the [GitHub repository](https://github.com/NamlessChokko/gemini-cli).

---

*Created with ❤️ by NamlessChokko.*
