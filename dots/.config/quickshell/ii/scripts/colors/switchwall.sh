#!/bin/bash
# Wallpaper switcher script (Pywal-compatible)
# Called by Quickshell with: --image <path> [--mode dark|light] [--noswitch]

while [[ $# -gt 0 ]]; do
    case "$1" in
        --image)
            IMAGE="$2"
            shift 2
            ;;
        --mode)
            MODE="$2"
            shift 2
            ;;
        --noswitch)
            NOSWITCH=1
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [[ -n "$IMAGE" && -f "$IMAGE" ]]; then
    wal -i "$IMAGE" -q
elif [[ -n "$MODE" ]]; then
    wal --theme "$MODE" -q
else
    wal -R -q
fi
