#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ARCH="$(uname -m)"

# Architecture mappings
case "$ARCH" in
    x86_64)  ARCH_DEB="amd64"; ARCH_UNAME="x86_64" ;;
    aarch64|arm64) ARCH_DEB="arm64"; ARCH_UNAME="aarch64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Parse --force flag and positional args
FORCE=false
FILTER_TOOLS=()
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=true ;;
        *) FILTER_TOOLS+=("$arg") ;;
    esac
done

SUCCEEDED=()
FAILED=()
SKIPPED=()

log()   { echo "==> $*"; }
warn()  { echo "WARNING: $*" >&2; }
fail()  { echo "ERROR: $*" >&2; }

detect_platform() {
    case "$(uname -s)" in
        Darwin) PLATFORM="macos" ;;
        Linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                case "$ID" in
                    debian|ubuntu|linuxmint|pop|elementary|zorin|kali|raspbian)
                        PLATFORM="debian" ;;
                esac
                if [ -z "${PLATFORM:-}" ]; then
                    case "${ID_LIKE:-}" in
                        *debian*) PLATFORM="debian" ;;
                    esac
                fi
            fi
            ;;
    esac
    [ -n "${PLATFORM:-}" ] || { fail "Unsupported OS"; exit 1; }
}

record_result() {
    local name="$1" rc="$2"
    if [ "$rc" -eq 0 ]; then
        SUCCEEDED+=("$name")
    else
        FAILED+=("$name")
    fi
}

should_install() {
    local name="$1"
    if [ "${#FILTER_TOOLS[@]}" -eq 0 ]; then
        return 0
    fi
    for t in "${FILTER_TOOLS[@]}"; do
        [ "$t" = "$name" ] && return 0
    done
    return 1
}

is_installed() {
    command -v "$1" &>/dev/null
}

resolve_placeholders() {
    local s="$1"
    s="${s//\{arch_deb\}/$ARCH_DEB}"
    s="${s//\{arch_uname\}/$ARCH_UNAME}"
    echo "$s"
}

github_latest_version() {
    local repo="$1"
    curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | jq -r '.tag_name'
}

# Strip leading v from version tags (v0.10.2 -> 0.10.2)
strip_v() { echo "${1#v}"; }

# --- Install methods ---

install_brew() {
    local pkg="$1"
    log "brew: $pkg"
    brew upgrade "$pkg" 2>/dev/null || brew install "$pkg"
}

install_apt() {
    local pkg="$1"
    log "apt: $pkg"
    sudo apt-get install -y "$pkg"
}

install_apt_repo() {
    local gpg_url="$1" keyring_name="$2" repo_line="$3" pkg="$4"
    local keyring_path="/etc/apt/keyrings/${keyring_name}.gpg"

    log "apt_repo: $pkg"

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL "$gpg_url" | sudo gpg --dearmor -o "$keyring_path" --yes

    repo_line="$(resolve_placeholders "$repo_line")"
    echo "$repo_line signed-by=$keyring_path" | sudo tee "/etc/apt/sources.list.d/${keyring_name}.list" > /dev/null

    sudo apt-get update -qq -o "Dir::Etc::sourcelist=sources.list.d/${keyring_name}.list" -o Dir::Etc::sourceparts=-
    sudo apt-get install -y "$pkg"
}

install_github_deb() {
    local repo="$1" asset_pattern="$2"
    local name="${repo#*/}"

    log "github_deb: $name"

    local ver
    ver="$(github_latest_version "$repo")"
    local ver_stripped
    ver_stripped="$(strip_v "$ver")"

    asset_pattern="$(resolve_placeholders "$asset_pattern")"
    asset_pattern="${asset_pattern//\{ver\}/$ver_stripped}"

    local download_url
    download_url="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
        | jq -r --arg pat "$asset_pattern" '.assets[] | select(.name | test($pat)) | .browser_download_url' \
        | head -1)"

    if [ -z "$download_url" ]; then
        fail "No matching asset for pattern '$asset_pattern' in $repo"
        return 1
    fi

    local tmp
    tmp="$(mktemp /tmp/${name}-XXXX.deb)"
    curl -fsSL -o "$tmp" "$download_url"
    sudo dpkg -i "$tmp"
    rm -f "$tmp"
}

