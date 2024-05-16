#!/bin/bash

# Variables
apiuser="apiuser"
apipass="apipass"
jssURL="https://jssURL.jamfcloud.com:443"

# Get the authentication token
token=$(curl -sku $apiuser:$apipass -X POST "$jssURL/api/v1/auth/token" | awk -F'"' '/token/{print $4}')

# Get the UUID of the computer
UUID=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/{print $4}')

# Fetch the XML response from Jamf Pro API
response=$(curl -s -H "Accept: text/xml" -H "Authorization: Bearer $token" "${jssURL}/JSSResource/computers/udid/${UUID}/subset/general")

# Parse the XML response to extract the asset_tag value
asset_tag=$(echo "$response" | xmllint --xpath 'string(//computer/general/asset_tag)' -)

# Check if asset_tag is not empty
if [ -n "$asset_tag" ]; then
  # Set the computer name, host name, and local host name
  scutil --set ComputerName "$asset_tag"
  scutil --set HostName "$asset_tag"
  scutil --set LocalHostName "$asset_tag"
  
  echo "Asset Tag: $asset_tag"
  echo "ComputerName, HostName, and LocalHostName have been set to $asset_tag"
  
  # Flush the DNS cache
  dscacheutil -flushcache
  
  # Trigger Jamf policy to update inventory
  /usr/local/jamf/bin/jamf policy -trigger update-inventory
else
  echo "Asset Tag not found in the response."
fi

# Exit the script
exit 0
