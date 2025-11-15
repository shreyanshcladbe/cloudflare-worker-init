#!/usr/bin/env bash

set -e

# Colors and formatting
BOLD='\033[1m'
ORANGE='\033[38;5;214m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'
DIM='\033[2m'

# Spinner characters
SPINNER_CHARS=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

# Spinner function
spin() {
    local pid=$1
    local message=$2
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${ORANGE}${SPINNER_CHARS[$i]}${RESET} ${message}"
        i=$(( (i + 1) % 10 ))
        sleep 0.1
    done

    wait "$pid"
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        printf "\r${GREEN}✓${RESET} ${message}\n"
    else
        printf "\r${ORANGE}✗${RESET} ${message} ${DIM}(failed)${RESET}\n"
        return $exit_code
    fi
}

# Print header
print_header() {
    echo -e "${BOLD}${ORANGE}╔════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${ORANGE}║${RESET}  Node.js + TypeScript Project Setup  ${BOLD}${ORANGE}║${RESET}"
    echo -e "${BOLD}${ORANGE}╚════════════════════════════════════════╝${RESET}"
    echo ""
}

# Check if project name is provided
if [ -z "$1" ]; then
    echo -e "${ORANGE}Error:${RESET} Please provide a project name"
    echo -e "Usage: $0 ${DIM}<project-name>${RESET}"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_DIR="$(pwd)/$PROJECT_NAME"

print_header

# Check if directory already exists
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${ORANGE}Error:${RESET} Directory ${BOLD}$PROJECT_NAME${RESET} already exists"
    exit 1
fi

# Create project directory
echo -e "${BOLD}Creating project:${RESET} ${ORANGE}$PROJECT_NAME${RESET}"
echo ""

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create directory structure
echo -e "${DIM}Setting up directory structure...${RESET}"
mkdir -p .vscode
mkdir -p src/{configs,controllers,helpers,middlewares,models,routes,tests,types,utils}

# Create .gitkeep files for empty directories
touch src/configs/.gitkeep
touch src/controllers/.gitkeep
touch src/helpers/.gitkeep
touch src/models/.gitkeep
touch src/tests/.gitkeep
touch src/types/.gitkeep
touch src/utils/.gitkeep

