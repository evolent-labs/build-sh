#!/bin/bash

readonly RESOURCES_FOLDER="resources/"

cd "$RESOURCES_FOLDER" || { echo "Error: Failed to access '$RESOURCES_FOLDER'."; exit 1; }

find . -type d -name "node_modules" -prune -o -type f -name "package.json" -print0 | while IFS= read -r -d '' package_file; do
    parent_folder="$(dirname "$package_file")"

    pushd "$parent_folder" > /dev/null || { echo "Error: Failed to access '$parent_folder'."; continue; }

    if [ ! -d "node_modules/" ]; then
        echo "Running 'pnpm install' in '$parent_folder'..."
        if ! pnpm i; then
            echo "Error: 'pnpm install' failed in '$parent_folder'."
            popd > /dev/null
            continue
        fi
    fi

    echo "Running 'pnpm run build' in '$parent_folder'..."
    if ! pnpm run build; then
        echo "Error: 'pnpm run build' failed in '$parent_folder'."
        popd > /dev/null
        continue
    fi

    popd > /dev/null
done

chmod +x "$0"