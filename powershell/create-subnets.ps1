
$loc = "eastus2"
$rg = "webfarm"
$vnet = New-AzVirtualNetwork -Name "web-vnet" -ResourceGroupName $rg -Location $loc -AddressPrefix "10.180.0.0/16"
$nsg = New-AzNetworkSecurityGroup -Name "sg-web" -ResourceGroupName $rg -Location $loc
$nsg | Add-AzNetworkSecurityRuleConfig -Name ssh-rule -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix "10.0.0.0/8" -SourcePortRange * -DestinationAddressPrefix "10.0.0.0/8" -DestinationPortRange 22 |
    set-AzNetworkSecurityGroup
$nsg | Add-AzNetworkSecurityRuleConfig -Name http-rule -Description "Allow HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 81 | 
    set-AzNetworkSecurityGroup
$nsg | Add-AzNetworkSecurityRuleConfig -Name https-rule -Description "Allow HTTPS" -Access Allow -Protocol Tcp -Direction Inbound -Priority 102 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 443 |
    set-AzNetworkSecurityGroup

Add-AzVirtualNetworkSubnetConfig -Name "web-1" -AddressPrefix "10.180.1.0/24" -VirtualNetwork $vnet -NetworkSecurityGroupId $nsg.Id |
    Set-AzVirtualNetwork
Add-AzVirtualNetworkSubnetConfig -Name "web-2" -AddressPrefix "10.180.2.0/24" -VirtualNetwork $vnet -NetworkSecurityGroupId $nsg.Id |
    Set-AzVirtualNetwork


