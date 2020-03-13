#!/bin/bash

# Creates a payload file with certain number of hosts for migration analytics consumption
# ./keating.sh -h 50 will create keating.json with 50 hosts in it

# Uncomment for debugging.
#set -x

die () {
    echo >&2 "$@"
    exit 1
}

prepare_payload () {
    echo "preparing keating.json file to build a payload"
    echo "{" > keating.json
}

add_provider () {
    echo "adding mastertemplate.json to keating.json"
    cat mastertemplate.json >> keating.json
}


add_host () {
i=0
    while [[ $i -lt $TOTALHOSTS ]]; do 
	    random=$((1 + RANDOM % 4))
	    a="${i}1"
	    b="${i}2"
	    c="${i}3"
	    d="${i}4"
	    e="${i}5"
	    f="${i}6"
	    g="${i}7"
	    h="${i}8"
	    j="${i}9"
        # In place counter vor Hosts
	    echo -ne "creating host ${i}"\\r
	    sed -e "s/IDENTIFIER/$i/" \
	        -e "s/SHORTNAME/host-$i/"  \
	        -e "s/VMID1/$a/" \
	        -e "s/VMNAME1/analytics-$a/" \
	        -e "s/VMEMS1/vm-$a/" \
	        -e "s/VMID2/$b/" \
	        -e "s/VMNAME2/nyc-$random-$b/" \
	        -e "s/VMEMS2/vm-$b/" \
	        -e "s/VMID3/$c/" \
	        -e "s/VMNAME3/bos--$c/" \
	        -e "s/VMEMS3/vm-$c/" \
	        -e "s/VMID4/$d/" \
	        -e "s/VMNAME4/bos-$random-$d/" \
	        -e "s/VMEMS4/vm-$d/" \
	        -e "s/VMID5/$e/" \
	        -e "s/VMNAME5/den-$e/" \
	        -e "s/VMEMS5/vm-$e/" \
	        -e "s/VMID6/$f/" \
	        -e "s/VMNAME6/web-$f/" \
	        -e "s/VMEMS6/vm-$f/" \
	        -e "s/VMID7/$g/" \
	        -e "s/VMNAME7/proto-$g/" \
	        -e "s/VMEMS7/vm-$g/" \
	        -e "s/VMID8/$h/" \
	        -e "s/VMNAME8/webapp-$random-$h/" \
	        -e "s/VMEMS8/vm-$h/" \
	        -e "s/VMID9/$j/" \
	        -e "s/VMNAME9/infra-$j/" \
	        -e "s/VMEMS9/vm-$j/" \
            -e "s/FQDN/host-$i.example.com/g" hosttemplate${random}.json >> keating.json
	    i=$[$i+1]
    done
    # Adding new line to on-screen counter.
    echo
}

close_host_list () {
    echo "completing host and vm list format"
    echo " ]" >> keating.json
    echo " }" >> keating.json
    echo "removing last comma hack"
    #remove comma from the last host instance (cheap and fast method - and unexplainable :)
    sed -i '$x;$G;/\(.*\),/!H;//!{$!d};  $!x;$s//\1/;s/^\n//' keating.json
}

close_provider_list () {
    echo "}"  >> keating.json
}

edit_cpu_data () {
    echo "editing cpu data"
	sed -i -e 's/"cpu_total_cores": 4,/"cpu_total_cores": '"$CPUCOUNT"',/g' keating.json
}


#Run parts:
#exit if no arguemts are given
if (( $# < 1 )); then
	die "./keating.sh -h #Number_of_Hosts [-c #Number_of_CPUs]"
else
    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
    key="$1"

    case $key in
        -h|--hosts|--hypervisors)
        TOTALHOSTS="$2"
        shift # past argument
        shift # past value
        ;;
        -p|--providers)
        TOTALPROVIDERS="$2"
        shift # past argument
        shift # past value
        ;;
        -c|--cpu)
        CPUCOUNT="$2"
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
        esac
    done
    set -- "${POSITIONAL[@]}" # restore positional parameters
fi
prepare_payload
add_provider
add_host 
close_host_list
close_provider_list

if (( $# > 1 )); then
    edit_cpu_data
fi

echo "compressing"
tar -zcvf keating-payload-$(date '+%Y%m%d_%H%M')-$TOTALHOSTS.tar.gz keating.json
rm -f keating.json
