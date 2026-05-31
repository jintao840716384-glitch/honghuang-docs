# Godot 4.6.x 常用节点速查表

> 当前使用版本：Godot 4.6.3
> 文档适用范围：Godot 4.6.x
> 项目方向：2D 像素风 / 顶视角 / 修仙刷怪游戏
> 说明：本表不是 Godot 节点大全，只记录当前项目和学习阶段最常用、最容易混淆、最值得记忆的节点与资源。
> 规则：节点 Node 和资源 Resource 分开记；旧教程里的旧节点名统一放到“旧版本名称对照”。

---

# 0. 阅读规则

| 项目    | 说明                     |
| ----- | ---------------------- |
| 英文名   | Godot 里实际搜索节点/资源时使用的名称 |
| 中文记忆名 | 方便自己记忆的中文叫法，不一定是官方翻译   |
| 类型    | 节点 / 资源 / 属性 / 概念      |
| 主要用途  | 它大概负责什么                |
| 常见搭配  | 通常和哪些东西一起使用            |
| 项目用途  | 在《洪荒修仙》项目里可能怎么用        |

---

# 1. 先记结论：当前项目第一批必须熟

| 英文名              | 类型 | 中文记忆名  | 一句话理解                   |
| ---------------- | -- | ------ | ----------------------- |
| Node             | 节点 | 普通空节点  | 最基础的逻辑容器，本身不显示、不带2D位置   |
| Node2D           | 节点 | 2D空节点  | 2D世界里的基础容器，有位置、旋转、缩放    |
| Sprite2D         | 节点 | 单张图片   | 显示一张2D图片                |
| AnimatedSprite2D | 节点 | 逐帧动画图片 | 播放像素角色/怪物的帧动画           |
| CharacterBody2D  | 节点 | 角色身体   | 玩家、敌人这种用代码控制移动的角色       |
| Area2D           | 节点 | 检测区域   | 只检测进入/离开/重叠，不负责真实阻挡     |
| CollisionShape2D | 节点 | 碰撞形状   | 给身体或区域提供实际碰撞范围          |
| Camera2D         | 节点 | 2D摄像机  | 控制玩家看到哪里                |
| CanvasLayer      | 节点 | UI固定层  | 让UI固定在屏幕上，不跟地图移动        |
| Control          | 节点 | UI基础节点 | 所有UI节点的基础父类             |
| Label            | 节点 | 文字     | 显示文字                    |
| Button           | 节点 | 按钮     | 可点击按钮                   |
| Panel            | 节点 | 面板     | UI背景框                   |
| ProgressBar      | 节点 | 进度条    | 血条、经验条、灵力条              |
| TileMapLayer     | 节点 | 瓦片地图层  | Godot 4.6 里制作2D瓦片地图的主节点 |
| Timer            | 节点 | 计时器    | 延迟、冷却、周期触发              |

---

# 2. 基础组织节点

| 英文名         | 类型 | 中文记忆名 | 主要用途                       | 常见搭配                            | 项目用途                                  |
| ----------- | -- | ----- | -------------------------- | ------------------------------- | ------------------------------------- |
| Node        | 节点 | 普通空节点 | 最基础节点，不负责显示和2D坐标，常用来做逻辑根节点 | 任意节点                            | GameManager、BattleManager、DataManager |
| Node2D      | 节点 | 2D空节点 | 2D世界基础节点，有位置、旋转、缩放         | Sprite2D、Area2D、CharacterBody2D | 地图物体容器、特效容器、敌人容器                      |
| Marker2D    | 节点 | 2D标记点 | 在编辑器里标记一个位置，本身不显示游戏图像      | Node2D、PackedScene              | 玩家出生点、怪物刷新点、技能发射点                     |
| CanvasLayer | 节点 | UI固定层 | 让UI独立于游戏世界，不受摄像机移动影响       | Control、Label、Button            | 血条层、菜单层、浮字层、战斗UI层                     |

