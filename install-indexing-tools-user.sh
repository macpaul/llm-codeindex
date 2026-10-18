#!/usr/bin/env bash
# ==============================================================================
# install-indexing-tools-user.sh
# User-level (non-sudo) installation script for LLM Code Indexing & Retrieval Tools
# Deploy Destination: ~/.local/bin and ~/go/bin (no root password needed)
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_step() { echo -e "\n${CYAN}${BOLD}==>${NC} ${BOLD}$*${NC}"; }

LOCAL_BIN="${HOME}/.local/bin"
mkdir -p "${LOCAL_BIN}"

ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64)
        TOKTOKEN_ARCH="x86_64"
        SCIP_ARCH="amd64"
        UV_ARCH="x86_64-unknown-linux-gnu"
        RUST_ANALYZER_ARCH="x86_64-unknown-linux-gnu"
        ;;
    aarch64|arm64)
        TOKTOKEN_ARCH="aarch64"
        SCIP_ARCH="arm64"
        UV_ARCH="aarch64-unknown-linux-gnu"
        RUST_ANALYZER_ARCH="aarch64-unknown-linux-gnu"
        ;;
    *)
        TOKTOKEN_ARCH="x86_64"
        SCIP_ARCH="amd64"
        UV_ARCH="x86_64-unknown-linux-gnu"
        RUST_ANALYZER_ARCH="x86_64-unknown-linux-gnu"
        ;;
esac

TEMP_DIR="$(mktemp -d -t indexing-user-XXXXXX)"
cleanup() { rm -rf "${TEMP_DIR}"; }
trap cleanup EXIT

# 1. Install Astral uv
log_step "Step 1: Installing uv into ${LOCAL_BIN}"
if ! command -v uv >/dev/null 2>&1; then
    curl -fsSL "https://github.com/astral-sh/uv/releases/latest/download/uv-${UV_ARCH}.tar.gz" -o "${TEMP_DIR}/uv.tar.gz"
    tar -xzf "${TEMP_DIR}/uv.tar.gz" -C "${TEMP_DIR}"
    install -m 755 "${TEMP_DIR}/uv-${UV_ARCH}/uv" "${LOCAL_BIN}/uv"
    install -m 755 "${TEMP_DIR}/uv-${UV_ARCH}/uvx" "${LOCAL_BIN}/uvx"
    log_success "Installed uv into ${LOCAL_BIN}"
fi

# 2. TokToken
log_step "Step 2: Installing TokToken"
TOKTOKEN_URL="https://github.com/mauriziofonte/toktoken/releases/latest/download/toktoken-linux-${TOKTOKEN_ARCH}"
if curl -fsSL -o "${LOCAL_BIN}/toktoken" "${TOKTOKEN_URL}"; then
    chmod +x "${LOCAL_BIN}/toktoken"
    log_success "Installed TokToken -> ${LOCAL_BIN}/toktoken"
fi

# 3. rust-analyzer
log_step "Step 3: Installing rust-analyzer binary"
RUST_ANALYZER_URL="https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-${RUST_ANALYZER_ARCH}.gz"
if curl -fsSL -o "${TEMP_DIR}/rust-analyzer.gz" "${RUST_ANALYZER_URL}"; then
    gzip -d -f "${TEMP_DIR}/rust-analyzer.gz"
    install -m 755 "${TEMP_DIR}/rust-analyzer" "${LOCAL_BIN}/rust-analyzer"
    log_success "Installed rust-analyzer -> ${LOCAL_BIN}/rust-analyzer"
fi

# 4. scip CLI
log_step "Step 4: Installing scip CLI"
SCIP_URL="https://github.com/scip-code/scip/releases/latest/download/scip-linux-${SCIP_ARCH}.tar.gz"
if curl -fsSL -o "${TEMP_DIR}/scip.tar.gz" "${SCIP_URL}"; then
    tar -xzf "${TEMP_DIR}/scip.tar.gz" -C "${TEMP_DIR}"
    if [[ -f "${TEMP_DIR}/scip" ]]; then
        install -m 755 "${TEMP_DIR}/scip" "${LOCAL_BIN}/scip"
    elif [[ -f "${TEMP_DIR}/scip-linux-${SCIP_ARCH}/scip" ]]; then
        install -m 755 "${TEMP_DIR}/scip-linux-${SCIP_ARCH}/scip" "${LOCAL_BIN}/scip"
    fi
    log_success "Installed scip -> ${LOCAL_BIN}/scip"
fi

# 5. Python CLI tools via uv tool
log_step "Step 5: Installing Python tools (serena, codetree, aider, pylsp)"
export PATH="${LOCAL_BIN}:$PATH"
uv tool install serena-agent || true
uv tool install mcp-server-codetree || true
uv tool install aider-chat || true
uv tool install python-lsp-server || true

# 6. Go tools
log_step "Step 6: Installing Go indexing tools"
if command -v go >/dev/null 2>&1; then
    go install golang.org/x/tools/gopls@latest || true
    go install github.com/scip-code/scip-go/cmd/scip-go@latest || true
    go install github.com/liza-mas/scip-search/cmd/scip-search@latest || true
    GOBIN_DIR="$(go env GOPATH)/bin"
    if [[ -d "${GOBIN_DIR}" ]]; then
        for f in "${GOBIN_DIR}"/*; do
            [[ -f "$f" ]] && ln -sf "$f" "${LOCAL_BIN}/$(basename "$f")"
        done
    fi
fi

# 7. NPM Global Tools (User prefix)
log_step "Step 7: Configuring npm prefix and installing node packages"
NPM_USER_DIR="${HOME}/.npm-global"
mkdir -p "${NPM_USER_DIR}"
npm config set prefix "${NPM_USER_DIR}"
npm install -g repomix repomix-rs tree-sitter-cli pyright typescript typescript-language-server @vtsls/language-server @sourcegraph/scip-typescript @sourcegraph/scip-python || true

for nb in "${NPM_USER_DIR}/bin"/*; do
    [[ -f "$nb" ]] && ln -sf "$nb" "${LOCAL_BIN}/$(basename "$nb")"
done

# PATH notice
echo -e "\n${GREEN}${BOLD}Installation Complete!${NC}"
echo -e "Make sure ${BOLD}${LOCAL_BIN}${NC} is in your PATH."
echo -e "Add this to your ~/.bashrc or ~/.zshrc if not already present:"
echo -e "${CYAN}export PATH=\"\$HOME/.local/bin:\$HOME/.npm-global/bin:\$HOME/go/bin:\$PATH\"${NC}\n"
