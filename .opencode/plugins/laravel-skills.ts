import { tool, type Plugin } from "@opencode-ai/plugin";
import path from "path";

function scriptPath(name: string): string {
  return path.join(path.resolve(import.meta.dir, "../.."), "scripts", name);
}

async function runBashScript(script: string, args: string[]): Promise<string> {
  const proc = Bun.spawn(["bash", script, ...args], {
    stdout: "pipe",
    stderr: "pipe",
  });
  const [stdout, stderr, code] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
    proc.exited,
  ]);
  if (code !== 0) {
    throw new Error((stderr || stdout).trim() || `${script} exited with ${code}`);
  }
  return stdout.trim();
}

/**
 * OpenCode plugin for this skills repository.
 *
 * Loads automatically when OpenCode runs with this repo as the project.
 * Exposes the same bash scripts as custom tools (in addition to running them directly).
 *
 * Skills are discovered from ~/.config/opencode/skills after `link-skills.sh opencode`,
 * or from .agents/skills in a project after `link-skills.sh --project <dir> opencode`.
 */
export const LaravelSkillsPlugin: Plugin = async () => {
  return {
    tool: {
      link_skills: tool({
        description:
          "Symlink Laravel agent skills from this repo into skill directories (Claude, OpenCode, or Agents). Run with target 'all' after cloning or updating this repo.",
        args: {
          target: tool.schema
            .enum(["claude", "opencode", "agents", "all"])
            .default("all")
            .describe("Where to install: claude (~/.claude/skills), opencode (~/.config/opencode/skills), agents (~/.agents/skills), or all"),
          project: tool.schema
            .string()
            .optional()
            .describe("Also link into <project>/.agents/skills (opencode/agents) and/or .claude/skills"),
        },
        async execute(args) {
          const argv: string[] = [];
          if (args.project) {
            argv.push("--project", args.project);
          }
          argv.push(args.target);
          const out = await runBashScript(scriptPath("link-skills.sh"), argv);
          return out || "Skills linked successfully.";
        },
      }),

      list_skills: tool({
        description: "List all SKILL.md files in the Laravel skills repository",
        args: {
          name_only: tool.schema
            .boolean()
            .default(false)
            .describe("If true, print skill folder names only"),
        },
        async execute(args) {
          const argv = args.name_only ? ["--name-only"] : [];
          return runBashScript(scriptPath("list-skills.sh"), argv);
        },
      }),
    },
  };
};