## 记忆重点

* `Node`：纯逻辑，不带2D位置。
* `Node2D`：2D世界里的空节点，适合当场景物体根节点。
* `Marker2D`：专门放位置点，比如刷怪点、出生点、技能发射点。
* `CanvasLayer`：UI专用固定层，不跟着地图乱跑。

---

# 3. 2D显示节点

| 英文名              | 类型 | 中文记忆名  | 主要用途                      | 常见搭配                          | 项目用途               |
| ---------------- | -- | ------ | ------------------------- | ----------------------------- | ------------------ |
| Sprite2D         | 节点 | 单张图片   | 显示一张2D图片，也可以显示图集中的一部分     | Node2D、Area2D、CharacterBody2D | 静态角色、道具、草药、矿石、背景装饰 |
| AnimatedSprite2D | 节点 | 逐帧动画图片 | 播放多帧动画，需要 SpriteFrames 资源 | SpriteFrames、CharacterBody2D  | 角色待机、走路、攻击、受击、怪物动画 |
| Line2D           | 节点 | 2D线条   | 绘制线段、路径、轨迹                | Node2D                        | 技能轨迹、调试线、范围提示      |
| Polygon2D        | 节点 | 2D多边形  | 绘制一个多边形区域                 | Node2D                        | 简单色块、临时区域表现，前期少用   |
| GPUParticles2D   | 节点 | GPU粒子  | 用GPU生成大量2D粒子              | Node2D、Texture2D              | 火焰、灵气、爆炸、飘散粒子      |
| CPUParticles2D   | 节点 | CPU粒子  | 用CPU生成2D粒子，兼容性较好但性能弱一些    | Node2D、Texture2D              | 少量粒子、测试粒子效果        |

## 记忆重点

* `Sprite2D`：只放一张图。
* `AnimatedSprite2D`：放一组帧动画。
* `GPUParticles2D`：后期做技能特效可能用。
* `Line2D`：画技能轨迹、调试范围时有用。

---

# 4. 2D物理与碰撞节点

| 英文名                | 类型 | 中文记忆名     | 主要用途                   | 常见搭配                                       | 项目用途                  |
| ------------------ | -- | --------- | ---------------------- | ------------------------------------------ | --------------------- |
| CharacterBody2D    | 节点 | 角色身体      | 适合玩家、敌人这种由代码控制移动的角色    | CollisionShape2D、Sprite2D、AnimatedSprite2D | 玩家、敌人、NPC             |
| Area2D             | 节点 | 检测区域      | 检测其他物体进入、离开、重叠，不负责真实阻挡 | CollisionShape2D、CollisionPolygon2D        | 拾取范围、技能命中范围、交互范围、仇恨范围 |
| StaticBody2D       | 节点 | 静态阻挡体     | 不主动移动的物理阻挡物            | CollisionShape2D、Sprite2D                  | 墙、石头、障碍物、地图边界         |
| RigidBody2D        | 节点 | 刚体        | 受物理系统影响，会被力、碰撞推动       | CollisionShape2D、Sprite2D                  | 前期少用，适合物理道具           |
| AnimatableBody2D   | 节点 | 可动画移动的物理体 | 适合通过动画或代码移动，但仍参与碰撞的物体  | CollisionShape2D、AnimationPlayer           | 移动平台、机关，前期少用          |
| CollisionShape2D   | 节点 | 碰撞形状      | 给物理体或检测区提供具体形状         | CharacterBody2D、Area2D、StaticBody2D        | 玩家碰撞盒、怪物碰撞盒、技能范围      |
| CollisionPolygon2D | 节点 | 多边形碰撞     | 用自定义多边形做碰撞范围           | Area2D、StaticBody2D                        | 不规则范围、复杂地形，前期少用       |

## 记忆重点

