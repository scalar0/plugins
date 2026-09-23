# Skills Marketplace

This repository is a Codex plugin marketplace.
It contains the `swe` plugin with skills for code, documentation, build tools, and repository work.
Each skill keeps its scripts and references in its own directory.

| Item | Path | Use |
| --- | --- | --- |
| Marketplace | [.agents/plugins/marketplace.json](.agents/plugins/marketplace.json) | List plugins for Codex. |
| Plugin manifest | [plugins/swe/plugin.json](plugins/swe/plugin.json) | Identify the `swe` plugin. |
| Skills | [plugins/swe/skills/](plugins/swe/skills/) | Provide workflows for the `swe` plugin. |

## Add the marketplace to Codex

Choose one marketplace source.

| Source | Command |
| --- | --- |
| Local clone | `codex plugin marketplace add .` from the repository root |
| Git repository | `codex plugin marketplace add scalar0/skills` after you push this change |

1. Run `codex plugin list` to check that `swe@me` appears.
2. Run `codex plugin add swe@me` to install the plugin.
3. Restart the ChatGPT desktop app to view the marketplace in the Plugins Directory.

For a Git source, run `codex plugin marketplace upgrade me` after you push later changes.

An old `me@scalar0-skills` install does not update to `swe@me`.
After you install `swe@me`, run `codex plugin remove me@scalar0-skills` if you no longer need the old plugin.

Use [plugins/swe/](plugins/swe/) as the plugin directory in a host that supports Agent Plugins.
For a host that supports Agent Skills, add [plugins/swe/skills/](plugins/swe/skills/) to its skill search path.
Some skills call tools that the host must provide.
Read each `SKILL.md` file before you use that skill in a new host.