install_github_binary() {
    local repo="$1" asset_pattern="$2" binary_name="$3"
    local name="${repo#*/}"

    log "github_binary: $name"

    asset_pattern="$(resolve_placeholders "$asset_pattern")"

    local download_url
    download_url="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
        | jq -r --arg pat "$asset_pattern" '.assets[] | select(.name | test($pat)) | .browser_download_url' \
        | head -1)"

    if [ -z "$download_url" ]; then
        fail "No matching asset for pattern '$asset_pattern' in $repo"
        return 1
    fi

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    local filename="${download_url##*/}"
    curl -fsSL -o "$tmp_dir/$filename" "$download_url"

    case "$filename" in
        *.tar.gz|*.tgz) tar -xzf "$tmp_dir/$filename" -C "$tmp_dir" ;;
        *.zip)          unzip -qo "$tmp_dir/$filename" -d "$tmp_dir" ;;
    esac

    local bin
    bin="$(find "$tmp_dir" -name "$binary_name" -type f | head -1)"
    if [ -z "$bin" ]; then
        fail "Binary '$binary_name' not found in archive"
        rm -rf "$tmp_dir"
        return 1
    fi

    chmod +x "$bin"
    sudo mv "$bin" "/usr/local/bin/$binary_name"
    rm -rf "$tmp_dir"
}