* `CharacterBody2D`：会走路的角色身体。
* `Area2D`：只检测，不阻挡。
* `StaticBody2D`：不会动的墙和障碍。
* `CollisionShape2D`：没有它，身体/区域通常没有实际范围。
* `RigidBody2D`：真实物理，前期少碰，容易复杂。

---

# 5. 动画相关节点与资源

## 5.1 动画节点

| 英文名              | 类型      | 中文记忆名   | 主要用途                     | 常见搭配                    | 项目用途                |
| ---------------- | ------- | ------- | ------------------------ | ----------------------- | ------------------- |
| AnimatedSprite2D | 节点      | 逐帧动画节点  | 播放像素帧动画                  | SpriteFrames            | 角色待机、移动、攻击、受击       |
| AnimationPlayer  | 节点      | 通用动画播放器 | 控制属性动画，比如位置、缩放、透明度、颜色、显隐 | Sprite2D、Node2D、Control | UI动画、受击闪烁、技能特效、镜头动画 |
| AnimationTree    | 节点      | 动画状态树   | 管理复杂动画状态切换               | AnimationPlayer         | 后期角色动画复杂后再用         |
| Tween            | 概念/代码对象 | 补间动画    | 用代码平滑改变属性                | Node、Control、Sprite2D   | UI弹出、数字变化、简单位移动画    |

## 5.2 动画资源

| 英文名          | 类型 | 中文记忆名 | 主要用途                       | 常见搭配             | 项目用途                        |
| ------------ | -- | ----- | -------------------------- | ---------------- | --------------------------- |
| SpriteFrames | 资源 | 精灵帧资源 | 给 AnimatedSprite2D 存放多组帧动画 | AnimatedSprite2D | idle、walk、attack、hurt、death |
| Animation    | 资源 | 动画资源  | 给 AnimationPlayer 使用的动画数据  | AnimationPlayer  | UI动画、属性动画、特效动画              |

## 记忆重点

* 像素角色动作用 `AnimatedSprite2D + SpriteFrames` 最直观。
* 属性变化、UI弹出、受击闪烁，用 `AnimationPlayer` 更合适。
* `AnimationTree` 先知道即可，前期不要急着用。
* `SpriteFrames` 是资源，不是节点。

---

# 6. UI界面节点

| 英文名                | 类型 | 中文记忆名  | 主要用途              | 常见搭配                        | 项目用途           |
| ------------------ | -- | ------ | ----------------- | --------------------------- | -------------- |
| Control            | 节点 | UI基础节点 | 所有常见UI节点的基础父类     | Button、Label、Panel          | UI根节点          |
| Panel              | 节点 | 面板     | 显示一个背景框           | Label、Button、VBoxContainer  | 属性面板、背包面板、提示框  |
| PanelContainer     | 节点 | 面板容器   | 带面板背景的容器，可自动包住子节点 | Label、VBoxContainer         | 更规整的UI面板       |
| Button             | 节点 | 按钮     | 可点击按钮             | Label、Control               | 修炼按钮、战斗按钮、菜单按钮 |
| Label              | 节点 | 普通文字   | 显示普通文字            | Panel、Control               | 数值、标题、说明       |
| RichTextLabel      | 节点 | 富文本    | 显示带格式的文字          | Control、Panel               | 功法说明、技能说明、剧情文本 |
| TextureRect        | 节点 | UI图片   | 在UI里显示图片          | Control、Panel               | 头像、图标、技能图片     |
| ProgressBar        | 节点 | 普通进度条  | 显示数值进度            | Label、Panel                 | 血条、经验条、灵力条     |
| TextureProgressBar | 节点 | 图片进度条  | 用图片表现进度条          | Texture2D、Control           | 更好看的血条/蓝条      |
| VBoxContainer      | 节点 | 竖排容器   | 子UI自动纵向排列         | Button、Label、Panel          | 竖向菜单、属性列表      |
| HBoxContainer      | 节点 | 横排容器   | 子UI自动横向排列         | Button、Label、TextureRect    | 技能栏、状态栏        |
| GridContainer      | 节点 | 网格容器   | 子UI按网格排列          | TextureRect、Button          | 背包格子、技能格子      |
| ScrollContainer    | 节点 | 滚动容器   | 内容超过区域时允许滚动       | VBoxContainer、RichTextLabel | 长文本、背包、日志      |
| MarginContainer    | 节点 | 边距容器   | 给子UI添加边距          | Panel、VBoxContainer         | UI排版留白         |
| ColorRect          | 节点 | 色块     | 显示纯色矩形            | Control                     | 遮罩、背景色块、调试UI   |

