# Get necessary SSH data from keepass based on serveraccount: url and port
source "./keepass_db.sh"

echo " * Trying to find KeePass entry: SSH - $serveraccount"
ssh_url=$(KPScript -c:GetEntryString "$keepass_db" -guikeyprompt -Field:URL -ref-Title:"SSH - $serveraccount" -Spr | head -1)
echo " * Response: $ssh_url"

# Check for error
if [[ "$ssh_url" == "E: "* || "$ssh_url" == "OK: "* ]]; then
	echo " * Probably wrong KeePass password"
	exit 1
fi

echo " * username: $serveraccount"

# Extract server from SSH url command
server="$ssh_url"
server="${server##*//}" # Remove all before //
server="${server%% *}"   # remove trailing whitespace characters

echo " * server: $server"

# Extract port from SSH url command
port="$ssh_url"
port="${port##*-P }" # Remove all before //
port="${port%% *}"   # remove trailing whitespace characters

echo " * port: $port"