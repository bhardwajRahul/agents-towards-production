#!/usr/bin/env bash
# -------------------------------------------------------
# Interactive runner for the Koog AI Agent tutorial.
# Checks your environment and runs each tutorial step.
# -------------------------------------------------------
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}=========================================${NC}"
    echo -e "${CYAN}${BOLD}  Kotlin AI Agent Tutorial with Koog${NC}"
    echo -e "${CYAN}${BOLD}=========================================${NC}"
    echo ""
}

check_java() {
    echo -e "${BOLD}Checking Java...${NC}"

    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
        if [ "$JAVA_VERSION" -ge 17 ] 2>/dev/null; then
            echo -e "  ${GREEN}Found Java $JAVA_VERSION${NC}"
            return 0
        else
            echo -e "  ${RED}Found Java $JAVA_VERSION, but JDK 17+ is required.${NC}"
        fi
    else
        echo -e "  ${RED}Java not found.${NC}"
    fi

    echo ""
    echo -e "${YELLOW}Install a JDK 17+ using one of these methods:${NC}"
    echo ""
    echo "  macOS (Homebrew):  brew install openjdk@17"
    echo "  macOS (SDKMAN):    sdk install java 17.0.13-tem"
    echo "  Ubuntu/Debian:     sudo apt install openjdk-17-jdk"
    echo "  Windows (Winget):  winget install EclipseAdoptium.Temurin.17.JDK"
    echo "  Any platform:      https://adoptium.net/temurin/releases/"
    echo ""
    exit 1
}

check_api_key() {
    echo -e "${BOLD}Checking OpenAI API key...${NC}"

    if [ -n "${OPENAI_API_KEY:-}" ]; then
        # Show first 8 and last 4 chars
        local key="$OPENAI_API_KEY"
        local masked="${key:0:8}...${key: -4}"
        echo -e "  ${GREEN}Found: $masked${NC}"
    else
        echo -e "  ${YELLOW}OPENAI_API_KEY is not set.${NC}"
        echo ""
        read -rp "  Paste your OpenAI API key (or press Enter to skip): " user_key
        if [ -n "$user_key" ]; then
            export OPENAI_API_KEY="$user_key"
            echo -e "  ${GREEN}API key set for this session.${NC}"
        else
            echo -e "  ${RED}No API key provided. The tutorial steps will fail without it.${NC}"
            echo -e "  You can set it later:  export OPENAI_API_KEY=\"sk-...\"${NC}"
            echo ""
        fi
    fi
}

run_step() {
    local step=$1
    local title=$2
    local description=$3

    echo ""
    echo -e "${CYAN}${BOLD}--- $title ---${NC}"
    echo -e "${description}"
    echo ""
    read -rp "Press Enter to run, or 's' to skip: " choice
    if [ "$choice" = "s" ] || [ "$choice" = "S" ]; then
        echo -e "${YELLOW}Skipped.${NC}"
        return
    fi

    echo ""
    ./gradlew "$step" --quiet 2>&1
    echo ""
    echo -e "${GREEN}Done.${NC}"
}

# ---- Main ----

print_header
check_java
echo ""
check_api_key

echo ""
echo -e "${BOLD}Environment OK. Starting tutorial...${NC}"
echo -e "(First run downloads dependencies -- this may take a minute.)"

run_step "step1" \
    "Step 1: Your First AI Agent" \
    "Creates a minimal agent that sends one prompt and prints the response."

run_step "step2" \
    "Step 2: Agent with Tools" \
    "The agent now has tools (weather, calculator, fact lookup).\n  It decides which tools to call and combines the results."

run_step "step3" \
    "Step 3: Structured Output" \
    "Instead of free text, the agent returns a typed Kotlin data class.\n  Each field is printed individually -- no string parsing needed."

echo ""
echo -e "${CYAN}${BOLD}=========================================${NC}"
echo -e "${CYAN}${BOLD}  Tutorial complete!${NC}"
echo -e "${CYAN}${BOLD}=========================================${NC}"
echo ""
echo -e "Next steps:"
echo -e "  - Read the full walkthrough:  ${BOLD}tutorial.md${NC}"
echo -e "  - Edit the .kt files and re-run to experiment"
echo -e "  - Try changing the prompt, adding a tool, or modifying the data class"
echo ""
