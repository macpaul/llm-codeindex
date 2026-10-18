#!/usr/bin/env bash
# ==============================================================================
# install-skills.sh
# Installs or symlinks the code indexing skills into:
#   1. Current Workspace (.agents/skills/)
#   2. User Global Antigravity Config (~/.gemini/config/skills/)
#   3. User Global Claude Code Config (~/.claude/skills/ if present)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILLS="${SCRIPT_DIR}/skills"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "\n${BOLD}${CYAN}Installing Code Indexing Skills for AI Coding CLIs...${NC}\n"

# 1. Install to Workspace .agents/skills/
WORKSPACE_AGENTS_SKILLS="${SCRIPT_DIR}/.agents/skills"
mkdir -p "${WORKSPACE_AGENTS_SKILLS}"

for skill_dir in "${SOURCE_SKILLS}"/*; do
    if [[ -d "${skill_dir}" ]]; then
        skill_name="$(basename "${skill_dir}")"
        echo -e "${BLUE}[Workspace]${NC} Linking ${skill_name} -> .agents/skills/${skill_name}"
        ln -sfn "../../skills/${skill_name}" "${WORKSPACE_AGENTS_SKILLS}/${skill_name}"
    fi
done

# 2. Install to Global Antigravity config
GLOBAL_GEMINI_SKILLS="${HOME}/.gemini/config/skills"
if mkdir -p "${GLOBAL_GEMINI_SKILLS}" 2>/dev/null; then
    for skill_dir in "${SOURCE_SKILLS}"/*; do
        if [[ -d "${skill_dir}" ]]; then
            skill_name="$(basename "${skill_dir}")"
            echo -e "${GREEN}[Global Antigravity]${NC} Linking ${skill_name} -> ${GLOBAL_GEMINI_SKILLS}/${skill_name}"
            ln -sfn "${skill_dir}" "${GLOBAL_GEMINI_SKILLS}/${skill_name}"
        fi
    done
fi

# 3. Install to Global Claude Code if ~/.claude exists
GLOBAL_CLAUDE_SKILLS="${HOME}/.claude/skills"
if [[ -d "${HOME}/.claude" ]]; then
    mkdir -p "${GLOBAL_CLAUDE_SKILLS}"
    for skill_dir in "${SOURCE_SKILLS}"/*; do
        if [[ -d "${skill_dir}" ]]; then
            skill_name="$(basename "${skill_dir}")"
            echo -e "${GREEN}[Global Claude Code]${NC} Linking ${skill_name} -> ${GLOBAL_CLAUDE_SKILLS}/${skill_name}"
            ln -sfn "${skill_dir}" "${GLOBAL_CLAUDE_SKILLS}/${skill_name}"
        fi
    done
fi

# Ensure all scripts inside skills are executable
find "${SOURCE_SKILLS}" -name "*.sh" -exec chmod +x {} +

echo -e "\n${GREEN}${BOLD}Skills installation completed successfully!${NC}"
echo -e "Available skills installed:"
ls -1 "${SOURCE_SKILLS}" | sed 's/^/  - /'
echo ""
