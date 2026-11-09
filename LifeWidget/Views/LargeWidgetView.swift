import SwiftUI
import WidgetKit

/// 桌面大号小组件 (SystemLarge 4x4) · 星曜流光双核高定版
/// 架构：
/// 1. 顶部：浪漫相伴正计时 + 周年/余生双陪伴倒计时主卡（支持长按桌面直接编辑）
/// 2. 中部：人生余生倒计时环形仪表盘 + 24阶流光生命胶片晶格
/// 3. 下部：今年 / 本月 / 今日 三联立体进度方卡（上下分层，杜绝折行）
/// 4. 底栏：无截断精炼哲思短句
struct LargeWidgetView: View {
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
    
    var body: some View {
        VStack(spacing: 9) {
            // MARK: - 1. 顶部：浪漫相伴 & 陪伴倒计时主视觉卡
            loveHeroBanner
            
            // MARK: - 2. 中部：人生余生倒计时 & 24阶流光生命晶格卡
            lifeDashboardCard
            
            // MARK: - 3. 中下部：三联立体时光进度方卡（今年 / 本月 / 今日）
            timeDimensionRow
            
            // MARK: - 4. 底部：精炼无截断生命箴言
            quoteFooterBar
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 12)
        .widgetURL(URL(string: "lifecountdown://home"))
    }
    
    // MARK: - 第一层：浪漫相伴正计时 + 周年/余生陪伴倒计时
    @ViewBuilder
    private var loveHeroBanner: some View {
        if let togetherDays = snapshot.togetherDays {
            HStack(spacing: 10) {
                // 左侧：已经在一起天数（正计时）
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.36, blue: 0.58))
                        Text("与 \(snapshot.partnerName) 相伴")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.92))
                            .lineLimit(1)
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("\(togetherDays)")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(red: 1.0, green: 0.78, blue: 0.86)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text("天")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                    }
                    
                    if let dateStr = snapshot.togetherDateFormatted {
                        Text("始于 \(dateStr)")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.55))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 中间渐变分割线
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color(red: 1.0, green: 0.45, blue: 0.65).opacity(0.35), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1, height: 58)
                
                // 右侧：陪伴倒计时双指标（周年纪念倒计时 + 余生共度倒计时）
                VStack(alignment: .leading, spacing: 7) {
                    // 1. 下一个周年纪念倒计时
                    VStack(alignment: .leading, spacing: 3) {
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
                            height: 3.5
                        )
                    }
                    
                    // 2. 余生共度倒计时
                    VStack(alignment: .leading, spacing: 3) {
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
                            height: 3.5
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 15)
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
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.45),
                                        Color.white.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.9
                            )
                    )
            )
        } else {
            // 尚未设置相伴日期时的精致引导卡（不造假，清晰指引长按编辑）
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.35, blue: 0.58).opacity(0.28), Color(red: 0.85, green: 0.25, blue: 0.70).opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text("相伴时光与陪伴倒计时")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.92))
                        Spacer()
                        Text("支持桌面直接设置")
                            .font(.system(size: 8.5, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.65))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color(red: 1.0, green: 0.38, blue: 0.58).opacity(0.18)))
                    }
                    
                    Text("长按小组件 → 点击「编辑小组件」")
                        .font(.system(size: 12.5, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("填入相伴起始日 (如 2023-05-20) 即可开启正计时与周年倒计时")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.60))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.35), lineWidth: 0.9)
                    )
            )
        }
    }
    
    // MARK: - 第二层：人生余生倒计时 + 24阶流光生命胶片晶格
    private var lifeDashboardCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // 左侧发光进度圆环
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
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(snapshot.remainingLifeDays)")
                            .font(.system(size: 25, weight: .heavy, design: .rounded))
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
            
            // 24 阶流光生命胶片晶格条（取代原本沉闷密集的 336 灰点，清爽、科幻、秩序感拉满）
            VStack(alignment: .leading, spacing: 4) {
                let totalSegments = 24
                let activeIndex = min(totalSegments - 1, max(0, Int(snapshot.lifeProgressRatio * Double(totalSegments))))
                
                HStack(spacing: 3.5) {
                    ForEach(0..<totalSegments, id: \.self) { idx in
                        let isPassed = idx < activeIndex
                        let isCurrent = idx == activeIndex
                        
                        RoundedRectangle(cornerRadius: 2.2)
                            .fill(segmentFill(index: idx, total: totalSegments, isPassed: isPassed, isCurrent: isCurrent))
                            .frame(height: 7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2.2)
                                    .stroke(isCurrent ? Color.white.opacity(0.9) : Color.clear, lineWidth: 1)
                            )
                    }
                }
                
                HStack {
                    Text("生命流光轨迹 · 已历 \(snapshot.passedMonths) 月")
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.48))
                    Spacer()
                    Text("每格约代表 \(String(format: "%.1f", Double(snapshot.targetAge) / 24.0)) 年时光")
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.48))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.055))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.68, blue: 0.22).opacity(0.35),
                                    Color.white.opacity(0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
        )
    }
    
    private func segmentFill(index: Int, total: Int, isPassed: Bool, isCurrent: Bool) -> AnyShapeStyle {
        if isCurrent {
            return AnyShapeStyle(Color(red: 1.0, green: 0.85, blue: 0.35))
        } else if isPassed {
            let progress = Double(index) / Double(max(1, total))
            let r = 1.0
            let g = 0.72 - progress * 0.30
            let b = 0.22 + progress * 0.35
            return AnyShapeStyle(Color(red: r, green: g, blue: b).opacity(0.88))
        } else {
            return AnyShapeStyle(Color.white.opacity(0.10))
        }
    }
    
    // MARK: - 第三层：三联立体时光进度方卡（今年 / 本月 / 今日，上下分层绝不折行）
    private var timeDimensionRow: some View {
        HStack(spacing: 8) {
            dimensionMiniCard(
                icon: "calendar",
                title: "\(snapshot.currentYear)年",
                remainingText: "剩 \(snapshot.yearRemainingDays) 天",
                ratio: snapshot.yearProgressRatio,
                accentColor: Color(red: 0.32, green: 0.76, blue: 1.0)
            )
            
            dimensionMiniCard(
                icon: "moon.stars.fill",
                title: "\(snapshot.currentMonth)月",
                remainingText: "剩 \(snapshot.monthRemainingDays) 天",
                ratio: snapshot.monthProgressRatio,
                accentColor: Color(red: 0.25, green: 0.90, blue: 0.75)
            )
            
            dimensionMiniCard(
                icon: "sun.max.fill",
                title: "今日",
                remainingText: "剩 \(snapshot.dayRemainingHours) 小时",
                ratio: snapshot.dayProgressRatio,
                accentColor: Color(red: 1.0, green: 0.65, blue: 0.22)
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
        VStack(alignment: .leading, spacing: 4) {
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
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.055))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accentColor.opacity(0.22), lineWidth: 0.7)
                )
        )
    }
    
    // MARK: - 第四层：底栏无截断生命箴言
    private var quoteFooterBar: some View {
        HStack(spacing: 5) {
            Image(systemName: "sparkles")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.25))
            
            Text(quote.shortContent)
                .font(.system(size: 9.5, weight: .medium))
                .foregroundColor(.white.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            
            Spacer(minLength: 4)
            
            Text("— \(quote.author)")
                .font(.system(size: 9, weight: .semibold))
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
