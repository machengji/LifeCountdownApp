import SwiftUI
import WidgetKit

/// 桌面中号小组件 (SystemMedium 2x4) · 星曜流光双核紧凑版
struct MediumWidgetView: View {
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
    
    var body: some View {
        HStack(spacing: 12) {
            // 左侧：发光进度环 + 余生倒计时
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.10), lineWidth: 6.5)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(snapshot.lifeProgressRatio, 1.0)))
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.72, blue: 0.20),
                                    Color(red: 1.0, green: 0.38, blue: 0.55),
                                    Color(red: 1.0, green: 0.72, blue: 0.20)
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 6.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text(String(format: "%.1f%%", snapshot.lifeProgressRatio * 100))
                            .font(.system(size: 12.5, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("已度过")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.white.opacity(0.55))
                    }
                }
                .frame(width: 64, height: 64)
                
                VStack(spacing: 1) {
                    Text("余生 \(snapshot.remainingLifeDays) 天")
                        .font(.system(size: 10.5, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.25))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text("目标 \(snapshot.targetAge) 岁")
                        .font(.system(size: 8.5))
                        .foregroundColor(.white.opacity(0.48))
                }
            }
            .frame(width: 82)
            
            // 分割线
            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 1)
                .padding(.vertical, 4)
            
            // 右侧：相伴正计时/倒计时 + 多维进度
            VStack(alignment: .leading, spacing: 7) {
                if let togetherDays = snapshot.togetherDays {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.38, blue: 0.58))
                        Text("与 \(snapshot.partnerName) 相伴")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                        Spacer(minLength: 2)
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(togetherDays)")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.65))
                            Text("天")
                                .font(.system(size: 9.5, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    HStack {
                        Text("\(snapshot.nextAnniversaryYear ?? 1)周年剩 \(snapshot.daysUntilNextAnniversary ?? 0) 天")
                            .font(.system(size: 9.5, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.65).opacity(0.9))
                        Spacer()
                        Text("余生同行 \(snapshot.togetherRemainingDays ?? snapshot.remainingLifeDays) 天")
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundColor(.white.opacity(0.65))
                    }
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                            Text("相伴时光与陪伴倒计时")
                                .font(.system(size: 10.5, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        Text("长按小组件 → 点击「编辑」填入相伴起始日")
                            .font(.system(size: 9.5, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.68, blue: 0.25))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                
                Divider().background(Color.white.opacity(0.10))
                
                // 三维简明进度胶囊
                HStack(spacing: 6) {
                    miniTag(label: "\(snapshot.currentYear)年", val: "剩\(snapshot.yearRemainingDays)天", color: Color(red: 0.35, green: 0.78, blue: 1.0))
                    miniTag(label: "\(snapshot.currentMonth)月", val: "剩\(snapshot.monthRemainingDays)天", color: Color(red: 0.28, green: 0.90, blue: 0.75))
                    miniTag(label: "今日", val: "剩\(snapshot.dayRemainingHours)h", color: Color(red: 1.0, green: 0.68, blue: 0.22))
                }
                
                Text(quote.shortContent)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.60))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
    }
    
    private func miniTag(label: String, val: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Circle().fill(color).frame(width: 4, height: 4)
            Text(label)
                .font(.system(size: 8.5, weight: .medium))
                .foregroundColor(.white.opacity(0.65))
            Text(val)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3.5)
        .background(Capsule().fill(Color.white.opacity(0.07)))
    }
}
