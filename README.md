# Skills

This repository contains one plugin with skills for code, documentation, build tools, and repository work.
Each skill has a `SKILL.md` file and keeps its scripts and references in the same directory.

| Item              | Path                                                   | Use                                                |
| ----------------- | ------------------------------------------------------ | -------------------------------------------------- |
| Marketplace       | [.agents/plugins/marketplace.json](.agents/plugins/marketplace.json) | List the plugin for Codex.                          |
| Plugin manifest   | [plugin.json](plugin.json)                             | Identify the plugin and provide Codex metadata.    |
| Skill directories | [skills/](skills/)                                     | Load a skill in a host that supports Agent Skills. |

## Add the marketplace to Codex

1. From the repository root, run `codex plugin marketplace add .`.
2. Run `codex plugin list` to check that `me@scalar0-skills` appears.
3. Run `codex plugin add me@scalar0-skills` to install the plugin.
4. Restart the ChatGPT desktop app to view the marketplace in the Plugins Directory.

After you push this repository to GitHub, use `codex plugin marketplace add scalar0/skills` to track the Git repository.
Run `codex plugin marketplace upgrade scalar0-skills` after you push changes.

Use the repository root as the plugin directory in a host that supports Agent Plugins.
For a host that supports Agent Skills, add the `skills/` directory to its skill search path.
Some skills call tools that the host must provide.
Read each `SKILL.md` file before you use that skill in a new host.
