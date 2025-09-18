#!/bin/bash

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Paths (since script is outside the project root)
ROOT_DIR="$(dirname "$(realpath "$0")")/scrapper"
ENV_FILE="$ROOT_DIR/.env"
DOCKER_COMPOSE_FILE="$ROOT_DIR/docker-compose.yml"
OUTPUT_DIR="3D_SKY_STRUCTURED_FOLDER/output"

echo -e "${CYAN}${BOLD}================ STEP 1: Select Service =================${NC}\n"

# Step 1: Show options for service to run
echo -e "${YELLOW}Select the service to run:${NC}"
echo -e "${BLUE}1) Scraper${NC} ${CYAN}- Run the scraper service"
echo -e "${BLUE}2) Merger${NC} ${CYAN}- Run the merger service\n"

read -p "Enter your choice (1-2): " OPTION

case "$OPTION" in
  1) SERVICE="scraper" ;;
  2) SERVICE="merger" ;;
  *) echo -e "${RED}❌ Invalid option${NC}"; exit 1 ;;
esac

echo -e "${GREEN}✅ Selected service: '${SERVICE}'${NC}\n"


echo -e "${CYAN}${BOLD}================ STEP 2: Cleanup Output =================${NC}\n"

# Step 2: Cleanup specific old output files
if [ -d "$OUTPUT_DIR" ]; then
  echo -e "${YELLOW}🧹 Cleaning up old output files in $OUTPUT_DIR...${NC}"
  rm -f "$OUTPUT_DIR/file_data.csv" "$OUTPUT_DIR/job_data_pdf.json" "$OUTPUT_DIR/job_data.json" "$OUTPUT_DIR/scrape_log.csv" 2>/dev/null || true
  echo -e "${GREEN}✅ Specific output files cleaned.${NC}\n"
else
  echo -e "${YELLOW}ℹ️ Output folder not found, skipping cleanup.${NC}\n"
fi


echo -e "${CYAN}${BOLD}================ STEP 3: Start Docker =================${NC}\n"

# Step 3: Build and start containers
echo -e "${YELLOW}⚙️  Building and starting docker container for service '$SERVICE'...${NC}"
cd "$ROOT_DIR"
sudo docker compose up -d "$SERVICE"

echo -e "${GREEN}${BOLD}\n🎉 Service '${SERVICE}' is now running in detached mode${NC}\n"