install_github_tarball() {
    local repo="$1" asset_pattern="$2" binary_name="$3" install_dir="$4"
    local name="${repo#*/}"

    log "github_tarball: $name -> $install_dir"

    asset_pattern="$(resolve_placeholders "$asset_pattern")"

    local download_url
    download_url="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
        | jq -r --arg pat "$asset_pattern" '.assets[] | select(.name | test($pat)) | .browser_download_url' \
        | head -1)"

    if [ -z "$download_url" ]; then
        fail "No matching asset for pattern '$asset_pattern' in $repo"
        return 1
    fi

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    local filename="${download_url##*/}"
    curl -fsSL -o "$tmp_dir/$filename" "$download_url"

    case "$filename" in
        *.tar.gz|*.tgz) tar -xzf "$tmp_dir/$filename" -C "$tmp_dir" ;;
        *.zip)          unzip -qo "$tmp_dir/$filename" -d "$tmp_dir" ;;
    esac

    sudo rm -rf "$install_dir"
    sudo mkdir -p "$install_dir"

    # Move extracted contents (handle single top-level dir)
    local dirs
    dirs=("$tmp_dir"/*/)
    if [ "${#dirs[@]}" -eq 1 ] && [ -d "${dirs[0]}" ]; then
        sudo cp -r "${dirs[0]}"/* "$install_dir/"
    else
        sudo cp -r "$tmp_dir"/* "$install_dir/"
    fi

    # Symlink binary
    local bin_path="$install_dir/bin/$binary_name"
    if [ -f "$bin_path" ]; then
        sudo ln -sf "$bin_path" "/usr/local/bin/$binary_name"
    fi

    rm -rf "$tmp_dir"
}

install_url_tarball() {
    local version_url="$1" version_jq="$2" url_template="$3" binary_name="$4" install_dir="$5" pinned_ver="$6"

    log "url_tarball: $binary_name -> $install_dir"

    local ver
    if [ -n "$pinned_ver" ]; then
        ver="$pinned_ver"
    else
        ver="$(curl -fsSL "$version_url" | jq -r "$version_jq")"
    fi

    local url
    url="$(resolve_placeholders "$url_template")"
    url="${url//\{ver\}/$ver}"

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    local filename="${url##*/}"
    curl -fsSL -o "$tmp_dir/$filename" "$url"

    case "$filename" in
        *.tar.gz|*.tgz) tar -xzf "$tmp_dir/$filename" -C "$tmp_dir" ;;
        *.zip)          unzip -qo "$tmp_dir/$filename" -d "$tmp_dir" ;;
    esac

    sudo rm -rf "$install_dir"
    sudo mkdir -p "$install_dir"

    # Move extracted contents (handle single top-level dir)
    local dirs
    dirs=("$tmp_dir"/*/)
    if [ "${#dirs[@]}" -eq 1 ] && [ -d "${dirs[0]}" ]; then
        sudo cp -r "${dirs[0]}"/* "$install_dir/"
    else
        sudo cp -r "$tmp_dir"/* "$install_dir/"
    fi

    # Symlink binary
    local bin_path="$install_dir/bin/$binary_name"
    if [ -f "$bin_path" ]; then
        sudo ln -sf "$bin_path" "/usr/local/bin/$binary_name"
    fi

    rm -rf "$tmp_dir"
}

install_binary_url() {
    local url_template="$1" binary_name="$2"

    log "binary_url: $binary_name"

    local url
    url="$(resolve_placeholders "$url_template")"

    sudo curl -fsSL -o "/usr/local/bin/$binary_name" "$url"
    sudo chmod +x "/usr/local/bin/$binary_name"
}

install_script() {
    local script_url="$1" name="$2"

    log "script: $name"
    curl -fsSL "$script_url" | bash
}

install_pipx() {
    local pkg="$1"
    log "pipx: $pkg"
    pipx install "$pkg" || pipx upgrade "$pkg"
}

install_uv_tool() {
    local pkg="$1"
    log "uv tool: $pkg"
    uv tool install "$pkg" || uv tool upgrade "$pkg"
}

install_go_install() {
    local pkg="$1" name="$2"
    log "go install: $name"
    [ -d /usr/local/go/bin ] && export PATH="/usr/local/go/bin:$PATH"
    if ! command -v go &>/dev/null; then
        fail "go not found; install go first"
        return 1
    fi
    go install "$pkg"
}

install_git_clone() {
    local repo_url="$1" target_dir="$2" install_cmd="$3" name="$4"

    target_dir="$(eval echo "$target_dir")"
    install_cmd="$(eval echo "$install_cmd")"

    log "git_clone: $name -> $target_dir"

    if [ -d "$target_dir" ]; then
        git -C "$target_dir" pull --ff-only
    else
        git clone --depth 1 "$repo_url" "$target_dir"
    fi

    if [ -n "$install_cmd" ]; then
        eval "$install_cmd"
    fi
}

# --- Ensure jq is available (needed to parse JSON config) ---

ensure_jq() {
    if command -v jq &>/dev/null; then
        return
    fi
    case "$PLATFORM" in
        macos)
            log "Installing jq (required for config parsing)"
            brew install jq
            ;;
        debian)
            log "Installing jq (required for config parsing)"
            sudo apt-get update -qq
            sudo apt-get install -y jq
            ;;
    esac
}

ensure_prerequisites() {
    local missing=()
    for cmd in curl jq gpg; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if [ "${#missing[@]}" -gt 0 ]; then
        log "Installing prerequisites: ${missing[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y "${missing[@]}"
    fi
}

# --- Main runner ---

run() {
    local conf="$REPO_DIR/packages.json"
    [ -f "$conf" ] || { fail "Config not found: $conf"; exit 1; }

    # Platform-specific setup
    if [ "$PLATFORM" = "macos" ]; then
        if ! command -v brew &>/dev/null; then
            fail "Homebrew not found. Install it first: https://brew.sh"
            exit 1
        fi

        # Process taps
        local taps
        taps="$(jq -r '.taps[]?' "$conf")"
        while IFS= read -r tap; do
            [ -z "$tap" ] && continue
            log "brew tap: $tap"
            brew tap "$tap" 2>/dev/null || true
        done <<< "$taps"
    fi

    if [ "$PLATFORM" = "debian" ]; then
        ensure_prerequisites
    fi

    # Iterate packages
    local tools
    tools="$(jq -r '.packages | keys[]' "$conf")"

    while IFS= read -r name; do
        [ -z "$name" ] && continue
        should_install "$name" || continue

        # Check if platform config exists
        local has_platform
        has_platform="$(jq -r --arg p "$PLATFORM" --arg n "$name" '.packages[$n] | has($p)' "$conf")"
        if [ "$has_platform" != "true" ]; then
            continue
        fi

        # Get bin name for is_installed check
        local bin_name
        bin_name="$(jq -r --arg n "$name" '.packages[$n].bin // $n' "$conf")"

        # Skip if already installed (unless --force)
        if [ "$FORCE" = false ] && is_installed "$bin_name"; then
            log "skip: $name (already installed)"
            SKIPPED+=("$name")
            continue
        fi

        local method
        method="$(jq -r --arg p "$PLATFORM" --arg n "$name" '.packages[$n][$p].method' "$conf")"

        local rc=0
        case "$method" in
            brew)
                install_brew "$name" || rc=$?
                ;;
            apt)
                install_apt "$name" || rc=$?
                ;;
            apt_repo)
                local gpg_url keyring_name repo_line pkg
                gpg_url="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].gpg_url' "$conf")"
                keyring_name="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].keyring_name' "$conf")"
                repo_line="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].repo_line' "$conf")"
                pkg="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].pkg' "$conf")"
                install_apt_repo "$gpg_url" "$keyring_name" "$repo_line" "$pkg" || rc=$?
                ;;
            github_deb)
                local repo asset
                repo="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].repo' "$conf")"
                asset="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].asset' "$conf")"
                install_github_deb "$repo" "$asset" || rc=$?
                ;;
            github_binary)
                local repo asset binary
                repo="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].repo' "$conf")"
                asset="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].asset' "$conf")"
                binary="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].binary' "$conf")"
                install_github_binary "$repo" "$asset" "$binary" || rc=$?
                ;;
            github_tarball)
                local repo asset binary install_dir
                repo="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].repo' "$conf")"
                asset="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].asset' "$conf")"
                binary="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].binary' "$conf")"
                install_dir="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].install_dir' "$conf")"
                install_github_tarball "$repo" "$asset" "$binary" "$install_dir" || rc=$?
                ;;
            url_tarball)
                local version_url version_jq url binary install_dir pinned_ver
                version_url="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].version_url // empty' "$conf")"
                version_jq="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].version_jq // empty' "$conf")"
                url="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].url' "$conf")"
                binary="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].binary' "$conf")"
                install_dir="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].install_dir' "$conf")"
                pinned_ver="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].version // empty' "$conf")"
                install_url_tarball "$version_url" "$version_jq" "$url" "$binary" "$install_dir" "$pinned_ver" || rc=$?
                ;;
            binary_url)
                local url binary
                url="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].url' "$conf")"
                binary="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].binary' "$conf")"
                install_binary_url "$url" "$binary" || rc=$?
                ;;
            script)
                local url
                url="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].url' "$conf")"
                install_script "$url" "$name" || rc=$?
                ;;
            pipx)
                local pkg
                pkg="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].pkg // $n' "$conf")"
                install_pipx "$pkg" || rc=$?
                ;;
            uv_tool)
                local pkg
                pkg="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].pkg // $n' "$conf")"
                install_uv_tool "$pkg" || rc=$?
                ;;
            go_install)
                local pkg
                pkg="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].pkg' "$conf")"
                install_go_install "$pkg" "$name" || rc=$?
                ;;
            git_clone)
                local repo_url target_dir install_cmd
                repo_url="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].repo_url' "$conf")"
                target_dir="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].target_dir' "$conf")"
                install_cmd="$(jq -r --arg n "$name" --arg p "$PLATFORM" '.packages[$n][$p].install_cmd // empty' "$conf")"
                install_git_clone "$repo_url" "$target_dir" "$install_cmd" "$name" || rc=$?
                ;;
            *)
                warn "Unknown method '$method' for $name"
                rc=1
                ;;
        esac

        record_result "$name" "$rc"
    done <<< "$tools"
}

# --- Main ---

detect_platform
ensure_jq

log "Platform=$PLATFORM ARCH=$ARCH (deb=$ARCH_DEB, uname=$ARCH_UNAME)"

if [ "${#FILTER_TOOLS[@]}" -gt 0 ]; then
    log "Installing: ${FILTER_TOOLS[*]}"
fi
if [ "$FORCE" = true ]; then
    log "Force mode: reinstalling all"
fi

run

echo ""
echo "========== Summary =========="
echo "Succeeded (${#SUCCEEDED[@]}): ${SUCCEEDED[*]:-none}"
echo "Skipped   (${#SKIPPED[@]}): ${SKIPPED[*]:-none}"
if [ "${#FAILED[@]}" -gt 0 ]; then
    echo "Failed    (${#FAILED[@]}): ${FAILED[*]}"
    exit 1
else
    echo "Failed    (0): none"
fi
