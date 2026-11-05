import SwiftUI

/// 点击人生格子弹出的月份详情
struct MonthDetailSheet: View {
    let monthIndex: Int
    let birthDate: Date
    let currentPassedMonths: Int
    @Environment(\.dismiss) private var dismiss
    
    private var monthYear: Int {
        monthIndex / 12
    }
    
    private var monthOffset: Int {
        (monthIndex % 12) + 1
    }
    
    private var targetMonthDate: Date {
        Calendar.current.date(byAdding: .month, value: monthIndex, to: birthDate) ?? birthDate
    }
    
    private var isPassed: Bool {
        monthIndex < currentPassedMonths
    }
    
    private var isCurrent: Bool {
        monthIndex == currentPassedMonths
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 图标与状态标识
                ZStack {
                    Circle()
                        .fill(isCurrent ? Color.orange.opacity(0.15) : (isPassed ? Color.secondary.opacity(0.1) : Color.blue.opacity(0.1)))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: isCurrent ? "sparkles" : (isPassed ? "checkmark" : "hourglass.badge.plus"))
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(isCurrent ? .orange : (isPassed ? .secondary : .blue))
                }
                .padding(.top, 20)
                
                VStack(spacing: 8) {
                    Text("人生第 \(monthIndex + 1) 个月")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    
                    Text("\(monthYear) 岁零 \(monthOffset) 个月")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                // 对应历法与状态信息
                VStack(spacing: 12) {
                    InfoRow(label: "对应历法年月", value: formattedDate(targetMonthDate))
                    InfoRow(label: "当前状态", value: isCurrent ? "⚡ 正在度过中" : (isPassed ? "已成回忆" : "⏳ 尚未抵达"))
                    InfoRow(label: "人生阶段", value: lifeStageName(age: monthYear))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("时间格印记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: date)
    }
    
    private func lifeStageName(age: Int) -> String {
        switch age {
        case 0...6: return "童年时期 · 探索世界"
        case 7...17: return "少年求学 · 志存高远"
        case 18...24: return "青年韶华 · 自我发现"
        case 25...39: return "而立壮年 · 奋斗拼搏"
        case 40...59: return "不惑之年 · 沉淀成熟"
        default: return "知天命与花甲 · 智者从容"
        }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}
