
$ResourceGroupName = "webfarm"

function Add-LinuxVMs {
    param(
        [string]$VMUserdata
    )
    Add-LinuxVM -VMName "web1" -VMSubnet "web-1" `
        -VMUserdata $VMUserdata -VMKey "../misc/id_rsa.pub" `
        -VMAvailabilitySet "webset"
    Add-LinuxVM -VMName "web2" -VMSubnet "web-2" `
        -VMUserdata $VMUserdata -VMKey "../misc/id_rsa.pub" `
        -VMAvailabilitySet "webset"
}
function Remove-LinuxVMs {
    Remove-VM -VMName "web1"
    Remove-VM -VMName "web2"
}

function Add-LinuxVM {
    param
  (
    [string]$VMName,
    [string]$VMSubnet,
    [string]$VMAvailabilitySet,
    [string]$VMUserdata,
    [string]$VMKey
  )
    # constants
    $LocationName = "eastus2"
    $VMSize = "Standard_B1s"
    $vnetName = "web-vnet"
    # modified vars
    $ComputerName = $VMName
    $nicName = $VMName + "-nic"
    # networking
    $vnet = Get-AzVirtualNetwork -name $vnetName
    $subnet1 = $vnet | Get-AzVirtualNetworkSubnetConfig | where-object {$_.name -eq $VMSubnet}
    $NIC = New-AzNetworkInterface `
        -Name $nicName -ResourceGroupName $ResourceGroupName `
        -Location $LocationName -SubnetId $subnet1.Id -Force
    # set up vm obj
    $availSet = Get-AzAvailabilitySet -name $VMAvailabilitySet
    $VirtualMachine = New-AzVMConfig `
        -VMName $VMName -VMSize $VMSize `
        -AvailabilitySetId $availSet.Id
    # creds
    $securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword)
    $sshPublicKey = Get-Content $VMKey
    # setup OS
    $userdata = Get-Content $VMUserdata | out-string
    $VirtualMachine = Set-AzVMOperatingSystem `
            -VM $VirtualMachine -Linux -ComputerName $ComputerName `
            -Credential $cred -DisablePasswordAuthentication `
            -CustomData $userdata
    Add-AzVMSshPublicKey `
        -VM $VirtualMachine `
        -KeyData $sshPublicKey `
        -Path "/home/azureuser/.ssh/authorized_keys"
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -NetworkInterface $NIC
    #  Get-AzVMImageSku -location eastus -publishername MicrosoftWindowsServer -offer WindowsServer 
    #  Get-AzVMImageSku -location eastus -publishername MicrosoftWindowsServer -offer WindowsServer
    # Get-AzVMImagePublisher -location eastus2 | where publishername -contains canonical
    # Get-AzVMImageOffer -location eastus2 -publisher canonical
    #  Get-AzVMImageSku -location eastus2 -publisher canonical -offer UbuntuServer
    $VirtualMachine = Set-AzVMSourceImage `
        -VM $VirtualMachine -PublisherName 'Canonical' `
        -Offer 'UbuntuServer' -Skus '18_04-lts-gen2' -Version latest 

    New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose
    # spit out private ip
    $vm = get-azvm -name $VMName
    Get-AzNetworkInterface | where-object {$_.VirtualMachine.Id -eq $vm.Id} | foreach-object {$_.IpConfigurations.PrivateIpAddress }
}

function Remove-VM {
    param(
        [string]$VMName
    )
    Remove-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -Force
}