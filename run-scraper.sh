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

echo -e "${CYAN}${BOLD}\n================ STEP 1: Model Directory =================${NC}\n"

# Step 1: Ask for model directory path
read -p "Enter the model directory path: " MODEL_DIR

if [ -z "$MODEL_DIR" ]; then
  echo -e "${RED}❌ Model directory path cannot be empty!${NC}"
  exit 1
fi

# Update MODEL_DIRECTORY_PATH in .env
if grep -q '^MODEL_DIRECTORY_PATH=' "$ENV_FILE"; then
  sed -i "s|^MODEL_DIRECTORY_PATH=.*|MODEL_DIRECTORY_PATH=\"../3D_SKY_STRUCTURED_FOLDER/${MODEL_DIR}\"|" "$ENV_FILE"
else
  echo "MODEL_DIRECTORY_PATH=\"../3D_SKY_STRUCTURED_FOLDER/${MODEL_DIR}\"" >> "$ENV_FILE"
fi
echo -e "${GREEN}✅ Updated MODEL_DIRECTORY_PATH in $ENV_FILE${NC}\n"


echo -e "${CYAN}${BOLD}================ STEP 2: Scraper Command =================${NC}\n"

# Step 2: Show options for scraper command file
echo -e "${YELLOW}Select the scraper command file to run:${NC}"
echo -e "${BLUE}1) scraper_for_3dsky.py${NC} ${CYAN}- Scrapes the 3D models only"
echo -e "${BLUE}2) scraper.py${NC} ${CYAN}- Scrapes the 3D models and generates PDF files"
echo -e "${BLUE}3) pdf_generator.py${NC} ${CYAN}- Only generates PDF files"
echo -e "${BLUE}4) pdf_merger.py${NC} ${CYAN}- Merge PDF files\n"

read -p "Enter your choice (1-4): " OPTION

case "$OPTION" in
  1) COMMAND_FILE="scraper_for_3dsky.py" ;;
  2) COMMAND_FILE="scraper.py" ;;
  3) COMMAND_FILE="pdf_generator.py" ;;
  4) COMMAND_FILE="pdf_merger.py" ;;
  *) echo -e "${RED}❌ Invalid option${NC}"; exit 1 ;;
esac

# Update scraper service command in docker-compose.yml
sed -i "/scraper:/,/^[^ ]/ s|command: .*|command: ${COMMAND_FILE}|" "$DOCKER_COMPOSE_FILE"
echo -e "${GREEN}✅ Updated scraper command to '${COMMAND_FILE}' in $DOCKER_COMPOSE_FILE${NC}\n"


echo -e "${CYAN}${BOLD}================ STEP 3: Cleanup Output =================${NC}\n"

# Step 3: Cleanup specific old output files
if [ -d "$OUTPUT_DIR" ]; then
  echo -e "${YELLOW}🧹 Cleaning up old job_data.json and file_data.csv in $OUTPUT_DIR...${NC}"
  rm -f "$OUTPUT_DIR/job_data.json" "$OUTPUT_DIR/file_data.csv" 2>/dev/null || true
  echo -e "${GREEN}✅ Specific output files cleaned.${NC}\n"
else
  echo -e "${YELLOW}ℹ️ Output folder not found, skipping cleanup.${NC}\n"
fi


echo -e "${CYAN}${BOLD}================ STEP 4: Start Docker =================${NC}\n"

# Step 4: Build and start containers
SERVICE="scraper"
if [ "$OPTION" -eq 4 ]; then
  SERVICE="merger"
fi

echo -e "${YELLOW}⚙️  Building and starting docker container for service '$SERVICE'...${NC}"
cd "$ROOT_DIR"
sudo docker compose up "$SERVICE"

echo -e "${GREEN}${BOLD}\n🎉 Scraper is now running with model path '${MODEL_DIR}' and command '${COMMAND_FILE}'${NC}\n"
