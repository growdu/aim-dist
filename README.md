# aim-dist —— aim 的分发包（skill + agent）

**这是什么**：[aim](https://github.com/growdu/aim)（人物形象仓）的**Claude Code 侧**交付物。

aim 本身交付的是 **CLI**（仓根的 `./aim`）。这个包把同一件事
**接到 Claude Code 上**：

| 交付物 | 装到哪 | 是干什么的 |
| --- | --- | --- |
| **skill** | `~/.claude/skills/aim/` | 教 agent **怎么用 aim**：流程、铁律、命令表 |
| **agent** | `~/.claude/agents/aim.md` | 一个**专职代理**：改契约、跑渲染、查素材 |

**为什么单独一个包**：aim 仓保持纯粹——它是一个**跑东西的仓**，
不是 Claude Code 的配置仓。把 skill / agent 放进去，两边都要改对方的形状。

**怎么保证不脱节**：skill / agent 里的**铁律与流程**指的是 aim 仓里那份
（`AGENTS.md` / `specs/`），**不是抄一份**；
命令表在**安装时从 aim 仓现生成**（单一出处，不会过期）。

---

## 装

```bash
git clone https://github.com/growdu/aim-dist.git && cd aim-dist
./install.sh                       # 装到 ~/.claude
./install.sh --aim-home /path/aim  # aim 仓不在旁边就指一份
./install.sh --model /path/model.json  # 顺便指一个人
./install.sh --uninstall           # 卸掉
```

装的是**「模板 + aim 仓路径」**——
`install.sh` 把 `{{AIM_HOME}}` / `{{AIM_MODEL}}` 换掉再写进目标目录。
所以**换了 aim 仓的位置，重装一次**就行。

**新开一个会话才会加载。**

### 装完是什么样

```
~/.claude/skills/aim/
├── SKILL.md              # skill 本体（铁律 + 流程 + 命令表）
└── references/
    ├── commands.md       # 命令总表（安装时从 aim 仓生成）
    └── agent.md          # agent 的副本（方便手翻）
~/.claude/agents/aim.md   # agent 本体
```

---

## 用

**skill** 是给**任何会话**用的：说到「人物形象 / 品牌片 / 铭牌 / model.json」，
它就会知道 aim 是怎么回事、该读哪几份规范、铁律有哪些。

**agent** 是给**专职干活**用的：`/agents` 里选它，
或者让它直接处理「把确认结论落成 model.json」「修品牌片底板配色」这类活。

两样都**只读 aim 仓**，改的都是 aim 仓里的文件——
**不 import 它的模块**（缝是一个文件）。

---

## 打 tarball

```bash
./pack.sh            # → dist/aim-dist-<日期>.tar.gz
```

给别人：`tar xzf aim-dist-*.tar.gz && cd aim-dist && ./install.sh`。

---

## 这个包自己守什么

- **它不含 aim 的实现**——只有模板 + 安装脚本。
  实现只有一份，在 aim 仓里。
- **它不改 aim 仓**——安装全程只往目标目录写。
- **命令表是生成的**，不是手抄的——aim 加了命令，重装就有。
