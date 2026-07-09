#!/bin/bash
QS_DIR="/run/user/$(id -u)/quickshell"

# Remove by-id dirs not referenced by any live PID
for pid_link in "$QS_DIR/by-pid"/*; do
    [ -L "$pid_link" ] || continue
    pid=$(basename "$pid_link")
    target=$(readlink "$pid_link")
    # Remove symlink if PID is dead
    if ! kill -0 "$pid" 2>/dev/null; then
        rm -f "$pid_link"
        # Remove target dir if it exists and no other symlinks point to it
        if [ -n "$target" ] && [ -d "$target" ]; then
            if ! find "$QS_DIR/by-pid" -type l -lname "$target" 2>/dev/null | grep -q .; then
                rm -rf "$target"
            fi
        fi
    fi
done

# Remove orphan by-id dirs (no pid symlink points to them)
for id_dir in "$QS_DIR/by-id"/*/; do
    [ -d "$id_dir" ] || continue
    id_dir=$(realpath "$id_dir")
    if ! find "$QS_DIR/by-pid" -type l -lname "$id_dir" 2>/dev/null | grep -q .; then
        rm -rf "$id_dir"
    fi
done
