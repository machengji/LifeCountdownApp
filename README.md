# 人生倒计时与小组件 App (LifeCountdownApp)

一款基于纯原生 **SwiftUI + WidgetKit (iOS 17+)** 打造的人生倒计时与多维度时光感知小组件应用。

秉承 **“向死而生 (Memento Mori)”** 的哲学理念，以优雅直观的视觉呈现，帮助用户具象化感知人生的有限与珍贵，专注当下、热爱生活。

---

## 🌟 核心特性与功能模块

1. **900 格人生画布（90年 × 12个月）**
   - 每一行代表一周岁（12个月），直观看到时光走过的灰色方格、正在经历的高亮橙色脉动格、以及未来尚待探索的岁月。
   - 支持点击任意方格，弹出《时间格印记》，查看该月份对应的历法年月与人生阶段（童年、少年、青年、壮年等）。
2. **高精度人生倒计时与环形时钟**
   - 精确计算出生至今已活过天数、剩余规划天数、总天数。
   - 动态双色发光渐变环形进度圈，百分比精确到小数点后两位。
3. **多维度时间感知体系**
   - **一生维度**：生命已度过比例与剩余总天数。
   - **年度维度**：当年已过去天数与剩余天数。
   - **月度维度**：当月进度与剩余天数。
   - **今日维度**：今日已过小时与剩余时分。
4. **全套 iOS 桌面与锁屏小组件 (WidgetKit)**
   - **小号组件 (SystemSmall 2x2)**：大字显示剩余天数 + 线性渐变微进度条。
   - **中号组件 (SystemMedium 2x4)**：环形进度圈 + 余生天数 + 每日哲学箴言 + 年度进程。
   - **大号组件 (SystemLarge 4x4)**：人生点阵小格矩阵缩略图 + 详细指标与箴言。
   - **锁屏小组件 (Accessory Widgets)**：支持 Circular（环形）、Rectangular（矩形）及 Inline（单行文字），锁屏即可一览无余。
5. **App Group 数据实时同步**
   - 主 App 与小组件之间通过 `group.com.lifecountdown.app` 共享数据容器保持强同步，修改生日或预期寿命后一键刷新所有小组件。

---

## 📁 项目目录结构

```text
LifeCountdownApp/
├── LifeCountdownApp/                # 主 App 工程代码
│   ├── App/
│   │   └── LifeCountdownApp.swift   # App 入口与 TabView 导航
│   ├── Models/
│   │   ├── LifeDataModel.swift      # 核心生命周期、年/月/日精确计算模型
│   │   ├── PhilosophyQuote.swift    # 每日哲学与时间箴言数据模型
│   │   └── AppSettings.swift        # AppGroup UserDefaults 数据持久化与同步
│   ├── Views/
│   │   ├── MainDashboardView.swift  # 首页仪表盘（倒计时核心进度环、多维时间感知）
│   │   ├── LifeGridView.swift       # 900格人生画布（支持点击月份弹窗）
│   │   ├── QuotesView.swift         # 哲学箴言库浏览
│   │   ├── SettingsView.swift       # 出生日期、目标年龄与小组件同步
│   │   └── Components/
│   │       ├── CircularProgressView.swift # 渐变环形进度条组件
│   │       ├── TimeDimensionCard.swift    # 多维时间流逝卡片
│   │       └── MonthDetailSheet.swift     # 月份详情弹窗
│   └── Info.plist                   # 主 App 配置
├── LifeWidget/                      # iOS WidgetKit 小组件 Extension
│   ├── LifeWidgetBundle.swift       # WidgetBundle 入口
│   ├── LifeWidget.swift             # TimelineProvider 与 Widget 声明
│   ├── Views/
│   │   ├── SmallWidgetView.swift    # 桌面小号小组件 (2x2)
│   │   ├── MediumWidgetView.swift   # 桌面中号小组件 (2x4)
│   │   ├── LargeWidgetView.swift    # 桌面大号小组件 (4x4)
│   │   └── LockScreenWidgetView.swift # 锁屏小组件 (Circular/Rectangular/Inline)
│   └── Info.plist                   # Widget Extension 配置
├── LifeCountdownApp.xcodeproj/      # 标准 Xcode 15/16 工程文件
│   └── project.pbxproj
├── .github/
│   └── workflows/
│       └── ios-ci-build.yml         # GitHub Actions 云端自动构建工作流
├── preview/
│   └── index.html                   # 零依赖本地浏览器全真模拟器（Windows 可直接体验）
└── README.md
```

---

## 💻 本地即时体验（无需 Mac / 无需 Xcode）

在 Windows 本地，我们特别为你准备了 **1:1 原生效果的交互模拟器**：
1. 打开目录：`C:\Users\Administrator\.gemini\antigravity\scratch\LifeCountdownApp\preview\`
2. 双击直接在浏览器中打开 `index.html`。
3. 可以在网页中实时修改你的**出生日期**、**预期寿命**、**昵称**，即时查看环形进度动画、900格人生画布、多维度时间感知以及 iOS 小组件（小号、中号）的实际渲染效果！

---

## ☁️ 暂时没有 Mac 时的云端自动打包构建方案

如果你暂时没有 Mac 电脑，你可以利用我们已配置好的 **GitHub Actions CI/CD** 进行免费的云端自动编译：

1. 在 GitHub 上新建一个 Git 仓库（如 `LifeCountdownApp`，可设为 Private 私有仓库）。
2. 将本目录下的所有文件上传推送到该仓库中：
   ```bash
   git init
   git add .
   git commit -m "feat: init iOS life countdown app & widget"
   git remote add origin https://github.com/<你的用户名>/LifeCountdownApp.git
   git push -u origin main
   ```
3. 进入 GitHub 仓库的 **Actions** 标签页，你会看到名为 `Build iOS Life Countdown App & Widget` 的工作流自动触发。
4. GitHub 会自动为你分配一台运行最新 macOS 14/15 且预装了 Xcode 15/16 的云端计算机，自动执行编译、语法检查与构建。
5. 构建完成后，即可在 Actions 页面底部的 **Artifacts** 中直接下载编译好的 App 产物！

---

## 🍎 在 Mac / Xcode 中运行与真机调试

当你使用 Mac 设备时：
1. 打开 `LifeCountdownApp.xcodeproj`。
2. 在 Xcode 的 `Signing & Capabilities` 中：
   - 选择你的 Apple ID 个人开发团队（Personal Team）。
   - 主 App 和 LifeWidget 的 Bundle Identifier 分别为：
     - App: `com.lifecountdown.app`（或你的自定义前缀）
     - Widget: `com.lifecountdown.app.widget`
   - 勾选 **App Groups**，添加 `group.com.lifecountdown.app`（主 App 与 Widget 勾选同一个 Group 标识符）。
3. 顶部设备选择你的 iPhone 真机或 iOS 17+ 模拟器。
4. 点击 **Run (⌘R)** 即可编译并安装到手机上！
5. 在手机桌面上长按空白处，点击左上角 `+` 号，搜索“人生倒计时”，即可添加小/中/大号桌面小组件以及锁屏小组件。
