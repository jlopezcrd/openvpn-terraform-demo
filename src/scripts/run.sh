#!/bin/bash

service=${1:-'account-services'}

run()
{
    PS3="Select the action to run: "
    items=("tfplan $service" "tfapply $service" "tfdestroy $service")

    while true; do
        select item in "${items[@]}" Quit
        do
            case $REPLY in
                1) doTerraform $service plan; break;;
                2) doTerraform; break;;
                3) doTerraform; break;;
                $((${#items[@]}+1))) echo "Exiting..."; break 2;;
                *) echo "Invalid option $REPLY"; break;
            esac
        done
    done
}

doTerraform()
{
    terraform -chdir=${1} ${2}
}

echo "==========="
echo "STARTING..."
echo "==========="
echo ""

run