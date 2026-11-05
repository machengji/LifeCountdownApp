import SwiftUI
import WidgetKit

/// iOS 16+ 锁屏与待机显示小组件 (AccessoryWidget)
struct LockScreenWidgetView: View {
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            // 环形锁屏小组件
            ZStack {
                AccessoryWidgetBackground()
                ProgressView(
                    value: snapshot.lifeProgressRatio,
                    total: 1.0
                ) {
                    Image(systemName: "hourglass")
                } currentValueLabel: {
                    Text("\(Int(snapshot.lifeProgressRatio * 100))%")
                        .font(.system(size: 11, weight: .bold))
                }
                .progressViewStyle(.circular)
            }
            
        case .accessoryRectangular:
            // 矩形锁屏小组件
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 10))
                    Text("人生剩余 \(snapshot.remainingLifeDays) 天")
                        .font(.system(size: 12, weight: .bold))
                }
                
                Text("已流逝 \(String(format: "%.1f%%", snapshot.lifeProgressRatio * 100)) · 设\(snapshot.targetAge)岁")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                
                Text(quote.content)
                    .font(.system(size: 10))
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            
        case .accessoryInline:
            // 锁屏顶部单行文字小组件
            HStack(spacing: 4) {
                Image(systemName: "hourglass")
                Text("余生 \(snapshot.remainingLifeDays)天 (\(Int(snapshot.lifeProgressRatio * 100))%)")
            }
            
        default:
            Text("余生 \(snapshot.remainingLifeDays)天")
        }
    }
}
