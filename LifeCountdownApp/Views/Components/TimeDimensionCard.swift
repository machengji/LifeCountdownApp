import SwiftUI

/// 多维度时间进度指标展示卡片
struct TimeDimensionCard: View {
    let title: String
    let icon: String
    let currentPassed: Int
    let total: Int
    let unit: String
    let ratio: Double
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(accentColor)
                Spacer()
                Text(String(format: "%.1f%%", ratio * 100))
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            }
            
            // 线性进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.06))
                        .frame(height: 7)
                    
                    Capsule()
                        .fill(accentColor)
                        .frame(width: max(0, min(geometry.size.width, geometry.size.width * CGFloat(ratio))), height: 7)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: ratio)
                }
            }
            .frame(height: 7)
            
            HStack {
                Text("已流逝 \(currentPassed) \(unit)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
                Text("剩余 \(max(0, total - currentPassed)) \(unit)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
}
