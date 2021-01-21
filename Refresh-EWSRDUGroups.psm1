# Script documentation home: https://github.com/engrit-illinois/Refresh-EWSRDUGroups
# Procedure documentation home: https://wiki.illinois.edu/wiki/display/engritprivate/EWS+remote+access+to+Windows+labs

function Refresh-EWSRDUGroups {
	param(
		[ValidatePattern('^[a-zA-Z0-9]+$')]
		[string]$CreateGroupsForSemester,
		
		[ValidatePattern('^[a-zA-Z0-9]+$')]
		[string]$AuthorizeGroupsForSemester,
		
		[ValidatePattern('^[a-zA-Z0-9]+$')]
		[string]$DeauthorizeGroupsForSemester,
		
		[string]$Log="c:\engrit\logs\Compare-AssignmentRevisions_$(Get-Date -Format `"yyyy-MM-dd_HH-mm-ss`").log"
	)
	
	function log($msg) {
		$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss:ffff"
		$msg = "[$ts] $msg"
		Write-Host $msg
		$msg | Out-File $Log -Append
	}
	
	# Record timestamp
	$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	
	# Define generic description for new objects
	$descBase = "scriptomatically created on $($ts). See documentation here: https://wiki.illinois.edu/wiki/display/engritprivate/EWS+remote+access+to+Windows+labs"
	
	# Define OU where parent groups exist
	$parentOUDN = "OU=RD User Groups,OU=Instructional,OU=UsersAndGroups,OU=Engineering,OU=Urbana,DC=ad,DC=uillinois,DC=edu"
	
	if($CreateGroupsForSemester) {
		$sem = $CreateGroupsForSemester
		log "Creating groups for semester `"$sem`"..."
		$semOUDN = "OU=$sem,$parentOUDN"
		
		# Pull all the parent groups
		log "    Pulling parent groups from `"$parentOUDN`"..."
		# SearchScope 1 is required to prevent also pulling groups in sub-OUs
		$parentGroups = Get-ADGroup -Filter "*" -SearchBase $parentOUDN -SearchScope 1
		
		# Create new sub-OU
		log "    Creating new sub-OU named `"$sem`"..."
		$desc = "This sub-OU $descBase"
		New-ADOrganizationalUnit -Name $sem -Path $parentOUDN -Description $desc
		
		# Create new semester groups under new sub-OU
		log "    Creating new groups..."
		foreach($parentGroup in $parentGroups) {
			$parentGroupName = $parentGroup.name
			$semGroupName = "$($parentGroupName)-$sem"
			log "        Creating new group for `"$parentGroupName`" named `"$semGroupName`"..."
			
			$desc = "This group $descBase"
			
			New-ADGroup -Name $semGroupName -SamAccountName $semGroupName -GroupCategory "Security" -GroupScope "Universal" -DisplayName $semGroupName -Path $semOUDN -Description $desc
		}
	}
	
	if($AuthorizeGroupsForSemester) {
		$sem = $AuthorizeGroupsForSemester
		log "Authorizing groups for semester `"$sem`"..."
		$semOUDN = "OU=$sem,$parentOUDN"
		
		# Add semester groups as members of respective parent groups
		log "    Adding new groups as members of their respective primary groups..."
		
		# Get list of semester groups
		$semGroups = Get-ADGroup -Filter "*" -SearchBase $semOUDN -SearchScope 1
		
		foreach($semGroup in $semGroups) {
			$semGroupName = $semGroup.Name
			
			# Caculate respective parent group that spawned this group
			$parentGroupName = $semGroupName.Replace("-$sem","")
			
			# Add this semester group as a member of its parent group
			log "        Adding `"$semGroupName`" as a member of `"$parentGroupName`"..."
			Add-ADGroupMember -Identity $parentGroupName -Members $semGroupName
		}
	}
	
	if($DeauthorizeGroupsForSemester) {
		$sem = $DeauthorizeGroupsForSemester
		log "Deauthorizing groups for semester `"$sem`"..."
		$semOUDN = "OU=$sem,$parentOUDN"
		
		# Get list of semester groups
		$semGroups = Get-ADGroup -Filter "*" -SearchBase $semOUDN -SearchScope 1
		
		foreach($semGroup in $semGroups) {
			$semGroupName = $semGroup.Name
			
			# Caculate respective parent group that spawned this group
			$parentGroupName = $semGroupName.Replace("-$sem","")
			
			# Remove this semester group as a member from its parent group
			log "        Removing `"$semGroupName`" as a member of `"$parentGroupName`"..."
			# Wow, the -Confirm switch is garbage:
			# https://serverfault.com/questions/513462/why-does-remove-adgroupmember-default-to-requiring-confirmation
			Remove-ADGroupMember -Identity $parentGroupName -Members $semGroupName -Confirm:$false
		}
	}
	
	log "EOF"
	
}