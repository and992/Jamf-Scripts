#!/bin/bash

#Dont work anymore, Legacy script.

# Enter the API Username, API Password and JSS URL here
apiuser="apiuser"
apipass="apipass"
jssURL="https://jssURL.jamfcloud.com:443"

# Generate API Token
token=$(curl -sku $apiuser:$apipass -X POST "$jssURL/api/v1/auth/token" | awk -F'"' '/token/{print $4}')

# Get computer's Mac Address so that the API can find the correct computer in the JSS database
macAddress=$(networksetup -getmacaddress en0 | awk '{print $3}' | sed 's/:/./g')

# Pull the current Asset Tag from JSS API using the Token
assetTag=$(curl -s -k -H "Authorization: Bearer $token" -H "Accept: application/json" "${jssURL}/JSSResource/computers/macaddress/${macAddress}" | awk -F'<asset_tag>|</asset_tag>' '{print $2}')

echo "$assetTag"

# Set the ComputerName, HostName, and LocalHostName to the Asset Tag
scutil --set ComputerName "$assetTag"
scutil --set HostName "$assetTag"
scutil --set LocalHostName "$assetTag"

# Trigger an update inventory policy
dscacheutil -flushcache
/usr/local/jamf/bin/jamf policy -trigger update-inventory

# Optional: Revoke the token if it's a one-time script
curl -sku $apiuser:$apipass -X POST "$jssURL/api/v1/auth/invalidate-token" -H "Authorization: Bearer $token"

exit 0