# Initialize package.json
cat > package.json << 'EOF'
{
  "name": "PROJECT_NAME_PLACEHOLDER",
  "version": "1.0.0",
  "description": "Node.js + TypeScript project",
  "main": "dist/server.js",
  "scripts": {
    "dev": "nodemon --watch src --exec ts-node -r tsconfig-paths/register src/server.ts",
    "build": "node esbuild.config.js",
    "start": "node dist/server.js",
    "lint": "eslint . --ext .ts",
    "lint:fix": "eslint . --ext .ts --fix",
    "format": "prettier --write .",
    "check-format": "prettier --check .",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
EOF

# Replace project name in package.json
sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" package.json
rm package.json.bak 2>/dev/null || true

# Create README.md
cat > README.md << 'EOF'
# PROJECT_NAME_PLACEHOLDER

A Node.js + TypeScript project with a clean, scalable architecture.

## 📁 Folder Structure

```
.
├── .vscode/                  # VS Code configuration
│   └── launch.json          # Debug configurations
├── src/                     # Source code
│   ├── configs/            # Configuration files (database, API keys, etc.)
│   ├── controllers/        # Request handlers and business logic
│   ├── helpers/            # Helper functions and utilities
│   ├── middlewares/        # Express middlewares
│   │   └── logger.ts      # Winston + Morgan logging middleware
│   ├── models/             # Data models and schemas
│   ├── routes/             # API route definitions
│   ├── tests/              # Test files
│   ├── types/              # TypeScript type definitions
│   ├── utils/              # Utility functions
│   └── server.ts           # Application entry point
├── dist/                    # Compiled JavaScript (generated)
├── node_modules/            # Dependencies (generated)
├── .dockerignore           # Docker ignore patterns
├── .env                    # Environment variables (not committed)
├── .eslintrc.json          # ESLint configuration
├── .gitignore              # Git ignore patterns
├── .prettierrc             # Prettier configuration
├── Dockerfile              # Multi-stage Docker build
├── esbuild.config.js       # ESBuild bundler configuration
├── package.json            # Project dependencies and scripts
├── package-lock.json       # Locked dependency versions
├── tsconfig.json           # TypeScript compiler configuration
└── README.md               # This file
```

## 📂 Directory Explanations

### `/src/configs/`
Store all configuration files here:
- Database connection configs
- Third-party API configurations
- Application settings
- Feature flags

### `/src/controllers/`
Contains controller functions that handle HTTP requests:
- Process incoming requests
- Call services/helpers for business logic
- Return responses to clients
- Example: `userController.ts`, `authController.ts`

### `/src/helpers/`
Helper functions that assist controllers and services:
- Business logic functions
- Data transformation utilities
- Common operations used across the app

### `/src/middlewares/`
Express middleware functions:
- **`logger.ts`**: Winston + Morgan logging (included by default)
- Authentication/authorization middleware
- Request validation
- Error handling

### `/src/models/`
Data models and schemas:
- Database models (MongoDB, PostgreSQL, etc.)
- Data validation schemas
- Type definitions for data structures

### `/src/routes/`
API route definitions:
- Define endpoint paths
- Connect routes to controllers
- Apply route-specific middleware
- Example: `user.routes.ts`, `auth.routes.ts`

### `/src/tests/`
Test files for your application:
- Unit tests
- Integration tests
- E2E tests

### `/src/types/`
TypeScript type definitions:
- Custom type definitions
- Interface declarations
- Type extensions

### `/src/utils/`
General utility functions:
- String manipulation
- Date formatting
- Validation helpers
- Common pure functions

## 🚀 Getting Started

### Prerequisites
- Node.js 18+ installed
- npm or yarn package manager

### Installation

```bash
# Install dependencies
npm install

# Copy environment file and configure
cp .env.example .env  # Edit .env with your values
```

## 📜 Available Scripts

### Development
```bash
npm run dev
```
Starts the development server with hot-reload using `nodemon` and `ts-node`. The server will automatically restart when you make changes to files in the `src/` directory.

### Build
```bash
npm run build
```
Compiles TypeScript to JavaScript and bundles the application using ESBuild. Output is generated in the `dist/` directory.

### Production
```bash
npm start
```
Runs the compiled application from `dist/server.js`. Make sure to run `npm run build` first.

### Linting
```bash
# Check for linting errors
npm run lint

# Fix linting errors automatically
npm run lint:fix
```

### Formatting
```bash
# Format all files with Prettier
npm run format

# Check if files are formatted correctly
npm run check-format
```

### Testing
```bash
npm test
```
Runs the test suite (you'll need to set up your testing framework).

## 🐳 Docker

### Build Docker Image
```bash
docker build -t PROJECT_NAME_PLACEHOLDER .
```

### Run Docker Container
```bash
docker run -p 8123:8123 --env-file .env PROJECT_NAME_PLACEHOLDER
```

The Dockerfile uses a multi-stage build:
1. **Builder stage**: Installs all dependencies and builds the application
2. **Runner stage**: Creates a minimal production image with only runtime dependencies

## ⚙️ Configuration

### Environment Variables (`.env`)
```env
NODE_ENV=development
PORT=8123
# Add your environment variables here
```

### Path Aliases
The project uses TypeScript path aliases for cleaner imports:

```typescript
// Instead of: import { User } from '../../../models/user'
import { User } from '@models/user';
```

Available aliases:
- `@routes/*` → `src/routes/*`
- `@controllers/*` → `src/controllers/*`
- `@models/*` → `src/models/*`
- `@configs/*` → `src/configs/*`
- `@utils/*` → `src/utils/*`
- `@helpers/*` → `src/helpers/*`
- `@middlewares/*` → `src/middlewares/*`

Configured in:
- `tsconfig.json` (for TypeScript)
- `esbuild.config.js` (for build process)

### ESLint & Prettier
The project comes with ESLint and Prettier pre-configured:
- **ESLint**: TypeScript-aware linting
- **Prettier**: Code formatting
- Both tools are integrated for automatic formatting on save (if configured in your editor)

## 🔍 Debugging

### VS Code Debugging
Two debug configurations are available:

1. **Debug with ts-node (dev)**
   - Runs the app with `nodemon` and `ts-node`
   - Auto-restarts on file changes
   - Full TypeScript debugging support

2. **Debug compiled code (dist)**
   - Debugs the compiled JavaScript in `dist/`
   - Runs build task before debugging

To debug:
1. Open VS Code
2. Press `F5` or go to Run and Debug
3. Select a debug configuration
4. Set breakpoints and start debugging

## 📝 Logging

The project includes a pre-configured logging system using Winston and Morgan:

```typescript
import { logger } from '@middlewares/logger';

// Use logger in your code
logger.info('Server started');
logger.error('An error occurred', { error });
logger.debug('Debug information');
```

HTTP requests are automatically logged with:
- Colored HTTP methods
- Response time
- Status codes
- Request bodies

## 🏗️ Architecture

This project follows a modular architecture:

```
Request → Routes → Middlewares → Controllers → Helpers/Services → Models
                                                                      ↓
Response ← Controllers ← Helpers/Services ← Models
```

### Best Practices
- Keep controllers thin - delegate business logic to helpers/services
- Use middlewares for cross-cutting concerns (auth, logging, validation)
- Store reusable logic in helpers and utilities
- Keep models focused on data structure and validation
- Use TypeScript types for better type safety
- Follow the single responsibility principle

## 📚 Tech Stack

### Core
- **Node.js** - Runtime environment
- **TypeScript** - Type-safe JavaScript
- **Express** - Web framework

### Build Tools
- **ESBuild** - Fast bundler and minifier
- **ts-node** - TypeScript execution for development
- **nodemon** - Auto-restart on file changes

### Code Quality
- **ESLint** - Linting
- **Prettier** - Code formatting
- **TypeScript** - Static type checking

### Logging
- **Winston** - Logging library
- **Morgan** - HTTP request logger
- **Chalk** - Terminal colors

### Development
- **dotenv** - Environment variable management
- **tsconfig-paths** - Path alias resolution

## 📄 License

ISC

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For issues and questions, please open an issue in the repository.
EOF

# Replace project name in README
sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" README.md
rm README.md.bak 2>/dev/null || true

# Create Dockerfile
cat > Dockerfile << 'EOF'
# syntax=docker/dockerfile:1

FROM node:20-alpine AS builder
WORKDIR /app

# Install all deps (including devDeps for build)
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build


FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Install only production deps
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copy built output from builder
COPY --from=builder /app/dist ./dist

# Copy environment file for dotenv
COPY .env .

USER node
EXPOSE 8123
CMD ["node", "dist/server.js"]
EOF

# Create .dockerignore
cat > .dockerignore << 'EOF'
# dependencies
node_modules

# build output
dist

# git
.git
.gitignore

# env & logs
# keep .env in context so it can be copied into the image
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# macOS
.DS_Store

# editor
.vscode
.idea

# docker
.dockerignore
EOF

# Create .env
cat > .env << 'EOF'
# Store environment variables in here
NODE_ENV=development
PORT=8123
EOF

# Create .eslintrc.json
cat > .eslintrc.json << 'EOF'
{
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint", "prettier"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended"
  ],
  "rules": {
    "prettier/prettier": "error"
  }
}
EOF

# Create .prettierrc
cat > .prettierrc << 'EOF'
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all"
}
EOF

# Create esbuild.config.js
cat > esbuild.config.js << 'EOF'
const esbuild = require('esbuild');
const path = require('path');
const { nodeExternalsPlugin } = require('esbuild-node-externals');

esbuild.build({
  entryPoints: ['src/server.ts'],
  outfile: 'dist/server.js',
  bundle: true,
  minify: true,
  platform: 'node',
  target: ['node18'],
  sourcemap: false,
  plugins: [nodeExternalsPlugin()],
  alias: {
    '@routes': path.resolve(__dirname, 'src/routes'),
    '@controllers': path.resolve(__dirname, 'src/controllers'),
    '@models': path.resolve(__dirname, 'src/models'),
    '@configs': path.resolve(__dirname, 'src/configs'),
    '@utils': path.resolve(__dirname, 'src/utils'),
    '@helpers': path.resolve(__dirname, 'src/helpers'),
    '@middlewares': path.resolve(__dirname, 'src/middlewares'),
  },
}).catch(() => process.exit(1));
EOF

# Create tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "ignoreDeprecations": "5.0",
    "target": "ES2022",
    "module": "commonjs",
    "rootDir": "src",
    "outDir": "dist",
    "baseUrl": "src",
    "paths": {
      "@routes/*": ["routes/*"],
      "@controllers/*": ["controllers/*"],
      "@models/*": ["models/*"],
      "@configs/*": ["configs/*"],
      "@utils/*": ["utils/*"],
      "@helpers/*": ["helpers/*"],
      "@middlewares/*": ["middlewares/*"]
    },
    "esModuleInterop": true,
    "skipLibCheck": true,
    "strict": true,
    "sourceMap": true,
    "inlineSources": true
  },
  "include": ["src"]
}
EOF

