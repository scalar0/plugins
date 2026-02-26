def normalize_text:
  tostring
  | gsub("\\s+"; " ")
  | gsub("^\\s+|\\s+$"; "");

def slug:
  normalize_text
  | ascii_downcase
  | gsub("[^a-z0-9]+"; "-")
  | gsub("^-+"; "")
  | gsub("-+$"; "");

def branch_name($plan_slug; $task_id):
  ($task_id | tostring | ascii_downcase | gsub("[^a-z0-9]+"; "-")) as $task_slug
  | "stack/\($plan_slug)/\($task_slug)";

def commit_message_placeholder($pr_index):
  "__COMMIT_MESSAGE_PR_\($pr_index)__";

def flatten_tasks:
  [
    .phases[] as $phase
    | $phase.tasks[] as $task
    | {
        phase_name: $phase.name,
        task_id: $task.id,
        task_name: $task.name,
        task_dependencies: ($task.dependencies // []),
        implementation_steps: ($task.sequential_steps // []),
        quality_gates: ($task.quality_gates // [])
      }
  ];

flatten_tasks as $flat
| ($flat | to_entries | map(.value + {pr_index: (.key + 1)})) as $indexed
| ($indexed | map({key: .task_id, value: .pr_index}) | from_entries) as $task_to_pr
| (.title | slug) as $plan_slug
| {
    schema_version: "1.0.0",
    graphite_submission: {
      provider: "graphite",
      workflow: "stacked-pr",
      submission_mode: "immediate-after-create",
      create_command_index: 1,
      submit_command_index: 2,
      submit_args: ["submit", "-r", "scalar0", "--ai", "--no-interactive"],
      branch_naming: "stack/<plan-slug>/<task-id-slug>",
      default_reviewers: ["scalar0"],
      ai_metadata: {
        enabled: true,
        mode: "graphite-submit-ai"
      }
    },
    source_plan: {
      title: .title,
      executive_summary: .executive_summary,
      key_objectives: (.key_objectives // []),
      high_level_approach: .high_level_approach,
      phase_count: (.phases | length),
      task_count: ($indexed | length)
    },
    stack: (
      $indexed
      | map(
          . + {
            depends_on_prs: (
              [.task_dependencies[]? | $task_to_pr[.]]
              | map(select(. != null))
              | unique
              | sort
            ),
            branch_name: branch_name($plan_slug; .task_id),
            commit_message_placeholder: commit_message_placeholder(.pr_index),
            pr_submission: {
              provider: "graphite",
              submission_mode: "immediate-after-create",
              create_command_index: 1,
              submit_command_index: 2,
              submit_args: ["submit", "-r", "scalar0", "--ai", "--no-interactive"],
              reviewers: ["scalar0"],
              ai_metadata: {
                enabled: true,
                mode: "graphite-submit-ai"
              }
            },
            gt_commands: [
              {
                tool: "mcp__graphite__run_gt_cmd",
                args: ["create", branch_name($plan_slug; .task_id), "--all", "--message", commit_message_placeholder(.pr_index), "--no-interactive"],
                why: "Create stack branch for task \(.task_id) \(.task_name | normalize_text)"
              },
              {
                tool: "mcp__graphite__run_gt_cmd",
                args: ["submit", "-r", "scalar0", "--ai", "--no-interactive"],
                why: "Submit PR immediately after creation to enable concurrent review for PR index \(.pr_index)"
              }
            ]
          }
        )
    ),
    execution: {
      preflight: [
        {
          tool: "mcp__graphite__run_gt_cmd",
          args: ["log", "short", "--no-interactive"],
          why: "Inspect current Graphite stack state before running plan commands"
        },
        {
          tool: "mcp__graphite__run_gt_cmd",
          args: ["state", "--no-interactive"],
          why: "Confirm branch and stack context before creating stack commits"
        }
      ],
      recovery: [
        {
          tool: "mcp__graphite__run_gt_cmd",
          args: ["sync", "--no-interactive"],
          why: "Sync trunk and restack branches before re-submitting"
        },
        {
          tool: "mcp__graphite__run_gt_cmd",
          args: ["restack", "--no-interactive"],
          why: "Restack when sync reports branch ordering or parent issues"
        },
        {
          tool: "mcp__graphite__run_gt_cmd",
          args: ["continue", "--no-interactive"],
          why: "Continue after resolving restack conflicts"
        },
        {
          tool: "mcp__graphite__run_gt_cmd",
          args: ["abort", "--no-interactive"],
          why: "Abort a conflicted restack session when resolution is not desired"
        }
      ]
    }
  }
