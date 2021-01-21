# Summary
<<<<<<< Updated upstream
Clears out the groups used by EWS to control remote desktop access to the labs, and sets them up for a new semester.

This script does the following:
1. Creates a new sub-OU within `ad.uillinois.edu/Urbana/Engineering/UsersAndGroups/Instructional/RD User Groups`, named after the given `<semester identifier>`
2. For each group found in the parent OU, a new group is created in the sub-OU, named like `<group>-<semester identifier>`
3. Clears out all members of all groups in the parent OU, except for members named like `<group>-persistent`
4. Each new group is added as a member of its respective parent OU group

For example, if a semester identifier of `2020a` is given, the following occurs:
1. A new sub-OU named `2020a` will be created
2. Taking the group `mel-1001-rdu` as an example, a new group named `mel-1001-rdu-2020a` will be created under the new `2020a` sub-OU
3. All members of `mel-1001-rdu` will be removed (except for `mel-1001-rdu-persistent`)
4. `mel-1001-rdu-2020a` will be added as a member of `mel-1001-rdu`.

(Of course, steps 2-4 will occur for all other groups in the parent OU)

Existing semester-based groups in their respective sub-OUs will not be touched. These are intentionally left in place as a reference of RDU group memberships of past semesters until such time as EWS sees fit to bulk delete them (which is easily done using ADUC). Since these older groups will no longer be members of the parent groups (which are used in the relevant GPOs), they will have no longer have any effect.

See the procedural documentation here: https://wiki.illinois.edu/wiki/display/engritprivate/EWS+remote+access+to+Windows+labs
=======
This script provides handy functions to automate bulk tasks for manipulating usergroups used to control remote desktop access to the labs.
>>>>>>> Stashed changes

# Usage
1. Download `Refresh-EWSRDUGroups.psm1`
2. Import it as a module: `Import-Module "c:\path\to\Refresh-EWSRDUGroups.psm1`
3. Run it:
- e.g. `Refresh-EWSRDUGroups -SemesterIdentifier "2021a"

<<<<<<< Updated upstream
# Parameters

### -SemesterIdentifier <string>
Required string.  
Should be a unique identifier which represents the upcoming semester.  
By convention it should be `<year><letter of semester>`, where `<letter of semester>` is `a` for spring, `b` for summer, `c` for fall, and `d` for winter (though probably only `a` and `c` will be used).  
This identifier determines both the name of the new sub-OU, and the suffix of the new groups that will be created in that new sub-OU.  

### -SkipRemoval
Optional switch.  
If specified, causes the script to skip step #3 as described in the summary section.  
Only do this is you intend to preseve RDU permissions of past semesters.  
If specified in combination with `-RemoveOnly`, `-RemoveOnly` will be ignored.  

### -RemoveOnly

=======
# Notes
- See the parameter documentation below.  Throughout this document and the code, "parent OU" is used to refer to `ad.uillinois.edu/Urbana/Engineering/UsersAndGroups/Instructional/RD User Groups`, and "parent groups" refers to the groups in that OU (but not to the groups in sub-OUs).
- The string values provided to the paramters should be unique identifiers referring to a specific semester, referred to as a `<semID>`. By convention this should be of the format `<year><letter of semester>`, where `<letter of semester>` is `a` for spring, `b` for summer, `c` for fall, and `d` for winter (though probably only `a` and `c` will be used). e.g. Spring 2021, would be `2021a`.
- It is useful to modularize the different functions provided by the different parameters because you may need to begin building the next semester's RDU groups before the current semester is over.
  - Taking the 2021 summer break as an example, you might want to run `Refresh-EWSRDUGroups -SemesterIdentifier "2021c" -SkipRemoval` before Spring 2021 is over, in order to create the new groups for Fall 2021, to process requests coming in for Fall 2021.
  - In this case, once Spring 2021 is over for realsies, you can then run `Refresh-EWSRDUGroups -SemesterIdentifier "2021a" -RemoveOnly` to strip access by those in the 2021a groups.
   Whenever it makes sense to remove those groups, the `-such time as EWS sees fit to bulk delete them (which is easily done using ADUC). Since these older groups will no longer be members of the parent groups (which are used in the relevant GPOs), they will have no longer have any effect.
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
>>>>>>> Stashed changes
WIP - not implemented yet!

Optional string.  
If specified:  
1. The membership of all groups in the given semester's sub-OU will be exported to have their membership data exported to a file, given by `-MembershipExportCsv <filepath>`
2. All groups in the given semester's sub-OU will be deleted
3. The given semester's sub-OU will be deleted

It may be useful to leave semester-based sub-OUs/groups of previous semesters intact for a while, as a reference of historical RDU group memberships.  
Deleting groups for a semester will inherently "deauthorize" those groups, as they will no longer exist to be members of their respective parent groups.  

### -MembershipExportCsv <filepath>
Required string if `-DeleteGroupsForSemester <semID>` is specified.  
The full file path to a CSV file where the membership of the groups to be deleted will be exported.  

# Notes
- By mseng3
