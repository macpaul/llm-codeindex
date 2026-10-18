#!/usr/bin/env bash
# ==============================================================================
# deploy-indexing-tools.sh
# System-wide (root/sudo) deployment script for LLM Code Indexing & Retrieval Tools
# Target OS: Ubuntu 22.04 / 24.04 / 26.04 (Debian-based x86_64 & aarch64)
# Deploy Destination: /usr/local/bin (accessible to all system users)
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_step() {
    echo -e "\n${CYAN}${BOLD}==>${NC} ${BOLD}$*${NC}"
}

# ------------------------------------------------------------------------------
# 0. Check Root / Sudo Privileges
# ------------------------------------------------------------------------------
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    log_error "This script must be executed with root privileges for system-wide installation."
    echo -e "Please re-run with: ${BOLD}sudo $0${NC}"
    exit 1
fi

ARCH="$(uname -m)"
log_info "Detected Architecture: ${ARCH}"
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
        log_warn "Architecture ${ARCH} might require manual builds for binary assets."
        TOKTOKEN_ARCH="x86_64"
        SCIP_ARCH="amd64"
        UV_ARCH="x86_64-unknown-linux-gnu"
        RUST_ANALYZER_ARCH="x86_64-unknown-linux-gnu"
        ;;
esac

TEMP_DIR="$(mktemp -d -t indexing-deploy-XXXXXX)"
cleanup() {
    rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

# ------------------------------------------------------------------------------
# 1. Install Ubuntu Native Packages via APT
# ------------------------------------------------------------------------------
log_step "Step 1: Installing Ubuntu system packages via APT"
export DEBIAN_FRONTEND=noninteractive

apt-get update -y

APT_PACKAGES=(
    build-essential
    gfortran
    pkg-config
    libsqlite3-dev
    sqlite3
    universal-ctags
    clangd
    curl
    wget
    git
    jq
    unzip
    tar
    gzip
    python3
    python3-pip
    python3-venv
    libopenblas-dev
    liblapack-dev
)

# Also check for nodejs and golang-go if not already present
if ! command -v node >/dev/null 2>&1; then
    APT_PACKAGES+=(nodejs npm)
fi
if ! command -v go >/dev/null 2>&1; then
    APT_PACKAGES+=(golang-go)
fi

apt-get install -y --no-install-recommends "${APT_PACKAGES[@]}"
log_success "APT packages successfully installed."

# ------------------------------------------------------------------------------
# 2. Install Astral UV (Fast, Isolated System-wide Python Runner)
# ------------------------------------------------------------------------------
log_step "Step 2: Installing Astral uv & uvx into /usr/local/bin"
if ! command -v uv >/dev/null 2>&1; then
    log_info "Downloading standalone uv archive..."
    UV_URL="https://github.com/astral-sh/uv/releases/latest/download/uv-${UV_ARCH}.tar.gz"
    curl -fsSL "${UV_URL}" -o "${TEMP_DIR}/uv.tar.gz"
    tar -xzf "${TEMP_DIR}/uv.tar.gz" -C "${TEMP_DIR}"
    install -m 755 "${TEMP_DIR}/uv-${UV_ARCH}/uv" /usr/local/bin/uv
    install -m 755 "${TEMP_DIR}/uv-${UV_ARCH}/uvx" /usr/local/bin/uvx
    log_success "Installed uv: $(/usr/local/bin/uv --version)"
else
    log_info "uv is already installed at $(command -v uv)"
fi

# ------------------------------------------------------------------------------
# 3. Install Global NPM Packages (Repomix, Pyright, SCIP-TS, SCIP-Python, LSPs)
# ------------------------------------------------------------------------------
log_step "Step 3: Installing global NPM packages for JS/TS, Python AST, and LSPs"
NPM_PACKAGES=(
    repomix
    repomix-rs
    tree-sitter-cli
    pyright
    typescript
    typescript-language-server
    @vtsls/language-server
    @sourcegraph/scip-typescript
    @sourcegraph/scip-python
)

log_info "Installing: ${NPM_PACKAGES[*]}"
npm install -g "${NPM_PACKAGES[@]}"
log_success "Global NPM indexing packages installed."

# ------------------------------------------------------------------------------
# 4. Install Standalone GitHub Binaries into /usr/local/bin
# ------------------------------------------------------------------------------
log_step "Step 4: Installing Standalone GitHub Binaries into /usr/local/bin"

# 4.1 TokToken (mauriziofonte/toktoken)
log_info "Deploying TokToken (Single C binary, SQLite FTS5 + ctags)..."
TOKTOKEN_URL="https://github.com/mauriziofonte/toktoken/releases/latest/download/toktoken-linux-${TOKTOKEN_ARCH}"
if curl -fsSL -o "${TEMP_DIR}/toktoken" "${TOKTOKEN_URL}"; then
    install -m 755 "${TEMP_DIR}/toktoken" /usr/local/bin/toktoken
    log_success "Installed TokToken: /usr/local/bin/toktoken"
else
    log_warn "Failed to download prebuilt TokToken. Please build from source."
fi

# 4.2 rust-analyzer (Official Rust LSP)
log_info "Deploying rust-analyzer..."
RUST_ANALYZER_URL="https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-${RUST_ANALYZER_ARCH}.gz"
if curl -fsSL -o "${TEMP_DIR}/rust-analyzer.gz" "${RUST_ANALYZER_URL}"; then
    gzip -d -f "${TEMP_DIR}/rust-analyzer.gz"
    install -m 755 "${TEMP_DIR}/rust-analyzer" /usr/local/bin/rust-analyzer
    log_success "Installed rust-analyzer: $(/usr/local/bin/rust-analyzer --version || true)"
else
    log_warn "Failed to download rust-analyzer binary."
fi

# 4.3 scip CLI (sourcegraph/scip)
log_info "Deploying SCIP CLI (Protobuf graph inspector)..."
SCIP_URL="https://github.com/scip-code/scip/releases/latest/download/scip-linux-${SCIP_ARCH}.tar.gz"
if curl -fsSL -o "${TEMP_DIR}/scip.tar.gz" "${SCIP_URL}"; then
    tar -xzf "${TEMP_DIR}/scip.tar.gz" -C "${TEMP_DIR}"
    if [[ -f "${TEMP_DIR}/scip" ]]; then
        install -m 755 "${TEMP_DIR}/scip" /usr/local/bin/scip
    elif [[ -f "${TEMP_DIR}/scip-linux-${SCIP_ARCH}/scip" ]]; then
        install -m 755 "${TEMP_DIR}/scip-linux-${SCIP_ARCH}/scip" /usr/local/bin/scip
    fi
    log_success "Installed scip CLI: $(/usr/local/bin/scip --version || true)"
else
    log_warn "Failed to download scip CLI."
fi

# 4.4 scip-clang (C/C++ SCIP Indexer)
if [[ "${ARCH}" == "x86_64" ]]; then
    log_info "Deploying scip-clang for C/C++..."
    SCIP_CLANG_URL="https://github.com/sourcegraph/scip-clang/releases/download/v0.4.0/scip-clang-x86_64-linux"
    if curl -fsSL -o "${TEMP_DIR}/scip-clang" "${SCIP_CLANG_URL}"; then
        install -m 755 "${TEMP_DIR}/scip-clang" /usr/local/bin/scip-clang
        log_success "Installed scip-clang: /usr/local/bin/scip-clang"
    fi
fi

# ------------------------------------------------------------------------------
# 5. Install Python CLI & MCP Indexing Tools System-wide
# ------------------------------------------------------------------------------
log_step "Step 5: Installing Python CLI & MCP Tools System-wide via uv"

PYTHON_TOOLS=(
    "serena-agent"
    "mcp-server-codetree"
    "python-lsp-server"
    "aider-chat"
)

# Detect host Python version.
# For Python >= 3.14, scientific packages like scipy (dependency of aider-chat)
# lack prebuilt wheels on PyPI and fail without gfortran. UV can manage a stable
# Python 3.12 runtime automatically to guarantee binary wheel installation.
TARGET_PYTHON="python3"
SYS_PY_VER="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || echo "unknown")"

if python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 14) else 1)' 2>/dev/null; then
    log_info "Detected Python ${SYS_PY_VER}. Prebuilt wheels for native packages (e.g., scipy) may be unavailable."
    log_info "Using uv managed Python 3.12 for /opt/indexing-python-tools to guarantee fast binary wheel installation."
    TARGET_PYTHON="3.12"
