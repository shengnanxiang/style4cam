# Lightroom / XMP 预设 → .cube LUT 操作指南（免费方案）

目标：把你手头的 `.lrtemplate` / `.xmp` 预设转成 `style4cam` 编辑器能直接套用的 `.cube` 3D LUT，放进 `other luts/` 目录即可。

---

## 0. 前提：哪些预设能转，哪些转不好

- ✅ **能转好**：预设里**内嵌了 3D RGB 查找表**的「Look / 电影 LUT 类」预设（`.xmp` 内含有 `crs:Table_xxx` 字段）。
- ⚠️ **转不好**：纯参数型预设（只有曝光、对比度、白平衡、HSL、曲线等参数，没有内嵌表）。转出来要么没效果，要么效果不完整。
- 判断方法：用记事本打开 `.xmp`，搜索 `Table_`，能找到就是带内嵌 LUT 的。

另外，`.lrtemplate` 是 Lightroom 旧格式，**转换工具基本只认 `.xmp`**，需先转成 `.xmp`（见第 3 节）。

---

## 1. 方案 A：xmp2cube（推荐，开源免费，纯本地）

- 项目地址：`https://github.com/mvimercati/xmp2cube`
- 只需 **Python 3**，无需 pip 安装任何依赖（只用标准库）。
- 已知限制：
  - 只提取预设内嵌的 3D 表，曝光/曲线/HSL 等表外参数不会烘焙进去；
  - 满强度导出（预设的强度范围不被应用）；
  - 每文件只取第一张匹配的表。

### 步骤

#### 1.1 安装 Python 3
1. 打开 `https://www.python.org/downloads/`，下载 Windows 版并安装。
2. 安装时**务必勾选**「Add Python to PATH」。
3. 装完打开 PowerShell（Win 键输入 powershell 回车），验证：
   ```powershell
   python --version
   ```
   能显示版本号即成功。

#### 1.2 下载 xmp2cube
1. 打开 `https://github.com/mvimercati/xmp2cube`。
2. 点击绿色 `Code` 按钮 → `Download ZIP`，解压。
3. 把解压出来的 `xmp2cube.py` 单独复制到一个干净的文件夹，例如：
   ```
   D:\lut-convert\
   ```

#### 1.3 准备 .xmp 文件
- 新建一个文件夹放所有要转换的 `.xmp`，例如：
  ```
  D:\lut-convert\input\
  ```
- **`.lrtemplate` 旧格式先转 `.xmp`**：网上搜「lrtemplate to xmp converter」或用 Lightroom 批量另存为 `.xmp`；本工具不接受 `.lrtemplate`。

#### 1.4 运行转换
在 PowerShell 里进入工具目录并执行（`.` 表示转换当前目录下所有 `.xmp`）：
```powershell
cd D:\lut-convert
python xmp2cube.py -m srgb -s 33 -o cube_out
```
参数说明：
- `-m srgb`：输出统一 sRGB 色彩空间，通用性最好（默认 native 也行，但 sRGB 更稳）。
- `-s 33`：网格分辨率 33（建议 ≥32，套用更精细；之前 25 的会偏粗）。
- `-o cube_out`：输出目录。

转单个文件（可选）：
```powershell
python xmp2cube.py "My Look.xmp" -m srgb -s 33 -v
```

#### 1.5 检查输出
用记事本打开生成的 `.cube`，确认头部有：
```
LUT_3D_SIZE 33
```
且数据行数是 `33³ = 35937` 行 × 3 列。满足说明文件完整可用。

---

## 2. 方案 B：在线转换（零安装，需联网上传）

- 地址：`https://filmfreebies.com/xmp-to-cube-converter.php`
- 直接把 `.xmp` 传上去，下载 `.cube`。
- 注意：文件要上传到对方服务器，介意隐私就别用；输出质量没有 xmp2cube 可控（size 不一定合适，可能偏小）。

---

## 3. 把 .cube 接入 style4cam

转换完成后，把 `.cube` 文件放入项目 `other luts/` 目录，然后把它登记进 `other-luts-list.json` 的 `files` 数组（按文件名排序）。

`other-luts-list.json` 示例：
```json
{
  "dir": "other luts",
  "files": [
    "Kodak Ektar 100.cube",
    "My Converted Look.cube"
  ]
}
```

> 也可以直接把转换好的文件发给我，我帮你批量校验（size、数据完整性）并写入清单。

---

## 4. 常见问题

| 问题 | 原因 / 处理 |
|------|------------|
| 转换后 `.cube` 打开是空的 / 报 Invalid | 该预设不内嵌 3D 表（纯参数型），无法用 xmp2cube 转换 |
| size 只有 25 或更小 | 转换时用 `-s 33` 重新导出 |
| 套用后图像异样 | 优先检查 size；另可能是表外参数（曝光/曲线）没被烘焙所致 |
| `.lrtemplate` 不识别 | 先转成 `.xmp` 再转换 |
| 颜色和 Lightroom 里看到的不一致 | LUT 只包含色彩映射，LR 里看到的还叠加了参数调整，属正常差异 |

---

## 5. 一句话总结

- 带内嵌 3D 表的 `.xmp` → **方案 A（xmp2cube）** 免费本地转换，`-s 33` 导出。
- 纯参数型预设 → 转不了，放弃或手动调色。
- 转好的 `.cube` 丢进 `other luts/` + 登记 `other-luts-list.json` 就能用。
