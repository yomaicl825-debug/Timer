# Timefold

安静的学习计时软件。当前第一版目标是 Windows 和 Android；iPhone 版在后续开发。

## 下载与使用

V0.3 中英文与品牌试用版：[下载安装包](https://github.com/yomaicl825-debug/Timer/releases/download/V0.3/Timefold-0.3.0-preview-windows-setup.exe) · [便携版、源码与校验文件](https://github.com/yomaicl825-debug/Timer/releases/tag/V0.3)。个人主页设置可切换中文与 English，采用透明 A1 图标，灰色主题使用更深背景和柔和浅灰文字。完整变化见 [V0.3 发行说明](docs/v0.3-release.md)。

[V0.2 归档](https://github.com/yomaicl825-debug/Timer/releases/tag/V0.2)、[V0.1 归档](https://github.com/yomaicl825-debug/Timer/releases/tag/V0.1) 保留。Android 构建和设备流程测试已通过，公开 APK 待配置长期签名密钥后发布。

主窗口只有任务列表与入口；开始学习或打开时钟后进入沉浸计时。支持正数计时、番茄钟、暂停继续、提前结束、深浅主题、三种数字字体、时区时钟及每日/每周/每月日历统计。历史记录可以归类或修改计入时长。番茄钟休息结束后等待手动开始下一轮，避免离开设备时继续累计。

目前云环境尚未配置。Windows 试用版仅在本机保存数据，账号与跨设备同步不可用；云同步版需要完成环境配置和权限验证。具体状态见 [更新记录](CHANGELOG.md)。

## 开发

需要 Flutter 3.47.5。Windows 构建需要 Visual Studio Desktop development with C++；Android 构建需要 Android SDK 和 JDK 17。

```powershell
flutter pub get
flutter analyze
flutter test test
flutter build windows --release
flutter build apk --debug
```

设备级流程测试位于 `integration_test/`；普通桌面组件测试位于 `test/`。Windows 第二窗口需要在真实 Windows 构建中复核。

CloudBase 配置见 [云端部署](docs/cloudbase-setup.md)。隐私与备份说明见 [隐私说明](docs/privacy.md)。设计说明见 [中文设计规格](docs/superpowers/specs/2026-09-27-timer-design-zh.md)。

## 许可

MIT，见 [LICENSE](LICENSE)。
