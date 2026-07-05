# OSI License Guide

Use this reference after reading the user's goals and project constraints.

The OSI licenses page states that OSI-approved licenses comply with the Open Source Definition and lists approved licenses with names, SPDX IDs, and categories.

Source: <https://opensource.org/licenses>.

## Default Shortlist

| Goal                                                                             | Prefer                               | SPDX ID                                           | Why                                                                                   |
| -------------------------------------------------------------------------------- | ------------------------------------ | ------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Maximize reuse with minimal obligations                                          | MIT                                  | MIT                                               | Simple permissive default with broad ecosystem recognition.                           |
| Permissive reuse plus explicit patent grant                                      | Apache License 2.0                   | Apache-2.0                                        | Strong default when patents, corporate adoption, or contributor patent grants matter. |
| Permissive reuse with traditional BSD terms                                      | BSD 2-Clause or BSD 3-Clause         | BSD-2-Clause or BSD-3-Clause                      | Common permissive alternatives with explicit redistribution conditions.               |
| Require derivative works to stay open source                                     | GNU General Public License v3        | GPL-3.0                                           | Strong copyleft for distributed software.                                             |
| Require hosted service modifications to be shared                                | GNU Affero General Public License v3 | AGPL-3.0                                          | Network copyleft for SaaS and server-side deployments.                                |
| Allow library linking from proprietary software while preserving library changes | GNU Lesser General Public License v3 | LGPL-3.0                                          | Weak copyleft for libraries.                                                          |
| Apply file-level copyleft                                                        | Mozilla Public License 2.0           | MPL-2.0                                           | Useful when only modified files should remain open.                                   |
| Use a business-friendly weak copyleft                                            | Eclipse Public License 2.0           | EPL-2.0                                           | Common in Eclipse and Java ecosystems.                                                |
| Use a public-domain-style option                                                 | Zero-Clause BSD                      | 0BSD                                              | OSI-approved minimal permissive option.                                               |
| License fonts                                                                    | SIL Open Font License                | OFL-1.1                                           | Special-purpose font license.                                                         |
| License open hardware designs                                                    | CERN Open Hardware Licence v2        | CERN-OHL-P-2.0, CERN-OHL-W-2.0, or CERN-OHL-S-2.0 | Special-purpose hardware licensing family.                                            |

## Decision Heuristics

- Choose `Apache-2.0` when the project may be used commercially and a patent grant is valuable.
- Choose `MIT` when simplicity and broad package-manager convention matter more than explicit patent terms.
- Choose `BSD-2-Clause` or `BSD-3-Clause` when the ecosystem expects BSD-style licensing.
- Choose `MPL-2.0` when you want copyleft to apply at file boundaries instead of the whole combined work.
- Choose `LGPL-3.0` when licensing a library and proprietary applications should be able to link to it.
- Choose `GPL-3.0` when distributed derivatives should remain under the same freedoms.
- Choose `AGPL-3.0` when hosted-service modifications should be shared with users over a network.
- Choose a special-purpose license only when the artifact type calls for it, such as fonts or hardware.

## Compatibility Checks

- Check whether existing dependencies impose reciprocal obligations before choosing a more permissive license.
- Check whether copied or vendored code already has license terms that must be preserved.
- Check whether contributors assigned rights or contributed under a developer certificate before relicensing.
- Check whether package ecosystems expect SPDX expressions in metadata.
- Check whether documentation, examples, test fixtures, data, models, fonts, and generated assets need separate licensing.

## Legal Review Triggers

- Existing code has multiple copyright holders.
- The user wants to relicense an existing project.
- The user wants dual licensing or commercial licensing.
- The project includes patent-sensitive technology.
- The project includes third-party code with unclear provenance.
- The user wants a non-OSI, source-available, field-of-use, non-commercial, or ethical-use restriction.
- The project ships cryptography, AI model weights, data, fonts, hardware designs, or standards-essential implementations.

## Implementation Notes

- Add a root `LICENSE` file using the canonical license text.
- Add the SPDX ID to package metadata where supported.
- Add per-file SPDX headers only when the project convention or target ecosystem expects them.
- Add `NOTICE` when the chosen license or bundled dependencies require notices.
- Keep copyright years and holder names consistent with project ownership.
