#!/data/data/com.termux/files/usr/bin/bash
[ -z "$_CO_FIXED" ] && sed -i 's/\r//g' "$0" && export _CO_FIXED=1 && exec bash "$0" "$@"
# ═══════════════════════════════════════════════════════════════════════════════
#   CO-INSTALL  v4.0  —  Installateur CO-TEAM pour Termux
#   Menu dense avec statut en temps réel  •  Actions par script  •  Thème/heure
# ═══════════════════════════════════════════════════════════════════════════════

SELF_URL="https://raw.githubusercontent.com/Bicode-dev/sh.Termux/refs/heads/main/Co-install.sh"
SELF_PATH="$(realpath "$0" 2>/dev/null || echo "$0")"

_self_update() {
    printf '\033[2m  › Vérification Co-install.sh...\033[0m\n'
    local http_code
    http_code=$(curl -sLo /dev/null -w "%{http_code}" "$SELF_URL" 2>/dev/null)
    if [ "$http_code" != "200" ]; then
        printf '\033[33m  ⚠ Code HTTP %s — script local conservé.\033[0m\n\n' "$http_code"
        sleep 0.6
        return
    fi
    local tmpdir="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
    mkdir -p "$tmpdir" 2>/dev/null
    local tmp
    tmp=$(mktemp "${tmpdir}/co-install-XXXXXX.sh")
    if curl -sL -o "$tmp" "$SELF_URL" 2>/dev/null && [ -s "$tmp" ]; then
        sed -i 's/\r//g' "$tmp"
        chmod +x "$tmp"
        cp "$tmp" "$SELF_PATH" 2>/dev/null || true
        chmod +x "$SELF_PATH"  2>/dev/null || true
        printf '\033[38;5;99m  ✔ Co-install.sh mis à jour — relancement...\033[0m\n\n'
        sleep 0.5
        exec bash "$tmp" --no-update
    else
        rm -f "$tmp"
        printf '\033[33m  ⚠ Téléchargement échoué — version locale conservée.\033[0m\n\n'
        sleep 0.6
    fi
}

if [ "$1" != "--no-update" ]; then
    _self_update
fi

VERSION="4.1"
RESET='\033[0m'; BOLD='\033[1m'; DIM='\033[2m'; ITALIC='\033[3m'

HOUR=$(date +%H); START_TIME=$(date +"%H:%M"); START_DATE=$(date +"%d/%m/%Y")

if   [ "$HOUR" -ge 5  ] && [ "$HOUR" -lt 9  ]; then
    THEME="Aube";    EMOJI="🌅"
    C1='\033[38;5;214m'; C2='\033[38;5;209m'; C3='\033[38;5;228m'; BAR='▓'
elif [ "$HOUR" -ge 9  ] && [ "$HOUR" -lt 12 ]; then
    THEME="Matin";   EMOJI="☀️ "
    C1='\033[38;5;81m';  C2='\033[38;5;123m'; C3='\033[38;5;195m'; BAR='█'
elif [ "$HOUR" -ge 12 ] && [ "$HOUR" -lt 17 ]; then
    THEME="Après-midi"; EMOJI="🌞"
    C1='\033[38;5;118m'; C2='\033[38;5;156m'; C3='\033[38;5;228m'; BAR='▪'
elif [ "$HOUR" -ge 17 ] && [ "$HOUR" -lt 21 ]; then
    THEME="Soirée";  EMOJI="🌆"
    C1='\033[38;5;213m'; C2='\033[38;5;205m'; C3='\033[38;5;183m'; BAR='◆'
else
    THEME="Nuit";    EMOJI="🌙"
    C1='\033[38;5;99m';  C2='\033[38;5;135m'; C3='\033[38;5;147m'; BAR='·'
fi

OK="${C1}✔${RESET}"; WARN="${C3}⚠${RESET}"; ERR='\033[38;5;196m✘'"${RESET}"
INFO="${C2}›${RESET}"; ARR="${C1}▶${RESET}"

# ── URLs ──────────────────────────────────────────────────────────────────────
URL_COMENU="https://raw.githubusercontent.com/Bicode-dev/Co-Menu/refs/heads/main/Co-Menu.py"
URL_COCHAN="https://raw.githubusercontent.com/Bicode-dev/anime_Co-Chan_download/refs/heads/main/Co-chan.py"
URL_COTUBE="https://raw.githubusercontent.com/Bicode-dev/Co-tube/main/Co-tube.py"
URL_COSAMA="https://raw.githubusercontent.com/Bicode-dev/Scan_Co-Sama_download/refs/heads/main/CO-SAMA.py"
# Co-flix : fichier local uniquement, pas d'URL

PY_DIR="$HOME/.local/share/CoTEAM/Co-Menu"
COMENU_PATH="$HOME/.local/share/CoTEAM/Co-Menu.py"
COCHAN_PATH="$PY_DIR/Co-chan.py"
COTUBE_PATH="$PY_DIR/Co-tube.py"
COSAMA_PATH="$PY_DIR/Co-sama.py"
COFLIX_PATH="$PY_DIR/Co-flix.py"

_CACHE_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}/co-status-cache"
_CACHE_TTL=300

_cached_remote_size() {
    local url="$1"
    local key
    key=$(printf '%s' "$url" | tr -dc 'a-zA-Z0-9' | tail -c 24)
    local cache_file="${_CACHE_DIR}/${key}"
    mkdir -p "$_CACHE_DIR" 2>/dev/null
    if [ -f "$cache_file" ]; then
        local mtime
        mtime=$(stat -c "%Y" "$cache_file" 2>/dev/null || echo 0)
        local now
        now=$(date +%s 2>/dev/null || echo 0)
        local age=$(( now - mtime ))
        if [ "$age" -lt "$_CACHE_TTL" ]; then
            cat "$cache_file"
            return
        fi
    fi
    local rsize
    rsize=$(curl -sLI "$url" 2>/dev/null \
        | grep -i "^content-length:" | tail -1 \
        | awk '{print $2}' | tr -d '\r\n')
    printf '%s' "$rsize" > "$cache_file"
    printf '%s' "$rsize"
}

_cache_invalidate() {
    rm -rf "$_CACHE_DIR" 2>/dev/null
}

clr() { clear; }
nl()  { echo ""; }

_file_date() {
    local epoch
    epoch=$(stat -c "%Y" "$1" 2>/dev/null)
    if [ -n "$epoch" ]; then
        date -d "@${epoch}" "+%d/%m %H:%M" 2>/dev/null || echo "—"
    else
        echo "—"
    fi
}

cols() { tput cols 2>/dev/null || echo 54; }

fill_to_cols() {
    local char="$1" used="${2:-2}"
    local w=$(( $(cols) - used ))
    [ "$w" -lt 1 ] && w=1
    local out="" i=0
    while [ "$i" -lt "$w" ]; do
        out="${out}${char}"
        i=$(( i + 1 ))
    done
    printf '%s' "$out"
}

sep_h(){ echo -e "${C1}  $(fill_to_cols '═' 2)${RESET}"; }
sep_l(){ echo -e "${DIM}  $(fill_to_cols '─' 2)${RESET}"; }

