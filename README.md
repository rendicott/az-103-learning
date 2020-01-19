# az-103 learning
Scripts and materials used while studying for the AZ-103 Microsoft Azure Administrator 2020 exam. 

# Exam Thoughts
Passed the exam on 1/16/2020. Barely. Min score 700, my score 700. 

The exam was pretty bad. It was poorly structured and bounced around a lot. It was never quite clear how many questions you had left because you'd get surprise sections pop up after you click submit. Overall the questions were poorly worded and were generally just trying to be complicated for no reason other than to mislead. That's about it for general complaints. Here are some  more concrete tips:

* It asked a lot of questions about how you could move resource groups around and where NICs had to be when VMs are in a specific region, etc. Make sure you know everything about how Resource Groups can move around. 
* Lots of questions about Azure AD and which Azure Policies you could apply to users to make certain things happen on login events. Stuff that was outside of the normal MFA stuff that most courses cover. 
* A bunch of questions required you to know what pre-baked roles could do what. For example, whether or not a "User Administrator" could "Register Devices" to the AD or "Join Devices". I still don't know what the difference between joining and registering is but there were several questions about that. 
* Several questions about storage accounts and whether a certain scenario warranted File, Blob, or Table, etc. 
* There was a question about Azure Automation and the order of operations you'd need to do to get it to configure VMs when they launch. I'd never heard of Azure Automation until I got in the exam.  
* There was a question about what happens when a billing threshold is hit. Does the VM shut down or just alert? I still don't know if I got that right.  

I'll add more if I think of it. 

# Takeaways on Azure so far
* creating a windows VM takes at least 15 minutes
* updating permissions on a Managed Service Identity (MSI) takes at least 30 minutes
* Azure Powershell module googling is a confusing wasteland of old references to `AzureRm` modules that don't work anymore.
* Powershell isn't very helpful when you give a cmdlet the wrong parameters
* Azure networking is wonky.
   * I don't know why I can't see subnets, NSG's, route tables, and VNets all in the same console window. I have to have 4 tabs open to get a good picture. 
   * The effective routes view takes at least 10 minutes to load which is trash. At least if you're not going to show me what my actual route table looks like then make the effective routes view not take 10 minutes to load.
* It seems to be impossible to load balance an existing set of VMs unless you had enough foresight to put them in an availability set before launching them. This is wacky.
* If I create an object called "Public IP Address" and I select "Dynamic" you should probably give me a warning that says I won't actually get a public IP until I associate rules to the load balancer. 
* Why doesn't the console have bulk actions? When I select multiple items from a list of network interfaces I should be able to delete all of them. 
* ARM template `resourceId()` lookup functions are annoying. See my rant below. 
* The Azure AD domain joining thing is a joke. It's obviously beta.

# Handy Powershell Commands

Get Private IP of a VM
```powershell
$vm = get-azvm -name web1
AGet-AzNetworkInterface | where-object {$_.VirtualMachine.Id -eq $vm.Id} | foreach-object {$_.IpConfigurations.PrivateIpAddress }
```

With Azure CLI
```
az vm show -d -n web1 --resource-group webfarm --query privateIps
```


# ARM resourceId() rant
In the following snippet of ARM template

```json
    {
      "apiVersion": "2018-02-01",
      "type": "Microsoft.Network/networkInterfaces",
      "name": "[variables('networkInterfaceName')]",
      "location": "[parameters('location')]",
      "dependsOn": [
        "[concat('Microsoft.Network/publicIPAddresses/', variables('publicIpAddressName'))]"
      ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('publicIpAddressName'))]"
              },
              "subnet": {
                "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', variables('virtualNetworkName'), variables('subnetName'))]"
              }
            }
          }
        ]
      }
    },
```

The `resourceId()` function for looking up the ID of an existing subnet is rather infuriating. The ARM docs tell you in a very cryptic way that you basically need the same number of positional args as you have slashes in the resource type namespace identifier.

So for a namespace like `Microsoft.Network/virtualNetworks/subnets` you'll need to have one positional argument for `virtualNetworks` and one for `subnets`.

Shorter namespaces like `Microsoft.Network/networkInterfaces` would only require one argument for the `networkInterfaces` section. 