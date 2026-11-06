import SwiftUI
import WidgetKit

/// 桌面中号小组件 (SystemMedium 2x4)
/// 紧凑高信息密度：左侧环形进度 + 右侧相伴天数/年度进程/每日箴言
struct MediumWidgetView: View {
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
    
    var body: some View {
        HStack(spacing: 14) {
            // 左侧：紧凑发光时钟环
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.08), lineWidth: 7.5)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(snapshot.lifeProgressRatio, 1.0)))
                        .stroke(
                            AngularGradient(
                                colors: [.orange, .purple, .orange],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 7.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text(String(format: "%.1f%%", snapshot.lifeProgressRatio * 100))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                        Text("已度过")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 68, height: 68)
                
                Text("余生 \(snapshot.remainingLifeDays)天")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
            }
            .frame(width: 80)
            
            Divider()
                .padding(.vertical, 4)
            
            // 右侧：在一起天数与时间印迹
            VStack(alignment: .leading, spacing: 6) {
                if let togetherDays = snapshot.togetherDays {
                    // 相伴高光
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.pink)
                        Text("与 \(snapshot.partnerName) 相伴")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 1) {
                            Text("\(togetherDays)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.pink)
                            Text("天")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    HStack {
                        Label("时间印迹", systemImage: "hourglass")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(snapshot.currentYear)年过 \(String(format: "%.0f%%", snapshot.yearProgressRatio * 100))")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                
                // 箴言
                Text("“\(quote.content)”")
                    .font(.system(size: 11))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .lineSpacing(2)
                
                Spacer(minLength: 0)
                
                HStack {
                    Text("\(snapshot.currentYear)年剩 \(snapshot.yearRemainingDays)天")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("— \(quote.author)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
    }
}