sec_hdr() {
    local color="$1" label="$2"
    local prefix="═══ ${label} "
    local used=$(( 2 + ${#prefix} ))
    local rest=$(fill_to_cols '═' "$used")
    echo -e "  ${color}${BOLD}${prefix}${RESET}${DIM}${rest}${RESET}"
}

line_ok()  { echo -e "  ${OK}  $1"; }
line_warn(){ echo -e "  ${WARN}  $1"; }
line_err() { echo -e "  ${ERR}  $1"; }
line_info(){ echo -e "  ${INFO}  $1"; }
section()  { echo -e "\n  ${ARR} ${BOLD}${C1}$1${RESET}"; sep_l; }
pause()    { printf "  ${DIM}Entrée pour continuer...${RESET} "; read -r; }

remote_size() {
    curl -sLI "$1" 2>/dev/null \
        | grep -i "^content-length:" | tail -1 \
        | awk '{print $2}' | tr -d '\r\n'
}

file_status_line() {
    local path="$1" url="$2" label="$3"
    local pad=12
    local lpad=$(( pad - ${#label} ))
    [ "$lpad" -lt 1 ] && lpad=1
    local spaces=$(printf '%*s' "$lpad" '')

    if [ ! -f "$path" ]; then
        echo -e "  ${ERR}  ${BOLD}${label}${RESET}${spaces}${ERR} Manquant${RESET}          ${DIM}—${RESET}"
        return
    fi

    local lsize=$(wc -c < "$path" | tr -d ' ')
    local ldate
    ldate=$(_file_date "$path")
    local rsize
    rsize=$(_cached_remote_size "$url")
    local size_fmt

    if   [ "$lsize" -gt 999999 ] 2>/dev/null; then size_fmt="$(( lsize/1024 ))Ko"
    elif [ "$lsize" -gt 999    ] 2>/dev/null; then size_fmt="$(( lsize/1024 ))Ko"
    else size_fmt="${lsize}o"; fi

    if [ -z "$rsize" ] || [ "$rsize" = "0" ]; then
        echo -e "  ${WARN}  ${BOLD}${label}${RESET}${spaces}${C3} Installé${RESET}  ${DIM}${size_fmt}${RESET}   ${DIM}màj: ${ldate}${RESET}  ${DIM}(taille distante inconnue)${RESET}"
        return
    fi

    local diff=$(( rsize - lsize ))
    [ "$diff" -lt 0 ] && diff=$(( -diff ))
    if [ "$diff" -le 1 ]; then
        echo -e "  ${OK}  ${BOLD}${label}${RESET}${spaces}${C1} À jour${RESET}    ${DIM}${size_fmt}${RESET}   ${DIM}màj: ${ldate}${RESET}"
    else
        local rdiff=$(( (rsize - lsize > 0 ? rsize - lsize : lsize - rsize) ))
        echo -e "  ${WARN}  ${BOLD}${label}${RESET}${spaces}${C3} MàJ dispo${RESET} ${DIM}${size_fmt}${RESET}   ${DIM}màj: ${ldate}  (+${rdiff}o)${RESET}"
    fi
}

# ── Statut Co-flix (local uniquement) — affiché SEULEMENT si le fichier existe
file_status_coflix() {
    [ ! -f "$COFLIX_PATH" ] && return
    local lsize
    lsize=$(wc -c < "$COFLIX_PATH" | tr -d ' ')
    local ldate
    ldate=$(_file_date "$COFLIX_PATH")
    local size_fmt
    if   [ "$lsize" -gt 999999 ] 2>/dev/null; then size_fmt="$(( lsize/1024 ))Ko"
    elif [ "$lsize" -gt 999    ] 2>/dev/null; then size_fmt="$(( lsize/1024 ))Ko"
    else size_fmt="${lsize}o"; fi
    local spaces="    "
    echo -e "  ${OK}  ${BOLD}Co-flix.py${RESET}${spaces}${C1} Local${RESET}     ${DIM}${size_fmt}${RESET}   ${DIM}màj: ${ldate}${RESET}  ${DIM}(pas de MàJ distante)${RESET}"
}

progress_bar() {
    local label="$1" W=36 i=0
    while [ "$i" -le 100 ]; do
        local f=$(( i * W / 100 )) e=$(( W - i * W / 100 ))
        local bar=""
        local x=0; while [ "$x" -lt "$f" ]; do bar="${bar}${BAR}"; x=$((x+1)); done
        local y=0; while [ "$y" -lt "$e" ]; do bar="${bar}─";       y=$((y+1)); done
        printf "\r  ${C1}[${RESET}${C2}%s${RESET}${C1}]${RESET} ${BOLD}%3d%%${RESET}  ${DIM}%s${RESET}   " "$bar" "$i" "$label"
        i=$((i+4)); sleep 0.03
    done; echo ""
}

fetch_script() {
    local url="$1" dest="$2" label="$3"; nl
    local rsize=$(remote_size "$url")

    if [ -f "$dest" ] && [ -n "$rsize" ] && [ "$rsize" != "0" ]; then
        local lsize=$(wc -c < "$dest" | tr -d ' ')
        local diff=$(( rsize - lsize < 0 ? lsize - rsize : rsize - lsize ))
        if [ "$diff" -le 1 ]; then
            line_info "${BOLD}${label}${RESET}${C1} — Déjà à jour${RESET} ${DIM}(${lsize}o)${RESET}${DIM} — retéléchargement forcé...${RESET}"
        else
            line_info "${BOLD}${label}${RESET} ${DIM}${lsize}o → ${rsize}o${RESET}"
        fi
    elif [ -f "$dest" ]; then
        line_info "${BOLD}${label}${RESET} ${DIM}— taille distante inconnue, mise à jour...${RESET}"
    else
        line_info "${BOLD}${label}${RESET} ${C3}— Première installation...${RESET}"
    fi

    mkdir -p "$(dirname "$dest")"
    progress_bar "$label"
    if curl -sL -o "$dest" "$url"; then
        local nsize=$(wc -c < "$dest" | tr -d ' ')
        line_ok "${BOLD}${label}${RESET}${C1} — OK${RESET} ${DIM}(${nsize}o)${RESET}"
        chmod +x "$dest"
        _cache_invalidate
        return 0
    else
        line_err "${label} — Échec"; return 1
    fi
}

# ── Vérifie Co-flix.py : si présent et ~155Ko (±1Ko) → installe tor ──────────
_check_coflix_tor() {
    [ ! -f "$COFLIX_PATH" ] && return
    local fsize
    fsize=$(wc -c < "$COFLIX_PATH" | tr -d ' ')
    local lo=$(( 154 * 1024 ))
    local hi=$(( 156 * 1024 ))
    if [ "$fsize" -ge "$lo" ] && [ "$fsize" -le "$hi" ]; then
        section "Co-flix détecté (~155Ko) — vérification de tor"
        if pkg list-installed 2>/dev/null | grep -q "^tor/"; then
            line_ok "${BOLD}tor${RESET} ${DIM}déjà installé${RESET}"
        else
            line_info "Installation de ${BOLD}tor${RESET} (requis par Co-flix ~155Ko)..."
            pkg install tor -y && line_ok "tor installé" || line_warn "Impossible d'installer tor"
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
#  BANNIÈRE
# ═══════════════════════════════════════════════════════════════════════════════
banner() {
    echo -e "${C1}"
    echo "  ╔═══════════════════════════════════════════════════════════╗"
    echo "  ║  ██████╗ ██████╗    ████████╗███████╗ █████╗ ███╗   ███╗  ║"
    echo "  ║  ██╔════╝██╔═══██╗     ██╔══╝██╔════╝██╔══██╗████╗ ████║  ║"
    echo "  ║  ██║     ██║   ██║     ██║   █████╗  ███████║██╔████╔██║  ║"
    echo "  ║  ╚██████╗╚██████╔╝     ██║   ███████╗██║  ██║██║╚██╔╝██║  ║"
    echo "  ║   ╚═════╝ ╚═════╝      ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝ ╚═╝ ╚═╝  ║"
    echo -e "  ║${RESET}${C3}  ${EMOJI}  ${THEME}  ·  ${START_TIME}  ·  v${VERSION}                              ${C1}║"
    echo "  ╚═══════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# ═══════════════════════════════════════════════════════════════════════════════
#  MENU PRINCIPAL DENSE
# ═══════════════════════════════════════════════════════════════════════════════
print_menu() {
    clr
    banner

    # ── Section ÉTAT DES FICHIERS ─────────────────────────────────────────────
    sec_hdr "${C1}" "ÉTAT DES FICHIERS"
    file_status_line "$COMENU_PATH" "$URL_COMENU" "Co-Menu.py"
    file_status_line "$COCHAN_PATH" "$URL_COCHAN" "Co-chan.py"
    file_status_line "$COSAMA_PATH" "$URL_COSAMA" "Co-sama.py"
    file_status_line "$COTUBE_PATH" "$URL_COTUBE" "Co-tube.py"
    file_status_coflix   # affiché seulement si Co-flix.py existe
    nl

    # ── Section PAR SCRIPT ───────────────────────────────────────────────────
    sec_hdr "${C2}" "PAR SCRIPT"
    echo -e "  ${C1}${BOLD} [1] ${RESET} Co-Menu.py   ${DIM}→ installer ou mettre à jour${RESET}"
    echo -e "  ${C1}${BOLD} [2] ${RESET} Co-chan.py   ${DIM}→ installer ou mettre à jour${RESET}"
    echo -e "  ${C1}${BOLD} [3] ${RESET} Co-sama.py  ${DIM}→ installer ou mettre à jour${RESET}"
    echo -e "  ${C1}${BOLD} [4] ${RESET} Co-tube.py  ${DIM}→ installer ou mettre à jour${RESET}"
    nl

    # ── Section INSTALLATION ─────────────────────────────────────────────────
    sec_hdr "${C2}" "INSTALLATION"
    echo -e "  ${C1}${BOLD} [5] ${RESET} Installation complète          ${DIM}paquets + scripts + config${RESET}"
    echo -e "  ${C1}${BOLD} [6] ${RESET} Mettre à jour tous les scripts ${DIM}Co-Menu + Co-chan + Co-sama + Co-tube${RESET}"
    nl

    # ── Section OUTILS ───────────────────────────────────────────────────────
    sec_hdr "${C3}" "OUTILS"
    echo -e "  ${C2}${BOLD} [7] ${RESET} Stockage Android               ${DIM}termux-setup-storage${RESET}"
    echo -e "  ${C2}${BOLD} [8] ${RESET} Alias & raccourcis Termux      ${DIM}co / anime / cosama / cotube / coupdate${RESET}"
    echo -e "  ${C2}${BOLD} [9] ${RESET} Supprimer les animes           ${DIM}/storage/.../Download/anime${RESET}"
    echo -e "  ${C3}${BOLD}[10] ${RESET} Tout désinstaller              ${DIM}scripts + alias + raccourcis${RESET}"
    nl

    sep_l
    echo -e "  ${DIM} [0]  Quitter${RESET}"
    sep_l
    nl
    printf "  ${C1}${BOLD}›› ${RESET}Choix : "
}

# ═══════════════════════════════════════════════════════════════════════════════
#  ACTIONS
# ═══════════════════════════════════════════════════════════════════════════════

update_packages() {
    section "Mise à jour des paquets Termux"
    pkg update -y && pkg upgrade -y
    line_ok "Paquets à jour"
}

install_pkg() {
    section "Paquets système"
    for p in python git curl ffmpeg yt-dlp; do
        if pkg list-installed 2>/dev/null | grep -q "^${p}/"; then
            line_ok "${BOLD}${p}${RESET} ${DIM}déjà installé${RESET}"
        else
            line_info "Installation de ${BOLD}${p}${RESET}..."
            pkg install "$p" -y && line_ok "${p} installé" || line_warn "Impossible d'installer ${p}"
        fi
    done
}

install_pip() {
    section "Bibliothèques Python"
    pip install --upgrade pip -q && line_ok "pip à jour"; nl
    for pkg_name in requests beautifulsoup4 yt-dlp Pillow; do
        if pip show "$pkg_name" >/dev/null 2>&1; then
            local cur
            cur=$(pip show "$pkg_name" 2>/dev/null | grep "^Version:" | awk '{print $2}')
            local result
            result=$(pip install --upgrade "$pkg_name" -q 2>&1)
            local new
            new=$(pip show "$pkg_name" 2>/dev/null | grep "^Version:" | awk '{print $2}')
            if [ "$new" != "$cur" ]; then
                line_ok "${BOLD}${pkg_name}${RESET} ${DIM}${cur} → ${new}${RESET}"
            else
                line_ok "${BOLD}${pkg_name}${RESET} ${DIM}À jour (${cur})${RESET}"
            fi
        else
            line_info "Installation de ${BOLD}${pkg_name}${RESET}..."
            pip install "$pkg_name" -q && line_ok "${pkg_name}" || line_warn "${pkg_name} optionnel, ignoré"
        fi
    done
}

setup_storage() {
    section "Stockage Android"
    if [ ! -d "$HOME/storage" ]; then
        line_info "Ouverture de termux-setup-storage..."
        line_warn "${DIM}Une fenêtre Android va s'ouvrir — appuie sur${RESET} ${BOLD}Autoriser${RESET}"
        termux-setup-storage
        sleep 2
    fi
    if [ ! -d "$HOME/storage/downloads" ]; then
        nl
        line_err "Permission de stockage refusée ou non accordée."
        line_warn "Va dans ${BOLD}Paramètres Android → Applis → Termux → Permissions → Stockage${RESET}"
        line_warn "puis relance l'option ${BOLD}[7]${RESET} de ce menu."
        nl; pause; return
    fi
    line_ok "Stockage configuré"
    local ANIME_DIR="/storage/emulated/0/Download/anime"
    mkdir -p "$ANIME_DIR" 2>/dev/null \
        && line_ok "Dossier anime prêt ${DIM}(${ANIME_DIR})${RESET}" \
        || line_warn "Dossier non créé — vérifie les permissions Android"
}

setup_shortcuts() {
    section "Raccourcis Termux Widget"
    mkdir -p "$HOME/.shortcuts"

    cat > "$HOME/.shortcuts/CO-MENU.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
python3 ~/.local/share/CoTEAM/Co-Menu.py
EOF
    cat > "$HOME/.shortcuts/CO-CHAN-Anime.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
python3 ~/.local/share/CoTEAM/Co-Menu/Co-chan.py
EOF
    cat > "$HOME/.shortcuts/CO-SAMA-Scan.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
python3 ~/.local/share/CoTEAM/Co-Menu/Co-sama.py
EOF
    cat > "$HOME/.shortcuts/CO-TUBE-YouTube.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
python3 ~/.local/share/CoTEAM/Co-Menu/Co-tube.py
EOF
    cat > "$HOME/.shortcuts/CO-UPDATE.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
SELF="$HOME/Co-install.sh"
curl -sL "https://raw.githubusercontent.com/Bicode-dev/sh.Termux/refs/heads/main/Co-install.sh" -o "$SELF" \
    && chmod +x "$SELF" && echo "✔ Co-install.sh mis à jour" && bash "$SELF"
EOF
    cat > "$HOME/.shortcuts/RM-ANIME.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
DIR="/storage/emulated/0/Download/anime"
count=$(find "$DIR" -name "*.mp4" 2>/dev/null | wc -l)
echo "Animes trouvés : $count"
read -p "Supprimer ? (o/n) : " c
[ "$c" = "o" ] && rm -rf "$DIR"/* && echo "✔ Supprimé" || echo "Annulé"
EOF

    # Raccourci Co-flix uniquement si le fichier existe
    if [ -f "$COFLIX_PATH" ]; then
        cat > "$HOME/.shortcuts/CO-FLIX.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
python3 ~/.local/share/CoTEAM/Co-Menu/Co-flix.py
EOF
        chmod +x "$HOME/.shortcuts/CO-FLIX.sh"
        line_ok "${DIM}~/.shortcuts/CO-FLIX.sh${RESET}"
    fi

    for f in CO-MENU.sh CO-CHAN-Anime.sh CO-SAMA-Scan.sh CO-TUBE-YouTube.sh CO-UPDATE.sh RM-ANIME.sh; do
        chmod +x "$HOME/.shortcuts/$f"
        line_ok "${DIM}~/.shortcuts/${f}${RESET}"
    done
    nl; line_info "${DIM}Installe Termux:Widget sur ton écran d'accueil pour y accéder.${RESET}"
}

setup_alias() {
    section "Alias ~/.bashrc"
    nl
    echo -e "   ${C1}${BOLD}co${RESET}        ${DIM}→ lance CO-MENU${RESET}"
    echo -e "   ${C1}${BOLD}anime${RESET}     ${DIM}→ lance Co-chan${RESET}"
    echo -e "   ${C1}${BOLD}cosama${RESET}    ${DIM}→ lance Co-sama${RESET}"
    echo -e "   ${C1}${BOLD}cotube${RESET}    ${DIM}→ lance Co-tube${RESET}"
    [ -f "$COFLIX_PATH" ] && echo -e "   ${C1}${BOLD}coflix${RESET}    ${DIM}→ lance Co-flix${RESET}"
    echo -e "   ${C1}${BOLD}coupdate${RESET}  ${DIM}→ relance cet installateur${RESET}"
    echo -e "   ${C1}${BOLD}rmanime${RESET}   ${DIM}→ supprime les animes téléchargés${RESET}"
    nl
    printf "  ${C1}${BOLD}›› ${RESET}Créer / mettre à jour les alias ? ${DIM}[o]${RESET} : "
    read -r ch; [ -z "$ch" ] && ch="o"
    if [ "$ch" = "o" ] || [ "$ch" = "O" ] || [ "$ch" = "y" ]; then
        sed -i '/# ── CO-TEAM START/,/# ── CO-TEAM END/d' "$HOME/.bashrc" 2>/dev/null
        # Bloc de base
        cat >> "$HOME/.bashrc" << 'ALIASES'
# ── CO-TEAM START ──────────────────────────────────────
alias co="python3 ~/.local/share/CoTEAM/Co-Menu.py"
alias anime="python3 ~/.local/share/CoTEAM/Co-Menu/Co-chan.py"
alias cosama="python3 ~/.local/share/CoTEAM/Co-Menu/Co-sama.py"
alias cotube="python3 ~/.local/share/CoTEAM/Co-Menu/Co-tube.py"
alias coupdate="curl -sL 'https://raw.githubusercontent.com/Bicode-dev/sh.Termux/refs/heads/main/Co-install.sh' -o ~/Co-install.sh && chmod +x ~/Co-install.sh && bash ~/Co-install.sh"
alias rmanime="bash ~/.shortcuts/RM-ANIME.sh"
ALIASES
        # Alias coflix ajouté uniquement si Co-flix.py existe
        if [ -f "$COFLIX_PATH" ]; then
            echo 'alias coflix="python3 ~/.local/share/CoTEAM/Co-Menu/Co-flix.py"' >> "$HOME/.bashrc"
        fi
        echo '# ── CO-TEAM END ────────────────────────────────────────' >> "$HOME/.bashrc"
        line_ok "Alias mis à jour dans ${DIM}~/.bashrc${RESET}"
        line_warn "Tape ${BOLD}source ~/.bashrc${RESET} ou redémarre Termux"
    else
        line_info "Ignoré"
    fi
}

delete_animes() {
    section "Supprimer les animes"
    local DIR="/storage/emulated/0/Download/anime"
    if [ ! -d "$DIR" ]; then line_warn "Dossier introuvable : $DIR"; nl; pause; return; fi
    local count=$(find "$DIR" -name "*.mp4" 2>/dev/null | wc -l)
    local total_size=$(du -sh "$DIR" 2>/dev/null | cut -f1)
    nl
    echo -e "  ${C3}Dossier   : ${DIM}${DIR}${RESET}"
    echo -e "  ${C3}Vidéos    : ${BOLD}${count} fichier(s)${RESET}"
    echo -e "  ${C3}Taille    : ${BOLD}${total_size}${RESET}"
    nl
    printf "  ${C1}${BOLD}›› ${RESET}Confirmer la suppression ? ${DIM}(oui/non)${RESET} : "
    read -r cf
    if [ "$cf" = "oui" ] || [ "$cf" = "yes" ]; then
        rm -rf "$DIR"/* && line_ok "${count} fichier(s) supprimé(s)"
    else
        line_info "Annulé"
    fi
}

uninstall_all() {
    clr; banner
    section "Désinstallation complète"
    nl
    echo -e "  ${C3}Éléments ciblés :${RESET}"
    echo -e "  ${DIM}  ~/.local/share/CoTEAM/Co-Menu.py${RESET}"
    echo -e "  ${DIM}  ~/.local/share/CoTEAM/Co-Menu/${RESET}"
    echo -e "  ${DIM}  ~/.shortcuts/CO-*.sh  +  RM-ANIME.sh${RESET}"
    echo -e "  ${DIM}  Alias CO-TEAM dans ~/.bashrc${RESET}"
    nl
    printf "  ${C1}${BOLD}›› ${RESET}Confirmer ? ${DIM}(oui/non)${RESET} : "
    read -r cf
    if [ "$cf" = "oui" ] || [ "$cf" = "yes" ]; then
        rm -f "$COMENU_PATH"; rm -rf "$PY_DIR"
        rm -f "$HOME/.shortcuts/CO-MENU.sh" "$HOME/.shortcuts/CO-CHAN-Anime.sh" \
              "$HOME/.shortcuts/CO-SAMA-Scan.sh" "$HOME/.shortcuts/CO-TUBE-YouTube.sh" \
              "$HOME/.shortcuts/CO-FLIX.sh" \
              "$HOME/.shortcuts/CO-UPDATE.sh" "$HOME/.shortcuts/RM-ANIME.sh"
        sed -i '/# ── CO-TEAM START/,/# ── CO-TEAM END/d' "$HOME/.bashrc" 2>/dev/null
        nl; line_ok "Désinstallation terminée"
    else
        line_info "Annulé"
    fi
}

full_install() {
    clr; banner
    nl
    echo -e "  ${C3}${BOLD}Installation complète CO-TEAM${RESET}"
    echo -e "  ${DIM}Durée estimée : 2-5 min selon votre connexion${RESET}"
    nl; pause

    update_packages
    install_pkg
    install_pip

    section "Scripts"
    fetch_script "$URL_COMENU" "$COMENU_PATH" "Co-Menu.py"
    fetch_script "$URL_COCHAN" "$COCHAN_PATH" "Co-chan.py"
    fetch_script "$URL_COSAMA" "$COSAMA_PATH" "Co-sama.py"
    fetch_script "$URL_COTUBE" "$COTUBE_PATH" "Co-tube.py"
    _check_coflix_tor

    setup_storage
    setup_shortcuts
    setup_alias

    nl; sep_h
    echo -e "  ${C1}${BOLD}  ✔  Installation terminée !${RESET}"
    sep_h; nl
    nl; pause
}

update_all_scripts() {
    clr; banner
    section "Mise à jour de tous les scripts"
    fetch_script "$URL_COMENU" "$COMENU_PATH" "Co-Menu.py"
    fetch_script "$URL_COCHAN" "$COCHAN_PATH" "Co-chan.py"
    fetch_script "$URL_COSAMA" "$COSAMA_PATH" "Co-sama.py"
    fetch_script "$URL_COTUBE" "$COTUBE_PATH" "Co-tube.py"
    _check_coflix_tor
    nl; pause
}

# ═══════════════════════════════════════════════════════════════════════════════
#  VÉRIFICATION TERMUX
# ═══════════════════════════════════════════════════════════════════════════════
if [ ! -d "/data/data/com.termux" ]; then
    banner; nl
    line_err "Ce script est réservé à Termux (Android)."; nl; exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
#  BOUCLE PRINCIPALE
# ═══════════════════════════════════════════════════════════════════════════════
while true; do
    print_menu
    read -r choice

    case "$choice" in
        1) clr; banner; fetch_script "$URL_COMENU" "$COMENU_PATH" "Co-Menu.py";  nl; pause ;;
        2) clr; banner; fetch_script "$URL_COCHAN" "$COCHAN_PATH" "Co-chan.py";   nl; pause ;;
        3) clr; banner; fetch_script "$URL_COSAMA" "$COSAMA_PATH" "Co-sama.py";  nl; pause ;;
        4) clr; banner; fetch_script "$URL_COTUBE" "$COTUBE_PATH" "Co-tube.py";  nl; pause ;;
        5) full_install ;;
        6) update_all_scripts ;;
        7) clr; banner; setup_storage;   nl; pause ;;
        8) clr; banner; setup_shortcuts; setup_alias; nl; pause ;;
        9) clr; banner; delete_animes;   nl; pause ;;
        10) uninstall_all; nl; pause ;;
        0|q|"")
            clr; banner; nl
            echo -e "  ${C1}${BOLD}À bientôt ! ${RESET}${DIM}— CO-TEAM  ${EMOJI}${RESET}"; nl
            exit 0 ;;
        *)
            line_warn "Choix invalide (0–10)"; sleep 0.5 ;;
    esac
done