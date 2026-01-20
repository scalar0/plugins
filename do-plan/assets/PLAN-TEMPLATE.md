# Implementation Plan

## Executive Summary

<!-- Executive summary here -->

## Key Objectives

<!-- List key objectives here -->

## High-Level Approach

<!-- Describe the overall approach here -->

<!-- Begin Phase list -->

# Phase {int:PhaseId}

| PhaseId | Name     | Goal                                         | Deliverable |
| ------- | -------- | -------------------------------------------- | ----------- |
| {int}   | {string} | {Specific, measurable objective, 1 sentence} | {string}    |

<!-- A phase is broken down into tasks, each with sequential steps, quality gates, risks. -->

## Risks

| RiskId                    | Description | Impact       | Likelihood   | Mitigation |
| ------------------------- | ----------- | ------------ | ------------ | ---------- |
| {PhaseId}.{int:RiskIndex} | {string}    | {1,2,3 (/3)} | {1,2,3 (/3)} | {string}   |

<!-- Additional rows -->

<!-- Begin Tasks list -->

## Task {PhaseId}.{int:TaskIndex}

| TaskId                    | Name     | Dependencies                                |
| ------------------------- | -------- | ------------------------------------------- |
| {PhaseId}.{int:TaskIndex} | {string} | {TaskId or List[TaskId], else 0 if no deps} |

<!-- If a Task is dependent on a whole phase {PhaseId} then its dependency is the last task of the phase {PhaseId}. -->

### Sequential Steps

| StepId               | Description | Verification |
| -------------------- | ----------- | ------------ |
| {TaskId}.{StepIndex} | {string}    | {`command`}  |

<!-- Additional rows -->

### Quality Gates

| GateId               | Description | Validation  |
| -------------------- | ----------- | ----------- |
| {TaskId}.{GateIndex} | {string}    | {`command`} |

<!-- Additional rows -->

<!-- Additional Tasks -->

<!-- End Phase -->