fi

SYSTEM_VENV="/opt/indexing-python-tools"
mkdir -p "${SYSTEM_VENV}"

log_info "Creating virtual environment at ${SYSTEM_VENV} using Python (${TARGET_PYTHON})..."
if ! uv venv "${SYSTEM_VENV}" --python "${TARGET_PYTHON}"; then
    log_warn "Failed to create venv with Python ${TARGET_PYTHON}. Falling back to system python3..."
    uv venv "${SYSTEM_VENV}" --python python3
fi

# Install packages individually with error isolation so one failure does not block the rest
log_info "Installing Python indexing tools in ${SYSTEM_VENV}..."
for pkg in "${PYTHON_TOOLS[@]}"; do
    log_info "Installing ${pkg}..."
    if uv pip install --python "${SYSTEM_VENV}/bin/python" "${pkg}"; then
        log_success "Successfully installed ${pkg}"
    else
        log_warn "Failed to install ${pkg}. Continuing with remaining tools..."
    fi
done

# Symlink executables into /usr/local/bin
log_info "Creating symlinks in /usr/local/bin for all users..."
for bin_name in serena codetree aider pylsp; do
    if [[ -f "${SYSTEM_VENV}/bin/${bin_name}" ]]; then
        ln -sf "${SYSTEM_VENV}/bin/${bin_name}" "/usr/local/bin/${bin_name}"
        log_success "Symlinked ${bin_name} -> /usr/local/bin/${bin_name}"
    else
        log_warn "Binary ${bin_name} was not generated in ${SYSTEM_VENV}/bin. Skipping symlink."
    fi
