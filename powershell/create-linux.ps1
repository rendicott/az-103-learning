$cred = Get-Credential
## Azure Account
$LocationName = "eastus2"
$ResourceGroupName = "webfarm"

## VM
$ComputerName = "web1"
$VMName = "web1"
## Get-AzVMSize -Location eastus | Sort-Object -Property MemoryInMB | select -First 10
$VMSize = "Standard_B1s"

## Networking
$subnet1 = Get-AzVirtualNetwork -name $vnet.name | Get-AzVirtualNetworkSubnetConfig | where-object {$_.name -eq "web-1" }
$NIC = New-AzNetworkInterface `
                    -Name "" -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $subnet1.Id
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem `
                    -VM $VirtualMachine `
                    -Windows `
                    -ComputerName $ComputerName `
                    -Credential $cred `
                    -ProvisionVMAgent `
                    -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -NetworkInterface $NIC
#  Get-AzVMImageSku -location eastus -publishername MicrosoftWindowsServer -offer WindowsServer 
#  Get-AzVMImageSku -location eastus -publishername MicrosoftWindowsServer -offer WindowsServer
# Get-AzVMImagePublisher -location eastus2 | where publishername -contains canonical
# Get-AzVMImageOffer -location eastus2 -publisher canonical
#  Get-AzVMImageSku -location eastus2 -publisher canonical -offer UbuntuServer
$VirtualMachine = Set-AzVMSourceImage `
                        -VM $VirtualMachine `
                        -PublisherName 'Canonical' `
                        -Offer 'UbuntuServer' `
                        -Skus '18_04-lts-gen2' `
                        -Version latest 
New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose