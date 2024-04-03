#!/bin/bash

# Enter the API Username, API Password and JSS URL here
apiuser="apiuser" # create a user for read only (Active Directory or local on Jamf Server)
apipass="apipass" # password for the api-read-only
jssURL="https://jssURL.jamfcloud.com:443"

# Get computer's Mac Address so that the API can find the correct computer in the JSS database
macAddress=`networksetup -getmacaddress en0 | awk '{print $3}' | sed 's/:/./g'`

# Pull the current Asset Tag from JSS API
assetTag=$( curl -s -k -u $apiuser:$apipass -H "Content-Type: application/xml" "${jssURL}/JSSResource/computers/macaddress/${macAddress}" | awk -F'<asset_tag>|</asset_tag>' '{print $2}' )

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
