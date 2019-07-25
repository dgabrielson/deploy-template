#!/usr/bin/env bash
set -e
shopt -s nullglob

grep="/bin/grep"
ln="/bin/ln"
mkdir="/bin/mkdir"
mount="/bin/mount"
mv="/bin/mv"
pwd="/bin/pwd"
rm="/bin/rm"
rsync="/usr/bin/rsync"
umount="/bin/umount"



# The target should be a sparse disk image file
# Create with (e.g.):
# sudo dd of=/var/local/backup/math/files.img seek=10G bs=1 count=0
# sudo mkfs.ext4 -m 0 /var/local/backup/math/files.img
# Resize is like create with a larger seek value; followed by resize2fs <file>

# Future enhancements:
#   - handle dst directory vs dst file
#   - if dst ends with .img and does not exit; create
#   - remove time from this script
#   - remove src from this script


function err_report() {
    echo "ABORT: problem on line $1"
}

trap 'err_report $LINENO' ERR


function prune_backups()
{
    declare -a all_backups=($(for each in ????-??-??-??????; do echo $each; done | /usr/bin/sort -r))
    declare -a monthly=($(for each in ????-??-01-??????; do echo $each; done | /usr/bin/sort -r))

    declare -a all_keep=${all_backups[@]::30}
    declare -a monthly_keep=${monthly[@]::13}

    for backup in ${all_keep[@]}; do
        #echo "Keep ${backup}"
        all_backups=( ${all_backups[@]/${backup}/} )
    done
    for backup in ${monthly_keep[@]}; do
        #echo "Keep ${backup}"
        all_backups=( ${all_backups[@]/${backup}/} )
    done
    for backup in ${all_backups[@]}; do
        echo "Removing old backup ${backup}"
        $rm -rf "${backup}"
    done
}


function do_backup()
{
    local src=$1
    local dst=$2
    local date_name=$(/bin/date +"%Y-%m-%d-%H%M%S")
    local backup_cmd="false"
    cd "${dst}"
    $mkdir "${date_name}"

    if [[ -e "latest" ]]; then
        if ! $rsync -a  --numeric-ids --link-dest="$($pwd)/latest" "${src}" "${date_name}"; then
            echo "WARNING: regular backup errors: ${date_name}"
        fi
    else
        #$mkdir _new
        if ! $rsync -a --numeric-ids "${src}" "${date_name}"; then
            echo "WARNING: first backup errors: ${date_name}"
        fi
    fi
    $ln -snf "${date_name}" latest
    prune_backups
    cd - > /dev/null
}


function main()
{
    local src=$1
    local dst=$2
    local dst_mount="/mnt/_backup"

    if [[ -z "${src}" ]]; then
        echo "ERROR: You must supply a backup source (end with /)."
        exit 1
    fi
    if [[ -z "${dst}" ]]; then
        echo "ERROR: You must supply a backup destination image."
        exit 1
    fi
    if [[ ! -f "${dst}" ]]; then
        echo "ERROR: Destination image does not exist"
        exit 2
    fi
    if [[ ! -d "${dst_mount}" ]]; then
        ${mkdir} ${dst_mount}
    fi
    if $mount | $grep -q "${dst_mount}"; then
        echo "WARNING: backup image already mounted; trying unmount..."
        $unmount "${dst_mount}"
    fi
    $mount -o loop "${dst}" "${dst_mount}"
    do_backup "${src}" "${dst_mount}"
    $umount "${dst_mount}"
}


main "/storage/" "$1"
