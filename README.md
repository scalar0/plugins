# Skills

This repository contains one plugin with skills for code, documentation, build tools, and repository work.
Each skill has a `SKILL.md` file and keeps its scripts and references in the same directory.

| Item              | Path                       | Use                                                |
| ----------------- | -------------------------- | -------------------------------------------------- |
| Plugin manifest   | [plugin.json](plugin.json) | Identify the plugin and provide Codex metadata.    |
| Skill directories | [skills/](skills/)         | Load a skill in a host that supports Agent Skills. |

Use the repository root as the plugin directory in a host that supports Agent Plugins.
For a host that supports Agent Skills, add the `skills/` directory to its skill search path.
Some skills call tools that the host must provide.
Read each `SKILL.md` file before you use that skill in a new host.
