az storage blob upload     --container-name vhds     --file ./be.vhd     --name OpenBSD-be.vhd     --account-name ideasyncraticstorage     --account-key XXX
# then create a "vm image" from the blob
--

# v6 load balancing VMs have to be made via CLI 
# Open powershell-type cloud shell via web interface
# https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-ipv6-internet-cli
#

$subscriptionid = "4706567a-599b-4483-aee4-41926752f05b"  # enter subscription id
$location = "westus2"
$rgname = "ideasyncratic"
$vnetName = "ideasyncratic-vnet"
$vnetPrefix = "10.0.0.0/24"
$subnet1Name = "default"
$subnet1Prefix = "10.0.0.0/24"
$dnsLabel = "be-ideasyncratic"
$lbName = "beIPv4IPv6Lb"


# set subscription for session
az account set --subscription $subscriptionid

# create lb
$lb = az network lb create --resource-group $rgname --location $location --name $lbName

# create public IP
$publicIpv4Name = "beIPv4Vip"
$publicIpv6Name = "beIPv6Vip"
$publicipV4 = az network public-ip create --resource-group $rgname --name $publicIpv4Name --location $location --version IPv4 --allocation-method Dynamic --dns-name $dnsLabel
$publicipV6 = az network public-ip create --resource-group $rgname --name $publicIpv6Name --location $location --version IPv6 --allocation-method Dynamic --dns-name $dnsLabel


# setup lb frontend/backend ip pools
$frontendV4Name = "BeFrontendVipIPv4"
$frontendV6Name = "BeFrontendVipIPv6"
$backendAddressPoolV4Name = "BeBackendPoolIPv4"
$backendAddressPoolV6Name = "BeBackendPoolIPv6"
$frontendV4 = az network lb frontend-ip create --resource-group $rgname --name $frontendV4Name --public-ip-address $publicIpv4Name --lb-name $lbName
$frontendV6 = az network lb frontend-ip create --resource-group $rgname --name $frontendV6Name --public-ip-address $publicIpv6Name --lb-name $lbName
$backendAddressPoolV4 = az network lb address-pool create --resource-group $rgname --name $backendAddressPoolV4Name --lb-name $lbName
$backendAddressPoolV6 = az network lb address-pool create --resource-group $rgname --name $backendAddressPoolV6Name --lb-name $lbName

# NAT and probe rules
$probeV4V6 = az network lb probe create --resource-group $rgname `
               --name BeProbeForIPv4AndIPv6 --protocol tcp --port 22 `
               --interval 15 --threshold 2 --lb-name $lbName
## v4 ports
az network lb rule create --resource-group $rgname `
                --name LBRuleForIPv4-Port22 --frontend-ip-name $frontendV4Name --backend-pool-name $backendAddressPoolV4Name `
                --probe-name BeProbeFordIPv4AndIPv6 --protocol Tcp --frontend-port 22 --backend-port 22 --lb-name $lbName
az network lb rule create --resource-group $rgname `
                --name LBRuleForIPv4-Port25 --frontend-ip-name $frontendV4Name --backend-pool-name $backendAddressPoolV4Name `
                --probe-name BeProbeForIPv4AndIPv6 --protocol Tcp --frontend-port 25 --backend-port 25 --lb-name $lbName
az network lb rule create --resource-group $rgname `
                --name LBRuleForIPv4-Port80 --frontend-ip-name $frontendV4Name --backend-pool-name $backendAddressPoolV4Name `
                --probe-name BeProbeForIPv4AndIPv6 --protocol Tcp --frontend-port 80 --backend-port 80 --lb-name $lbName
az network lb rule create --resource-group $rgname `
                --name LBRuleForIPv4-Port443 --frontend-ip-name $frontendV4Name --backend-pool-name $backendAddressPoolV4Name `
                --probe-name BeProbeForIPv4AndIPv6 --protocol Tcp --frontend-port 443 --backend-port 443 --lb-name $lbName
