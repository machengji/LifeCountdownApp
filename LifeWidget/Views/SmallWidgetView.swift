import SwiftUI
import WidgetKit

/// 桌面小号小组件 (SystemSmall 2x2) · 星曜高对比度版
struct SmallWidgetView: View {
    let snapshot: LifeProgressSnapshot
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.68, blue: 0.22))
                    Text("余生倒计时")
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                }
                Spacer()
                Text(String(format: "%.0f%%", snapshot.lifeProgressRatio * 100))
                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.68, blue: 0.22))
            }
            
            Spacer(minLength: 0)
            
            // 核心余生天数
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(snapshot.remainingLifeDays)")
                        .font(.system(size: 25, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text("天")
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.68, blue: 0.22))
                }
                Text("目标设定 \(snapshot.targetAge) 岁")
                    .font(.system(size: 8.5, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer(minLength: 0)
            
            // 底部相伴徽章或进度条
            if let togetherDays = snapshot.togetherDays {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 9))
                        .foregroundColor(Color(red: 1.0, green: 0.38, blue: 0.58))
                    Text("相伴 \(togetherDays) 天")
                        .font(.system(size: 9.5, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.70))
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(red: 1.0, green: 0.35, blue: 0.55).opacity(0.15))
                )
            } else {
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.12))
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.68, blue: 0.20), Color(red: 1.0, green: 0.35, blue: 0.55)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(4, min(geo.size.width, geo.size.width * CGFloat(snapshot.lifeProgressRatio))))
                        }
                    }
                    .frame(height: 4)
                    
                    HStack {
                        Text("\(snapshot.currentYear)年剩\(snapshot.yearRemainingDays)天")
                            .font(.system(size: 8.5, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text("长按可设相伴")
                            .font(.system(size: 8))
                            .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.65))
                    }
                }
            }
        }
        .padding(12)
    }
}
