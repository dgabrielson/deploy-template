#!/bin/bash

virsh="/usr/bin/virsh"
tr="/usr/bin/tr"
cut="/usr/bin/cut"
cp="/bin/cp"
rm="/bin/rm"
grep="/bin/grep"

# Backup KVM qemu2 disk images.

function vm-backup()
{
    # name of the virtual machine
    local vm_name=$1
    # directory for backups, end in /
    local backup_dst=$2
    
    $virsh dumpxml "${vm_name}" > "${backup_dst}${vm_name}.xml"
    while read -r devname diskfile ; do
        # for each qcow disk associated with this vm
        if [[ -f "${diskfile}" && (${diskfile} != *.iso) ]]; then
            echo -e "${vm_name}:${diskfile}"
            local state="$(sudo virsh dominfo ${vm_name} | $grep State | $cut -f 2 -d :)"
            #echo -e "state: ${state}"
            local backup_disk="${backup_dst}$(basename "${diskfile}")"
            #echo -e "backup_disk: ${backup_disk}"
            if [ "${state}" == "running" ]; then
                # create overlay disk for changes
                local snapshot="${diskfile}-snapshot"
                #echo -e "snapshot: ${snapshot}"
                #echo -n -e "\t"
                $virsh -q snapshot-create-as --domain "${vm_name}" "backup" \
                    --diskspec ${devname},file="${snapshot}" \
                    --no-metadata --disk-only --atomic > /dev/null 
                if [ $? = 0 ]; then
                    # copy original disk to backup
                    $cp -a "${diskfile}" "${backup_disk}"
                    # pivot back to original disk(s)
                    #   NB: all disks get snapshotted, but we only deal with 
                    #       one at a time.
                    while read -r subdevname subdiskfile ; do
                        $virsh -q blockcommit "${vm_name}" ${subdevname} \
                            --active --pivot > /dev/null 
                        if [ $? = 0 ]; then
                            if [ -f "${subdiskfile}" ]; then
                                $rm -f "${subdiskfile}"
                            fi
                        else
                            echo -e "WARNING: blockcommit failed; keeping snapshot: ${subdiskfile}" 
                        fi
                    done < <($virsh -q domblklist "${vm_name}")
                    #echo -e "Backup -> \"${backup_disk}\""
                else
                    echo "FAILED backup for ${vm_name}:${devname}:${diskfile}"
                fi
            else
                # state is NOT running
                $cp -a "${diskfile}" "${backup_disk}"
            fi
        fi
    done < <($virsh -q domblklist "${vm_name}")
}


function list-all-vms()
{
    $virsh -q list --all | $tr -s ' ' | $cut -f 3 -d ' ' 
}


function backup-all-vms()
{
    # directory for backups, end in /
    local backup_dst=$1
    
    while read -r vm_name ; do
        if [[ -n "${vm_name}" ]]; then
            vm-backup ${vm_name} "${backup_dst}"
        fi
    done < <(list-all-vms)
}


function main()
{
    local dst=$1
    
    if [[ -z "${dst}" ]]; then
        echo "You must supply a backup destination (end with /)."
        exit 1
    fi
    backup-all-vms "${dst}"
}


main "$@"