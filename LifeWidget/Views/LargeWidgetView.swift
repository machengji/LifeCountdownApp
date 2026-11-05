import SwiftUI
import WidgetKit

/// 桌面大号小组件 (SystemLarge 4x4)
/// 包含人生矩阵点阵图（高密度缩略）与全维度指标
struct LargeWidgetView: View {
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
    
    // 大号小组件网格展示：按年展示或按季度/双月展示，由于小组件空间有限，用 24 列紧凑点阵
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 24)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 顶部信息栏
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("人生倒计时印迹")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    Text("目标设定：\(snapshot.targetAge) 岁")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("余 \(snapshot.remainingLifeDays) 天")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("已度过 \(String(format: "%.1f%%", snapshot.lifeProgressRatio * 100))")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // 中部：人生点阵小格矩阵（缩略渲染）
            VStack(alignment: .leading, spacing: 4) {
                Text("人生格网（已过 \(snapshot.passedMonths) 月 / 剩余 \(snapshot.remainingMonths) 月）")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                // 渲染前 360~480 个点（或采样代表全生命周期）
                let sampleCount = min(snapshot.totalMonths, 288) // 12行 x 24列
                LazyVGrid(columns: gridColumns, spacing: 2) {
                    ForEach(0..<sampleCount, id: \.self) { index in
                        // 按比例映射到当前月数
                        let mappedMonth = Int(Double(index) / Double(sampleCount) * Double(snapshot.totalMonths))
                        let isPassed = mappedMonth < snapshot.passedMonths
                        let isCurrent = mappedMonth == snapshot.passedMonths
                        
                        RoundedRectangle(cornerRadius: 1)
                            .fill(isCurrent ? Color.orange : (isPassed ? Color.secondary.opacity(0.4) : Color.primary.opacity(0.08)))
                            .frame(height: 5)
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            // 底部多维感知与箴言
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    miniProgress(label: "\(snapshot.currentYear)年", ratio: snapshot.yearProgressRatio, remaining: "\(snapshot.yearRemainingDays)天")
                    miniProgress(label: "\(snapshot.currentMonth)月", ratio: snapshot.monthProgressRatio, remaining: "\(snapshot.monthRemainingDays)天")
                    miniProgress(label: "今日", ratio: snapshot.dayProgressRatio, remaining: "\(snapshot.dayRemainingHours)小时")
                }
                
                Text("“\(quote.content)” — \(quote.author)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .padding(.top, 2)
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private func miniProgress(label: String, ratio: Double, remaining: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                Spacer()
                Text(remaining)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.08))
                    Capsule().fill(Color.orange)
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(ratio))))
                }
            }
            .frame(height: 3)
        }
        .frame(maxWidth: .infinity)
    }
}
