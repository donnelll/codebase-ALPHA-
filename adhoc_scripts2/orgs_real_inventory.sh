#!/bin/bash

invpageurl="https://ansibledev.autotrader.com/api/v2/inventories/?order_by=organization"

# invpageurl="https://ansibledev.autotrader.com/api/v2/inventories/?order_by=organization&page_size=1"

invpage="one"

# Loop on inventories pages. We need a loop due to pagination.

while [ ! -z "$invpage" ]
do

inventorypage=`curl -k -s --user admin:20tbcv0K -X GET -H "Content-Type:application/json" "$invpageurl"`

# Loop on inventories in inventory page
for i in `echo $inventorypage | jq '.results[]| .id'` ; do


	# skip smart inventories

        kind=`curl -k -s --user admin:20tbcv0K -X GET -H "Content-Type:application/json" "https://ansibledev.autotrader.com/api/v2/inventories/$i/" | jq -r '.kind'`
	#  echo "kind " $kind

        if [ "$kind" != "smart" ]; then

	# Print Inventory header
	 echo "inventory id " $i `curl -k -s --user admin:20tbcv0K -X GET -H "Content-Type:application/json" "https://ansibledev.autotrader.com/api/v2/inventories/$i/" | jq -r '.name,"organization id",.organization'`

	 # Loop through hosts records. We need a loop due to pagination.

	url="https://ansibledev.autotrader.com/api/v2/inventories/$i/hosts/"
        page="one"

        while [ ! -z "$page" ]
        do

         jqOutput=`curl -k -s --user admin:20tbcv0K -X GET -H "Content-Type:application/json" "$url"`


               # Print hosts for the inventory
                hosts=`echo $jqOutput| jq -r '.results[] | .name'`
                printf "%s\n" "$hosts"

                page=`echo $jqOutput|jq -r '.next'`
                # echo "page " $page
                url=https://ansibledev.autotrader.com$page
                # echo "URL "$url

        done
fi

done

invpage=`echo $inventorypage|jq -r '.next'`
# echo $invpage

invpageurl=https://ansibledev.autotrader.com$invpage

done