# Create launch.json
cat > .vscode/launch.json << 'EOF'
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug with ts-node (dev)",
      "runtimeExecutable": "nodemon",
      "runtimeArgs": [
        "--watch",
        "src",
        "--exec",
        "ts-node",
        "-r",
        "tsconfig-paths/register",
        "src/server.ts"
      ],
      "restart": true,
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "sourceMaps": true,
      "resolveSourceMapLocations": [
        "${workspaceFolder}/**",
        "!**/node_modules/**"
      ]
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug compiled code (dist)",
      "program": "${workspaceFolder}/dist/server.js",
      "preLaunchTask": "npm: build",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "sourceMaps": true,
      "console": "integratedTerminal"
    }
  ]
}
EOF

# Create logger middleware
cat > src/middlewares/logger.ts << 'EOF'
// src/middlewares/logger.ts
import winston from 'winston';
import morgan from 'morgan';
import { Request, Response } from 'express';
import chalk from 'chalk';

// Define log format
const { combine, timestamp, printf, colorize } = winston.format;

const logFormat = printf(({ level, message, timestamp, ...meta }) => {
  if (meta && meta.service) delete meta.service;
  return `[${timestamp}] ${level}: ${message} ${Object.keys(meta).length ? JSON.stringify(meta) : ''}`;
});