done

# ------------------------------------------------------------------------------
# 6. Compile & Install Go Indexing Tools to /usr/local/bin
# ------------------------------------------------------------------------------
log_step "Step 6: Building and Installing Go Indexing Tools (gopls, scip-go, scip-search)"

export GOPATH="${TEMP_DIR}/go"
export GOCACHE="${TEMP_DIR}/go-cache"
mkdir -p "${GOPATH}" "${GOCACHE}"

# 6.1 gopls (Official Go LSP)
log_info "Compiling gopls..."
go install golang.org/x/tools/gopls@latest || log_warn "gopls install failed"

# 6.2 scip-go (Go SCIP Indexer)
log_info "Compiling scip-go..."
go install github.com/scip-code/scip-go/cmd/scip-go@latest || log_warn "scip-go install failed"

# 6.3 scip-search (High-speed SCIP query CLI)
log_info "Compiling scip-search..."
go install github.com/liza-mas/scip-search/cmd/scip-search@latest || log_warn "scip-search install failed"

# Copy compiled Go binaries to /usr/local/bin
if [[ -d "${GOPATH}/bin" ]]; then
    for gobin in "${GOPATH}/bin"/*; do
        if [[ -f "${gobin}" ]]; then
            bname="$(basename "${gobin}")"
            install -m 755 "${gobin}" "/usr/local/bin/${bname}"
            log_success "Installed Go tool /usr/local/bin/${bname}"
        fi
    done
fi

# ------------------------------------------------------------------------------
# 7. Rust MCP Tools (rust-analyzer-mcp & CodeRLM)
# ------------------------------------------------------------------------------
log_step "Step 7: Installing Rust Indexing Tools"
if command -v cargo >/dev/null 2>&1; then
    log_info "Cargo detected. Compiling rust-analyzer-mcp..."
    cargo install --root /usr/local rust-analyzer-mcp || log_warn "rust-analyzer-mcp cargo build skipped"
else
    log_warn "Rust/Cargo is not installed on this system. Skipping cargo crates."
    log_info "Tip: Install rustup if you wish to compile rust-analyzer-mcp and coderlm: curl https://sh.rustup.rs -sSf | sh"
fi

# ------------------------------------------------------------------------------
# 8. Configure System Environment for All Users (/etc/profile.d)
# ------------------------------------------------------------------------------
log_step "Step 8: Setting up /etc/profile.d/indexing-tools.sh"
cat << 'EOF' > /etc/profile.d/indexing-tools.sh
# System-wide environment configuration for AI Code Indexing Tools
if [ -d "/usr/local/bin" ]; then
    case ":$PATH:" in
        *:/usr/local/bin:*) ;;
        *) export PATH="/usr/local/bin:$PATH" ;;
    esac
fi

# Ensure TokToken cache directory is configured per user
export TOKTOKEN_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/toktoken"
EOF
chmod 644 /etc/profile.d/indexing-tools.sh
log_success "Environment profile configured."

# Ensure standard permissions on /usr/local/bin tools
chmod 755 /usr/local/bin/* 2>/dev/null || true

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}${BOLD}================================================================${NC}"
echo -e "${GREEN}${BOLD} All LLM Code Indexing Tools Successfully Deployed System-Wide! ${NC}"
echo -e "${GREEN}${BOLD}================================================================${NC}"
echo -e "You can now run ${BOLD}./verify-indexing-tools.sh${NC} to validate all installations.\n"
