<p align="center">
  <h1 align="center">RimTidy</h1>
  <p align="center">
    基于 <a href="https://github.com/RimSort/RimSort">RimSort</a> 重构的 RimWorld Mod 管理器<br>
    使用 QML 重写界面，新增文件夹分类、Mod 备注等实用功能
  </p>
  <p align="center">
    <strong>Windows · Linux</strong>
  </p>
</p>

---

![RimTidy 预览](./docs/rimsort_preview.png)

## 关于本项目

RimTidy 是基于 [RimSort](https://github.com/RimSort/RimSort) 的二次开发版本。感谢 RimSort 原团队的开源贡献，为 RimWorld 社区提供了优秀的 Mod 管理工具。

本项目在 RimSort 的基础上，使用 **QML** 对用户界面进行了重构，并新增了多项实用功能。

## 相比 RimSort 的变化

### 界面重构

- 使用 **QML** 重写了整个前端界面，替代原有的 Qt Widgets 实现
- 通过 Python Bridge 架构实现 QML 与后端的通信，保持业务逻辑不变
- 无边框窗口 + 自定义标题栏，视觉更现代

### 新增功能

- **文件夹分类** — 在未激活 Mod 列表中创建虚拟文件夹，拖拽 Mod 进行分类管理。纯视觉组织，不影响实际 Mod 文件。文件夹支持展开/折叠、重命名、删除，Mod 从激活列表拖回时自动归位到之前所在的文件夹
- **单 Mod 备注** — 点击任意 Mod 后可在信息面板中添加个人备注，按 Mod 独立存储，重启后保留
- **设置后自动刷新** — 在设置中配置或自动检测路径后，关闭设置对话框即自动扫描并加载 Mod 列表，无需重启
- **中文界面** — 通过 i18n 系统提供完整的简体中文翻译

### 保留的核心功能

RimSort 的所有核心能力均完整保留：

- 拓扑排序 / 依赖解析 / 加载顺序优化
- Steam 创意工坊集成 / SteamCMD 支持
- 社区规则数据库
- 冲突检测（缺失依赖、不兼容、加载顺序违规）
- 多实例管理
- Mod 列表导入/导出（XML、剪贴板、存档、Rentry.co）
- Git Mod 克隆
- 纹理批量优化（DDS）
- 深色/浅色主题

## 安装

| 平台 | 说明 |
|------|------|
| **Windows** | 解压后运行 `RimTidy.exe` |
| **Linux** | 解压后运行 `RimTidy`（也可通过 RPM 安装） |

## 从源码构建

需要 **Python 3.12** 和 [uv](https://github.com/astral-sh/uv) 包管理器。

```bash
git clone --recurse-submodules <your-repo-url>
cd RimTidy

# 安装依赖
just dev-setup

# 运行 QML 界面
uv run python -m app --use-qml

# 运行原版 Qt Widgets 界面
just run

# 测试 / 代码检查
just test
just check
```

## 技术架构

```
QML 界面层  ←→  Python Bridge 层  ←→  核心业务逻辑（排序/元数据/Steam）
```

- **QML + JS** — 前端界面渲染、文件夹状态管理、拖拽交互
- **Python Bridge** — `ModListModel`、`AppBridge`、`ModInfoBridge` 等桥接对象
- **核心层不变** — 排序算法、元数据管理、Steam 集成等均沿用 RimSort 原有实现

## 致谢

- [RimSort](https://github.com/RimSort/RimSort) — 原项目及其开发团队，感谢开源
- [RimSort Discord](https://discord.gg/aV7g69JmR2) — 社区交流

## 许可证

本项目开源，详见 [LICENSE](./LICENSE)。

---

# English

RimTidy is a fork of [RimSort](https://github.com/RimSort/RimSort), rebuilt with a **QML-based interface** and enhanced with new features. Thanks to the RimSort team for their open-source contribution to the RimWorld modding community.

**Supported platforms:** Windows, Linux

### What's Changed

**UI Rewrite:** The entire frontend has been rebuilt using QML, replacing the original Qt Widgets implementation. A Python Bridge architecture connects QML to the unchanged backend logic.

**New Features:**
- **Virtual folders** — Organize inactive mods into drag-and-drop folders (visual only, no file changes). Mods automatically return to their folder when moved back from the active list.
- **Per-mod notes** — Add personal annotations to any mod, persisted across sessions.
- **Auto-refresh after settings** — Mod lists reload automatically after configuring paths, no restart needed.
- **Chinese localization** — Full Simplified Chinese translation via i18n system.

**Preserved:** All RimSort core features remain fully functional — topological sorting, Steam Workshop/SteamCMD integration, community rules, conflict detection, multi-instance, import/export, Git mods, texture optimization, and theming.

### Credits

- [RimSort](https://github.com/RimSort/RimSort) — Original project and team
- [RimSort Discord](https://discord.gg/aV7g69JmR2) — Community

### License

Open source. See [LICENSE](./LICENSE) for details.
