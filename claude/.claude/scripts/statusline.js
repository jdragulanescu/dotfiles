#!/usr/bin/env node

const fs = require('fs');
const { execFileSync } = require('child_process');
const path = require('path');

// Colors
const RESET = '\x1b[0m';
const DIM = '\x1b[2m';
const MAGENTA = '\x1b[35m';
const YELLOW = '\x1b[33m';
const CYAN = '\x1b[36m';
const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const WHITE = '\x1b[37m';
const BLUE = '\x1b[34m';

// Read JSON from stdin
let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    render(data);
  } catch (e) {
    console.log(`${DIM}statusline error${RESET}`);
  }
});

function formatTokens(tokens) {
  if (tokens >= 1000) {
    return Math.floor(tokens / 1000) + 'k';
  }
  return String(tokens);
}

function formatDuration(ms) {
  const seconds = Math.floor(ms / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);

  if (hours > 0) {
    const remainingMins = minutes % 60;
    return `${hours}h${remainingMins}m`;
  } else if (minutes > 0) {
    return `${minutes}m`;
  }
  return `${seconds}s`;
}

function buildProgressBar(percent, width = 10) {
  const filled = Math.floor(percent * width / 100);
  const empty = width - filled;
  return '[' + '='.repeat(filled) + ' '.repeat(empty) + ']';
}

function getModelVersion(modelId, modelName) {
  if (modelId?.includes('opus-4-5')) return 'Opus 4.5';
  if (modelId?.includes('opus-4')) return 'Opus 4';
  if (modelId?.includes('sonnet-4')) return 'Sonnet 4';
  if (modelId?.includes('sonnet-3-5')) return 'Sonnet 3.5';
  if (modelId?.includes('haiku')) return 'Haiku';
  return modelName || 'Claude';
}

function getGitInfo(cwd) {
  try {
    const branch = execFileSync('git', ['rev-parse', '--abbrev-ref', 'HEAD'], {
      cwd,
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'pipe']
    }).trim();

    let dirty = false;
    try {
      execFileSync('git', ['diff', '--quiet'], { cwd, stdio: ['pipe', 'pipe', 'pipe'] });
      execFileSync('git', ['diff', '--cached', '--quiet'], { cwd, stdio: ['pipe', 'pipe', 'pipe'] });
    } catch {
      dirty = true;
    }

    return { branch, dirty };
  } catch {
    return { branch: null, dirty: false };
  }
}

function parseAgentsFromTranscript(transcriptPath) {
  try {
    const stats = fs.statSync(transcriptPath);
    const fileSize = stats.size;

    // Read last ~100KB for performance on large files
    const readSize = Math.min(fileSize, 100 * 1024);
    const startPos = Math.max(0, fileSize - readSize);

    const buffer = Buffer.alloc(readSize);
    const fd = fs.openSync(transcriptPath, 'r');
    fs.readSync(fd, buffer, 0, readSize, startPos);
    fs.closeSync(fd);

    const content = buffer.toString('utf8');
    const lines = content.split('\n');

    // Track tool_use ids for Task agents and their completions
    const taskAgents = new Map(); // id -> { subagent_type }
    const completedIds = new Set();

    for (const line of lines) {
      if (!line.trim()) continue;

      try {
        const entry = JSON.parse(line);
        const message = entry.message;
        if (!message || !message.content) continue;

        for (const block of message.content) {
          // Check for Task tool_use (agent spawn)
          if (block.type === 'tool_use' && block.name === 'Task' && block.id) {
            const subagentType = block.input?.subagent_type || 'agent';
            taskAgents.set(block.id, { subagent_type: subagentType });
          }

          // Check for tool_result (agent completion)
          if (block.type === 'tool_result' && block.tool_use_id) {
            completedIds.add(block.tool_use_id);
          }
        }
      } catch {
        // Skip malformed JSON lines
      }
    }

    // Return running agents (spawned but not completed)
    const runningAgents = [];
    for (const [id, info] of taskAgents) {
      if (!completedIds.has(id)) {
        runningAgents.push({
          id,
          subagent_type: info.subagent_type,
          status: 'running',
          context_usage: { input_tokens: 0, output_tokens: 0 }
        });
      }
    }

    return runningAgents;
  } catch {
    return [];
  }
}

