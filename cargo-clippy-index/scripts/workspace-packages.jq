[.workspace_members[]] as $members
| [
    .packages[]
    | select(.id as $id | $members | index($id))
    | .name
  ]
| sort
| .[]
