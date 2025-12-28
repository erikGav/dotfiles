#!/bin/bash

set -e

CURRENT_KERNEL=$(uname -r)
echo "Currently running kernel: $CURRENT_KERNEL"
echo

echo "Finding installed kernel versions..."
KERNEL_PACKAGES=$(dpkg --list | grep -E 'linux-image-[0-9]+' | awk '{print $2}')

# Extract versions (e.g., linux-image-6.11.26-generic -> 6.11.26-generic)
INSTALLED_KERNELS=$(echo "$KERNEL_PACKAGES" | sed 's/linux-image-//')

TO_DELETE=()

echo "Checking for old kernels to remove..."
for VERSION in $INSTALLED_KERNELS; do
    if [[ "$VERSION" != "$CURRENT_KERNEL" ]]; then
        echo -e "\nFound unused kernel: $VERSION"
        read -p "Do you want to remove kernel $VERSION? [y/N]: " yn
        case "$yn" in
            [Yy]*) TO_DELETE+=("$VERSION") ;;
            *) echo "Skipping $VERSION" ;;
        esac
    fi
done

if [ ${#TO_DELETE[@]} -eq 0 ]; then
    echo -e "\nNo kernels selected for removal. Exiting."
    exit 0
fi

echo -e "\nRemoving selected kernels:"
for VERSION in "${TO_DELETE[@]}"; do
    echo "Purging linux-image-$VERSION and linux-headers-$VERSION..."
    sudo apt remove --purge -y "linux-image-$VERSION" "linux-headers-$VERSION" || echo "Warning: failed to remove $VERSION"
done

echo -e "\nRunning autoremove and updating GRUB..."
sudo apt autoremove --purge -y
sudo update-grub

echo -e "\nDone."

