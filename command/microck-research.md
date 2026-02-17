---
type: command
description: Launches the Microck Deep Researcher for exhaustive, autonomous research on a topic.
---

<input>
Task(
    subagent_type="microck-researcher",
    description="Run deep recursive research",
    prompt="Start an exhaustive deep research session on the following topic. Initialize the planning files (task_plan.md, findings.md) if they don't exist. \n\nTOPIC: {{args}}"
)
</input>
