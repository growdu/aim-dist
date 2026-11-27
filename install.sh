#!/usr/bin/env bash
# 把 aim 的 skill 与 agent 装进 Claude Code。
#
#   ./install.sh                        # 装到 ~/.claude
#   ./install.sh --target /tmp/claude   # 装到别处（先看看效果）
#   ./install.sh --aim-home /path/aim   # 指一份别的 aim 仓
#   ./install.sh --model /path/model.json
#   ./install.sh --uninstall            # 卸掉
#
# **它不联网、不改 aim 仓**——只往目标目录写两个文件（外加一份命令表）。
set -euo pipefail

PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET="${HOME}/.claude"
AIM_HOME_ARG=""
MODEL_ARG=""
UNINSTALL=0

while [ $# -gt 0 ]; do
  case "$1" in
    --target)   TARGET="$2"; shift 2 ;;
    --aim-home) AIM_HOME_ARG="$2"; shift 2 ;;
    --model)    MODEL_ARG="$2"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help)
      sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "不认识的参数：$1" >&2; exit 2 ;;
  esac
done

# --- 找 aim 仓 -------------------------------------------------------
find_aim_home() {
  if [ -n "$AIM_HOME_ARG" ]; then echo "$AIM_HOME_ARG"; return; fi
  if [ -n "${AIM_HOME:-}" ]; then echo "$AIM_HOME"; return; fi
  for candidate in "$PKG_DIR/../aim" "$PKG_DIR/../aim-repo"; do
    if [ -f "$candidate/aimkit/cli.py" ]; then
      (cd "$candidate" && pwd); return
    fi
  done
  echo ""   # 找不到
}

AIM_HOME="$(find_aim_home)"

if [ "$UNINSTALL" -eq 1 ]; then
  python3 - "$TARGET" <<'PY'
import shutil, sys
from pathlib import Path
target = Path(sys.argv[1])
removed = []
skill = target / "skills" / "aim"
agent = target / "agents" / "aim.md"
if skill.exists():
    shutil.rmtree(skill); removed.append(str(skill))
if agent.exists():
    agent.unlink(); removed.append(str(agent))
print("卸掉了：" + (", ".join(removed) if removed else "（本来就没装）"))
PY
  exit 0
fi

if [ -z "$AIM_HOME" ]; then
  echo "找不到 aim 仓。用 --aim-home /path/aim 指一份，或设 AIM_HOME 环境变量。" >&2
  exit 2
fi
if [ ! -f "$AIM_HOME/aimkit/cli.py" ]; then
  echo "那不像是个 aim 仓（没有 aimkit/cli.py）：$AIM_HOME" >&2
  exit 2
fi

AIM_HOME="$(cd "$AIM_HOME" && pwd)"

# --- 装 ---------------------------------------------------------------
# 用 python 写文件：路径里有空格 / 中文 / 特殊字符都不怕，
# 也不怕目标机器上 `cp` 被别成了交互式（会卡住等输入）。
python3 - "$PKG_DIR" "$TARGET" "$AIM_HOME" "$MODEL_ARG" <<'PY'
import shutil, sys
from pathlib import Path

pkg, target, aim_home, model = (Path(sys.argv[1]), Path(sys.argv[2]),
                                Path(sys.argv[3]), sys.argv[4])

skill_dst = target / "skills" / "aim"
agent_dst = target / "agents" / "aim.md"
skill_dst.mkdir(parents=True, exist_ok=True)
agent_dst.parent.mkdir(parents=True, exist_ok=True)

model_text = model or f"{aim_home}/models/<slug>/model.json"

def render(text: str) -> str:
    return (text.replace("{{AIM_HOME}}", str(aim_home))
                .replace("{{AIM_MODEL}}", model_text))

# skill：SKILL.md + references/
(skill_dst / "SKILL.md").write_text(
    render((pkg / "skills" / "aim" / "SKILL.md").read_text(encoding="utf-8")),
    encoding="utf-8")
(skill_dst / "references").mkdir(exist_ok=True)
(skill_dst / "references" / "commands.md").write_text(
    render((pkg / "skills" / "aim" / "references" / "commands.md").read_text(encoding="utf-8")),
    encoding="utf-8")

# agent：装到 references/ 旁边，好让人手翻到
agent_text = render((pkg / "agents" / "aim.md").read_text(encoding="utf-8"))
agent_dst.write_text(agent_text, encoding="utf-8")
(skill_dst / "references" / "agent.md").write_text(agent_text, encoding="utf-8")

print(f"skill → {skill_dst}")
print(f"agent → {agent_dst}")
PY

# --- 命令表：从 aim 仓现生成（单一出处，不会过期）-------------------
if command -v python3 >/dev/null 2>&1; then
  ( cd "$AIM_HOME" && python3 - "$TARGET" <<'PY'
import sys
from pathlib import Path
sys.path.insert(0, str(Path.cwd()))
from aimkit.cli import COMMANDS
target = Path(sys.argv[1])
lines = ["# 命令总表（安装时从 aim 仓生成）", "",
         "| 命令 | 干什么 |", "| --- | --- |"]
for c in COMMANDS:
    lines.append(f"| `aim {c.path}` | {c.summary} |")
out = target / "skills" / "aim" / "references" / "commands.md"
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"命令表 → {out}（{len(COMMANDS)} 条）")
PY
  ) || echo "命令表没生成（aim 仓里的命令表读不出来）——不影响 skill 能用" >&2
fi

echo
echo "装好了。装的是「模板 + aim 仓路径」——"
echo "  skill：$TARGET/skills/aim/SKILL.md"
echo "  agent：$TARGET/agents/aim.md"
echo "新开一个会话才会加载。"