## 记忆重点

* UI基本都在 `CanvasLayer` 下面。
* UI节点通常继承 `Control`，不属于普通2D世界。
* `Sprite2D` 是游戏世界图片；`TextureRect` 是UI图片。
* 背包、技能栏这类格子，用 `GridContainer` 很方便。
* 长文本说明，用 `RichTextLabel`。

---

# 7. 地图与瓦片

## 7.1 地图节点

| 英文名                | 类型 | 中文记忆名 | 主要用途                                       | 常见搭配               | 项目用途            |
| ------------------ | -- | ----- | ------------------------------------------ | ------------------ | --------------- |
| TileMapLayer       | 节点 | 瓦片地图层 | Godot 4.6.x 中绘制2D瓦片地图的主节点，一层一个TileMapLayer | TileSet            | 地面层、墙体层、装饰层、遮挡层 |
| ParallaxBackground | 节点 | 视差背景  | 多层背景移动形成纵深感                                | ParallaxLayer      | 后期背景层效果         |
| ParallaxLayer      | 节点 | 视差层   | 视差背景中的单独一层                                 | ParallaxBackground | 云层、远景、树林层       |

## 7.2 地图资源

| 英文名       | 类型 | 中文记忆名 | 主要用途                     | 常见搭配                         | 项目用途        |
| --------- | -- | ----- | ------------------------ | ---------------------------- | ----------- |
| TileSet   | 资源 | 瓦片资源集 | 存放地图瓦片，给 TileMapLayer 使用 | TileMapLayer                 | 地图素材库       |
| Texture2D | 资源 | 贴图资源  | 图片资源的基础类型                | Sprite2D、TextureRect、TileSet | 角色图、UI图、瓦片图 |

## 记忆重点

* Godot 4.6 里地图优先记 `TileMapLayer`。
* `TileSet` 不是节点，是资源。
* 多层地图就用多个 `TileMapLayer`。
* 旧教程如果还在讲 `TileMap`，要注意版本差异。

---

# 8. 摄像机与视图

| 英文名               | 类型 | 中文记忆名  | 主要用途                | 常见搭配                   | 项目用途        |
| ----------------- | -- | ------ | ------------------- | ---------------------- | ----------- |
| Camera2D          | 节点 | 2D摄像机  | 控制游戏画面显示区域，可跟随角色    | CharacterBody2D、Node2D | 玩家视角、地图跟随   |
| RemoteTransform2D | 节点 | 远程变换同步 | 把一个节点的位置/旋转同步给另一个节点 | Camera2D、Node2D        | 特殊跟随逻辑，前期少用 |

## 记忆重点

* 普通2D游戏基本只需要先记 `Camera2D`。
* `Camera2D` 可以挂在玩家下面，也可以单独做摄像机控制节点。
* UI不要挂在摄像机下面，UI通常走 `CanvasLayer`。

---

# 9. 音频节点

| 英文名                 | 类型 | 中文记忆名   | 主要用途         | 常见搭配   | 项目用途           |
| ------------------- | -- | ------- | ------------ | ------ | -------------- |
| AudioStreamPlayer   | 节点 | 普通音频播放器 | 播放不带空间位置的声音  | Node   | BGM、UI音效       |
| AudioStreamPlayer2D | 节点 | 2D音频播放器 | 播放带2D空间位置的声音 | Node2D | 怪物叫声、技能爆炸声、环境音 |
| AudioStreamPlayer3D | 节点 | 3D音频播放器 | 3D游戏音频       | Node3D | 2D项目基本不用       |

