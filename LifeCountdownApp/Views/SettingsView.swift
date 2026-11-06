import SwiftUI

/// 个人设置与小组件同步偏好页面
struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var showReloadSuccessAlert = false
    @State private var showHelpSheet = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基础生命档案")) {
                    DatePicker(
                        "出生日期",
                        selection: $settings.birthDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    
                    Stepper(value: $settings.targetAge, in: 40...120) {
                        HStack {
                            Text("预期寿命目标")
                            Spacer()
                            Text("\(settings.targetAge) 岁")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("个性化表达")) {
                    HStack {
                        Text("称呼 / 昵称")
                        Spacer()
                        TextField("请输入昵称", text: $settings.userName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("人生座右铭")
                            .font(.system(size: 14))
                        TextField("写下一句激励自己的话", text: $settings.customMotto, axis: .vertical)
                            .lineLimit(2...4)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("桌面与锁屏小组件"), footer: Text("修改出生日期或预期目标后，系统会自动更新小组件。若未及时刷新，可点击上方按钮手动同步。")) {
                    Button(action: {
                        settings.notifyWidgetReload()
                        showReloadSuccessAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("立即同步并刷新全部小组件")
                        }
                    }
                    
                    Button(action: {
                        showHelpSheet = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("小组件无法添加或搜不到？查看解决方法")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Section(header: Text("关于应用")) {
                    HStack {
                        Text("版本号")
                        Spacer()
                        Text("1.0.1 (含全套高清图标)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("设计哲学")
                        Spacer()
                        Text("Memento Mori · 珍惜此刻")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("偏好设置")
            .alert("小组件同步指令已发出", isPresented: $showReloadSuccessAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("桌面及锁屏小组件的时间轴已请求 WidgetCenter 重新装载。")
            }
            .sheet(isPresented: $showHelpSheet) {
                WidgetTroubleshootingView()
            }
        }
    }
}

/// 小组件故障排除与侧载使用说明弹窗
struct WidgetTroubleshootingView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("为什么桌面搜不到或无法添加小组件？")
                            .font(.system(size: 18, weight: .bold))
                        Text("iOS 系统对第三方小组件（WidgetKit Extension）有严格的安全沙盒与加载时机要求，请按照以下步骤排查：")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    guideCard(
                        step: "1",
                        title: "首次安装后必须彻底开启一次主 App",
                        desc: "iOS 系统的 chronod 守护进程只有在主应用首次冷启动后，才会将其小组件注册到系统的小组件库中。如果刚刚安装，请在主 App 停留 10 秒后返回桌面再尝试添加。"
                    )
                    
                    guideCard(
                        step: "2",
                        title: "检查签名工具是否禁用了插件（特别注意！）",
                        desc: "使用爱思助手等工具进行【免费 Apple ID 签名】时，部分版本默认会剔除或损坏 PlugIns 扩展插件的签名。强烈建议使用 Sideloadly 侧载安装，Sideloadly 会自动为 PlugIns/LifeWidget.appex 正确签名。"
                    )
                    
                    guideCard(
                        step: "3",
                        title: "在锁屏界面尝试添加",
                        desc: "如果桌面小组件列表中暂时未刷新出来，可以在 iPhone 锁屏界面长按自定，进入锁屏小组件列表查找「人生倒计时」，通常锁屏小组件会被系统更优先索引展示。"
                    )
                    
                    guideCard(
                        step: "4",
                        title: "重启 iPhone 让系统重新扫描小组件缓存",
                        desc: "侧载第三方 Widget 偶尔会遇到 iOS 系统小组件缓存未刷新的情况，简单重启一次 iPhone，桌面上就会立即显示出该 App 的小组件！"
                    )
                }
                .padding()
            }
            .navigationTitle("小组件使用指南")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("好的") { dismiss() }
                }
            }
        }
    }
    
    private func guideCard(step: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(Color.orange.opacity(0.15)).frame(width: 28, height: 28)
                Text(step).font(.system(size: 13, weight: .bold)).foregroundColor(.orange)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 14, weight: .semibold))
                Text(desc).font(.system(size: 12)).foregroundColor(.secondary).lineSpacing(3)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}
