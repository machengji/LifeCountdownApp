import SwiftUI
import WidgetKit

/// 桌面小号小组件 (SystemSmall 2x2)
struct SmallWidgetView: View {
    let snapshot: LifeProgressSnapshot
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("余生倒计时")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "hourglass")
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
            }
            
            Spacer(minLength: 0)
            
            // 核心天数
            VStack(alignment: .leading, spacing: 0) {
                Text("\(snapshot.remainingLifeDays)")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                
                Text("天剩余")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 0)
            
            // 紧凑进度条与百分比
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.1))
                            .frame(height: 5)
                        Capsule()
                            .fill(LinearGradient(colors: [.orange, .purple], startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(snapshot.lifeProgressRatio))), height: 5)
                    }
                }
                .frame(height: 5)
                
                HStack {
                    Text("已过 \(String(format: "%.1f%%", snapshot.lifeProgressRatio * 100))")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("设 \(snapshot.targetAge)岁")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
    }
}
