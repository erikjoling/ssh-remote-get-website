# Create bash script on the fly
# Give option if already exists
if [[ -f "$tmp_removal_script" ]]; then
	echo "$tmp_removal_script already exists. Overwrite? (y/n)"
	read answer
	if echo "$answer" | grep -iq "^y" ;then
	    echo "Proceding with overwrite"
	else
		echo "Aborting"
	    exit 1
	fi	
fi

# To make script dynamic create a scriptfile with passed argument
# Note: Chosen this solution because plink needs a scriptfile and it doesn't accept parameters
# ---------------------------------------------------------------------------------------------------

cat > "$tmp_removal_script" << EOF
#!/bin/bash"

# Check if specified directory exists
if [[ ! -d $remote_website_path ]]; then
	echo "$remote_website_path doesn't exists"
	exit 1
fi

# Check if website is WordPress
if [[ ! -f $remote_website_path/wp-config.php ]]; then
	echo "wp-config.php doesn't exists. No wordpress website."
	exit 1
fi

# Remove Database Backup
rm "$remote_website_path/$project.sql" 

# Remove File Backup
rm "$remote_website_path/$project.tar.gz"

echo "Success: Backup removed."
EOF

# ---------------------------------------------------------------------------------------------------

# Convert line-endings to unix (because executed on remote unix-machine)
dos2unix.exe "$tmp_removal_script"