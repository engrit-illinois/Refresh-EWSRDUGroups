# Summary
Clears out the groups used by EWS to control remote desktop access to the labs, and sets them up for a new semester.

This script does the following:
1. Looks at all of the groups in `ad.uillinois.edu/Urbana/Engineering/UsersAndGroups/Instructional/RD User Groups`
2. Clears out all members of these groups
3. Creates a new sub-OU for the given `<semester identifier>`
4. For each group in the parent OU, a new group is created in the sub-OU, named like `<group>-<semester identifier>`
5. Each new group is added as a member of its originating group.

e.g. If a semester identifier of `2020a` is given, a new sub-OU named `2020a` will be created. Taking the group `mel-1001-rdu` as an example, a new group named `mel-1001-rdu-2020a` will be created under the new `2020a` sub-OU. `mel-1001-rdu-2020a` will be added as a member of `mel-1001-rdu` (and any previous members of `mel-1001-rdu` will have been removed). Similar groups will be created for every other group in the parent OU.

Existing semester-based groups will not be touched. These are intentionally left in place as a reference of RDU group memberships of past semesters until such time as EWS sees fit to bulk delete them (which is easily done using ADUC). Since these older groups will no longer be members of the parent groups (which are used in the relevant GPOs), they will have no longer have any effect.

See the procedural documentation here: https://wiki.illinois.edu/wiki/display/engritprivate/EWS+remote+access+to+Windows+labs

# Usage
1. Download `Refresh-EWSRDUGroups.psm1`
2. 