## 记忆重点

* BGM、按钮音效：`AudioStreamPlayer`。
* 地图中某个位置发出的声音：`AudioStreamPlayer2D`。
* 2D项目不用管 `AudioStreamPlayer3D`。

---

# 10. 时间、生成与辅助节点

| 英文名                       | 类型 | 中文记忆名   | 主要用途              | 常见搭配                        | 项目用途             |
| ------------------------- | -- | ------- | ----------------- | --------------------------- | ---------------- |
| Timer                     | 节点 | 计时器     | 延迟触发、循环触发、冷却时间    | Node、Area2D、AnimationPlayer | 技能持续时间、怪物刷新、伤害间隔 |
| Path2D                    | 节点 | 2D路径    | 定义一条路径曲线          | PathFollow2D                | 巡逻路线、飞行轨迹        |
| PathFollow2D              | 节点 | 路径跟随点   | 沿 Path2D 移动       | Path2D                      | 怪物巡逻、弹道路径        |
| RayCast2D                 | 节点 | 射线检测    | 检测一条线方向上是否碰到物体    | CharacterBody2D、Area2D      | 视线检测、前方障碍检测      |
| VisibleOnScreenNotifier2D | 节点 | 屏幕可见检测  | 检测节点是否进入/离开屏幕     | Sprite2D、Enemy              | 离屏回收、怪物激活        |
| VisibleOnScreenEnabler2D  | 节点 | 屏幕可见启用器 | 根据是否在屏幕内自动启用/禁用节点 | Enemy、AnimationPlayer       | 优化大量敌人或特效        |

## 记忆重点

* `Timer` 很常用，技能、冷却、刷新都可能用。
* `RayCast2D` 是“探测前方有没有东西”。
* `VisibleOnScreenNotifier2D` 可以帮助优化离屏对象。

---

# 11. 常用资源 Resource

| 英文名          | 类型 | 中文记忆名 | 主要用途                     | 常见搭配                 | 项目用途                  |
| ------------ | -- | ----- | ------------------------ | -------------------- | --------------------- |
| Texture2D    | 资源 | 贴图    | 图片资源基础类型                 | Sprite2D、TextureRect | 角色图、图标、背景             |
| SpriteFrames | 资源 | 精灵动画帧 | 存放 AnimatedSprite2D 的动画帧 | AnimatedSprite2D     | idle、walk、attack、hurt |
| TileSet      | 资源 | 瓦片资源集 | 存放瓦片，给 TileMapLayer 使用   | TileMapLayer         | 地图资源                  |
| PackedScene  | 资源 | 打包场景  | 可被代码实例化的场景资源             | instantiate()        | 生成敌人、技能、掉落物           |
| Animation    | 资源 | 动画资源  | AnimationPlayer 使用的数据    | AnimationPlayer      | UI动画、属性动画             |
| Font         | 资源 | 字体    | 文字显示用字体                  | Label、RichTextLabel  | UI字体                  |
| Theme        | 资源 | UI主题  | 统一控制UI样式                 | Control、Button、Label | 游戏整体UI风格              |

## 记忆重点

* `PackedScene` 很重要：怪物、技能、掉落物基本都会做成场景，然后实例化生成。
* `SpriteFrames` 是 `AnimatedSprite2D` 的动画库。
* `TileSet` 是 `TileMapLayer` 的瓦片库。
* 资源不是节点，不能直接作为场景树里的节点添加。

---

# 12. Godot 4.6.x 旧教程名称对照

