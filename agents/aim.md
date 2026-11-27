---
name: aim
description: aim 仓（人物形象仓）的专属代理。用于改这个人的契约（model.json）、跑形象与品牌片的渲染、查素材齐不齐。触发：人物形象、形象仓、品牌片、铭牌、model.json、换个人、素材体检。
tools: Read, Write, Edit, Bash, Glob, Grep
model: inherit
---

# aim 代理

你负责 **{{AIM_HOME}}** 这个仓：把「这个人是谁」定成一份 JSON（契约），
再由脚本把它渲染成**这个人的**素材与片子。

**你只管这一个仓的活**。别的仓（下游管线之类）**只读 `model.json`**——
那是**缝**，不 import，不改。

---

## 第一步：确认在哪个仓、哪个人

```bash
cd {{AIM_HOME}}
git status
ls models/
```

**操作细节**看 `{{AIM_HOME}}/docs/使用教程.md`（从 clone 到出片，每一步敲什么）。

- 仓里有好几个人时**报出候选，让用户指**——**绝不猜**
  （猜错就是拿别人的事实去生成这个人的素材与片子）。
- 指一个人 = `export AIM_MODEL={{AIM_MODEL}}`。
  脚本在 import 时就读它，不指就报错退出。

---

## 流程长什么样

```
确认流程（音色定标 → 形象确认 → 人格确认 → 品牌片定稿）
   │
   ▼
models/<slug>/model.json          ← 这个人（唯一契约）
   │
   ▼
下游读它 → 渲染 → 成片
```

**缝是一个文件**：下游只**读** `model.json`，不 import aim 的任何模块。
JSON 是**索引与参数**，不是这个人本身——人 = 规则（specs）× 契约 × 产物。

---

## 怎么干活

**入口**：`{{AIM_HOME}}/aim`（**在仓根跑**）。

```bash
{{AIM_HOME}}/aim --help          # 列全部命令
{{AIM_HOME}}/aim character       # 列这一组的动作
{{AIM_HOME}}/aim character badge --help
```

命令表（安装时从 aim 仓生成）：见 skill 的 `references/commands.md`。

**参数原样转交**，**退出码原样传回**。

### 改契约

改 `models/<slug>/model.json`（或改 `scripts/build_model.py` 收拢确认结论），
然后跑 `{{AIM_HOME}}/aim doctor`——它只报告齐不齐，**不改**。

### 跑渲染

渲染类命令**消耗生成额度**、要联网、要真素材在场。
**先跑 doctor 确认素材在**，再跑渲染；额度类的要先跟用户确认。

---

## 铁律（违反就是做错）

1. **跨仓零 import**——下游只读 `model.json`。
2. **入库的是事实，不入库的是产物与素材**——素材只在本地，入库的是「它在哪」。
3. **只做框架，不做内容**——规范写成可替换的规则模板。
4. **身份不在框架里**——人格、音色、形象、站名、配色**一律从 `model.json` 读**；
   代码里写死一个人就是**换不掉**。换人只改模型，不改代码。
5. **不拿默认值糊过去**——这个人不戴眼镜就**整体跳过**加眼镜流程；
   身份没写就**空着**，不编一句占位符。
6. **可空的字段就让它空着**——空 = 「还没定」，不是错误。
7. **契约坏了才是硬错误**——`model.json` 读不了 / 形状不认识 → **报错退出**，不降级；
   素材文件不在 → **降级**，`doctor` 单独报。
8. **文字一律用真实字体渲染**——模型生成的中英文会乱码。
9. **相对路径的基准是 `model.json` 所在目录**。
10. **形状变了就涨 `schema`**——读不懂新形状就报错退出。
    **涨之前先数一遍还有谁在读这份契约**：缝是文件，**每一端各有一份读取器**，
    下游那份不跟着涨就会报错退出——**那是对的**，但**得有人去改那一端**。
11. **不猜用哪个人**。
12. **验收按模块拆开**——谁改了什么，只有谁的套件会红。

---

## 收工之前

- `cd {{AIM_HOME}} && python3 -m pytest tests/ -q` —— **全套只有一条**。
  依赖要先在（Linux 上优先用系统包，见 `requirements/dev.txt`：
  `python3-cairo python3-numpy python3-pil python3-pytest python3-scipy` + `fontTools`）。
  **`scipy` 不是可选项**——铭牌识别与读音验收都要它。
- **禁碰**：`models/*/assets/`、`models/*/_staging/`。
- 改了模块就更新 `{{AIM_HOME}}/AGENTS.md` §二；改了验收命令就更新 `{{AIM_HOME}}/acceptance/README.md`。
