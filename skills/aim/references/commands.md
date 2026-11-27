# 命令总表（安装时从 aim 仓生成）

> 这一份是**兜底**——`install.sh` 装的时候会从 aim 仓**现生成**一份覆盖它。
> 单一出处是 aim 仓自己的命令表（`aimkit/cli.py`），不在这儿手抄。

| 命令 | 干什么 |
| --- | --- |
| `aim doctor` | 体检：这个人的契约与素材齐不齐（只报告，不改） |
| `aim model build` | 把确认结论归一化成 model.json（校验通过才写） |
| `aim font install` | 装内置字体子集（跨机版式一致靠它） |
| `aim character generate` | 从形象原型生成主形象与 6 姿态表（消耗生成额度） |
| `aim character glasses` | 给形象戴眼镜（没声明眼镜就整体跳过） |
| `aim character badge` | 盖铭牌：刷白那块白矩形，再用真实字体写上品牌词 |
| `aim character clear-badge` | 抹掉铭牌，产出「无标牌」素材 |
| `aim character white` | 把透明底素材铺成白底（合成，不重新生成） |
| `aim brand poses` | 生成品牌片用的点赞 / 挥手姿态素材 |
| `aim brand backgrounds` | 生成品牌片用的两张 AI 背景（含语义验收） |
| `aim brand render` | 渲染品牌片头 / 片尾（2.833s，1920×1080） |
| `aim brand fix-plates` | 修复底板里被 16:9 裁断的文字（真实字体重排） |
| `aim brand audio` | 按配乐窗口切曲混音，产出成品音轨 |
| `aim voice measure` | 量测参照录音的音色特征 |
| `aim voice check` | 查多音字读音对不对 |

**参数原样转交**给脚本，**退出码原样传回**——完整参数看 `aim <命令> --help`。