| 旧教程里可能出现        | Godot 4.6.x 当前应优先使用                  | 说明                                          |
| --------------- | ------------------------------------ | ------------------------------------------- |
| KinematicBody2D | CharacterBody2D                      | 旧版角色身体节点名，新版用 CharacterBody2D               |
| Position2D      | Marker2D                             | 旧版位置标记点，新版用 Marker2D                        |
| TileMap         | TileMapLayer                         | TileMap 已不建议作为新项目主节点，4.6.x 优先用 TileMapLayer |
| YSort           | Node2D / CanvasItem 的 Y Sort Enabled | Godot 4.x 更常用属性控制Y排序                        |
| AnimatedSprite  | AnimatedSprite2D                     | 2D动画精灵节点在4.x中是 AnimatedSprite2D             |
| Sprite          | Sprite2D                             | 2D图片节点在4.x中是 Sprite2D                       |
| Area            | Area2D                               | 2D检测区域用 Area2D                              |
| CollisionShape  | CollisionShape2D                     | 2D碰撞形状用 CollisionShape2D                    |
| Camera          | Camera2D                             | 2D摄像机用 Camera2D                             |

## 记忆重点

看到旧教程时不要慌，很多只是名字变了。
当前项目按 Godot 4.6.x 写，优先使用新版节点名。

---

# 13. 洪荒修仙项目常见组合模板

## 13.1 玩家角色基础组合

```text
Player（CharacterBody2D）
├─ AnimatedSprite2D
├─ CollisionShape2D
├─ Camera2D
└─ Marker2D
```

用途：

| 节点               | 作用              |
| ---------------- | --------------- |
| CharacterBody2D  | 玩家身体，负责移动和碰撞    |
| AnimatedSprite2D | 播放待机、走路、施法、受击动画 |
| CollisionShape2D | 玩家身体碰撞盒         |
| Camera2D         | 摄像机跟随玩家         |
| Marker2D         | 技能发射点、交互点、脚底基准点 |

---

## 13.2 敌人基础组合

```text
Enemy（CharacterBody2D）
├─ AnimatedSprite2D
├─ CollisionShape2D
├─ Area2D
│  └─ CollisionShape2D
└─ Timer
```

用途：

| 节点               | 作用           |
| ---------------- | ------------ |
| CharacterBody2D  | 敌人身体，负责移动和碰撞 |
| AnimatedSprite2D | 播放敌人动画       |
| CollisionShape2D | 敌人身体碰撞盒      |
| Area2D           | 仇恨范围、攻击检测范围  |
| Timer            | 攻击间隔、行为刷新间隔  |

---

## 13.3 掉落物基础组合

```text
DropItem（Area2D）
├─ Sprite2D
└─ CollisionShape2D
```

用途：

| 节点               | 作用           |
| ---------------- | ------------ |
| Area2D           | 检测玩家是否进入拾取范围 |
| Sprite2D         | 显示掉落物图片      |
| CollisionShape2D | 定义拾取范围       |

---

## 13.4 技能命中范围基础组合

```text
SkillHitbox（Area2D）
├─ CollisionShape2D
├─ AnimatedSprite2D
└─ Timer
```

用途：

| 节点               | 作用            |
| ---------------- | ------------- |
| Area2D           | 检测命中的敌人       |
| CollisionShape2D | 定义技能命中范围      |
| AnimatedSprite2D | 播放技能特效        |
| Timer            | 控制技能持续时间或销毁时间 |

---

## 13.5 远程飞行技能基础组合

```text
Projectile（Area2D）
├─ AnimatedSprite2D
├─ CollisionShape2D
└─ VisibleOnScreenNotifier2D
```

用途：

| 节点                        | 作用           |
| ------------------------- | ------------ |
| Area2D                    | 检测飞行技能是否命中敌人 |
| AnimatedSprite2D          | 播放飞行特效       |
| CollisionShape2D          | 技能碰撞范围       |
| VisibleOnScreenNotifier2D | 离开屏幕后回收      |

---

## 13.6 UI界面基础组合

```text
UIRoot（CanvasLayer）
└─ Control
   ├─ Panel
   │  ├─ Label
   │  └─ ProgressBar
   └─ Button
```

