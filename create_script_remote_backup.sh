# Create bash script on the fly
# Give option if already exists
if [[ -f "$tmp_creation_script" ]]; then
	echo "$tmp_creation_script already exists. Overwrite? (y/n)"
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

cat > "$tmp_creation_script" << EOF
#!/bin/bash"

# Check if specified directory exists
if [[ ! -d $remote_website_path ]]; then
	echo "$remote_website_path doesn't exists"
	exit 1
fi

# Go to project
cd $remote_website_path

# Check if directory is Wordpress
if [[ ! -f wp-config.php ]]; then
	echo "wp-config.php doesn't exists. No wordpress website."
	exit 1
fi

# Backup wordpress database as <project>.sql
wp db export "$remote_website_path/$project.sql" 

# Backup wordpress files including website
tar -czf "$remote_website_path/$project.tar.gz" * --exclude="*.tar" --exclude="*.tar.gz" --exclude="cgi-bin" --exclude="*.log" 

echo "Success: Website exported to '$remote_website_path/$project.tar.gz'."
EOF

# ---------------------------------------------------------------------------------------------------

# Convert line-endings to unix (because executed on remote unix-machine)
dos2unix.exe "$tmp_creation_script"