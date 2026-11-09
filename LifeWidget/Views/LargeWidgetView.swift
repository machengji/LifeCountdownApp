import SwiftUI
import WidgetKit

/// 桌面大号小组件 (SystemLarge 4x4) · 曜石星轨·旗舰高定版
/// 针对用户反馈深度重构：
/// 1. 彻底消除边缘大面积松散留白与空隙，卡片有机铺展，饱满紧凑；
/// 2. 四层黄金比例：顶部浪漫相伴双核主卡 + 中部余生仪表与28阶生命晶格 + 下部三联立体进度方卡 + 底栏极简短箴言；
/// 3. 全局 .unredacted()，彻底杜绝任何骨架屏灰色长条遮罩。
struct LargeWidgetView: View {
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
    
    var body: some View {
        VStack(spacing: 7) {
            // MARK: - 1. 顶部：浪漫相伴正计时 + 周年/余生双陪伴倒计时主视觉卡
            loveHeroBanner
            
            // MARK: - 2. 中部：人生余生倒计时 & 28阶流光生命晶格卡
            lifeDashboardCard
            
            // MARK: - 3. 中下部：三联立体时光进度方卡（今年 / 本月 / 今日）
            timeDimensionRow
            
            // MARK: - 4. 底部：精炼无截断生命箴言
            quoteFooterBar
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .unredacted()
        .widgetURL(URL(string: "lifecountdown://home"))
    }
    
    // MARK: - 第一层：浪漫相伴正计时 + 周年/余生陪伴倒计时
    @ViewBuilder
    private var loveHeroBanner: some View {
        if let togetherDays = snapshot.togetherDays {
            HStack(spacing: 10) {
                // 左侧：已经在一起天数（正计时）
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.36, blue: 0.58))
                        Text("与 \(snapshot.partnerName) 相伴")
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundColor(.white.opacity(0.92))
                            .lineLimit(1)
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(togetherDays)")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(red: 1.0, green: 0.82, blue: 0.90)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        Text("天")
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                    }
                    
                    if let dateStr = snapshot.togetherDateFormatted {
                        Text("始于 \(dateStr)")
                            .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.55))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 中间微光分割线
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color(red: 1.0, green: 0.45, blue: 0.65).opacity(0.35), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1, height: 54)
                
                // 右侧：双陪伴倒计时（周年纪念倒计时 + 余生共度倒计时）
                VStack(alignment: .leading, spacing: 6) {
                    // 1. 周年纪念倒计时
                    VStack(alignment: .leading, spacing: 2.5) {
                        HStack {
                            Text("\(snapshot.nextAnniversaryYear ?? 1)周年倒计时")
                                .font(.system(size: 9.5, weight: .medium))
                                .foregroundColor(.white.opacity(0.75))
                            Spacer(minLength: 2)
                            Text("剩 \(snapshot.daysUntilNextAnniversary ?? 0) 天")
                                .font(.system(size: 10.5, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.65))
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        progressCapsule(
                            ratio: snapshot.anniversaryProgressRatio ?? 0.5,
                            colors: [Color(red: 1.0, green: 0.35, blue: 0.58), Color(red: 0.95, green: 0.55, blue: 0.85)],
                            height: 3.2
                        )
                    }
                    
                    // 2. 余生共度倒计时
                    VStack(alignment: .leading, spacing: 2.5) {
                        HStack {
                            Text("余生陪伴倒计时")
                                .font(.system(size: 9.5, weight: .medium))
                                .foregroundColor(.white.opacity(0.75))
                            Spacer(minLength: 2)
                            Text("\(snapshot.togetherRemainingDays ?? snapshot.remainingLifeDays) 天")
                                .font(.system(size: 10.5, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.28))
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        progressCapsule(
                            ratio: max(0.05, 1.0 - snapshot.lifeProgressRatio),
                            colors: [Color(red: 1.0, green: 0.65, blue: 0.2), Color(red: 1.0, green: 0.38, blue: 0.55)],
                            height: 3.2
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 8.5)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.30, blue: 0.52).opacity(0.14),
                                Color(red: 0.55, green: 0.20, blue: 0.65).opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.40),
                                        Color.white.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.75
                            )
                    )
            )
        } else {
            // 尚未设置相伴日期时的引导卡
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.35, blue: 0.58).opacity(0.28), Color(red: 0.85, green: 0.25, blue: 0.70).opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("相伴时光与陪伴倒计时")
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(.white.opacity(0.92))
                        Spacer()
                        Text("待设定")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.65))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(Capsule().fill(Color(red: 1.0, green: 0.38, blue: 0.58).opacity(0.18)))
                    }
                    
                    Text("点击小组件打开 App 设定相伴日")
                        .font(.system(size: 11.5, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("或直接告诉我您的相伴年月日，为您编译专属版")
                        .font(.system(size: 8.5))
                        .foregroundColor(.white.opacity(0.60))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.35), lineWidth: 0.75)
                    )
            )
        }
    }
    
    // MARK: - 第二层：人生余生倒计时 + 28阶流光生命胶片晶格
    private var lifeDashboardCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 11) {
                // 左侧发光圆环仪表
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.10), lineWidth: 5.5)
                    Circle()
                        .trim(from: 0, to: CGFloat(min(1.0, max(0.02, snapshot.lifeProgressRatio))))
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.72, blue: 0.20),
                                    Color(red: 1.0, green: 0.38, blue: 0.52),
                                    Color(red: 1.0, green: 0.72, blue: 0.20)
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 5.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text(String(format: "%.0f%%", snapshot.lifeProgressRatio * 100))
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("已度过")
                            .font(.system(size: 7.5, weight: .medium))
                            .foregroundColor(.white.opacity(0.55))
                    }
                }
                .frame(width: 48, height: 48)
                
                // 右侧人生余生核心指标
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        HStack(spacing: 3) {
                            Image(systemName: "hourglass")
                                .font(.system(size: 9.5, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.68, blue: 0.20))
                            Text("人生余生倒计时")
                                .font(.system(size: 10.5, weight: .bold))
                                .foregroundColor(.white.opacity(0.88))
                        }
                        Spacer()
                        Text("目标 \(snapshot.targetAge) 岁 · 已走过 \(snapshot.passedLifeDays) 天")
                            .font(.system(size: 8.5, weight: .medium))
                            .foregroundColor(.white.opacity(0.52))
                            .lineLimit(1)
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("\(snapshot.remainingLifeDays)")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(red: 1.0, green: 0.80, blue: 0.40)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .lineLimit(1)
                        Text("天剩余")
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.68, blue: 0.20))
                        Spacer()
                        Text("余 \(snapshot.remainingMonths) 个月")
                            .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.68, blue: 0.20).opacity(0.9))
                    }
                }
            }
            
            // 28 阶流光生命胶片晶格条
            VStack(alignment: .leading, spacing: 3.5) {
                let totalSegments = 28
                let activeIndex = min(totalSegments - 1, max(0, Int(snapshot.lifeProgressRatio * Double(totalSegments))))
                
                HStack(spacing: 2.8) {
                    ForEach(0..<totalSegments, id: \.self) { idx in
                        let isPassed = idx < activeIndex
                        let isCurrent = idx == activeIndex
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(segmentFill(index: idx, total: totalSegments, isPassed: isPassed, isCurrent: isCurrent))
                            .frame(height: 7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(isCurrent ? Color.white.opacity(0.9) : Color.clear, lineWidth: 0.9)
                            )
                    }
                }
                
                HStack {
                    Text("生命流光轨迹 · 已历 \(snapshot.passedMonths) 月")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.white.opacity(0.48))
                    Spacer()
                    Text("每格代表 \(String(format: "%.1f", Double(snapshot.targetAge) / Double(totalSegments))) 年")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.white.opacity(0.48))
                }
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8.5)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.055))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.68, blue: 0.20).opacity(0.28),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.75
                        )
                )
        )
    }
    
    /// 晶格背景着色逻辑
    private func segmentFill(index: Int, total: Int, isPassed: Bool, isCurrent: Bool) -> some ShapeStyle {
        if isCurrent {
            return LinearGradient(
                colors: [.white, Color(red: 1.0, green: 0.75, blue: 0.25)],
                startPoint: .top,
                endPoint: .bottom
            )
        } else if isPassed {
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.68, blue: 0.22), Color(red: 0.95, green: 0.38, blue: 0.50)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [Color.white.opacity(0.12), Color.white.opacity(0.06)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    // MARK: - 第三层：三联立体时光进度方卡（今年 / 本月 / 今日，横向铺满，紧凑分层）
    private var timeDimensionRow: some View {
        HStack(spacing: 6) {
            dimensionMiniCard(
                icon: "calendar",
                title: "\(snapshot.currentYear)年",
                remainingText: "剩 \(snapshot.yearRemainingDays) 天",
                ratio: snapshot.yearProgressRatio,
                accentColor: Color(red: 0.35, green: 0.75, blue: 1.0)
            )
            
            dimensionMiniCard(
                icon: "circle.grid.2x2",
                title: "\(snapshot.currentMonth)月",
                remainingText: "剩 \(snapshot.monthRemainingDays) 天",
                ratio: snapshot.monthProgressRatio,
                accentColor: Color(red: 0.40, green: 0.90, blue: 0.68)
            )
            
            dimensionMiniCard(
                icon: "sun.max.fill",
                title: "今日",
                remainingText: "剩 \(snapshot.dayRemainingHours) 小时",
                ratio: snapshot.dayProgressRatio,
                accentColor: Color(red: 1.0, green: 0.72, blue: 0.25)
            )
        }
    }
    
    private func dimensionMiniCard(
        icon: String,
        title: String,
        remainingText: String,
        ratio: Double,
        accentColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 3.5) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 8.5, weight: .bold))
                    .foregroundColor(accentColor)
                Text(title)
                    .font(.system(size: 9.5, weight: .semibold))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text("\(Int(ratio * 100))%")
                    .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                    .foregroundColor(accentColor.opacity(0.9))
            }
            
            Text(remainingText)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            
            progressCapsule(
                ratio: ratio,
                colors: [accentColor.opacity(0.7), accentColor],
                height: 3
            )
        }
        .padding(.horizontal, 8.5)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.055))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accentColor.opacity(0.22), lineWidth: 0.65)
                )
        )
    }
    
    // MARK: - 第四层：底栏无截断精炼生命箴言
    private var quoteFooterBar: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.25))
            
            Text(quote.shortContent)
                .font(.system(size: 9.5, weight: .medium))
                .foregroundColor(.white.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            
            Spacer(minLength: 3)
            
            Text("— \(quote.author)")
                .font(.system(size: 8.5, weight: .semibold))
                .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.25).opacity(0.85))
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - 通用流光进度条组件
    private func progressCapsule(ratio: Double, colors: [Color], height: CGFloat) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.10))
                Capsule()
                    .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(height, min(geo.size.width, geo.size.width * CGFloat(ratio))))
            }
        }
        .frame(height: height)
    }
}
