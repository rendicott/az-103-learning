$cred = Get-Credential
## Azure Account
$LocationName = "eastus2"
$ResourceGroupName = "default"

## VM
$ComputerName = "rusty-cpu-name"
$VMName = "rusty-vm"
# Modern hardware environment with fast disk, high IOPs performance.
# Required to run a client VM with efficiency and performance
## Get-AzVMSize -Location eastus | Sort-Object -Property MemoryInMB | select -First 10
$VMSize = "Standard_B1s"

## Networking
$DNSNameLabel = "rusty-pip2" # mydnsname.westus.cloudapp.azure.com
$NICName = "rusty-nic2"
$PublicIPAddressName = "rusty-pip2"
$vnet = Get-AzVirtualNetwork -name default-vnet 

$PIP = New-AzPublicIpAddress -Name $PublicIPAddressName -DomainNameLabel $DNSNameLabel -ResourceGroupName $ResourceGroupName -Location $LocationName -AllocationMethod Dynamic
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $PIP.Id

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
#  Get-AzVMImageSku -location eastus -publishername MicrosoftWindowsServer -offer WindowsServer
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest 
New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose