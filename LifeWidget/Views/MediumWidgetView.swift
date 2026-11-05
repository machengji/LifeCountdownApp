import SwiftUI
import WidgetKit

/// 桌面中号小组件 (SystemMedium 2x4)
struct MediumWidgetView: View {
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
    
    var body: some View {
        HStack(spacing: 16) {
            // 左侧：紧凑进度环
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.08), lineWidth: 9)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(snapshot.lifeProgressRatio, 1.0)))
                        .stroke(
                            AngularGradient(
                                colors: [.orange, .purple, .orange],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 9, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text(String(format: "%.1f%%", snapshot.lifeProgressRatio * 100))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        Text("已度过")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 80, height: 80)
                
                Text("余生 \(snapshot.remainingLifeDays) 天")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.orange)
            }
            .frame(width: 95)
            
            Divider()
                .padding(.vertical, 8)
            
            // 右侧：多维数据与每日箴言
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("时间印迹", systemImage: "hourglass")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(snapshot.currentYear)年已过 \(String(format: "%.0f%%", snapshot.yearProgressRatio * 100))")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // 箴言
                Text("“\(quote.content)”")
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .lineSpacing(2)
                
                Spacer(minLength: 0)
                
                HStack {
                    Text("走过 \(snapshot.passedMonths)/\(snapshot.totalMonths) 个月")
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
        .background(Color(UIColor.secondarySystemBackground))
    }
}
