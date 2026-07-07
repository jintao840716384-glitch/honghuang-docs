# 音频素材目录

本目录只存听觉资源文件，不写播放规则。

- `sfx/`：战斗音效、卡牌音效、通用一次性音效。
- `ui/`：按钮、确认、悬停等 UI 音效。
- `music/`：主菜单、战斗、地图等循环音乐。
- `ambience/`：环境底噪、地图气氛音。
- `voice/`：未来角色语音或旁白。

音频事件必须先登记到 `scripts/audio/AudioEventDatabase.gd`，再由 `AudioManager.gd` 播放。
