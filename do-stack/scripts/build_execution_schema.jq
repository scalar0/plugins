def branch_pattern:
  "^stack/[a-z0-9]+(?:-[a-z0-9]+)*/[a-z0-9]+(?:-[a-z0-9]+)*$";

def commit_placeholder_pattern:
  "^__COMMIT_MESSAGE_PR_[0-9]+__$";

{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Do Stack Execution Manifest",
  "type": "object",
  "additionalProperties": false,
  "required": ["schema_version", "repo_root", "source_plan", "tasks", "commands"],
  "properties": {
    "schema_version": {
      "type": "string",
      "const": "1.0.0"
    },
    "repo_root": {
      "type": "string"
    },
    "source_plan": {
      "type": "object"
    },
    "tasks": {
      "type": "array",
      "minItems": 1,
      "items": {
        "$ref": "#/$defs/task"
      }
    },
    "commands": {
      "type": "array",
      "minItems": 1,
      "items": {
        "$ref": "#/$defs/command"
      }
    }
  },
  "$defs": {
    "implementation_subagent": {
      "type": "object",
      "additionalProperties": false,
      "required": ["required", "role", "objective", "input_fields", "expected_outputs"],
      "properties": {
        "required": {
          "type": "boolean",
          "const": true
        },
        "role": {
          "type": "string",
          "const": "implementation"
        },
        "objective": {
          "type": "string"
        },
        "input_fields": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "expected_outputs": {
          "type": "array",
          "items": {
            "type": "string"
          }
        }
      }
    },
    "commit_message_subagent": {
      "type": "object",
      "additionalProperties": false,
      "required": ["required", "role", "skill", "objective", "expected_outputs"],
      "properties": {
        "required": {
          "type": "boolean",
          "const": true
        },
        "role": {
          "type": "string",
          "const": "commit-message"
        },
        "skill": {
          "type": "string",
          "const": "$commit-msg"
        },
        "objective": {
          "type": "string"
        },
        "expected_outputs": {
          "type": "array",
          "items": {
            "type": "string"
          }
        }
      }
    },
    "task": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "pr_index",
        "task_id",
        "task_name",
        "phase_name",
        "depends_on_prs",
        "implementation_steps",
        "quality_gates",
        "commit_message_placeholder",
        "delegation"
      ],
      "properties": {
        "pr_index": {
          "type": "integer",
          "minimum": 1
        },
        "task_id": {
          "type": "string"
        },
        "task_name": {
          "type": "string"
        },
        "phase_name": {
          "type": "string"
        },
        "depends_on_prs": {
          "type": "array",
          "items": {
            "type": "integer",
            "minimum": 1
          }
        },
        "implementation_steps": {
          "type": "array"
        },
        "quality_gates": {
          "type": "array"
        },
        "commit_message_placeholder": {
          "type": "string",
          "pattern": commit_placeholder_pattern
        },
        "delegation": {
          "type": "object",
          "additionalProperties": false,
          "required": ["implementation_subagent", "commit_message_subagent"],
          "properties": {
            "implementation_subagent": {
              "$ref": "#/$defs/implementation_subagent"
            },
            "commit_message_subagent": {
              "$ref": "#/$defs/commit_message_subagent"
            }
          }
        }
      }
    },
    "create_args": {
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
    "submit_args": {
      "type": "array",
      "minItems": 5,
      "prefixItems": [
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
      ],
      "items": {
        "type": "string"
      }
    },
    "preflight_log_args": {
      "type": "array",
      "minItems": 3,
      "maxItems": 3,
      "prefixItems": [
        {
          "const": "log"
        },
        {
          "const": "short"
        },
        {
          "const": "--no-interactive"
        }
      ],
      "items": {
        "type": "string"
      }
    },
    "preflight_state_args": {
      "type": "array",
      "minItems": 2,
      "maxItems": 2,
      "prefixItems": [
        {
          "const": "state"
        },
        {
          "const": "--no-interactive"
        }
      ],
      "items": {
        "type": "string"
      }
    },
    "command": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "phase",
        "pr_index",
        "task_id",
        "task_name",
        "command_index",
        "args",
        "why",
        "execution_owner",
        "requires_subagent",
        "jit_commit_msg",
        "commit_message_placeholder",
        "step_index"
      ],
      "properties": {
        "phase": {
          "type": "string",
          "enum": ["preflight", "stack"]
        },
        "pr_index": {
          "type": ["integer", "null"],
          "minimum": 1
        },
        "task_id": {
          "type": ["string", "null"]
        },
        "task_name": {
          "type": ["string", "null"]
        },
        "command_index": {
          "type": "integer",
          "minimum": 0
        },
        "args": {
          "type": "array",
          "minItems": 2,
          "items": {
            "type": "string"
          }
        },
        "why": {
          "type": "string"
        },
        "execution_owner": {
          "type": "string",
          "const": "overseer"
        },
        "requires_subagent": {
          "type": ["string", "null"],
          "enum": ["commit-message", null]
        },
        "jit_commit_msg": {
          "type": "boolean"
        },
        "commit_message_placeholder": {
          "type": ["string", "null"],
          "pattern": "^(__COMMIT_MESSAGE_PR_[0-9]+__)?$"
        },
        "step_index": {
          "type": "integer",
          "minimum": 1
        }
      },
      "allOf": [
        {
          "if": {
            "properties": {
              "phase": {
                "const": "preflight"
              }
            }
          },
          "then": {
            "properties": {
              "pr_index": {
                "const": null
              },
              "task_id": {
                "const": null
              },
              "task_name": {
                "const": null
              },
              "command_index": {
                "const": 0
              },
              "requires_subagent": {
                "const": null
              },
              "jit_commit_msg": {
                "const": false
              },
              "commit_message_placeholder": {
                "const": null
              },
              "args": {
                "oneOf": [
                  {
                    "$ref": "#/$defs/preflight_log_args"
                  },
                  {
                    "$ref": "#/$defs/preflight_state_args"
                  }
                ]
              }
            }
          }
        },
        {
          "if": {
            "properties": {
              "phase": {
                "const": "stack"
              }
            }
          },
          "then": {
            "properties": {
              "command_index": {
                "enum": [1, 2]
              }
            }
          }
        },
        {
          "if": {
            "properties": {
              "phase": {
                "const": "stack"
              },
              "command_index": {
                "const": 1
              }
            }
          },
          "then": {
            "properties": {
              "pr_index": {
                "type": "integer",
                "minimum": 1
              },
              "task_id": {
                "type": "string"
              },
              "task_name": {
                "type": "string"
              },
              "args": {
                "$ref": "#/$defs/create_args"
              },
              "requires_subagent": {
                "const": "commit-message"
              },
              "jit_commit_msg": {
                "const": true
              },
              "commit_message_placeholder": {
                "type": "string",
                "pattern": commit_placeholder_pattern
              }
            }
          }
        },
        {
          "if": {
            "properties": {
              "phase": {
                "const": "stack"
              },
              "command_index": {
                "const": 2
              }
            }
          },
          "then": {
            "properties": {
              "pr_index": {
                "type": "integer",
                "minimum": 1
              },
              "task_id": {
                "type": "string"
              },
              "task_name": {
                "type": "string"
              },
              "args": {
                "$ref": "#/$defs/submit_args"
              },
              "requires_subagent": {
                "const": null
              },
              "jit_commit_msg": {
                "const": false
              },
              "commit_message_placeholder": {
                "const": null
              }
            }
          }
        }
      ]
    }
  }
}
