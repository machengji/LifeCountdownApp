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
                
                Section(header: Text("相伴时光与纪念日"), footer: Text("开启后，小组件将为您精美展示和 TA 在一起的流逝天数与余生携手倒计时。")) {
                    Toggle("开启在一起纪念日", isOn: $settings.isTogetherEnabled)
                    
                    if settings.isTogetherEnabled {
                        DatePicker(
                            "在一起起始日",
                            selection: $settings.togetherDate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        
                        HStack {
                            Text("伴侣称呼")
                            Spacer()
                            TextField("例如：宝贝、亲爱的", text: $settings.partnerName)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                
                Section(header: Text("个性化表达")) {
                    HStack {
                        Text("我的称呼")
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
                
                Section(header: Text("桌面与锁屏小组件"), footer: Text("修改日期或目标后，系统会自动更新小组件。若未及时刷新，可点击上方按钮手动同步。")) {
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
                            Text("小组件使用指南与问题排查")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Section(header: Text("关于应用")) {
                    HStack {
                        Text("版本号")
                        Spacer()
                        Text("1.0.4 (紧凑小组件与相伴纪念日)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("设计哲学")
                        Spacer()
                        Text("Memento Mori · 珍视相伴")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("偏好设置")
            .navigationBarTitleDisplayMode(.inline)
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

/// 小组件使用说明弹窗
struct WidgetTroubleshootingView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("小组件使用小技巧")
                            .font(.system(size: 18, weight: .bold))
                        Text("全新升级的紧凑版小组件不仅支持人生倒计时，还融合了「在一起已经多少天」的甜蜜相伴记录！")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    guideCard(
                        step: "1",
                        title: "选择更紧凑的中号小组件 (推荐)",
                        desc: "如果您觉得大号小组件占了半个屏幕，您可以长按桌面选择【中号小组件 (2x4)】，高度只有大号的一半，左侧是人生环形倒计时，右侧是恋爱相伴天数，极致紧凑、精致耐看！"
                    )
                    
                    guideCard(
                        step: "2",
                        title: "大号小组件已全面消灭空白留白",
                        desc: "新版大号小组件已重构为高密度紧凑矩阵，中部饱满融入了「在一起天数」卡片与 288 个点阵人生矩阵，排布紧凑有力，绝不再留多余空白！"
                    )
                    
                    guideCard(
                        step: "3",
                        title: "修改在一起日期后记得点刷新",
                        desc: "在设置里更改了「在一起起始日」后，点击「立即同步并刷新全部小组件」，桌面上的天数就会同步变更。"
                    )
                }
                .padding()
            }
            .navigationTitle("使用技巧")
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