az network lb rule create --resource-group $rgname `
                --name LBRuleForIPv4-Port8443 --frontend-ip-name $frontendV4Name --backend-pool-name $backendAddressPoolV4Name `
                --probe-name BeProbeForIPv4AndIPv6 --protocol Tcp --frontend-port 8443 --backend-port 8443 --lb-name $lbName

## v6 ports
az network lb rule create --resource-group $rgname `
                --name LBRuleForIPv6-Port22 --frontend-ip-name $frontendV6Name --backend-pool-name $backendAddressPoolV6Name `
                --probe-name BeProbeForIPv4AndIPv6 --protocol Tcp --frontend-port 22 --backend-port 22 --lb-name $lbName
az network lb rule create --resource-group $rgname `
                --name LBRuleForIPv6-Port25 --frontend-ip-name $frontendV6Name --backend-pool-name $backendAddressPoolV6Name `
                --probe-name BeProbeForIPv4AndIPv6 --protocol Tcp --frontend-port 25 --backend-port 25 --lb-name $lbName
az network lb rule create --resource-group $rgname `
                --name LBRuleForIPv6-Port80 --frontend-ip-name $frontendV6Name --backend-pool-name $backendAddressPoolV6Name `
                --probe-name BeProbeForIPv4AndIPv6 --protocol Tcp --frontend-port 80 --backend-port 80 --lb-name $lbName
az network lb rule create --resource-group $rgname `
                --name LBRuleForIPv6-Port443 --frontend-ip-name $frontendV6Name --backend-pool-name $backendAddressPoolV6Name `
                --probe-name BeProbeForIPv4AndIPv6 --protocol Tcp --frontend-port 443 --backend-port 443 --lb-name $lbName
az network lb rule create --resource-group $rgname `
                --name LBRuleForIPv6-Port8443 --frontend-ip-name $frontendV6Name --backend-pool-name $backendAddressPoolV6Name `
                --probe-name BeProbeForIPv4AndIPv6 --protocol Tcp --frontend-port 8443 --backend-port 8443 --lb-name $lbName

az network lb show --resource-group $rgName --name $lbName

# Create NICs and associate them with NAT rules, load balancer rules, and probes.

$nic1Name = "beIPv4IPv6Nic1"
$subnet1Id = "/subscriptions/$subscriptionid/resourceGroups/$rgName/providers/Microsoft.Network/VirtualNetworks/$vnetName/subnets/$subnet1Name"
$backendAddressPoolV4Id = "/subscriptions/$subscriptionid/resourceGroups/$rgname/providers/Microsoft.Network/loadbalancers/$lbName/backendAddressPools/$backendAddressPoolV4Name"
$backendAddressPoolV6Id = "/subscriptions/$subscriptionid/resourceGroups/$rgname/providers/Microsoft.Network/loadbalancers/$lbName/backendAddressPools/$backendAddressPoolV6Name"

$nic1 = az network nic create --name $nic1Name --resource-group $rgname --location $location --private-ip-address-version "IPv4" --subnet $subnet1Id --lb-address-pools $backendAddressPoolV4Id 
$nic1IPv6 = az network nic ip-config create --resource-group $rgname --name "IPv6IPConfig" --private-ip-address-version "IPv6" --lb-address-pools $backendAddressPoolV6Id --nic-name $nic1Name

# create availability set and VM

$availabilitySetName = "beIPv4IPv6AvailabilitySet"
$vm1Name = "be"
$nic1Id = "/subscriptions/$subscriptionid/resourceGroups/$rgname/providers/Microsoft.Network/networkInterfaces/$nic1Name"
$imageurn = "/subscriptions/4706567a-599b-4483-aee4-41926752f05b/resourceGroups/IDEASYNCRATIC/providers/Microsoft.Compute/images/beImg"
$vmUserName = "vmuser"
$mySecurePassword = "StubPassword*1"

$availabilitySet = az vm availability-set create --name $availabilitySetName --resource-group $rgName --location $location

az vm create --resource-group $rgname --name $vm1Name --image $imageurn --admin-username $vmUserName --admin-password $mySecurePassword --nics $nic1Id --location $location --availability-set $availabilitySetName --size "Standard_B1s" 