function render(data) {
  // Extract main session data
  const model = data.model || {};
  const modelVersion = getModelVersion(model.id, model.display_name);

  const contextWindow = data.context_window || {};
  const percentUsed = Math.floor(contextWindow.used_percentage || 0);
  const contextSize = contextWindow.context_window_size || 200000;
  const currentUsage = contextWindow.current_usage || {};

  const inputTokens = currentUsage.input_tokens || 0;
  const cacheRead = currentUsage.cache_read_input_tokens || 0;
  const cacheCreation = currentUsage.cache_creation_input_tokens || 0;

  let totalTokens = inputTokens + cacheRead + cacheCreation;
  if (totalTokens === 0) {
    totalTokens = contextWindow.total_input_tokens || 0;
  }

  const totalInput = contextWindow.total_input_tokens || 0;
  const totalOutput = contextWindow.total_output_tokens || 0;

  // Cache efficiency
  let cachePercent = 0;
  if (totalTokens > 0 && cacheRead > 0) {
    cachePercent = Math.floor(cacheRead * 100 / totalTokens);
  }

  // Cost and stats
  const cost = data.cost || {};
  const totalCost = cost.total_cost_usd || 0;
  const durationMs = cost.total_duration_ms || 0;
  const linesAdded = cost.total_lines_added || 0;
  const linesRemoved = cost.total_lines_removed || 0;

  // Directory
  const workspace = data.workspace || {};
  const currentDir = workspace.current_dir || '';
  const projectDir = workspace.project_dir || '';

  let dirDisplay = path.basename(currentDir);
  if (currentDir === projectDir || currentDir.startsWith(projectDir + '/')) {
    dirDisplay = path.basename(projectDir);
  }

  // Git
  const git = getGitInfo(currentDir);

  // Format values
  const tokensDisplay = formatTokens(totalTokens);
  const contextDisplay = formatTokens(contextSize);
  const inputDisplay = formatTokens(totalInput);
  const outputDisplay = formatTokens(totalOutput);
  const durationDisplay = formatDuration(durationMs);
  const costDisplay = `$${totalCost.toFixed(2)}`;
  const bar = buildProgressBar(percentUsed);

  // === LINE 1: Model, context, tokens, cost ===
  let line1 = '';
  line1 += `${MAGENTA}${modelVersion}${RESET} `;
  line1 += `${DIM}${bar}${RESET} `;
  line1 += `${YELLOW}${percentUsed}%${RESET}`;
  line1 += ` ${DIM}|${RESET} `;
  line1 += `${WHITE}${tokensDisplay}/${contextDisplay}${RESET}`;
  line1 += ` ${DIM}|${RESET} `;
  line1 += `${DIM}↓${RESET}${CYAN}${inputDisplay}${RESET} ${DIM}↑${RESET}${MAGENTA}${outputDisplay}${RESET}`;
  line1 += ` ${DIM}|${RESET} `;
  line1 += `${DIM}cost${RESET} ${YELLOW}${costDisplay}${RESET}`;

  console.log(line1);

  // === BLANK LINE ===
  console.log(' ');

  // === LINE 2: Stats + location ===
  let line2 = '';
  line2 += `${DIM}lines${RESET} ${GREEN}+${linesAdded}${RESET}${DIM}/${RESET}${RED}-${linesRemoved}${RESET}`;

  if (cachePercent > 0) {
    line2 += ` ${DIM}|${RESET} `;
    line2 += `${DIM}cache${RESET} ${CYAN}${cachePercent}%${RESET}`;
  }

  line2 += ` ${DIM}|${RESET} `;
  line2 += `${DIM}time${RESET} ${BLUE}${durationDisplay}${RESET}`;
  line2 += ` ${DIM}|${RESET} `;
  line2 += `${GREEN}${dirDisplay}${RESET}`;

  if (git.branch) {
    line2 += ` ${DIM}on${RESET} `;
    line2 += `${CYAN}${git.branch}${RESET}`;
    if (git.dirty) {
      line2 += `${RED}*${RESET}`;
    }
  }

  console.log(line2);

  // === AGENT LINES ===
  let subAgents = data.sub_agents || [];

  // If no sub_agents provided, try parsing from transcript
  if (subAgents.length === 0 && data.transcript_path) {
    subAgents = parseAgentsFromTranscript(data.transcript_path);
  }

  const runningAgents = subAgents.filter(a => a.status === 'running');

  if (runningAgents.length > 0) {
    // Blank separator
    console.log(' ');

    // Find max agent name length for alignment
    const maxNameLen = Math.max(...runningAgents.map(a => (a.subagent_type || 'agent').length));

    for (const agent of runningAgents) {
      const agentType = agent.subagent_type || 'agent';
      const paddedName = agentType.padEnd(maxNameLen);

      const ctx = agent.context_usage || {};
      const agentInput = ctx.input_tokens || 0;
      const agentOutput = ctx.output_tokens || 0;
      const agentTotal = agentInput + agentOutput;

      // Assume subagents have ~128k context window
      const agentContextSize = 128000;
      const agentPercent = Math.min(100, Math.floor(agentTotal * 100 / agentContextSize));
      const agentBar = buildProgressBar(agentPercent);

      let agentLine = '';
      agentLine += `${CYAN}◉${RESET} `;
      agentLine += `${WHITE}${paddedName}${RESET} `;
      agentLine += `${DIM}${agentBar}${RESET} `;
      agentLine += `${YELLOW}${agentPercent}%${RESET}`;
      agentLine += ` ${DIM}|${RESET} `;
      agentLine += `${WHITE}${formatTokens(agentTotal)}/${formatTokens(agentContextSize)}${RESET}`;
      agentLine += ` ${DIM}|${RESET} `;
      agentLine += `${DIM}↓${RESET}${CYAN}${formatTokens(agentInput)}${RESET} ${DIM}↑${RESET}${MAGENTA}${formatTokens(agentOutput)}${RESET}`;

      console.log(agentLine);
    }
  }
}
