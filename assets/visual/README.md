# 视觉素材目录

本目录只存视觉资源文件，不写规则逻辑。

- `ui/`：界面背景、面板、按钮、边框等 UI 贴图。
- `static/`：地图背景、战斗背景、章节背景等静态场景图。
- `characters/`：角色立绘、头像、战斗精灵、敌方精灵图。
- `battle_animations/`：战斗动画、特效资源、序列帧或 `.tres` 动画资源。
- `icons/`：卡牌图标、状态图标、资源图标、按钮图标。

资源必须先登记到 `scripts/assets/VisualAssetDatabase.gd`，再由 UI、角色视觉或表现路由引用。
