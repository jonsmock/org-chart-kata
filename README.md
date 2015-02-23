# Organization/User/Role kata

This is one take on the organization-user-role kata as outlined
[here](http://www.adomokos.com/2012/10/the-organizations-users-roles-kata.html)
with one notable change:  no database access.

The kata seemed to hint that users wouldn't ever have access to the root
organization, but it didn't say that outright. I decided to enforce this by
throwing an exception, but it could easily be changed.

For this take, I tried to pull out the two responsibilities: structure and
permissions. The tree structure of organizations is handled by the OrgChart, and
the permissions is handled by the GateKeeper. Organization and User are simply
pieces of data.
