<p align="center">
	<h1 align="center"><b>Lunch Flow 🤝 Actual Budget</b></h1>
<p align="center">
    Connect multiple open banking providers to your Actual Budget server.
    <br />
    <br />
    <a href="https://discord.gg/TJn5mMV4jZ">Discord</a>
    ·
    <a href="https://lunchflow.app">Website</a>
	·
    <a href="https://lunchflow.app/feedback">Feedback</a>
  </p>
</p>

## About Lunch Flow

[Lunch Flow](https:lunchflow.app) is a tool that allows you to connect your banks globally to the tools you love. We currently support multiple open banking providers (GoCardless, Finicity, MX, Finverse, and more ...).

## Demo

![Demo](./docs/demo.gif)

## Features

- 🔗 **Easy Setup**: Simple configuration process for both Lunch Flow and Actual Budget connections

- 📋 **Account Mapping**: Interactive terminal UI to map Lunch Flow accounts to Actual Budget accounts

- 📊 **Transaction Import**: Import transactions with proper mapping and deduplication

- 📅 **Sync Start Dates**: Configure per-account sync start dates to control import scope

- 🔍 **Connection Testing**: Test and verify connections to both services

- 📱 **Terminal UI**: Beautiful, interactive command-line interface

- 🚀 **Direct Import Command**: Run imports directly from command line for automation

- 🔄 **Deduplication**: Prevents importing duplicate transactions

- 🐳 **Docker Support**: Run in containers with built-in cron scheduling for automated syncs

- ⏰ **Automatic Scheduling**: Configure flexible sync schedules with cron expressions

- 📦 **Persistent Configuration**: Volume-based config storage for easy portability

## Installation

### Option 1: NPX (Recommended for Interactive Use)

A simple command to install!

```
npx @lunchflow/actual-flow
```

or using pnpm

```
pnpm dlx @lunchflow/actual-flow
```

### Option 2: Docker (Recommended for Automation)

Run actual-flow in a Docker container manually or with automatic scheduled syncs.

#### Quick Start with Docker Compose

1. Create a `docker-compose.yml` file:

```yaml
services:
  actual-flow:
    image: ghcr.io/lukaswinter/actual-flow:latest
    container_name: actual-flow
    volumes:
      # Persist configuration
      - ./data:/data
    environment:
      # Optional: Set timezone for cron (default is UTC)
      - TZ=UTC
      # Optional: Set cron schedule (default is "0 2 * * *" - daily at 2 AM)
      # Examples:
      #   - "0 */6 * * *" (every 6 hours)
      #   - "*/30 * * * *" (every 30 minutes)
      #   - "0 8,20 * * *" (daily at 8 AM and 8 PM)
      - CRON_SCHEDULE=0 2 * * *
    restart: unless-stopped
```

2. Start the container:

```bash
docker compose up -d
```

3. Configure on first run (interactive mode):

```bash
docker compose run --rm actual-flow interactive
```

The configuration will be saved in `./data/config.json` and persisted across container restarts.

#### Docker Run Command

Alternatively, use Docker directly:

```bash
# Run in cron mode (automatic daily sync)
docker run -d \
  --name actual-flow \
  -v $(pwd)/data:/data \
  -e TZ=UTC \
  -e CRON_SCHEDULE="0 2 * * *" \
  ghcr.io/lukaswinter/actual-flow:latest cron

# Initial configuration
docker run --rm -it \
  -v $(pwd)/data:/data \
  ghcr.io/lukaswinter/actual-flow:latest interactive
```

## Configuration

The tool will guide you through the initial setup process:

1. **Lunch Flow API Key**: Enter your Lunch Flow API key
2. **Lunch Flow Base URL**: Enter the API base URL (default: https://api.lunchflow.com)
3. **Actual Budget Server URL**: Enter your Actual Budget server URL (default: http://localhost:5007)
4. **Actual Budget Budget Sync ID**: Enter your budget sync ID
5. **Actual Budget Password**: Enter password if required

Configuration is saved to `config.json` in the project directory.

## Usage

### Command Line Interface

The tool supports both interactive and non-interactive modes:

```bash
# Interactive mode (default)
actual-flow

# Direct import (non-interactive)
actual-flow import

# Show help
actual-flow help
```

### Docker Usage

#### Running Modes

**Cron Mode (Default)**: Automatically syncs on a schedule
```bash
docker compose up -d
#OR
docker run -d \
  --name actual-flow \
  -v $(pwd)/data:/data \
  -e TZ=UTC \
  -e CRON_SCHEDULE="0 2 * * *" \
  ghcr.io/lukaswinter/actual-flow:latest cron
```

**Interactive Mode**: Configure settings manually
```bash
docker compose run --rm actual-flow interactive
#OR
docker run --rm -it \
  -v $(pwd)/data:/data \
  ghcr.io/lukaswinter/actual-flow:latest interactive
```

**Direct Import**: One-time import without interaction
```bash
docker compose run --rm actual-flow import
#OR
docker run --rm -it \
  -v $(pwd)/data:/data \
  ghcr.io/lukaswinter/actual-flow:latest import
```

**Manual Sync**: Trigger an immediate sync
```bash
docker exec actual-flow /usr/local/bin/docker-entrypoint.sh sync
```

#### View Logs

```bash
# View all logs
docker logs actual-flow

# Follow logs in real-time
docker logs -f actual-flow

# View cron log file
docker exec actual-flow tail -f /var/log/actual-flow.log
```

#### Custom Cron Schedule

Set the `CRON_SCHEDULE` environment variable to customize sync frequency:

```yaml
environment:
  # Every 6 hours
  - CRON_SCHEDULE=0 */6 * * *
  
  # Every 30 minutes
  - CRON_SCHEDULE=*/30 * * * *
  
  # Daily at 8 AM and 8 PM
  - CRON_SCHEDULE=0 8,20 * * *
```

### Main Menu (Interactive Mode)

The tool provides an interactive menu with the following options:

- **🔗 Test connections**: Verify connections to both Lunch Flow and Actual Budget
- **📋 List available budgets**: Show all budgets available on your Actual Budget server
- **📋 Configure account mappings**: Map Lunch Flow accounts to Actual Budget accounts
- **📊 Show current mappings**: Display currently configured account mappings
- **📥 Import transactions**: Import transactions for a selected date range
- **⚙️ Reconfigure credentials**: Update API credentials
- **❌ Exit**: Exit the application

### Account Mapping

When configuring account mappings, you'll see:

1. All available Lunch Flow accounts
2. All available Actual Budget accounts
3. Interactive selection to map each Lunch Flow account to an Actual Budget account
4. **Optional sync start date** for each mapping (YYYY-MM-DD format)
5. Option to skip accounts that don't need mapping

#### Sync Start Dates

You can configure a sync start date for each account mapping to control which transactions are imported:
- Only transactions on or after the specified date will be imported
- Leave empty to import all available transactions
- Useful for limiting historical data or starting fresh with specific accounts

### Transaction Import

#### Interactive Mode
1. Review a preview of transactions to be imported
2. Confirm the import
3. Monitor progress with real-time feedback
4. Automatic deduplication prevents importing existing transactions

#### Non-Interactive Mode (`actual-flow import`)
1. Automatically imports transactions without confirmation prompts
2. Perfect for automation, cron jobs, or CI/CD pipelines
3. Shows transaction preview and processing summary
4. Respects configured sync start dates for each account

## Automation Examples

### NPX/PNPM Cron Job
```bash
# Run import every day at 2 AM
0 2 * * * npx @lunchflow/actual-flow import
```

### Docker Cron (Built-in)

The Docker image includes a built-in cron scheduler:

```yaml
services:
  actual-flow:
    image: ghcr.io/lukaswinter/actual-flow:latest
    environment:
      - CRON_SCHEDULE=0 2 * * *  # Daily at 2 AM
    restart: unless-stopped
```

### Docker in External Cron

You can also trigger Docker syncs from your system's cron:

```bash
# Run manual sync every 6 hours
0 */6 * * * docker exec actual-flow /usr/local/bin/docker-entrypoint.sh sync
```

## Docker Architecture

The Docker implementation uses a multi-stage build process:

- **Build Stage**: Compiles TypeScript and builds native dependencies
- **Production Stage**: Minimal Alpine-based runtime with only production dependencies
- **Configuration**: Persisted in `/data` volume for easy backup and portability
- **Logging**: All sync operations logged to `/var/log/actual-flow.log`

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CRON_SCHEDULE` | `0 2 * * *` | Cron expression for automatic sync schedule |
| `TZ` | `UTC` | Timezone for cron scheduling |

### Volume Mounts

- `/data`: Configuration and Actual Budget cache storage
  - `config.json`: Your saved credentials and account mappings
  - `actual-data/`: Actual Budget local cache



---

Made with ❤️ for the Actual Budget community
