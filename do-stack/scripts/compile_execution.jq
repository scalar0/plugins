def ordered_items:
  .stack
  | sort_by(.pr_index);

. as $plan
| ($plan | ordered_items) as $items
| {
    schema_version: "1.0.0",
    repo_root: $repo_root,
    source_plan: $plan.source_plan,
    tasks: (
      $items
      | map({
          pr_index,
          task_id,
          task_name,
          phase_name,
          depends_on_prs,
          implementation_steps,
          quality_gates,
          commit_message_placeholder,
          delegation: {
            implementation_subagent: {
              required: true,
              role: "implementation",
              objective: ("Implement task " + .task_id + " " + .task_name),
              input_fields: ["task_id", "task_name", "implementation_steps", "quality_gates"],
              expected_outputs: ["code_changes_staged", "verification_summary"]
            },
            commit_message_subagent: {
              required: true,
              role: "commit-message",
              skill: "$commit-msg",
              objective: ("Generate commit message for task " + .task_id + " after implementation is staged"),
              expected_outputs: ["commit_message"]
            }
          }
        })
    ),
    commands: (
      (
        (
          $plan.execution.preflight
          | map({
              phase: "preflight",
              pr_index: null,
              task_id: null,
              task_name: null,
              command_index: 0,
              args,
              why,
              execution_owner: "overseer",
              requires_subagent: null,
              jit_commit_msg: false,
              commit_message_placeholder: null
            })
        )
        +
        (
          [
            $items[] as $item
            | $item.gt_commands
            | to_entries[]
            | {
                phase: "stack",
                pr_index: $item.pr_index,
                task_id: $item.task_id,
                task_name: $item.task_name,
                command_index: (.key + 1),
                args: .value.args,
                why: .value.why,
                execution_owner: "overseer",
                requires_subagent: (
                  if (
                    (
                      .value.args
                      | map(select(. == $item.commit_message_placeholder))
                      | length
                    ) > 0
                  ) then
                    "commit-message"
                  else
                    null
                  end
                ),
                jit_commit_msg: (
                  (
                    .value.args
                    | map(select(. == $item.commit_message_placeholder))
                    | length
                  ) > 0
                ),
                commit_message_placeholder: (
                  if (
                    (.value.args | map(select(. == $item.commit_message_placeholder)) | length) > 0
                  ) then
                    $item.commit_message_placeholder
                  else
                    null
                  end
                )
              }
          ]
        )
      )
      | to_entries
      | map(.value + {step_index: (.key + 1)})
    )
  }
