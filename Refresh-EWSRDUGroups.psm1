# Script documentation home: https://github.com/engrit-illinois/Refresh-EWSRDUGroups
# Procedure documentation home: https://wiki.illinois.edu/wiki/display/engritprivate/EWS+remote+access+to+Windows+labs

function Refresh-EWSRDUGroups {
	param(
		[Parameter(Mandatory=$true)]
		[ValidatePattern('^[a-zA-Z0-9]+$')]
		[string]$SemesterIdentifier,
		
		[switch]$SkipRemoval
	)
	
	function log($msg) {
		$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss:ffff"
		$msg = "[$ts] $msg"
		Write-Host $msg
	}
	
	# Record timestamp
	$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	
	# Define generic description for new objects
	$descBase = "scriptomatically created on $($ts). See documentation here: https://wiki.illinois.edu/wiki/display/engritprivate/EWS+remote+access+to+Windows+labs"
	
	# Define OU where primary groups exist
	$RDUOUDN = "OU=RD User Groups,OU=Instructional,OU=UsersAndGroups,OU=Engineering,OU=Urbana,DC=ad,DC=uillinois,DC=edu"
	$newOUDN = "OU=$($SemesterIdentifier),$RDUOUDN"
	
	# Pull all the primary groups
	log "Pulling primary groups from `"$RDUOUDN`"..."
	# SearchScope 1 is required to prevent also pulling groups in sub-OUs
	$groups = Get-ADGroup -Filter "*" -SearchBase $RDUOUDN -SearchScope 1
	
	# Create new sub-OU
	log "Creating new sub-OU named `"$SemesterIdentifier`"..."
	$desc = "This sub-OU $descBase"
	New-ADOrganizationalUnit -Name $SemesterIdentifier -Path $RDUOUDN -Description $desc
	
	# Create new groups under new sub-OU
	log "Creating new groups..."
	foreach($group in $groups) {
		$newName = "$($group.Name)-$SemesterIdentifier"
		log "    Creating new group for `"$($group.Name)`" named `"$newName`"..."
		
		$desc = "This group $descBase"
		
		New-ADGroup -Name $newName -SamAccountName $newName -GroupCategory "Security" -GroupScope "Universal" -DisplayName $newName -Path $newOUDN -Description $desc
	}
	
	# Remove all members of primary groups
	if(!$SkipRemoval) {
		log "Removing existing members from primary groups..."
		foreach($group in $groups) {
			log "Removing members from group `"$($group.Name)`"..."
			
			# Get existing members
			$members = $group | Get-ADGroupMember
			
			# Remove members
			# Wow, the -Confirm switch is garbage:
			# https://serverfault.com/questions/513462/why-does-remove-adgroupmember-default-to-requiring-confirmation
			Remove-ADGroupMember -Identity $group.Name -Members $members -Confirm:$false
		}
	}
	else {
		log "-SkipRemoval was specified. Skipping removal of existing members from primary groups!"
	}
	
	# Add new groups as members of respective primary groups
	log "Adding new groups as members of their respective primary groups..."
	
	$groups = Get-ADGroup -Filter "*" -SearchBase $newOUDN
	
	foreach($group in $groups) {
		# Caculate respective primary group that spawned this group
		$primary = ($group.Name).Replace("-$SemesterIdentifier","")
		
		log "    Adding `"$($group.Name)`" as a member of `"$primary`"..."
		Add-ADGroupMember -Identity $primary -Members $group.Name
	}
	
	log "EOF"
	
}