用途：

| 节点          | 作用         |
| ----------- | ---------- |
| CanvasLayer | 固定UI层      |
| Control     | UI根节点      |
| Panel       | 面板背景       |
| Label       | 文字         |
| ProgressBar | 血条、经验条、灵力条 |
| Button      | 按钮         |

---

## 13.7 背包格子基础组合

```text
InventoryUI（CanvasLayer）
└─ Control
   └─ Panel
      └─ GridContainer
         ├─ Button
         │  └─ TextureRect
         └─ Button
            └─ TextureRect
```

用途：

| 节点            | 作用        |
| ------------- | --------- |
| GridContainer | 自动排列背包格子  |
| Button        | 每个格子的点击区域 |
| TextureRect   | 显示道具图标    |
| Panel         | 背包面板背景    |

---

## 13.8 瓦片地图基础组合

```text
World（Node2D）
├─ GroundLayer（TileMapLayer）
├─ ObstacleLayer（TileMapLayer）
├─ DecorationLayer（TileMapLayer）
├─ Player（CharacterBody2D）
└─ Enemies（Node2D）
```

用途：

| 节点                             | 作用    |
| ------------------------------ | ----- |
| World / Node2D                 | 地图根节点 |
| GroundLayer / TileMapLayer     | 地面层   |
| ObstacleLayer / TileMapLayer   | 障碍层   |
| DecorationLayer / TileMapLayer | 装饰层   |
| Player                         | 玩家    |
| Enemies / Node2D               | 敌人容器  |

---

# 14. 当前学习阶段优先级

## 第一批：必须熟

| 优先级 | 节点/资源            | 为什么                   |
| --- | ---------------- | --------------------- |
| 1   | Node             | 所有场景结构基础              |
| 1   | Node2D           | 2D场景基础                |
| 1   | Sprite2D         | 显示图片                  |
| 1   | AnimatedSprite2D | 角色帧动画                 |
| 1   | SpriteFrames     | AnimatedSprite2D 必用资源 |
| 1   | CharacterBody2D  | 玩家和敌人基础               |
| 1   | Area2D           | 技能、拾取、交互检测            |
| 1   | CollisionShape2D | 碰撞范围基础                |
| 1   | Camera2D         | 2D视角                  |
| 1   | CanvasLayer      | UI固定层                 |
| 1   | Control          | UI基础                  |
| 1   | Label            | 文字                    |
| 1   | Button           | 按钮                    |
| 1   | Panel            | 面板                    |
| 1   | ProgressBar      | 血条/经验条                |
| 1   | Timer            | 冷却/延迟                 |
| 1   | TileMapLayer     | 地图层                   |
| 1   | TileSet          | 地图瓦片资源                |

## 第二批：随后熟悉

| 优先级 | 节点/资源               | 为什么            |
| --- | ------------------- | -------------- |
| 2   | AnimationPlayer     | UI动画、属性动画、技能特效 |
| 2   | Marker2D            | 出生点、刷怪点、技能发射点  |
| 2   | TextureRect         | UI图片           |
| 2   | VBoxContainer       | UI竖排           |
| 2   | HBoxContainer       | UI横排           |
| 2   | GridContainer       | 背包格子、技能格子      |
| 2   | RichTextLabel       | 长说明、技能文本       |
| 2   | AudioStreamPlayer   | BGM、UI音效       |
| 2   | AudioStreamPlayer2D | 2D空间音效         |
| 2   | PackedScene         | 生成敌人、技能、掉落物    |

## 第三批：后期再学

