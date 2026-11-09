import SwiftUI

/// 个人设置与小组件同步偏好页面
struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var showReloadSuccessAlert = false
    @State private var showHelpSheet = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text("全能签 / 侧载小组件必看提示"),
                    footer: Text("由于第三方签名工具（如全能签、爱思助手）会隔离主 App 与小组件沙盒，您在桌面【长按小组件 → 点击编辑小组件】，直接填入相伴日期（如 2023-05-20）即可 100% 立即生效！")
                ) {
                    HStack(spacing: 10) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.pink)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("支持桌面直接长按编辑小组件")
                                .font(.system(size: 14, weight: .bold))
                            Text("长按桌面小组件 → 编辑小组件 → 填入相伴日期")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
                
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
                
                Section(header: Text("相伴时光与陪伴倒计时"), footer: Text("修改日期后将同步至小组件；若使用全能签安装，也可直接在桌面长按小组件点「编辑」填入日期。")) {
                    Toggle("开启在一起纪念日", isOn: $settings.isTogetherEnabled)
                    
                    if settings.isTogetherEnabled {
                        DatePicker(
                            "在一起起始日",
                            selection: $settings.togetherDate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        
                        HStack {
                            Text("已相伴时光")
                            Spacer()
                            Text("\(settings.calculatedTogetherDays()) 天")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.pink)
                        }
                        
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
                
                Section(header: Text("桌面与锁屏小组件")) {
                    Button(action: {
                        settings.persistAll()
                        showReloadSuccessAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("立即同步并刷新全部小组件")
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Button(action: {
                        showHelpSheet = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("小组件设置指南（全能签/侧载必读）")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Section(header: Text("关于应用")) {
                    HStack {
                        Text("版本号")
                        Spacer()
                        Text("1.0.8 (星曜高定 & 桌面长按直接编辑版)")
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
            .onAppear {
                settings.persistAll()
            }
            .alert("小组件同步指令已发出", isPresented: $showReloadSuccessAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("已请求刷新桌面小组件。若您使用全能签签名导致沙盒隔离，请在桌面【长按小组件 → 编辑小组件】直接填入相伴日期，100% 立即生效！")
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
                        Text("小组件设置指南")
                            .font(.system(size: 18, weight: .bold))
                        Text("全新 1.0.8 版本专门针对全能签、爱思助手等重签名工具内置了「桌面长按直接编辑」引擎！")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    guideCard(
                        step: "1",
                        title: "桌面长按小组件 → 编辑小组件 (最稳妥)",
                        desc: "在手机桌面上直接长按本小组件，点击弹出的【编辑小组件】，在「相伴起始日」一栏直接输入日期（例如 2023-05-20），无需跨沙盒即可 100% 精准显示相伴天数、周年倒计时与余生陪伴倒计时！"
                    )
                    
                    guideCard(
                        step: "2",
                        title: "全新星曜流光双核大组件",
                        desc: "顶部为浪漫玫瑰流光【相伴正计时 + 周年/余生双陪伴倒计时】，中部为【人生余生发光圆环 + 24阶流光生命晶格条】，下部为【今年/本月/今日三联立体进度方卡】，视觉层次分明，绝无换行与留白。"
                    )
                    
                    guideCard(
                        step: "3",
                        title: "支持多种日期输入格式",
                        desc: "在编辑小组件时，无论是输入 2023-05-20、2023.05.20、2023/05/20 还是 20230520，系统均能自动智能识别并精确到自然日零点计算。"
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