// Get log level from environment variable or use default based on NODE_ENV
const getLogLevel = (): string => {
  return process.env.NODE_ENV === 'production' ? 'info' : 'debug';
};

// Create Winston logger instance (console only, no file logging)
const logger = winston.createLogger({
  level: getLogLevel(),
  format: combine(
    colorize(),
    timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    logFormat
  ),
  transports: [
    new winston.transports.Console({
      level: getLogLevel(),
    })
  ]
});

// Colorize HTTP method
function colorMethod(method: string) {
  switch (method) {
    case 'GET': return chalk.green(method);
    case 'POST': return chalk.yellow(method);
    case 'PUT': return chalk.blue(method);
    case 'DELETE': return chalk.red(method);
    case 'PATCH': return chalk.magenta(method);
    case 'OPTIONS': return chalk.cyan(method);
    case 'HEAD': return chalk.gray(method);
    default: return chalk.white(method);
  }
}

// Custom Morgan format with colored method
morgan.token('coloredMethod', req => colorMethod(req.method || ''));

const morganFormat = ':coloredMethod :url :status :res[content-length] - :response-time ms :reqBody';

// Create a stream for Morgan to use
const morganStream = {
  write: (message: string) => {
    logger.info(message.trim());
  }
};

// Define custom Morgan tokens
morgan.token('reqBody', (req: Request) => JSON.stringify(req.body));
morgan.token('resTime', (req: Request) => {
  // @ts-ignore - Morgan adds responseTime during processing
  if (req.responseTime) {
    // @ts-ignore
    return req.responseTime;
  }
  return '';
});

