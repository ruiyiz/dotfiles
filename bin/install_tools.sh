#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILTER_TOOLS=("$@")

OS="$(uname -s)"
ARCH="$(uname -m)"

# Architecture mappings
case "$ARCH" in
    x86_64)  ARCH_DEB="amd64"; ARCH_UNAME="x86_64" ;;
    aarch64|arm64) ARCH_DEB="arm64"; ARCH_UNAME="aarch64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

SUCCEEDED=()
FAILED=()

log()   { echo "==> $*"; }
warn()  { echo "WARNING: $*" >&2; }
fail()  { echo "ERROR: $*" >&2; }

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

# --- macOS (Homebrew) ---

install_brew() {
    local pkg="$1"
    log "brew: $pkg"
    brew upgrade "$pkg" 2>/dev/null || brew install "$pkg"
}

run_macos() {
    local conf="$REPO_DIR/install/packages_macos.conf"
    [ -f "$conf" ] || { fail "Config not found: $conf"; exit 1; }

    if ! command -v brew &>/dev/null; then
        fail "Homebrew not found. Install it first: https://brew.sh"
        exit 1
    fi

    while IFS= read -r line <&3 || [ -n "$line" ]; do
        line="$(echo "$line" | sed 's/#.*//' | xargs)"
        [ -z "$line" ] && continue

        if [[ "$line" == tap:* ]]; then
            local tap="${line#tap: }"
            tap="$(echo "$tap" | xargs)"
            log "brew tap: $tap"
            brew tap "$tap" 2>/dev/null || true
            continue
        fi

        should_install "$line" || continue
        install_brew "$line"
        record_result "$line" $?
    done 3< "$conf"
}

# --- Ubuntu Linux ---

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

run_ubuntu() {
    local conf="$REPO_DIR/install/packages_ubuntu.conf"
    [ -f "$conf" ] || { fail "Config not found: $conf"; exit 1; }

    ensure_prerequisites

    while IFS= read -r line <&3 || [ -n "$line" ]; do
        line="$(echo "$line" | sed 's/#.*//' | xargs)"
        [ -z "$line" ] && continue

        IFS='|' read -ra fields <<< "$line"
        # Trim whitespace from each field
        for i in "${!fields[@]}"; do
            fields[$i]="$(echo "${fields[$i]}" | xargs)"
        done

        local name="${fields[0]}"
        local method="${fields[1]}"

        should_install "$name" || continue

        local rc=0
        case "$method" in
            apt)
                install_apt "$name" || rc=$?
                ;;
            apt_repo)
                install_apt_repo "${fields[2]}" "${fields[3]}" "${fields[4]}" "${fields[5]}" || rc=$?
                ;;
            github_deb)
                install_github_deb "${fields[2]}" "${fields[3]}" || rc=$?
                ;;
            github_binary)
                install_github_binary "${fields[2]}" "${fields[3]}" "${fields[4]}" || rc=$?
                ;;
            github_tarball)
                install_github_tarball "${fields[2]}" "${fields[3]}" "${fields[4]}" "${fields[5]}" || rc=$?
                ;;
            binary_url)
                install_binary_url "${fields[2]}" "${fields[3]}" || rc=$?
                ;;
            script)
                install_script "${fields[2]}" "$name" || rc=$?
                ;;
            git_clone)
                install_git_clone "${fields[2]}" "${fields[3]}" "${fields[4]}" "$name" || rc=$?
                ;;
            *)
                warn "Unknown method '$method' for $name"
                rc=1
                ;;
        esac

        record_result "$name" "$rc"
    done 3< "$conf"
}

# --- Main ---

log "OS=$OS ARCH=$ARCH (deb=$ARCH_DEB, uname=$ARCH_UNAME)"

if [ "${#FILTER_TOOLS[@]}" -gt 0 ]; then
    log "Installing: ${FILTER_TOOLS[*]}"
fi

case "$OS" in
    Darwin) run_macos ;;
    Linux)  run_ubuntu ;;
    *)      fail "Unsupported OS: $OS"; exit 1 ;;
esac

echo ""
echo "========== Summary =========="
echo "Succeeded (${#SUCCEEDED[@]}): ${SUCCEEDED[*]:-none}"
if [ "${#FAILED[@]}" -gt 0 ]; then
    echo "Failed    (${#FAILED[@]}): ${FAILED[*]}"
    exit 1
else
    echo "Failed    (0): none"
fi
