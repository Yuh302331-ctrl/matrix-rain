# Matrix Rain（绿色矩阵雨）

Windows PowerShell 终端绿色字符雨动画，纯原生实现，不依赖任何第三方库。

## 效果

- 绿色字符雨 + 高亮雨头 + 渐暗拖尾
- 自动适配终端窗口大小
- 退出时自动恢复光标、清屏
- 平均 25 FPS 左右

## 用法

```powershell
powershell -ExecutionPolicy Bypass -File matrix_rain.ps1
```

限定时长：

```powershell
powershell -ExecutionPolicy Bypass -File matrix_rain.ps1 -Seconds 30
```

按 `Ctrl+C` 退出。

## 参数

| 参数 | 说明 | 默认 |
| --- | --- | --- |
| -Seconds | 运行秒数，0 表示一直运行 | 0 |
| -Cols | 强制列数 | 终端宽度 |
| -Rows | 强制行数 | 终端高度 |

## 环境要求

- Windows 10 / 11
- Windows PowerShell 5.1（系统自带）或 PowerShell 7

## 说明

脚本通过 `SetConsoleMode` 开启 VT 转义支持，因此在旧版控制台里也能显示颜色。
建议把终端窗口最大化后运行，效果最佳。

## License

MIT