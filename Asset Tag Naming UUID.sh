#!/bin/bash

# Enter the API Username, API Password and JSS URL here
apiuser="apiuser" # create a user for read only (Active Directory or local on Jamf Server)
apipass="apipass" # password for the api-read-only
jssURL="https://jssURL.jamfcloud.com:443"

# Get the Mac's UUID string
UUID=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/{print $4}')

# Make first a "Inventory Preload" with Asset Tag (Settings > Global Management)
# Pull the Asset Tag by accessing the computer records "general" subsection
Asset_Tag=$(curl -H "Accept: text/xml" -sfku "${apiuser}:${apipass}" "${jssURL}/JSSResource/computers/udid/${UUID}/subset/general" | xmllint --format - 2>/dev/null | awk -F'>|<' '/<asset_tag>/{print $3}')

echo "$Asset_Tag"

scutil --set ComputerName "$Asset_Tag"
scutil --set HostName "$Asset_Tag"
scutil --set LocalHostName "$Asset_Tag"

# Make first a policy with a trigger for update-inventory
# Computers > Policies > General > General (Display Name: Update Inventory)
# Computers > Policies > General > Trigger (Custom Event: update-inventory)
# Computers > Policies > Maintenance > Update inventory

dscacheutil -flushcache

/usr/local/jamf/bin/jamf policy -trigger update-inventory

exit 0
