# Cloudflare Worker Setup Script

This repository contains a bash script (`initworker.sh`) that automates the setup of a TypeScript-based Cloudflare Worker project using the `create-cloudflare` CLI. The script initializes a "Hello World" Worker project, configures `wrangler.jsonc`, creates a detailed `README.md`, and sets up a modular folder structure for maintainable development.

## Features

- Initializes a Cloudflare Worker project with TypeScript using the "Hello World" template.
- Automatically configures `wrangler.jsonc` with environment variable comments.
- Creates a comprehensive `README.md` with project structure and best practices.
- Sets up a modular `src/` directory structure: `configs/`, `controllers/`, `helpers/`, `middlewares/`, `models/`, `routes/`, `types/`, and `utils/`.
- Initializes a git repository (no deployment during setup).
- **Docker-inspired CLI interface** with professional animations:
  - Docker-style rotating spinner `[|] [-] [/] [\]` for active processes
  - Orange highlights for important text and headers
  - Minimalist color palette (gray, light gray, blue, green, orange)
  - Clean status indicators (✓ success, ✗ error, → steps)
  - Progress counters for folder creation [1/8], [2/8], etc.
  - Spinners for each step showing active processing
  - Professional, distraction-free output

## Prerequisites

To run the script, ensure your system has the following:
- `bash`: Required to execute the script.
- `npm`: Needed for `npx create-cloudflare` to install dependencies.
- `curl` or `wget`: To fetch the script from GitHub.
- Internet access: To download the script and install npm dependencies.

## Usage

Run the script directly from GitHub without downloading it using one of the following commands. Replace `your-project-name` with your desired project name (e.g., `my-worker-app`).

### Option 1: Provide Project Name as Argument (Recommended)
```bash
curl -s https://raw.githubusercontent.com/shreyanshcladbe/cloudflare-worker-init/main/initworker.sh | bash -s "your-project-name"
```

### Option 2: Use Environment Variable
```bash
export PROJECT_NAME="your-project-name"
curl -s https://raw.githubusercontent.com/shreyanshcladbe/cloudflare-worker-init/main/initworker.sh | bash
```

### Option 3: Interactive Mode
If no project name is provided, the script will prompt for one:
```bash
curl -s https://raw.githubusercontent.com/shreyanshcladbe/cloudflare-worker-init/main/initworker.sh | bash
```

### Option 4: Use `wget` Instead of `curl`
```bash
wget -qO- https://raw.githubusercontent.com/shreyanshcladbe/cloudflare-worker-init/main/initworker.sh | bash -s "your-project-name"
```


## What the Script Does

1. **Prompts for Project Name**: Accepts a project name via command-line argument, environment variable (`PROJECT_NAME`), or interactive prompt.
2. **Initializes Project**: Uses `npx create-cloudflare@latest` to create a TypeScript-based Cloudflare Worker project with the "Hello World" template, enabling git and skipping deployment.
3. **Configures `wrangler.jsonc`**: Adds a comment about environment variables.
4. **Creates `README.md`**: Generates a detailed README with project structure and best practices.
5. **Sets Up Folder Structure**: Creates `src/` subdirectories: `configs/`, `controllers/`, `helpers/`, `middlewares/`, `models/`, `routes/`, `types/`, and `utils/`.
6. **Displays Output**: Uses orange for highlights and white for regular text in the CLI.

## Next Steps After Running

Once the script completes, navigate to your project directory and proceed:
```bash
cd your-project-name
npm run start    # Start the development server
npm run deploy   # Deploy to Cloudflare
```

## Example Output

The script will create a project with the following structure:
```
.
├── configs
├── controllers
├── helpers
├── middlewares
├── models
├── routes
├── server.ts
├── types
└── utils
```

## Troubleshooting

- **Error: "command not found: npm"**: Ensure `npm` is installed. Install Node.js from [nodejs.org](https://nodejs.org).
- **Error: "curl: command not found"**: Install `curl` (e.g., `sudo apt install curl` on Ubuntu or `brew install curl` on macOS).