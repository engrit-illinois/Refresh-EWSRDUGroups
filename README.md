# Summary
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

# Usage
1. Download `Refresh-EWSRDUGroups.psm1`
2. Import it as a module: `Import-Module "c:\path\to\Refresh-EWSRDUGroups.psm1`
3. Run it:
- e.g. `Refresh-EWSRDUGroups -SemesterIdentifier "2021a"

#Parameters

### -SemesterIdentifier <string>
Required string.  
Should be a unique identifier which represents the upcoming semester.  
By convention it should be `<year><letter of semester>`, where `<letter of semester>` is `a` for spring, `b` for summer, `c` for fall, and `d` for winter (though probably only `a` and `c` will be used).  
This identifier determines both the name of the new sub-OU, and the suffix of the new groups that will be created in that new sub-OU.  

### -SkipRemoval
Optional switch.  
Causes the script to skip step #3 as described in the summary section.  
Only do this is you intend to preseve RDU permissions of past semesters.  

# Notes
- By mseng3