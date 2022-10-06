#Check if the Exchange Online Management module is installed and ask to install it if not.

if (Get-Module -ListAvailable -Name ExchangeOnlineManagement) { 
	
	Write-Host "Exchange Online Management module installed, continuing..." 
	
} else { 
	
	Write-Host "Exchange Online Management module is not installed, do you wish to install?"; 
	
	$install = Read-Host -Prompt "Yes/No"; 
	
	if ($install -eq "Yes" -or $install -eq "yes") { 
	
		Install-Module -Name ExchangeOnlineManagement
	
	} else { 
		
		#If the user doesn't want to install the module, exit the script.
		Write-Host "This script requires the Exchange Online Management module for Powershell, see https://www.powershellgallery.com/packages/ExchangeOnlineManagement for installation instructions"; 
		return 
	
	} 
}

#Check if an Exchange online session already exists, and prompt for login if not
if (Get-PSSession -Name ExchangeOnline* ) { 
	
	Write-Output "EXO session active, continuing..."; 
	
} else { 
		
	$sessionEmail = Read-Host -Prompt "Please enter your EA email address to open an EXO session"; Connect-ExchangeOnline -UserPrincipalName $sessionEmail -ShowProgress $true 
		
}

#Create new mailbox
$mailbox_name = Read-Host -Prompt "Please enter the new shared mailbox address to create"
$correctFormat = $mailbox_name -match '^([a-zA-Z0-9_\-\.]+)@(ucdenver.edu|cuanschutz.edu|auraria.edu)$'
#Write-Output $correctFormat

if(!$correctFormat) {
	
	## Fail out
    Write-Output "Invalid format or domain. Shared mailboxes must be at ucdenver.edu, cuanschutz.edu, or auraria.edu domains and follow RFC 5322 for naming conventions otherwise."
    return 
    
}

#Generate the security group name
$security_group_name = $mailbox_name.split("@")[0] + "-sg"
	
#write-host $security_group_name
	
#Get the owners of the mailbox into an array and validate them..
$mailbox_owners = Read-Host -Prompt "Please enter the owner(s) email addresses as a comma-separated list"
$mailbox_owners = $mailbox_owners.Split(",")
    
#Write-Output $mailbox_owners
[System.Collections.ArrayList]$mailbox_owners_clean = @()
    
#iterator variable to be able to extract specific elements from an array
$i = 0
foreach ($owner in $mailbox_owners) {
       
    if($owner.Trim() -match '^([a-zA-Z0-9_\-\.]+)@(ucdenver.edu|cuanschutz.edu|auraria.edu)$') {
        $mailbox_owners_clean.Add($mailbox_owners[$i].Trim())
    }
    $i++       
}

$mailbox_owners_clean.Add("ExchangeAdminsEA-grp")

#Write-Output $mailbox_owners_clean
    
#Get the members of the mailbox.
$mailbox_members = Read-Host -Prompt "Please enter the member(s) email addresses as a comma-separated list"
$mailbox_members = $mailbox_members.Split(",")
	
#Write-Output $mailbox_members
[System.Collections.ArrayList]$mailbox_members_clean = @()
	
#another iterator
$j = 0
foreach ($member in $mailbox_members) {
       
    if($member.Trim() -match '^([a-zA-Z0-9_\-\.]+)@(ucdenver.edu|cuanschutz.edu|auraria.edu)$') {
        $mailbox_members_clean.Add($mailbox_members[$j].Trim())
    }
    $j++       
}

#Write-Output $mailbox_members_clean

#Generate Security Group to manage the mailbox.

New-DistributionGroup -Name $security_group_name -Type "Security"
	
#Create shared mailbox

New-Mailbox -Shared -Name $mailbox_name -DisplayName $mailbox_name -PrimarySmtpAddress $mailbox_name
Set-Mailbox -Identity $mailbox_name -GrantSendOnBehalfTo $security_group_name

#Assign membership

foreach ($sg_member in $mailbox_members_clean) {
    
    Add-DistributionGroupMember -Identity $security_group_name -Member $sg_member

}

#Assign ownership

Set-DistributionGroup -Identity $security_group_name -ManagedBy $mailbox_owners_clean

#Grant permissions to SG

Add-MailboxPermission -Identity $mailbox_name -User $security_group_name -AccessRights FullAccess
Add-RecipientPermission -Identity $mailbox_name -Trustee $security_group_name -AccessRights SendAs
