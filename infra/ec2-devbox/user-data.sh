#!/bin/bash
# devbox first-boot prep. Deliberately minimal and secret-free — user-data is
# readable from instance metadata, so no tokens ever go in here. The real
# provisioning is push-based (`devbox provision` over SSH with agent forwarding).
#
# Job: make the persistent work volume real and mounted, and make sure a tmux
# server can survive without a login session.
set -euxo pipefail
exec > >(tee -a /var/log/devbox-user-data.log) 2>&1

USERNAME="${username}"

apt-get update -y
apt-get install -y git curl ca-certificates

# ── Find the work volume. On Nitro instances EBS shows up as /dev/nvme*n1, NOT the
# /dev/sdf we asked for, and the attachment can land slightly after first boot —
# so wait for a disk that has no partitions and isn't the root disk.
WORK_DEV=""
for _ in $(seq 1 60); do
  ROOT_DISK=$(lsblk -no PKNAME "$(findmnt -no SOURCE /)" 2>/dev/null || true)
  for d in /dev/nvme*n1; do
    [ -b "$d" ] || continue
    [ "$(basename "$d")" = "$ROOT_DISK" ] && continue
    # skip anything already carrying a mounted filesystem
    if ! lsblk -no MOUNTPOINT "$d" | grep -q .; then WORK_DEV="$d"; break; fi
  done
  [ -n "$WORK_DEV" ] && break
  sleep 5
done

if [ -z "$WORK_DEV" ]; then
  echo "FATAL: work volume never appeared" >&2
  exit 1
fi

# Format ONLY if blank. On a restart (or a rebuilt instance re-attaching the same
# volume) this is already ext4 and we must not touch it.
if ! blkid "$WORK_DEV" >/dev/null 2>&1; then
  mkfs.ext4 -L devbox-work "$WORK_DEV"
fi

mkdir -p /data
UUID=$(blkid -s UUID -o value "$WORK_DEV")
# nofail: never let a missing volume wedge the boot into emergency mode
grep -q "$UUID" /etc/fstab || echo "UUID=$UUID /data ext4 defaults,nofail 0 2" >> /etc/fstab
mount -a

mkdir -p /data/work
chown -R "$USERNAME:$USERNAME" /data

# ~/work lives on the persistent volume; everything else is disposable.
sudo -u "$USERNAME" bash -c '[ -e "$HOME/work" ] || ln -s /data/work "$HOME/work"'

# Let the tmux server (and the fleet sessions) keep running with nobody logged in.
loginctl enable-linger "$USERNAME" || true

touch /var/lib/devbox-user-data-done
echo "user-data complete"
