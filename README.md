# GNOME 象棋 (Xiangqi)

GNOME 象棋是一个基于GTK4和Libadwaita的中国象棋游戏，为GNOME桌面环境设计。

## 功能特点

- 完整实现中国象棋规则
- 美观的棋盘和棋子设计
- 将军提示效果
- 历史记录查看和恢复棋盘状态
- 标准中国象棋记谱法
- 支持悔棋功能
- 计时系统

## 安装

### 依赖项

- GTK 4 (>= 4.0.0)
- Libadwaita (>= 1.0.0)
- librsvg (>= 2.46.0)

### 从源码构建

```bash
# 配置构建
meson setup builddir

# 编译
cd builddir
meson compile

# 安装
meson install
```

## 使用方法

启动游戏后，红方先行。点击棋子选中，然后点击目标位置移动。点击同一个棋子可以取消选择。

### 快捷键

- `Ctrl+N`: 新游戏
- `Ctrl+Z`: 悔棋
- `Ctrl+Q`: 退出

## 开发计划

- 实现AI功能
- 添加网络对战
- 支持保存/加载游戏
- 添加棋谱导入导出功能

## 许可证

本项目采用GNU通用公共许可证v3.0 (GPL-3.0)。详情请参阅[COPYING](COPYING)文件。