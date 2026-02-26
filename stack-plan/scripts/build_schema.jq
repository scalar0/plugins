def branch_pattern:
  "^stack/[a-z0-9]+(?:-[a-z0-9]+)*/[a-z0-9]+(?:-[a-z0-9]+)*$";

def commit_placeholder_pattern:
  "^__COMMIT_MESSAGE_PR_[0-9]+__$";

def submit_args_pattern:
  [
    {
      "const": "submit"
    },
    {
      "const": "-r"
    },
    {
      "const": "scalar0"
    },
    {
      "const": "--ai"
    },
    {
      "const": "--no-interactive"
    }
  ];

{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Stack Plan",
  "type": "object",
  "additionalProperties": false,
  "required": ["schema_version", "graphite_submission", "source_plan", "stack", "execution"],
  "properties": {
    "schema_version": {
      "type": "string",
      "const": "1.0.0"
    },
    "graphite_submission": {
      "$ref": "#/$defs/graphite_submission"
    },
    "source_plan": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "title",
        "executive_summary",
        "key_objectives",
        "high_level_approach",
        "phase_count",
        "task_count"
      ],
      "properties": {
        "title": {
          "type": "string"
        },
        "executive_summary": {
          "type": "string"
        },
        "key_objectives": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "high_level_approach": {
          "type": "string"
        },
        "phase_count": {
          "type": "integer",
          "minimum": 0
        },
        "task_count": {
          "type": "integer",
          "minimum": 1
        }
      }
    },
    "stack": {
      "type": "array",
      "minItems": 1,
      "items": {
        "$ref": "#/$defs/stack_item"
      }
    },
    "execution": {
      "type": "object",
      "additionalProperties": false,
      "required": ["preflight", "recovery"],
      "properties": {
        "preflight": {
          "type": "array",
          "minItems": 1,
          "items": {
            "$ref": "#/$defs/preflight_command"
          }
        },
        "recovery": {
          "type": "array",
          "minItems": 1,
          "items": {
            "$ref": "#/$defs/recovery_command"
          }
        }
      }
    }
  },
  "$defs": {
    "step": {
      "type": "object",
      "additionalProperties": false,
      "required": ["id", "description", "verification"],
      "properties": {
        "id": {
          "type": "string"
        },
        "description": {
          "type": "string"
        },
        "verification": {
          "type": "string"
        }
      }
    },
    "gate": {
      "type": "object",
      "additionalProperties": false,
      "required": ["id", "description", "validation"],
      "properties": {
        "id": {
          "type": "string"
        },
        "description": {
          "type": "string"
        },
        "validation": {
          "type": "string"
        }
      }
    },
    "preflight_command": {
      "type": "object",
      "additionalProperties": false,
      "required": ["tool", "args", "why"],
      "properties": {
        "tool": {
          "type": "string",
          "const": "mcp__graphite__run_gt_cmd"
        },
        "args": {
          "type": "array",
          "minItems": 2,
          "maxItems": 3,
          "prefixItems": [
            {
              "enum": ["log", "state"]
            },
            {
              "type": "string"
            },
            {
              "type": "string"
            }
          ],
          "items": {
            "type": "string"
          }
        },
        "why": {
          "type": "string"
        }
      }
    },
    "recovery_command": {
      "type": "object",
      "additionalProperties": false,
      "required": ["tool", "args", "why"],
      "properties": {
        "tool": {
          "type": "string",
          "const": "mcp__graphite__run_gt_cmd"
        },
        "args": {
          "type": "array",
          "minItems": 2,
          "maxItems": 2,
          "prefixItems": [
            {
              "enum": ["sync", "restack", "continue", "abort"]
            },
            {
              "const": "--no-interactive"
            }
          ],
          "items": {
            "type": "string"
          }
        },
        "why": {
          "type": "string"
        }
      }
    },
    "create_stack_command": {
      "type": "object",
      "additionalProperties": false,
      "required": ["tool", "args", "why"],
      "properties": {
        "tool": {
          "type": "string",
          "const": "mcp__graphite__run_gt_cmd"
        },
        "args": {
          "type": "array",
          "minItems": 6,
          "maxItems": 6,
          "prefixItems": [
            {
              "const": "create"
            },
            {
              "type": "string",
              "pattern": branch_pattern
            },
            {
              "const": "--all"
            },
            {
              "const": "--message"
            },
            {
              "type": "string",
              "pattern": commit_placeholder_pattern
            },
            {
              "const": "--no-interactive"
            }
          ],
          "items": {
            "type": "string"
          }
        },
        "why": {
          "type": "string"
        }
      }
    },
    "submit_stack_command": {
      "type": "object",
      "additionalProperties": false,
      "required": ["tool", "args", "why"],
      "properties": {
        "tool": {
          "type": "string",
          "const": "mcp__graphite__run_gt_cmd"
        },
        "args": {
          "type": "array",
          "minItems": 5,
          "prefixItems": [
            submit_args_pattern[]
          ],
          "items": {
            "type": "string"
          }
        },
        "why": {
          "type": "string"
        }
      }
    },
    "graphite_submission": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "provider",
        "workflow",
        "submission_mode",
        "create_command_index",
        "submit_command_index",
        "submit_args",
        "branch_naming",
        "default_reviewers",
        "ai_metadata"
      ],
      "properties": {
        "provider": {
          "type": "string",
          "const": "graphite"
        },
        "workflow": {
          "type": "string",
          "const": "stacked-pr"
        },
        "submission_mode": {
          "type": "string",
          "const": "immediate-after-create"
        },
        "create_command_index": {
          "type": "integer",
          "const": 1
        },
        "submit_command_index": {
          "type": "integer",
          "const": 2
        },
        "submit_args": {
          "type": "array",
          "minItems": 5,
          "prefixItems": [
            submit_args_pattern[]
          ],
          "items": {
            "type": "string"
          }
        },
        "branch_naming": {
          "type": "string",
          "const": "stack/<plan-slug>/<task-id-slug>"
        },
        "default_reviewers": {
          "type": "array",
          "minItems": 1,
          "prefixItems": [
            {
              "const": "scalar0"
            }
          ],
          "items": {
            "type": "string"
          }
        },
        "ai_metadata": {
          "$ref": "#/$defs/ai_metadata"
        }
      }
    },
    "ai_metadata": {
      "type": "object",
      "additionalProperties": false,
      "required": ["enabled", "mode"],
      "properties": {
        "enabled": {
          "type": "boolean",
          "const": true
        },
        "mode": {
          "type": "string",
          "const": "graphite-submit-ai"
        }
      }
    },
    "pr_submission": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "provider",
        "submission_mode",
        "create_command_index",
        "submit_command_index",
        "submit_args",
        "reviewers",
        "ai_metadata"
      ],
      "properties": {
        "provider": {
          "type": "string",
          "const": "graphite"
        },
        "submission_mode": {
          "type": "string",
          "const": "immediate-after-create"
        },
        "create_command_index": {
          "type": "integer",
          "const": 1
        },
        "submit_command_index": {
          "type": "integer",
          "const": 2
        },
        "submit_args": {
          "type": "array",
          "minItems": 5,
          "prefixItems": [
            submit_args_pattern[]
          ],
          "items": {
            "type": "string"
          }
        },
        "reviewers": {
          "type": "array",
          "minItems": 1,
          "prefixItems": [
            {
              "const": "scalar0"
            }
          ],
          "items": {
            "type": "string"
          }
        },
        "ai_metadata": {
          "$ref": "#/$defs/ai_metadata"
        }
      }
    },
    "stack_item": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "phase_name",
        "task_id",
        "task_name",
        "task_dependencies",
        "implementation_steps",
        "quality_gates",
        "pr_index",
        "depends_on_prs",
        "branch_name",
        "commit_message_placeholder",
        "pr_submission",
        "gt_commands"
      ],
      "properties": {
        "phase_name": {
          "type": "string"
        },
        "task_id": {
          "type": "string"
        },
        "task_name": {
          "type": "string"
        },
        "task_dependencies": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "implementation_steps": {
          "type": "array",
          "items": {
            "$ref": "#/$defs/step"
          }
        },
        "quality_gates": {
          "type": "array",
          "items": {
            "$ref": "#/$defs/gate"
          }
        },
        "pr_index": {
          "type": "integer",
          "minimum": 1
        },
        "depends_on_prs": {
          "type": "array",
          "items": {
            "type": "integer",
            "minimum": 1
          }
        },
        "branch_name": {
          "type": "string",
          "pattern": branch_pattern
        },
        "commit_message_placeholder": {
          "type": "string",
          "pattern": commit_placeholder_pattern
        },
        "pr_submission": {
          "$ref": "#/$defs/pr_submission"
        },
        "gt_commands": {
          "type": "array",
          "minItems": 2,
          "maxItems": 2,
          "prefixItems": [
            {
              "$ref": "#/$defs/create_stack_command"
            },
            {
              "$ref": "#/$defs/submit_stack_command"
            }
          ],
          "items": {
            "type": "object",
            "required": [],
            "properties": {},
            "additionalProperties": false
          }
        }
      }
    }
  }
}
