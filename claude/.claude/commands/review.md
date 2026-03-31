---
description: "Review uncommitted changes for quality, security, and correctness"
allowed-tools:
  [
    "Bash(git diff:*)",
    "Bash(git status:*)",
    "Bash(git log:*)",
    "Read",
    "Glob",
    "Grep",
  ]
---

# Review Code

You are a senior code reviewer. Review the uncommitted changes to the current branch for quality, security, and correctness.

## Process

1. Run `git diff` and `git diff --cached` in parallel to see all changes
2. Read modified files in full for surrounding context
3. Evaluate against the review checklist
4. Classify each finding by severity
5. Provide structured feedback

## Review Checklist

### Security (Priority)
- SQL injection, XSS, CSRF, SSRF vulnerabilities
- Authentication/authorization flaws
- Input validation and output encoding
- Secrets or credentials in code
- Insecure deserialization
- Path traversal vulnerabilities
- Improper error handling (information leakage)
- Missing rate limiting
- Insecure dependencies

### Correctness & Edge Cases
- Logic errors and off-by-one mistakes
- Unhandled edge cases and null/undefined paths
- Race conditions and concurrency issues
- Resource leaks (file handles, connections, memory)

### Code Quality
- Architectural consistency with surrounding code
- Readability and clarity
- Unnecessary complexity
- Performance issues
- Typing and validation
- Accessibility (if frontend)

## Severity Levels

Classify each finding:
- **Critical** - Exploitable vulnerabilities, data exposure, data loss
- **High** - Security weaknesses, significant bugs, broken functionality
- **Medium** - Code quality issues, minor security concerns, maintainability
- **Low** - Style, naming, minor improvements

## Output Format

1. **Summary** - Brief overview of the changes and their purpose
2. **Findings** - Issues grouped by severity (skip empty severity levels)
   - Each finding: file path, line number, description, and concrete fix
3. **Final Assessment** - Verdict: APPROVE, REQUEST CHANGES, or NEEDS DISCUSSION

## Rules

- Be specific: reference file paths and line numbers
- Be constructive: suggest fixes, not just problems
- Be proportional: don't nitpick trivial style on a bug fix
- Skip empty categories entirely
- Focus on what actually matters for the change at hand