// Create Morgan middleware
const morganMiddleware = morgan(
  morganFormat,
  { stream: morganStream }
);

// Response time middleware
const responseTime = (req: Request, res: Response, next: Function) => {
  const startHrTime = process.hrtime();

  res.on('finish', () => {
    const elapsedHrTime = process.hrtime(startHrTime);
    const elapsedTimeInMs = elapsedHrTime[0] * 1000 + elapsedHrTime[1] / 1e6;
    // @ts-ignore - Adding custom property
    req.responseTime = elapsedTimeInMs.toFixed(3);
  });

  next();
};

// Export the logger and middleware
export {
  logger,
  morganMiddleware,
  responseTime
};
EOF

# Create basic server.ts
cat > src/server.ts << 'EOF'
import express from 'express';
import dotenv from 'dotenv';
import { logger, morganMiddleware, responseTime } from '@middlewares/logger';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 8123;

// Middleware
app.use(express.json());
app.use(responseTime);
app.use(morganMiddleware);

// Basic health check route
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start server
app.listen(PORT, () => {
  logger.info(`Server is running on port ${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
package-lock.json

# Build output
dist/

# Environment variables
.env
.env.local
.env.*.local

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Testing
coverage/

# Misc
.cache/
EOF

echo -e "${GREEN}✓${RESET} Directory structure created"
echo ""

# Install dependencies
echo -e "${BOLD}Installing dependencies...${RESET}"
echo ""

(npm install --silent chalk dotenv esbuild-node-externals morgan winston express > /dev/null 2>&1) &
spin $! "Installing production dependencies"

(npm install --save-dev --silent \
  @types/cors \
  @types/express \
  @types/morgan \
  @types/node \
  @types/ws \
  @typescript-eslint/eslint-plugin \
  @typescript-eslint/parser \
  esbuild \
  esbuild-ts-paths \
  eslint \
  eslint-config-prettier \
  eslint-plugin-prettier \
  nodemon \
  prettier \
  ts-node \
  tsconfig-paths \
  typescript > /dev/null 2>&1) &
spin $! "Installing development dependencies"

echo ""
echo -e "${BOLD}${GREEN}✓ Project setup complete!${RESET}"
echo ""
echo -e "${BOLD}Next steps:${RESET}"
echo -e "  ${DIM}1.${RESET} cd $PROJECT_NAME"
echo -e "  ${DIM}2.${RESET} ${ORANGE}npm run dev${RESET}     ${DIM}# Start development server${RESET}"
echo -e "  ${DIM}3.${RESET} ${ORANGE}npm run build${RESET}   ${DIM}# Build for production${RESET}"
echo ""
echo -e "${DIM}Available scripts:${RESET}"
echo -e "  ${ORANGE}npm run dev${RESET}           ${DIM}# Development mode with hot reload${RESET}"
echo -e "  ${ORANGE}npm run build${RESET}         ${DIM}# Build production bundle${RESET}"
echo -e "  ${ORANGE}npm start${RESET}             ${DIM}# Run production build${RESET}"
echo -e "  ${ORANGE}npm run lint${RESET}          ${DIM}# Lint code${RESET}"
echo -e "  ${ORANGE}npm run lint:fix${RESET}      ${DIM}# Fix linting issues${RESET}"
echo -e "  ${ORANGE}npm run format${RESET}        ${DIM}# Format code with Prettier${RESET}"
echo ""
echo -e "${DIM}📖 Check README.md for complete documentation${RESET}"
echo ""
