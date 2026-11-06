import SwiftUI
import WidgetKit

/// 桌面大号小组件 (SystemLarge 4x4)
/// 紧凑高密度排布：人生倒计时 + 伴侣相伴天数卡片 + 饱满人生点阵网格 + 多维流逝与箴言
struct LargeWidgetView: View {
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
    
    // 采用 24 列高密度点阵，确保纵向饱满充实
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 24)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 1. 顶部人生总倒计时栏
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("人生倒计时印迹")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("目标设定：\(snapshot.targetAge) 岁")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text("余")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.orange)
                        Text("\(snapshot.remainingLifeDays)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                        Text("天")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    Text("已度过 \(String(format: "%.1f%%", snapshot.lifeProgressRatio * 100))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            // 2. 在一起相伴纪念日紧凑卡片 (用户特别指定新增功能)
            if let togetherDays = snapshot.togetherDays {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.pink.opacity(0.2), Color.red.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 32, height: 32)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.pink)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("和 \(snapshot.partnerName) 已经在一起")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 3) {
                            Text("\(togetherDays)")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.pink)
                            Text("天")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("余生同行")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text("共赴每刻")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.primary.opacity(0.8))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary.opacity(0.04))
                )
            }
            
            // 3. 饱满人生小格网格 (消灭原本多余的空白空间，排布紧凑有力)
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("人生格网")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.primary.opacity(0.8))
                    Spacer()
                    Text("已过 \(snapshot.passedMonths) 月 · 剩余 \(snapshot.remainingMonths) 月")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                // 渲染 24列 x 12行 = 288个紧凑方块
                let sampleCount = min(snapshot.totalMonths, 288)
                LazyVGrid(columns: gridColumns, spacing: 2.5) {
                    ForEach(0..<sampleCount, id: \.self) { index in
                        let mappedMonth = Int(Double(index) / Double(sampleCount) * Double(snapshot.totalMonths))
                        let isPassed = mappedMonth < snapshot.passedMonths
                        let isCurrent = mappedMonth == snapshot.passedMonths
                        
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(isCurrent ? Color.orange : (isPassed ? Color.secondary.opacity(0.35) : Color.primary.opacity(0.08)))
                            .frame(height: 6)
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            // 4. 底部多维度时间指标与生命箴言
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    miniDimension(label: "\(snapshot.currentYear)年", ratio: snapshot.yearProgressRatio, remaining: "\(snapshot.yearRemainingDays)天", color: .blue)
                    miniDimension(label: "\(snapshot.currentMonth)月", ratio: snapshot.monthProgressRatio, remaining: "\(snapshot.monthRemainingDays)天", color: .teal)
                    miniDimension(label: "今日", ratio: snapshot.dayProgressRatio, remaining: "\(snapshot.dayRemainingHours)小时", color: .orange)
                }
                
                Text("“\(quote.content)” — \(quote.author)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(14)
    }
    
    private func miniDimension(label: String, ratio: Double, remaining: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                Spacer()
                Text(remaining)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.08))
                    Capsule().fill(color)
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(ratio))))
                }
            }
            .frame(height: 3)
        }
        .frame(maxWidth: .infinity)
    }
}
