#!/bin/sh
set -e

MODE="${MODE:-compress}"
INPUT_FILE="${INPUT_FILE:-/data/sqlite.db}"
OUTPUT_FILE="${OUTPUT_FILE:-}"
ZSTD_LEVEL="${ZSTD_LEVEL:-9}"

# ── Helpers ───────────────────────────────────────────────────────────────────
BOLD="\033[1m"
DIM="\033[2m"
GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"
RESET="\033[0m"

step() {
    printf "${CYAN}${BOLD}  →${RESET} ${BOLD}$1${RESET}\n"
}

info() {
    printf "${DIM}    $1${RESET}\n"
}

done_msg() {
    printf "${GREEN}${BOLD}  ✓${RESET} $1\n"
}

elapsed() {
    END=$(date +%s)
    SECS=$((END - START))
    if [ $SECS -lt 60 ]; then
        printf "%ds" $SECS
    else
        printf "%dm %ds" $((SECS / 60)) $((SECS % 60))
    fi
}

START=$(date +%s)

# ── Compress ──────────────────────────────────────────────────────────────────
if [ "$MODE" = "compress" ]; then
    : "${OUTPUT_FILE:=/data/output.sql.zst}"

    if [ ! -f "$INPUT_FILE" ]; then
        printf "\033[31m${BOLD}  ✗ ERROR:${RESET} Input file '$INPUT_FILE' not found.\n"
        exit 1
    fi

    printf "\n${BOLD}  SQLite Backup - Compress${RESET}\n"
    printf "${DIM}  ────────────────────────────────────${RESET}\n"
    info "Source:      $INPUT_FILE"
    info "Destination: $OUTPUT_FILE"
    info "zstd level:  $ZSTD_LEVEL"
    printf "\n"

    ORIGINAL_SIZE=$(du -sh "$INPUT_FILE" | cut -f1)
    step "Dumping schema and rows to SQL..."
    info "Input size: $ORIGINAL_SIZE"

    sqlite3 "$INPUT_FILE" .dump | zstd -"$ZSTD_LEVEL" -q -o "$OUTPUT_FILE" --force

    COMPRESSED_SIZE=$(du -sh "$OUTPUT_FILE" | cut -f1)
    done_msg "Compressed: ${ORIGINAL_SIZE} → ${BOLD}${COMPRESSED_SIZE}${RESET}"

    printf "\n${DIM}  ────────────────────────────────────${RESET}\n"
    printf "${GREEN}${BOLD}  Done!${RESET} $(elapsed) - output: ${BOLD}$OUTPUT_FILE${RESET}\n\n"

# ── Decompress ────────────────────────────────────────────────────────────────
elif [ "$MODE" = "decompress" ]; then
    : "${OUTPUT_FILE:=/data/restored.db}"

    if [ ! -f "$INPUT_FILE" ]; then
        printf "\033[31m${BOLD}  ✗ ERROR:${RESET} Input file '$INPUT_FILE' not found.\n"
        exit 1
    fi

    printf "\n${BOLD}  SQLite Backup - Decompress${RESET}\n"
    printf "${DIM}  ────────────────────────────────────${RESET}\n"
    info "Source:      $INPUT_FILE"
    info "Destination: $OUTPUT_FILE"
    printf "\n"

    COMPRESSED_SIZE=$(du -sh "$INPUT_FILE" | cut -f1)
    step "Decompressing archive..."
    info "Compressed size: $COMPRESSED_SIZE"

    TEMP_SQL=$(mktemp /tmp/dump_XXXXXX.sql)
    zstd -d "$INPUT_FILE" -o "$TEMP_SQL" --force

    step "Importing SQL into SQLite..."
    rm -f "$OUTPUT_FILE"
    sqlite3 "$OUTPUT_FILE" < "$TEMP_SQL"
    rm -f "$TEMP_SQL"

    RESTORED_SIZE=$(du -sh "$OUTPUT_FILE" | cut -f1)
    done_msg "Restored: ${COMPRESSED_SIZE} → ${BOLD}${RESTORED_SIZE}${RESET}"

    printf "\n${DIM}  ────────────────────────────────────${RESET}\n"
    printf "${GREEN}${BOLD}  Done!${RESET} $(elapsed) - output: ${BOLD}$OUTPUT_FILE${RESET}\n\n"

# ── Unknown ───────────────────────────────────────────────────────────────────
else
    printf "\033[31m${BOLD}  ✗ ERROR:${RESET} Unknown MODE '$MODE'. Use 'compress' or 'decompress'.\n"
    exit 1
fi