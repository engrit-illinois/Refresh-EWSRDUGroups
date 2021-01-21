# Summary
This script provides handy functions to automate bulk tasks for manipulating usergroups used to control remote desktop access to the labs.

# Usage
1. Download `Refresh-EWSRDUGroups.psm1`
2. Import it as a module: `Import-Module "c:\path\to\Refresh-EWSRDUGroups.psm1`
3. Run it using one or more of the parameters documented below

# Notes
- Throughout this document and the code, "parent OU" is used to refer to `ad.uillinois.edu/Urbana/Engineering/UsersAndGroups/Instructional/RD User Groups`, and "parent groups" refers to the groups in that OU (but not to the groups in sub-OUs).
- The string values provided to the paramters should be unique identifiers referring to a specific semester, referred to as a `<semID>`.
  - By convention this should be of the format `<year><letter of semester>`, where `<letter of semester>` is `a` for spring, `b` for summer, `c` for fall, and `d` for winter (though probably only `a` and `c` will be used).
  - e.g. Spring 2021, would be `2021a`.
- It is useful to modularize the different functions provided by the different parameters because you may need to begin building the next semester's RDU groups before the current semester is over.
- Does not currently do any checking for existence or non-existence of OUs or groups corresponding to provided `<semester identifiers>`. So know what you're doing and get them right!
- See the procedural documentation here: https://wiki.illinois.edu/wiki/display/engritprivate/EWS+remote+access+to+Windows+labs

# Parameters

### -CreateGroupsForSemester <semID>
Optional string.  
If specified:  
1. A new sub-OU under the parent OU named `<semID>` will be created. e.g. if `-CreateGroupsForSemester "2021a"` is specified, a new sub-OU named `2021a` will be created.
2. One new group will be created under the new sub-OU for each parent group. e.g. for parent group `mel-1001-rdu`, a new group in sub-OU `2021a` will be created, named `mel-1001-rdu-2021a`. All other parent groups will have new "-2021a" groups created in the new sub-OU as well.

### -AuthorizeGroupsForSemester <semID>
Optional string.  
If specified, each group within the given semester's sub-OU will be added as a member of its respective parent group.  
e.g. if `-AuthorizeGroupsForSemester "2021a"` is specified, `mel-1001-rdu-2021a` will be added as a member of `mel-1001-rdu`, and the same will hold for all other `2021a` groups.  

### -DeauthorizeGroupsForSemester <semID>
Optional string.  
If specified, each group within the given semester's sub-OU will be removed as a member of its respective parent group.  
e.g. if `-DeauthorizeGroupsForSemester "2021a"` is specified, `mel-1001-rdu-2021a` will be removed as a member of `mel-1001-rdu`, and the same will hold for all other `2021a` groups.  

### -DeleteGroupsForSemester <semID>
WIP - not implemented yet!

Optional string.  
If specified:  
1. The membership of all groups in the given semester's sub-OU will be exported to a CSV-formatted file, saved to the path given by `-MembershipExportCsv <filepath>`
2. All groups in the given semester's sub-OU will be deleted
3. The given semester's sub-OU will be deleted

It may be useful to leave semester-based sub-OUs/groups of previous semesters intact for a while, as a reference of historical RDU group memberships. This is why `-DeauthorizeGroupsForSemester` is provided.  
Deleting groups for a semester will inherently "deauthorize" those groups, as they will no longer exist to be members of their respective parent groups.  

### -MembershipExportCsv <filepath>
Required string if `-DeleteGroupsForSemester <semID>` is specified.  
The full file path to a CSV file where the membership of the groups to be deleted will be exported.  

# Notes
- By mseng3