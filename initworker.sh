#!/bin/bash

# ============================================================================
# Enhanced Cloudflare Worker Project Setup Script
# With animations and visual improvements using pure bash
# ============================================================================

# Enhanced Color Palette
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
ORANGE='\033[38;5;208m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ============================================================================
# Animation Functions
# ============================================================================

# Spinner animation for long-running tasks
spinner() {
    local pid=$1
    local message=$2
    local delay=0.08
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r${CYAN}  [%c]${NC} ${WHITE}%s${NC}" "$spinstr" "$message"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done

    wait $pid
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        printf "\r${GREEN}  [✓]${NC} ${WHITE}%s${NC}\n" "$message"
    else
        printf "\r${RED}  [✗]${NC} ${WHITE}%s${NC}\n" "$message"
    fi

    return $exit_code
}

# Progress bar animation
progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "\r${ORANGE}  ["
    printf "${GREEN}%${filled}s" | tr ' ' '█'
    printf "${DIM}%${empty}s" | tr ' ' '░'
    printf "${ORANGE}] ${WHITE}%3d%%${NC}" "$percentage"

    if [ $current -eq $total ]; then
        echo ""
    fi
}

# Typewriter effect for text
typewriter() {
    local text="$1"
    local delay=${2:-0.02}
    local color=${3:-$WHITE}

    for (( i=0; i<${#text}; i++ )); do
        printf "${color}%s${NC}" "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

# Print a decorative box
print_box() {
    local text="$1"
    local color=${2:-$ORANGE}
    local padding=2
    local text_length=${#text}
    local box_width=$((text_length + padding * 2))

    printf "${color}"
    printf '╔'
    printf '═%.0s' $(seq 1 $box_width)
    printf '╗\n'
    printf "║%${padding}s%s%${padding}s║\n" "" "$text" ""
    printf '╚'
    printf '═%.0s' $(seq 1 $box_width)
    printf '╝'
    printf "${NC}\n"
}

# Print step indicator
print_step() {
    local step=$1
    local total=$2
    local message="$3"
    echo ""
    echo -e "${ORANGE}${BOLD}[${step}/${total}]${NC} ${WHITE}${message}${NC}"
}

# Success animation with checkmark
success_msg() {
    local message="$1"
    printf "${GREEN}  ✓${NC} ${WHITE}%s${NC}\n" "$message"
}

# Error message
error_msg() {
    local message="$1"
    printf "${RED}  ✗${NC} ${WHITE}%s${NC}\n" "$message"
}

# Info message
info_msg() {
    local message="$1"
    printf "${CYAN}  ℹ${NC} ${DIM}%s${NC}\n" "$message"
}

# Warning message
warning_msg() {
    local message="$1"
    printf "${YELLOW}  ⚠${NC} ${WHITE}%s${NC}\n" "$message"
}

# Animated banner
show_banner() {
    clear
    echo ""
    printf "${ORANGE}"
    echo "    ╔═══════════════════════════════════════════════════════╗"
    sleep 0.1
    echo "    ║                                                       ║"
    sleep 0.1
    echo "    ║        ☁  Cloudflare Worker Project Setup  ☁         ║"
    sleep 0.1
    echo "    ║                                                       ║"
    sleep 0.1
    echo "    ╚═══════════════════════════════════════════════════════╝"
    printf "${NC}"
    echo ""
    sleep 0.3
}

# Pulsing text effect
pulse_text() {
    local text="$1"
    local cycles=${2:-2}

    for (( i=0; i<cycles; i++ )); do
        printf "\r${BOLD}${ORANGE}%s${NC}" "$text"
        sleep 0.4
        printf "\r${DIM}${ORANGE}%s${NC}" "$text"
        sleep 0.4
    done
    printf "\r${ORANGE}%s${NC}\n" "$text"
}

# Loading dots animation
loading_dots() {
    local message="$1"
    local duration=${2:-3}
    local end_time=$((SECONDS + duration))

    while [ $SECONDS -lt $end_time ]; do
        printf "\r${CYAN}  %s${NC}   " "$message"
        sleep 0.3
        printf "\r${CYAN}  %s.${NC}  " "$message"
        sleep 0.3
        printf "\r${CYAN}  %s..${NC} " "$message"
        sleep 0.3
        printf "\r${CYAN}  %s...${NC}" "$message"
        sleep 0.3
    done
    printf "\r${GREEN}  %s... Done!${NC}\n" "$message"
}

# Run command with spinner
run_with_spinner() {
    local message="$1"
    local command="$2"

    $command > /tmp/cmd_output.log 2>&1 &
    local pid=$!

    spinner $pid "$message"
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        cat /tmp/cmd_output.log
        rm -f /tmp/cmd_output.log
    fi

    rm -f /tmp/cmd_output.log
    return $exit_code
}

# ============================================================================
# Main Script
# ============================================================================

# Show animated banner
show_banner

# Project name input with styling
if [ -n "$1" ]; then
    PROJECT_NAME="$1"
    info_msg "Using provided project name: ${BOLD}${PROJECT_NAME}${NC}"
elif [ -n "$PROJECT_NAME" ]; then
    info_msg "Using environment variable: ${BOLD}${PROJECT_NAME}${NC}"
else
    echo ""
    typewriter "  Please enter your project name:" 0.03 "$ORANGE"
    printf "  ${CYAN}→${NC} "
    read -r PROJECT_NAME
fi

if [ -z "$PROJECT_NAME" ]; then
    echo ""
    error_msg "No project name provided. Exiting."
    exit 1
fi

echo ""
print_box "Creating Project: ${PROJECT_NAME}" "$GREEN"
echo ""
sleep 0.5

# Step 1: Initialize Cloudflare Worker
TOTAL_STEPS=6
print_step 1 $TOTAL_STEPS "Initializing Cloudflare Worker project"
info_msg "This may take a few minutes while dependencies are installed..."
echo ""

npx create-cloudflare@latest --platform=workers "$PROJECT_NAME" \
    --category=hello-world \
    --type=hello-world \
    --lang=ts \
    --git=true \
    --deploy=false > /tmp/create_output.log 2>&1 &

spinner $! "Installing dependencies and setting up project"

if [ $? -ne 0 ]; then
    echo ""
    error_msg "Error during create-cloudflare. Check logs below:"
    cat /tmp/create_output.log
    rm -f /tmp/create_output.log
    exit 1
fi

rm -f /tmp/create_output.log
echo ""
success_msg "Project initialized successfully"

# Wait for file operations
sleep 1

# Navigate to project directory
if [ ! -d "$PROJECT_NAME" ]; then
    echo ""
    error_msg "Project directory was not created. Exiting."
    exit 1
fi

cd "$PROJECT_NAME" || {
    error_msg "Could not navigate to project directory."
    exit 1
}

# Step 2: Configure wrangler.jsonc
print_step 2 $TOTAL_STEPS "Configuring wrangler.jsonc"

TEMP_FILE=$(mktemp)
{
    echo "// PLACE ENVIORNMENT VARIABLES OVER HERE INSTEAD OF .env BECAUSE ITS A WRANGLER PROJECT AND WRANGLER USES THIS FILE TO LOAD"
    echo "// ENIVORNMENT VARIABLES"
    cat wrangler.jsonc
} > "$TEMP_FILE"
mv "$TEMP_FILE" wrangler.jsonc

success_msg "wrangler.jsonc configured"

# Step 3: Create comprehensive README
print_step 3 $TOTAL_STEPS "Generating comprehensive README.md"

cat > README.md << 'READMEEOF'
# Template Worker Project

This repository contains the codebase for a Cloudflare worker built with TypeScript and deployed using Cloudflare Workers. The project is structured to separate concerns, with controllers orchestrating logic by combining helpers, middlewares, models, and utils. Below is an explanation of the folder structure and the purpose of each file and directory.

## Folder Structure

### Root Directory

The root directory contains configuration files and dependencies for the project. Here's a breakdown of the files and folders:

- `node_modules/` \
  Contains all dependencies installed via npm or yarn. This folder is automatically generated when you run `npm install` or `yarn install`. Do not manually modify this folder, as it is managed by the package manager. Excluded from version control using `.gitignore`.

- `package.json`\
  The main configuration file for the Node.js project. It defines project metadata, scripts, dependencies, and devDependencies. Update this file to add new dependencies or scripts.

- `package-lock.json`\
  Automatically generated by npm to lock dependency versions, ensuring consistent installations across environments. Do not edit this file manually.

- `tsconfig.json`\
  The TypeScript configuration file for the project. It specifies compiler options like target JavaScript version, module system, and paths. Modify this file to adjust TypeScript settings, such as enabling strict type checking.

- `vitest.config.mts`\
  The configuration file for Vitest, the testing framework used in this project. It defines settings for running tests, such as test environment, file patterns, and coverage options. Update this file to customize test behavior.

- `worker-configuration.d.ts`\
  A TypeScript declaration file defining types for the worker configuration. Use this file to specify the structure of configuration objects used in the project.

- `wrangler.jsonc`\
  The configuration file for Cloudflare Wrangler, used to deploy and manage the worker. It includes settings like worker name, environment variables, and deployment targets. Update this file to configure deployment settings.

### `src/` Directory

The `src/` directory contains the main application logic, organized into subdirectories for modularity. Here's a breakdown:

- `src/configs/`\
  Contains configuration files for external services and resources, such as databases or third-party APIs. For example:

  - `redis.config.ts`: Initializes and manages a Redis client connection. It exports a function like `getRedisClient` to provide a singleton Redis client, connecting to a URL specified in environment variables.\
    Use this folder to centralize configurations for services like Redis, Firebase, or other external dependencies.

- `src/controllers/`\
  Contains controller files that orchestrate business logic for specific routes or endpoints. Controllers combine helpers, middlewares, and models to process incoming requests and return responses. For example, a controller might use a Firebase helper to fetch data, apply validation middleware, and use a model to structure and save data to a database.

- `src/helpers/`\
  Contains reusable helper functions that perform specific tasks, such as interacting with external services. For example:

  - A Firebase helper might fetch data from Firestore and format it for use in a controller.\
    Use this folder for service-specific logic that can be reused across controllers.

- `src/middlewares/`\
  Contains middleware functions for handling cross-cutting concerns, such as request validation, authentication, or logging. For example, a validation middleware might check the format of incoming request data before passing it to a controller. These are applied to routes to preprocess requests or responses.

- `src/models/`\
  Contains data models or schemas that define the structure of data used in the application. Models may include TypeScript interfaces or classes that shape data (e.g., for API responses or database entries) and logic to insert or update data in a database according to the defined structure.

- `src/routes/`\
  Contains route definitions that map HTTP endpoints to controller functions. Routes use controllers to handle requests, which in turn leverage helpers, middlewares, and models. Organize routes by feature or resource (e.g., `user.routes.ts`, `message.routes.ts`).

- `src/index.ts`\
  The entry point of the application. This file sets up the Cloudflare Worker, initializes routes, and applies global middleware or configuration setup (e.g., from `src/configs/`).

- `src/types/`\
  Contains custom TypeScript type definitions or interfaces specific to the application. Use this folder to define types for API payloads, database models, or configuration objects.

- `src/utils/`\
  Contains general-purpose utility functions, such as string manipulation, currency formatting, or date handling. These utilities are used across the application to perform common tasks not tied to specific services or business logic.

### `test/` Directory

The `test/` directory contains test files and configurations for testing the application using Vitest. Here's a breakdown:

- `test/env.d.ts`\
  A TypeScript declaration file for defining types related to the test environment, such as mocked APIs or environment variables used in tests.

- `test/index.spec.ts`\
  Contains test cases for the main application logic, typically testing the entry point (`index.ts`) or core functionality. Follow a naming convention like `*.spec.ts` or `*.test.ts` for test files.

- `test/tsconfig.json`\
  A TypeScript configuration file specific to the test environment. It may extend the root `tsconfig.json` and include test-specific settings, such as paths to test utilities or mocks.

## Application Flow

The application follows a modular flow where:

1. **Routes** (`src/routes/`) define endpoints and map them to **controllers** (`src/controllers/`).
2. **Controllers** orchestrate logic by:
   - Using **helpers** (`src/helpers/`) for tasks like fetching data from Firestore or other services.
   - Applying **middlewares** (`src/middlewares/`) for validation, authentication, or other preprocessing.
   - Using **models** (`src/models/`) to structure and persist data to a database according to defined interfaces or schemas.
   - Leveraging **utils** (`src/utils/`) for general-purpose tasks like string manipulation or currency formatting.
3. **Configurations** (`src/configs/`) provide initialized clients (e.g., Redis via `redis.config.ts`) or settings for external services, used by helpers or controllers.
4. The **entry point** (`src/index.ts`) ties everything together, setting up the worker and routing logic.

## Getting Started

1. **Install Dependencies**: Run `npm install` or `yarn install` to set up the project and generate the `node_modules/` folder.
2. **Development**:
   - Place application logic in the `src/` directory, organized into `configs/`, `controllers/`, `helpers/`, `middlewares/`, `models/`, `routes/`, `types/`, and `utils/`.
   - Use `index.ts` as the entry point for the worker.
   - Configure external services in `src/configs/` (e.g., `redis.config.ts` for Redis).
3. **Testing**:
   - Write tests in the `test/` directory, using `index.spec.ts` for core tests and adding feature-specific tests as needed.
   - Run tests with `npm test` or `yarn test`, configured via `vitest.config.mts`.
4. **Deployment**:
   - Configure `wrangler.jsonc` for Cloudflare Worker deployment.
   - Use `wrangler deploy` to deploy the worker.
5. **TypeScript**: Ensure TypeScript files adhere to the settings in `tsconfig.json` (root) and `test/tsconfig.json` (for tests). Use `worker-configuration.d.ts` and `src/types/` for type definitions.

## Best Practices

- Organize `src/` subdirectories by feature or responsibility for maintainability.
- Write unit and integration tests for controllers, helpers, and models in the `test/` directory.
- Keep configuration files in `src/configs/` to centralize environment-specific settings (e.g., Redis or Firebase connections).
- Use `src/middlewares/` for reusable request/response processing logic, such as validation or authentication.
- Define data models and schemas in `src/models/` to ensure consistent data handling.
- Place reusable, non-service-specific functions (e.g., string or currency utilities) in `src/utils/`.
- Define custom types in `src/types/` to ensure type safety across the application.
- Regularly update `package.json` and `package-lock.json` when adding or updating dependencies.
- Avoid committing the `node_modules/` folder to version control; ensure it's excluded via `.gitignore`.
READMEEOF

success_msg "README.md created with comprehensive documentation"

# Step 4: Create VS Code debugging configuration
print_step 4 $TOTAL_STEPS "Setting up VS Code debugging configuration"

mkdir -p .vscode
cat > .vscode/launch.json << 'LAUNCHEOF'
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Cloudflare Worker (dev)",
      "type": "node",
      "request": "launch",
      "runtimeExecutable": "wrangler",
      "runtimeArgs": ["dev", "--inspector-port=9229"],
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "restart": true,
      "sourceMaps": true,
      "resolveSourceMapLocations": [
        "${workspaceFolder}/**",
        "!**/node_modules/**"
      ],
      "skipFiles": ["<node_internals>/**"],
      "env": {
        "NODE_OPTIONS": "--enable-source-maps"
      }
    },
    {
      "name": "Attach to Wrangler Inspector",
      "type": "node",
      "request": "attach",
      "port": 9229,
      "restart": false,
      "sourceMaps": true,
      "resolveSourceMapLocations": [
        "${workspaceFolder}/**",
        "!**/node_modules/**"
      ],
      "skipFiles": ["<node_internals>/**"]
    }
  ]
}
LAUNCHEOF

success_msg "VS Code debugging configured"

# Step 5: Create modular folder structure
print_step 5 $TOTAL_STEPS "Creating modular folder structure"

folders=(
    "src/configs"
    "src/controllers"
    "src/helpers"
    "src/middlewares"
    "src/models"
    "src/routes"
    "src/types"
    "src/utils"
)

echo ""
for i in "${!folders[@]}"; do
    folder="${folders[$i]}"
    mkdir -p "$folder"
    progress_bar $((i + 1)) ${#folders[@]}
    sleep 0.1
done

echo ""
success_msg "Folder structure created successfully"

# Step 6: Final summary
print_step 6 $TOTAL_STEPS "Finalizing setup"
sleep 0.5

echo ""
echo ""
printf "${GREEN}${BOLD}"
echo "    ╔═══════════════════════════════════════════════════════╗"
echo "    ║                                                       ║"
echo "    ║              ✨  Setup Complete!  ✨                  ║"
echo "    ║                                                       ║"
echo "    ╚═══════════════════════════════════════════════════════╝"
printf "${NC}"
echo ""
echo ""

# Display project structure with tree
echo -e "${CYAN}${BOLD}Project Structure:${NC}"
echo ""
echo -e "${DIM}"
echo "  ${PROJECT_NAME}/"
echo "  ├── .vscode/"
echo "  │   └── launch.json          ${ORANGE}(VS Code debug config)${NC}${DIM}"
echo "  ├── src/"
echo "  │   ├── configs/             ${ORANGE}(Service configurations)${NC}${DIM}"
echo "  │   ├── controllers/         ${ORANGE}(Business logic)${NC}${DIM}"
echo "  │   ├── helpers/             ${ORANGE}(Reusable functions)${NC}${DIM}"
echo "  │   ├── middlewares/         ${ORANGE}(Request/response processing)${NC}${DIM}"
echo "  │   ├── models/              ${ORANGE}(Data models & schemas)${NC}${DIM}"
echo "  │   ├── routes/              ${ORANGE}(Endpoint definitions)${NC}${DIM}"
echo "  │   ├── types/               ${ORANGE}(TypeScript types)${NC}${DIM}"
echo "  │   ├── utils/               ${ORANGE}(Utility functions)${NC}${DIM}"
echo "  │   └── index.ts             ${ORANGE}(Entry point)${NC}${DIM}"
echo "  ├── test/                    ${ORANGE}(Test files)${NC}${DIM}"
echo "  ├── package.json"
echo "  ├── tsconfig.json"
echo "  ├── wrangler.jsonc           ${ORANGE}(Cloudflare config)${NC}${DIM}"
echo "  └── README.md"
echo -e "${NC}"
echo ""

# Next steps with styling
echo -e "${ORANGE}${BOLD}Next Steps:${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} ${WHITE}Navigate to your project:${NC}"
echo -e "     ${DIM}\$ cd ${PROJECT_NAME}${NC}"
echo ""
echo -e "  ${CYAN}2.${NC} ${WHITE}Start development server:${NC}"
echo -e "     ${DIM}\$ npm run start${NC}"
echo ""
echo -e "  ${CYAN}3.${NC} ${WHITE}Deploy to Cloudflare:${NC}"
echo -e "     ${DIM}\$ npm run deploy${NC}"
echo ""
echo -e "  ${CYAN}4.${NC} ${WHITE}Debug in VS Code:${NC}"
echo -e "     ${DIM}Open in VS Code and press F5${NC}"
echo -e "     ${DIM}Select 'Debug Cloudflare Worker (dev)' configuration${NC}"
echo ""
echo ""

# Final celebratory message
pulse_text "  🚀  Happy coding with Cloudflare Workers!  🚀"
echo ""
