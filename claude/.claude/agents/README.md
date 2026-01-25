# Custom Subagents

Specialized agents for Claude Code. These are automatically available in all projects.

## Available Agents

| Agent | Purpose | Tools |
|-------|---------|-------|
| **planning-architecture** | System design, tech stack, database schema | Read-only |
| **planning-ux** | User flows, requirements, edge cases | Read-only |
| **planning-security** | Security requirements, testing strategy | Read-only |
| **coder** | Implement features and write code | All |
| **code-reviewer** | Security-focused code review | Read-only |
| **test-generator** | Unit, integration, and security tests | Read + Write |
| **debugger** | Debug errors and fix issues | All |
| **refactoring** | Code smell analysis, improvements | Read-only |
| **doc-writer** | Documentation and API docs | Read + Write |

## Usage

Claude automatically delegates to these agents based on the task. You can also request them explicitly:

```
Use the code-reviewer agent to review my recent changes
Use the planning-security agent to analyze security requirements
Use the test-generator agent to write tests for the auth module
```

## Notes

- Subagents run in isolated context and return summaries
- Read-only agents can't modify files (safer for analysis)
- Subagents can't spawn other subagents
- Use `/agents` to manage these from within Claude Code
