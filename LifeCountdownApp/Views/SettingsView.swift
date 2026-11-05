import SwiftUI

/// 个人设置与小组件同步偏好页面
struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var showReloadSuccessAlert = false
    
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
                }
                
                Section(header: Text("关于应用")) {
                    HStack {
                        Text("版本号")
                        Spacer()
                        Text("1.0.0 (Build 1)")
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
        }
    }
}