| 优先级 | 节点/资源                     | 为什么      |
| --- | ------------------------- | -------- |
| 3   | AnimationTree             | 复杂动画状态管理 |
| 3   | GPUParticles2D            | 技能粒子特效   |
| 3   | RayCast2D                 | 视线/障碍检测  |
| 3   | Path2D                    | 路径       |
| 3   | PathFollow2D              | 路径跟随     |
| 3   | VisibleOnScreenNotifier2D | 离屏检测     |
| 3   | Theme                     | UI整体样式   |
| 3   | ParallaxBackground        | 视差背景     |
| 3   | ParallaxLayer             | 视差层      |

---

# 15. 我的记忆口诀

| 英文名              | 记忆方式       |
| ---------------- | ---------- |
| Node             | 纯逻辑空节点     |
| Node2D           | 2D世界里的空节点  |
| Sprite2D         | 放一张图       |
| AnimatedSprite2D | 放一组逐帧动画    |
| SpriteFrames     | 逐帧动画资源库    |
| CharacterBody2D  | 会走路的角色身体   |
| Area2D           | 只检测，不阻挡    |
| CollisionShape2D | 碰撞范围本体     |
| Camera2D         | 2D摄像机      |
| CanvasLayer      | 固定在屏幕上的UI层 |
| Control          | UI世界的基础节点  |
| Label            | 显示文字       |
| Button           | 可点击按钮      |
| Panel            | UI面板背景     |
| ProgressBar      | 进度条        |
| Timer            | 计时器        |
| TileMapLayer     | 画地图瓦片的一层   |
| TileSet          | 瓦片资源库      |
| PackedScene      | 可生成的场景模板   |
| Marker2D         | 地图上的位置标记   |
| AnimationPlayer  | 控制属性动画     |

---

# 16. 当前项目实践规则

## 16.1 节点命名规则

Godot 节点可以使用中文名，但为了避免脚本、路径、插件兼容问题，建议：

| 类型  | 建议                   |
| --- | -------------------- |
| 文件名 | 英文/拼音/下划线            |
| 场景名 | 英文/拼音/下划线            |
| 脚本名 | 英文/拼音/下划线            |
| 节点名 | 学习阶段可用中文；正式项目建议英文/拼音 |
| 资源名 | 英文/拼音/下划线            |

示例：

```text
player.tscn
enemy_goblin.tscn
skill_fireball.tscn
ui_main.tscn
```

## 16.2 当前项目推荐根结构

```text
Main（Node）
├─ World（Node2D）
│  ├─ Map（Node2D）
│  │  ├─ GroundLayer（TileMapLayer）
│  │  ├─ ObstacleLayer（TileMapLayer）
│  │  └─ DecorationLayer（TileMapLayer）
│  ├─ Player（CharacterBody2D）
│  ├─ Enemies（Node2D）
│  ├─ Drops（Node2D）
│  └─ Skills（Node2D）
├─ UI（CanvasLayer）
└─ Managers（Node）
```

## 16.3 当前项目文件夹建议

```text
res://
├─ scenes/
│  ├─ player/
│  ├─ enemies/
│  ├─ skills/
│  ├─ ui/
│  └─ maps/
├─ scripts/
├─ assets/
│  ├─ sprites/
│  ├─ tilesets/
│  ├─ ui/
│  └─ audio/
├─ resources/
└─ docs/
```

---

# 17. 后续补充规则

以后遇到新节点，按这个格式添加：

```text
| 英文名 | 类型 | 中文记忆名 | 主要用途 | 常见搭配 | 项目用途 |
```

如果是资源，不要放到节点表里，放到“常用资源 Resource”。

如果是旧教程里的旧名字，放到“旧版本名称对照”。

如果暂时不知道怎么用，先写“待测试”，不要强行归类。

---

# 18. 本文档当前状态

| 项目   | 状态                    |
| ---- | --------------------- |
| 版本基准 | Godot 4.6.x           |
| 当前使用 | Godot 4.6.3           |
| 项目方向 | 2D 像素风 / 顶视角 / 修仙刷怪游戏 |
| 文档用途 | 学习记忆、节点速查、AI协作交接      |
| 是否完整 | 否，后续按实际学习继续补充         |
