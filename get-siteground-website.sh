#!/bin/bash  
#
# Title:
# Get the files and database of a WordPress website on a Siteground server. 
#
# Description:
# Creates a temporary filebackup and mysqldump of a WordPress website, then downloads it and 
# finally removes it from the server.
#
# Usage:
# [Windows/PowerShell] sh ./create_remote_backup.sh <host-account> <website>
#
# Notes:
# - Generates a temporary bash-script for creating backup and removing backup (removed afterwards)
# - Expects a website to live in `/home/<host-account>/public_html/<website>/`
# - Filebackup will be stored as `/home/<host-account>/public_html/<website>/<website>.tar.gz`
# - Databasebackup will be stored as `/home/<host-account>/public_html/<website>/<website>.sql`
# - Expects Serveraccounts to be titled `SSH - <serveraccount>` in KeePass
# 
# Dependancies:
# - plink.exe (from PuTTY creators). Add it to Path Variable
# - pscp.exe (from PuTTY creators). Add it to Path Variable
# - KeePass 
# - KeeScript (KeePass plugin) to get SSH url from KeePass based on <serveraccount>
# - KeeAgent (KeePass plugin) as a way to manage private keys for smooth experience

# Exit if missing argument 1
if [[ -z "$1" ]]; then
	echo "Missing argument 1: serveraccount"
	exit 1
fi

# Exit if missing argument 2
if [[ -z "$2" ]]; then
	echo "Missing argument 2: project"
	exit 1
fi

# Parameter 1 is the serveraccount
serveraccount="$1"

# Parameter 2 is the project 
project="$2"

# Remote website path
remote_website_path="/home/$serveraccount/public_html/$project"

# Load necessary SSH data from keepass
source "./get_ssh_data_from_keepass.sh"

# Generate names for scripts 
tmp_creation_script="tmp_create_${project}_backup.sh" # temporary backup-creation-script
tmp_removal_script="tmp_create_${project}_backup_removal.sh" # temporary backup-removal-script

# Create temporary scripts 
source "./create_script_remote_backup.sh" # Create temporary backup-creation-script
source "./create_script_remote_backup_removal.sh" # Creat temporary backup-removal-script

# Run script on server
plink -ssh $serveraccount@$server -P $port -m "$tmp_creation_script"

# Download the file- and databasebackup of a WordPress website on a Siteground server. 
# pscp -P $port $serveraccount@$server:$remote_website_path/$project.sql "./backups/" # Not necessary to download, because its already included in tar
pscp -P $port $serveraccount@$server:$remote_website_path/$project.tar.gz "./backups/"

# Remove the file- and databasebackup of a WordPress website on a Siteground server. 
plink -ssh $serveraccount@$server -P $port -m "$tmp_removal_script"

# Remove created scripts
rm "$tmp_creation_script"
rm "$tmp_removal_script"
