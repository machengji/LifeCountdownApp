import SwiftUI
import WidgetKit

/// 桌面大号小组件 (SystemLarge 4x4) · 顶级艺术与质感高定版
/// 曜石流光黑金设计 · 饱满星河点阵 (彻底消灭空白留白) · 单行自适应时光胶囊 (杜绝换行)
struct LargeWidgetView: View {
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
    
    // 24列高密度精雕微星芒点阵 (铺满充实，消除中间断层)
    private let matrixColumns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 24)
    
    var body: some View {
        VStack(spacing: 8) {
            // MARK: - 1. 顶部双核心 Hero 卡片
            HStack(spacing: 8) {
                lifeHeroCard
                
                if let togetherDays = snapshot.togetherDays {
                    togetherHeroCard(togetherDays: togetherDays)
                } else {
                    yearHeroCard
                }
            }
            .frame(height: 78)
            
            // MARK: - 2. 中部：饱满星河人生织锦 (无大块留白，紧密排布)
            lifeGalaxyMatrixSection
            
            // MARK: - 3. 下部：三联单行时光胶囊 (严防换行，极简精致)
            timeCapsulesRow
            
            // MARK: - 4. 底部：经典生命哲学箴言
            quoteFooter
        }
        .padding(12)
        .widgetURL(URL(string: "lifecountdown://home"))
    }
    
    // MARK: - 左侧：人生余生 Hero 卡片
    private var lifeHeroCard: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 3) {
                Image(systemName: "hourglass")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.15))
                Text("余生倒计时")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("已行\(String(format: "%.0f%%", snapshot.lifeProgressRatio * 100))")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.15))
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(snapshot.remainingLifeDays)")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("天")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.15))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.12))
                    Capsule()
                        .fill(LinearGradient(colors: [Color(red: 1.0, green: 0.6, blue: 0.1), Color(red: 0.95, green: 0.3, blue: 0.4)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(snapshot.lifeProgressRatio))))
                }
            }
            .frame(height: 3)
            
            Text("设 \(snapshot.targetAge) 岁终章")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 1.0, green: 0.6, blue: 0.15).opacity(0.2), lineWidth: 0.8))
        )
    }
    
    // MARK: - 右侧：相伴纪念日 Hero 卡片
    private func togetherHeroCard(togetherDays: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 3) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.35, blue: 0.55))
                Text("与\(snapshot.partnerName)相伴")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                Spacer()
                Text("共赴")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.35, blue: 0.55))
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(togetherDays)")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("天")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.35, blue: 0.55))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.12))
                    Capsule()
                        .fill(LinearGradient(colors: [Color(red: 1.0, green: 0.35, blue: 0.55), Color(red: 0.85, green: 0.2, blue: 0.8)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width)
                }
            }
            .frame(height: 3)
            
            if let rem = snapshot.togetherRemainingDays {
                Text("余生同行 \(rem) 天")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.5))
            } else {
                Text("朝夕相守 · 每瞬皆诗")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 1.0, green: 0.35, blue: 0.55).opacity(0.2), lineWidth: 0.8))
        )
    }
    
    private var yearHeroCard: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 3) {
                Image(systemName: "calendar")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 0.3, green: 0.75, blue: 1.0))
                Text("\(snapshot.currentYear)年度")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("已过\(String(format: "%.0f%%", snapshot.yearProgressRatio * 100))")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color(red: 0.3, green: 0.75, blue: 1.0))
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(snapshot.yearRemainingDays)")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("天剩")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.3, green: 0.75, blue: 1.0))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.12))
                    Capsule().fill(Color(red: 0.3, green: 0.75, blue: 1.0))
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(snapshot.yearProgressRatio))))
                }
            }
            .frame(height: 3)
            
            Text("步履不停 · 奔赴热爱")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0.3, green: 0.75, blue: 1.0).opacity(0.2), lineWidth: 0.8))
        )
    }
    
    // MARK: - 2. 饱满星河点阵 (扩充至 14行 x 24列 = 336个圆点，饱满消除空白断层)
    private var lifeGalaxyMatrixSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9))
                        .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                    Text("生命星河织锦")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Text("\(snapshot.passedMonths) 印迹已过 · 余 \(snapshot.remainingMonths) 月")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            let sampleCount = 336 // 14 行 x 24 列
            LazyVGrid(columns: matrixColumns, spacing: 3) {
                ForEach(0..<sampleCount, id: \.self) { index in
                    let mappedMonth = Int(Double(index) / Double(sampleCount) * Double(snapshot.totalMonths))
                    let isPassed = mappedMonth < snapshot.passedMonths
                    let isCurrent = mappedMonth == snapshot.passedMonths
                    
                    ZStack {
                        Circle()
                            .fill(dotColor(isPassed: isPassed, isCurrent: isCurrent))
                            .frame(height: 5.5)
                        
                        if isCurrent {
                            Circle()
                                .stroke(Color(red: 1.0, green: 0.65, blue: 0.15), lineWidth: 1.2)
                                .scaleEffect(1.6)
                        }
                    }
                }
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.04))
            )
        }
    }
    
    private func dotColor(isPassed: Bool, isCurrent: Bool) -> Color {
        if isCurrent {
            return Color(red: 1.0, green: 0.7, blue: 0.2)
        } else if isPassed {
            return Color.white.opacity(0.32)
        } else {
            return Color.white.opacity(0.08)
        }
    }
    
    // MARK: - 3. 三联单行胶囊 (自适应紧凑单行，绝对不换行！)
    private var timeCapsulesRow: some View {
        HStack(spacing: 6) {
            cleanPill(icon: "calendar", label: "\(snapshot.currentYear)年", value: "\(snapshot.yearRemainingDays)天", color: Color(red: 0.35, green: 0.75, blue: 1.0))
            cleanPill(icon: "calendar.badge.clock", label: "\(snapshot.currentMonth)月", value: "\(snapshot.monthRemainingDays)天", color: Color(red: 0.3, green: 0.88, blue: 0.75))
            cleanPill(icon: "sun.max.fill", label: "今日", value: "\(snapshot.dayRemainingHours)h", color: Color(red: 1.0, green: 0.65, blue: 0.2))
        }
    }
    
    private func cleanPill(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.75))
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(value)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.06))
        )
    }
    
    // MARK: - 4. 底部生命金句
    private var quoteFooter: some View {
        HStack(spacing: 4) {
            Text("“")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
            Text("\(quote.content) — \(quote.author)")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(1)
            Spacer()
        }
    }
}
