# CloudBase 部署

公开版尚未配置 CloudBase 环境。下列步骤供仓库维护者部署；环境 ID 不是密钥，管理员密钥与 Android 签名材料不得提交 Git。

1. 在腾讯云开发控制台创建环境，启用邮箱密码登录、邮箱验证码以及云函数。
2. 创建 `timer_records`、`timer_operations`、`timer_locks`、`sync_cursors` 四个集合。每个集合应用 `cloudbase/rules/private-rules.json`，禁止客户端直接读写；应用只通过云函数访问记录。云函数使用环境内管理员权限访问集合，并按登录 UID 隔离数据。
3. 在 `cloudbase/functions/timer-command` 安装依赖并部署名为 `timer-command` 的云函数。应用 `cloudbase/rules/function-rules.json` 限制调用者须登录。运行 Node.js 语法检查：`node --check cloudbase/functions/timer-command/index.js`。
4. 在 GitHub Actions 仓库变量中设置 `CLOUDBASE_ENV` 为环境 ID；构建时通过 `--dart-define=CLOUDBASE_ENV=...` 注入。客户端不需要管理员密钥。
5. 用账号 A、B 现场检查：A 无法读取/修改 B 的记录；两个客户端同时抢占计时时仅一方成功；离线重复提交不产生重复记录；跨设备统计一致。完成前不发布“云同步已可用”的声明。

本机可不配置云环境运行计时器；此时账号入口提示云端未配置。
