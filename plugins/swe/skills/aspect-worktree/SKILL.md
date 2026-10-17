---
name: aspect-worktree
description: >
    Take, use and release a pooled git worktree with `aspect worktree`, so each
    parallel task gets its own checkout with Bazel already warm. Trigger when the
    user asks for a new worktree, for isolated or parallel work, or for worktree
    cleanup.
---

## Pooled worktrees

Never run `git worktree add`. A worktree at a path Bazel has not seen is a cold build, and deleting it strands an output base that nothing in Bazel reclaims. `aspect worktree` hands out **slots**: directories at reused paths, so Bazel's state survives from one task to the next and many tasks cost one output base rather than one each.

Run `aspect describe 'worktree add'` (or `aspect worktree --help`) for the current flags. This page is the workflow; that is the reference. Every command takes `--output=json` and answers with one document, which is how you read a result or a refusal without parsing prose.

<Note>
  Fetching this page programmatically? Append `.md` to the URL for the source. The rendered page may come back summarized, and a summary of a workflow is not a workflow.
</Note>

### Safety boundary

- The main clone is not a work directory. Work happens in a slot.
- Never `git stash`. The stash stack is shared by every worktree of the clone, so another session can pop what you pushed.
- Never discard someone's uncommitted work. `aspect worktree release` refuses a dirty slot and lists the files; only pass `--force` when the user has said to. Untracked build output is not counted and never blocks a release: the `bazel-*` symlinks, and a `MODULE.bazel.lock` the repo does not track. A **tracked** file that changed always counts, lock file included — if that is all the refusal lists, committing it is usually the way through, and that is a decision for the user.
- A slot `aspect worktree list` shows as held by another session is not yours, and nor is a taken slot with no agent beside it: a person took that one at a terminal — unless you took it yourself and your harness is not detected, which `inspect` in your own slot shows. Taking it over, or ending its lease with `release --force=all`, is a decision for the user, and never one to make while that session is still running. Plain `--force` never touches another session's lease.
- A git worktree inside a slot — one your harness makes under an ignored `.claude/worktrees/`, say — is work in that slot, listed as `NW` ("a worktree nested in this one"): removing the slot would delete it. `release` refuses without `--force`, and the slot is not taken back or pruned while it is there.
- A slot whose directory is gone — moved with `mv`, or deleted — while git still keeps commits only its HEAD reflog reaches (`DH`), refs only it has (`WR`), an operation in progress (`IP`) or a staged index (`IX`) keeps its lease. `release` refuses it, saying the slot "holds a checkout gone from its directory, with work git still keeps for it", listed under `VG` with a `DH` line naming the commits: if it was moved, `git worktree repair <its new path>` from the clone brings it back; otherwise the `git branch <name> <sha>` the `DH` line names keeps them. `add --take-over` refuses it too. `--force` discards them and frees the branch, and that is the user's decision.
- Never run `aspect worktree prune` unless asked. It deletes warm state other sessions are relying on.
- Never delete a Bazel output base by hand, and never run `aspect gc` unless asked: it removes idle output bases across every repository on the machine. `aspect gc --dry-run` shows what it would take.

### Take a slot

`add` behaves as `git worktree add` does: it checks out a branch that exists — in this clone, or only on a remote, which it then tracks — and refuses a name that does not. New work says so with `--create=origin/main`, which starts it from a fresh main — bare `--create` would start from wherever you stand:

```shell theme={null}
git fetch origin
slot=$(aspect worktree add <branch> --create=origin/main --output=path) && cd "$slot"
```

To pick up an existing branch — yours, a teammate's, a pull request's — leave `--create` off:

```shell theme={null}
slot=$(aspect worktree add <branch> --output=path) && cd "$slot"
```

To build or read something without working on it — a tag, a SHA, a branch checked out elsewhere — take it on no branch:

```shell theme={null}
slot=$(aspect worktree add <commit-ish> --detach --output=path) && cd "$slot"
```

A detached slot has no branch to be named by, so `path` and `release` take the slot id `add` prints, or the ref you gave while no other slot is at it. Anything you commit there needs a branch before release — `git switch -c <branch>` — and `release` refuses with `unreferenced_commits` until it has one.

