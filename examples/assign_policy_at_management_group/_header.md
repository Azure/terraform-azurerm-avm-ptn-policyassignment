# Assign policy at management group

This example creates a uniquely named child management group and assigns a policy at that scope. Its existing parent defaults to `avm-test`; set `parent_management_group_id` to the full resource ID of another existing parent. The deployment identity needs permission to create child management groups and manage policy assignments and role assignments beneath that parent.
