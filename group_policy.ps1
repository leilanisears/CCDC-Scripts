#MASS Remove users from 'Domain Admins' group
Get-ADGroupMember 'Domain Admins' | Remove-ADPrincipalGroupMembership -MemberOf 'Domain Admins'

#Reset GPOs
dcgpofix /target:both

# Group policy updates (GPO)
Gpupdate /force /sync