Use the two-step form. `cd "$(aspect worktree add …)"` returns 0 even when the command fails, because the substitution is empty and `cd ""` does nothing, so you would carry on in the main clone believing you had moved.

If your harness refuses compound shell commands, run the `aspect worktree add … --output=path` on its own and `cd` into the path it prints in the next command. Check the exit status first: on failure nothing is printed. Where it refuses `cd <slot> && git …`, run git as `git -C <slot> …` instead.

Every command writes its human-readable output to stderr. Stdout carries only `--output=json`, `--output=path`, and the directory `aspect worktree path` prints, so capturing any of them is safe; `aspect worktree list 2>/dev/null` prints nothing.

If it fails, branch on the `error` token in the JSON, not on the sentence. When `retryable` is true for `pool_busy` or `branch_pending` (exit 75), or for `slot_setting_up` or `reservation_lost`, wait a moment and run the same command again. `slot_warm`, from `prune`, is retryable too but clears only when Bazel's idle timeout fires, which can be hours: report it rather than wait. Everything else is a decision, and the table says whose:

| `error`                                 | What it means                                                                                                                                                                                                                                                                                                                                          | What you do                                                                                                                                                                                                                                                                                                                                                                                                             |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pool_busy`, `branch_pending` (exit 75) | Another call was writing the pool's bookkeeping, or checking out the branch you asked for                                                                                                                                                                                                                                                              | Wait a moment and retry. Under `--create`, `branch_pending` exits 1 instead: another agent is creating that branch, so choose another name                                                                                                                                                                                                                                                                              |
| `no_such_branch`                        | No branch by that name here or on a remote this clone has fetched                                                                                                                                                                                                                                                                                      | A typo: use `closest` — with `aspect worktree path <branch>` when the message suggests it, since your session already holds that branch. A branch somebody else pushed: `git fetch`, then retry — never `--create` a name that may be theirs. New work: `--create=origin/main`                                                                                                                                          |
| `not_a_branch`                          | You named a remote branch, a tag or a commit; `kind` says which                                                                                                                                                                                                                                                                                        | `remote_branch`: ask for the branch without the remote. `branch_case`: use the spelling in `branch`. Otherwise `--create=<it>` for new work, `--detach` to only build or read it                                                                                                                                                                                                                                        |
| `ambiguous_remote_branch`               | Several remotes have the branch, none of them `origin`                                                                                                                                                                                                                                                                                                 | Ask the user which, then `--create=<remote>/<branch>`                                                                                                                                                                                                                                                                                                                                                                   |
| `branch_exists`, `remote_branch_exists` | `--create` was given a name already in use                                                                                                                                                                                                                                                                                                             | Leave `--create` off to work on that branch, or choose another name                                                                                                                                                                                                                                                                                                                                                     |
| `no_such_ref`                           | The ref for `--create=` or `--detach` does not resolve                                                                                                                                                                                                                                                                                                 | Fix it (`closest`), or `git fetch` first                                                                                                                                                                                                                                                                                                                                                                                |
| `invalid_branch`, `conflicting_flags`   | The name or the flag combination cannot work                                                                                                                                                                                                                                                                                                           | Fix the command                                                                                                                                                                                                                                                                                                                                                                                                         |
| `checkout_failed`                       | `git worktree add` failed in the slot it chose, or that slot still held uncommitted work                                                                                                                                                                                                                                                               | Report the message to the user                                                                                                                                                                                                                                                                                                                                                                                          |
| `branch_held_by_this_session`           | Your session already holds a slot on that branch                                                                                                                                                                                                                                                                                                       | If you took it, `aspect worktree path <branch>`. Subagents report their parent's session, so if you did not, a sibling did: use a different branch, never its slot                                                                                                                                                                                                                                                      |
| `branch_in_use`                         | Another session holds that branch                                                                                                                                                                                                                                                                                                                      | When `same_session` is true it is your own session or a sibling subagent: take a branch of your own and leave it to the session; only a slot your session holds comes with a `path` — a subagent gets only its own, and the session itself its subagents'. Otherwise report it to the user — never take over a running session's slot. `--take-over` only on their say-so — it inherits that session's uncommitted work |
| `branch_elsewhere`                      | Checked out outside the pool, usually in the main clone                                                                                                                                                                                                                                                                                                | Do not work there. `aspect worktree add <new-branch> --create=<branch>`, or `--detach` to only build it                                                                                                                                                                                                                                                                                                                 |
| `worktree_dirty`                        | Release refused: uncommitted changes, listed in `uncommitted`                                                                                                                                                                                                                                                                                          | If `holder` names another session, the work is not yours: report it — discarding it needs `--force=all` and is the user's decision. If it names your own subagent and you are the session itself, discarding is your session's decision. Otherwise commit it; discarding with `--force` is the user's decision                                                                                                          |
| `unreferenced_commits`                  | Release refused: commits only the slot's HEAD reaches, listed by their `tips` — the fewest whose branches keep them all                                                                                                                                                                                                                                | `git branch <branch> <tip>` from the clone for each, then release                                                                                                                                                                                                                                                                                                                                                       |
| `held_by_another_session`               | Another session's lease; `uncommitted` lists what it would lose                                                                                                                                                                                                                                                                                        | Not yours. `--force=all` is the user's decision, never while that session runs. When `same_session` is true it is your own session's or a sibling subagent's: leave it — the session itself, run without an `--agent-id`, releases it or takes it over. No flag overrides that for a subagent, and `path` refuses a subagent its parent session's slot too                                                              |
| `no_such_worktree`, `slot_not_leased`   | Nothing of that name is out, or the slot is already free                                                                                                                                                                                                                                                                                               | `no_such_worktree` carries `names` and `closest`, and `ended` when your session's lease on that branch ended in the last day — then `aspect worktree add <branch>` takes it again; `slot_not_leased` names the slot. `aspect worktree list` shows what is out                                                                                                                                                           |
| `slot_setting_up`                       | An `add` is still checking a worktree out into that slot                                                                                                                                                                                                                                                                                               | Wait a moment and try again while `retryable` is true; with `abandoned: true` that `add` has stopped, and `add` of its branch recovers it                                                                                                                                                                                                                                                                               |
| `owned_elsewhere`                       | The slot belongs to another clone of the repository                                                                                                                                                                                                                                                                                                    | Run the command from that clone                                                                                                                                                                                                                                                                                                                                                                                         |
| `slot_stranded`                         | The slot belongs to a clone that is gone or moved, or to the clone that was at this one's path before it — or is this clone's own, damaged                                                                                                                                                                                                             | Report it to the user. If that clone moved, the command run from where it is now takes the slot back. If the message names `git worktree repair`, that is the user's to try. Otherwise deleting it with the `prune` command the message names is their decision                                                                                                                                                         |
| `invalid_agent`                         | The agent kind or id given is not usable: the kind is not a name, or the id is all spaces, over 128 characters, or has a character a terminal would act on or hide (a control, zero-width, bidirectional, separator, invisible, filler, variation-selector, musical formatting or tag character), which the message shows escaped inside double quotes | Fix the `--agent-kind` / `--agent-id` value, or the `ASPECT_AGENT_KIND` / `ASPECT_AGENT_ID` it came from                                                                                                                                                                                                                                                                                                                |
| `not_a_repository`                      | You are not in a clone                                                                                                                                                                                                                                                                                                                                 | `cd` into the repository                                                                                                                                                                                                                                                                                                                                                                                                |

`path` and `release` take a branch, a slot id, or the slot's directory — whichever you have. A slot found by its branch is found by the branch checked out in it, so one you ran `git switch` in answers to the new name.

**`warnings`** in the JSON of a successful `add` are worth reading. `pool_over_limit` means the pool grew past its budget: release any slot you are done with, and tell the user. `upstream_elsewhere` means an existing branch tracks a branch of another name, so a bare `git push` could land there: push with the explicit `git push -u` it names. `score_hook_failed` means the repository's scoring hook is broken or too slow; mention it to the user. `lease_reclaimed` means the slot was taken back from a stopped session, whose `branch` and `previous_holder` it names. Files git ignores go with a checkout on `release` without being listed: keep nothing you need in one.

Fetching from any worktree of the clone updates them all. `add` says what a new branch was created from, and what its upstream is.

A branch made with `--create` has no upstream, so your first push must name it: `git push -u origin <branch>`. A bare `git push` has nothing to target, which is deliberate. A branch picked up from a remote tracks that remote branch already.

### Working in parallel

Subagents report their parent's session, so to `list` every slot your siblings hold looks like yours — and filtering by session would hand you theirs to release. When you fan work out, give each agent its own id and use it on every call:

```shell theme={null}
aspect worktree add <branch> --create=origin/main --agent-id=<session>-<task> --output=json
aspect worktree inspect --agent-id=<session>-<task>
aspect worktree release <branch> --agent-id=<session>-<task>
```

Every `aspect worktree` command takes `--agent-id`. Setting `ASPECT_AGENT_ID` once in each agent's environment does the same. `path` will not hand an agent another session's slot, a sibling's, or one a person took at a terminal: only the session itself gets its own subagents' slots. The ids are what tells siblings apart, and the commands a refusal suggests carry the id.

A subagent's lease records your session as its `parent_id`, and `list --verbose` lists it under your session with the subagent named. Its liveness is your session's, so a subagent that crashed still reads as running: whether it stopped is yours to know. Run as the session itself, without an `--agent-id` of your own, you can act on a subagent's slot as on your own: `aspect worktree release <branch>` ends its lease (`--force` to discard its uncommitted work), and `aspect worktree add <branch> --take-over` takes the slot with its work — your call, not the user's, since the work is your session's own. A sibling subagent cannot: `release` and `--take-over` of another sibling's slot are refused, with `same_session: true`, and the message says to leave it to the session. Neither `add`'s `branch_in_use` nor `path`'s `held_by_another_session` gives an agent the `path` of a slot it does not hold: a subagent gets only its own — not a sibling's, and not its parent session's — and only the session itself gets its subagents'. It is told the slot's id, not the way into it. In refusals, `same_session: true` marks a holder in your harness session.

Keep the `slot` and `path` each `add` returns, and act on those. Take slots with `--output=json` rather than `--output=path` when you start several at once: it gives both.

`add` takes a slot back on its own from a session whose process stopped more than `Worktrees.abandoned_grace_hours` ago — counted from the slot's last activity — and whose checkout holds nothing to lose. Files git ignores do not count as something to lose: its checkout is removed and the branch asked for is checked out fresh there, which `INFO: taking back …` says. Work in a checkout always keeps the slot. Once a stopped session's slot is taken back, a plain `add` of its branch gives you that branch, so make sure it is yours to work on. The grace period is set in `.aspect/config.axl`, by the user rather than by an agent:

```python theme={null}
load("@aspect//traits.axl", "Worktrees")
def config(ctx: ConfigContext):
    ctx.traits[Worktrees].abandoned_grace_hours = 48
