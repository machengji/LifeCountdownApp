import SwiftUI
import WidgetKit

/// 桌面大号小组件 (SystemLarge 4x4) · 顶级艺术与质感高定版
/// 曜石流光黑金设计 · 双核心生命与相伴能量卡片 · 璀璨星河时光点阵 · 三联药丸胶囊
struct LargeWidgetView: View {
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
    
    // 20列高质感微星芒点阵
    private let matrixColumns = Array(repeating: GridItem(.flexible(), spacing: 3.5), count: 20)
    
    var body: some View {
        VStack(spacing: 11) {
            // MARK: - 1. 顶部双核心 Hero 卡片 (左人生倒计时，右相伴纪念日)
            HStack(spacing: 9) {
                // 左核心：人生余生天数
                lifeHeroCard
                
                // 右核心：相伴天数 (若开启) 或 年度终章卡片
                if let togetherDays = snapshot.togetherDays {
                    togetherHeroCard(togetherDays: togetherDays)
                } else {
                    yearHeroCard
                }
            }
            .frame(height: 82)
            
            // MARK: - 2. 中部：璀璨星河人生织锦 (高质感点阵，杜绝密集方块)
            lifeGalaxyMatrixSection
            
            Spacer(minLength: 0)
            
            // MARK: - 3. 下部：三联时光胶囊 (年度/月度/今日)
            timeCapsulesRow
            
            // MARK: - 4. 底部：经典生命哲学箴言
            quoteFooter
        }
        .padding(14)
        .widgetURL(URL(string: "lifecountdown://home"))
    }
    
    // MARK: - 左侧：人生余生 Hero 卡片
    private var lifeHeroCard: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "hourglass")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.15))
                Text("余生倒计时")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.75))
                Spacer()
                Text("已行 \(String(format: "%.0f%%", snapshot.lifeProgressRatio * 100))")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.15))
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(snapshot.remainingLifeDays)")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                Text("天")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.15))
            }
            
            // 微光生命刻度细线
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.6, blue: 0.1), Color(red: 0.95, green: 0.3, blue: 0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(snapshot.lifeProgressRatio))))
                }
            }
            .frame(height: 3)
            .padding(.top, 2)
            
            Text("设 \(snapshot.targetAge) 岁终章")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 1.0, green: 0.6, blue: 0.15).opacity(0.25), lineWidth: 0.8)
                )
        )
    }
    
    // MARK: - 右侧：甜蜜相伴 Hero 卡片
    private func togetherHeroCard(togetherDays: Int) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.35, blue: 0.55))
                Text("与\(snapshot.partnerName)相伴")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(1)
                Spacer()
                Text("共赴")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.35, blue: 0.55))
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(togetherDays)")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                Text("天")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.35, blue: 0.55))
            }
            
            // 爱情微光细线
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.12))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.35, blue: 0.55), Color(red: 0.85, green: 0.2, blue: 0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width)
                }
            }
            .frame(height: 3)
            .padding(.top, 2)
            
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
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 1.0, green: 0.35, blue: 0.55).opacity(0.25), lineWidth: 0.8)
                )
        )
    }
    
    // MARK: - 未配置相伴时的备用卡片
    private var yearHeroCard: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.3, green: 0.75, blue: 1.0))
                Text("\(snapshot.currentYear)年度")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.75))
                Spacer()
                Text("已过\(String(format: "%.0f%%", snapshot.yearProgressRatio * 100))")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(red: 0.3, green: 0.75, blue: 1.0))
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(snapshot.yearRemainingDays)")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("天剩")
                    .font(.system(size: 12, weight: .bold))
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
            .padding(.top, 2)
            
            Text("步履不停 · 奔赴热爱")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0.3, green: 0.75, blue: 1.0).opacity(0.25), lineWidth: 0.8)
                )
        )
    }
    
    // MARK: - 2. 璀璨星河时光点阵 (高定版)
    private var lifeGalaxyMatrixSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                    Text("生命星河织锦")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Text("\(snapshot.passedMonths) 印迹已过 · 余 \(snapshot.remainingMonths) 月")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.55))
            }
            
            // 200 个精雕时光微圆点 (20列 x 10行)
            let sampleCount = 200
            LazyVGrid(columns: matrixColumns, spacing: 3.5) {
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
            .padding(.horizontal, 9)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.04))
            )
        }
    }
    
    private func dotColor(isPassed: Bool, isCurrent: Bool) -> Color {
        if isCurrent {
            return Color(red: 1.0, green: 0.7, blue: 0.2) // 璀璨高光金
        } else if isPassed {
            return Color.white.opacity(0.35) // 已走过星轨
        } else {
            return Color.white.opacity(0.08) // 未来星芒
        }
    }
    
    // MARK: - 3. 三联时光胶囊 (年度/月度/今日)
    private var timeCapsulesRow: some View {
        HStack(spacing: 6) {
            pillChip(icon: "calendar", title: "\(snapshot.currentYear)年", value: "剩\(snapshot.yearRemainingDays)天", color: Color(red: 0.35, green: 0.75, blue: 1.0))
            pillChip(icon: "calendar.badge.clock", title: "\(snapshot.currentMonth)月", value: "剩\(snapshot.monthRemainingDays)天", color: Color(red: 0.3, green: 0.88, blue: 0.75))
            pillChip(icon: "sun.max.fill", title: "今日", value: "剩\(snapshot.dayRemainingHours)h", color: Color(red: 1.0, green: 0.65, blue: 0.2))
        }
    }
    
    private func pillChip(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            Spacer(minLength: 0)
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.06))
        )
    }
    
    // MARK: - 4. 底部生命金句
    private var quoteFooter: some View {
        HStack(spacing: 5) {
            Text("“")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
            Text("\(quote.content) — \(quote.author)")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(1)
            Spacer()
        }
        .padding(.top, 1)
    }
}