```

A resumed session keeps its slots too: when it runs `path`, `inspect` anywhere in the clone or its slots, or `add` of a branch already leased, every lease of the session — its subagents' included — moves to its new process, provided the one recorded has stopped. Leases are matched by the session id the harness reported, never by an `--agent-id` you chose; a session whose harness reports no session id has none moved.

### Finding your slot again

If you lose track of where you were working:

- `aspect worktree inspect`, run from the clone, lists the slots this session holds with their branches and paths — run as the session itself, its subagents' too, each named — then the leases of this session that ended in the last day: released, taken over, or taken back. Their commits are on their branches. A held slot whose checkout directory is gone is marked ``(checkout gone: `aspect worktree release` says why)``; `release` of it names what git still keeps for it and how to keep that. With `--output=json` these are `held` and `ended`, each `held` entry `{slot, branch, path, agent_id, gone}`, `gone` true for such a slot, and each `ended` entry `{branch, slot, ended_ms, agent_id}`, `agent_id` naming the subagent and empty for the session's own lease.
- `aspect worktree path <branch>` prints one slot's directory again.
- After a resume (`claude --resume`), run `aspect worktree inspect` early, from the clone or a slot. Run by your session from a new process, it moves every lease of your session — your subagents' included — off a recorded process that has stopped onto the new one, so the slots read as running and are not taken back; `aspect worktree path <branch>` and `add` of a leased branch do the same. A lease whose process was never captured is left as it is. To keep working on a branch listed under `ended`, `add` it again.
- `aspect worktree inspect --output=json`, run inside the slot, gives its full state: `branch`, `head`, `head_on_remote`, `uncommitted` and `base_sha`.

### Work in it

Nothing in the slot has to be an Aspect command. Bazel derives its output base from the directory, so `bazel`, `aspect`, an IDE or a script all reach the same warm state.

```shell theme={null}
bazel test //...
```

<Note>
  If a fresh checkout in your repo needs setting up — symlinking ignored files such as `.env`, running `direnv allow`, installing hooks — say so here. The pool hands over a checkout and a warm output base; it has no idea what else your repo expects.
</Note>

### Release it

Releasing removes the checkout and keeps the branch: every commit stays in the clone, so the only thing a release can lose is work you have not committed. Decide by what the work needs, not by fear of losing it.

`aspect worktree inspect --output=json`, run in the slot, gives the evidence: `head`, `head_on_remote`, `uncommitted`, and where a branch you created started — `base` as you named it, `base_sha` as the commit it was then.

| Evidence                                                                     | Verdict                                                                                    |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Uncommitted changes, Bazel's output aside                                    | **Hold.** Commit them, then decide by the rows below. If they are not yours to commit, ask |
| Pull request open, or you will keep working on it                            | **Hold.** The work is live                                                                 |
| Pull request merged, or the tip is an ancestor of the branch it started from | **Release**                                                                                |
| Pushed, no pull request                                                      | **Release.** The work is on the remote                                                     |
| Not on any remote                                                            | **Push it**, or with no reachable remote **archive it**, then release                      |
| Pull request closed without merging                                          | **Archive it, then ask**                                                                   |

To archive, bundle only what the branch added: `git bundle create <file> <base_sha>..<branch>`, using `base_sha` from `inspect` — the commit, since a ref like `origin/main` moves on the next fetch. `base_sha` is empty for a branch that already existed in the clone; then start from `$(git merge-base origin/main <branch>)`, or bundle the whole branch with `git bundle create <file> <branch>`. For a branch picked up from a remote, `base_sha` is the remote's tip when you took it, so the bundle holds only your commits on top. Run `git bundle` from the clone or the slot — branches are shared — and check it with `git bundle verify <file>`. If you commit again after archiving, archive again: the bundle stops at the tip it was made from. Say where you left it, and how to restore it: `git fetch <file> <branch>:<branch>` in a clone that has `base_sha`.

A branch you only picked up to read — a teammate's, a pull request's — leaves a local copy behind after release; `git branch -D <branch>` from the clone removes it.

If you started a Bazel server in the slot and want it gone, `bazel shutdown` there first: once the slot is released there is nowhere to run it from. `cd` back to the directory you ran `add` from — usually the main clone — before releasing. A release from inside the slot removes the directory your shell is standing in, and every later command from there fails; `release` warns when that has happened and names where to go back to. An `aspect` command run from the removed directory fails with "the current directory no longer exists — if it was a worktree that was released, `cd` back into the clone".

```shell theme={null}
aspect worktree release <branch>
```

The slot keeps its Bazel state for whoever takes it next, so releasing costs nothing and skipping it is not an error — it does hold a slot nobody is using. Releasing twice is not an error either. `release` says when the branch's commits are on no remote, which is the row above to act on.

### Reclaiming disk

`aspect worktree list` shows how long each free slot has been idle. `aspect gc` reclaims output bases machine-wide; `aspect worktree prune` retires a whole slot — all the stale ones, or just the one you name. Running either is the user's call (see Safety boundary); `--dry-run` on either only looks. When `add` warns that the pool is over its advisory limit, release what you are done with and tell the user; `prune --dry-run` shows what could go, and deletes nothing.

<Note>
  `aspect worktree inspect` reports the slot you are standing in — its Bazel state,
  its history, and how to get back to the session holding it. `aspect worktree
    list --all` covers every pool on the machine, which is the one way to answer
  "what did I leave alone because another session held it".
</Note>

## Report back

- the slot path and the branch;
- what you released, and what you held with the reason and the files;
- any archive you created, and how to restore it;
- anything you left alone because another session held it.

If anything is ambiguous, leave it in place and say so.
