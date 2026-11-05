import SwiftUI

/// 首页核心仪表盘视图
/// 聚合人生倒计时环形进度、精确天数指标及多维度时间流逝感知
struct MainDashboardView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var currentTime = Date()
    
    // 定时器：每秒更新一次细微的时间流逝
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    private var snapshot: LifeProgressSnapshot {
        LifeCalculator.calculate(birthDate: settings.birthDate, targetAge: settings.targetAge, asOf: currentTime)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 问候与自定义座右铭
                    greetingHeader
                    
                    // 核心环形倒计时进度卡片
                    countdownHeroCard
                    
                    // 多维度时间感知卡片组（一生、今年、本月、今日）
                    dimensionSection
                    
                    // 今日哲学寄语预览
                    todayQuotePreview
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("时间印迹")
            .onReceive(timer) { newTime in
                currentTime = newTime
            }
        }
    }
    
    // MARK: - 问候区
    private var greetingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("你好，\(settings.userName)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text(settings.customMotto)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.top, 6)
    }
    
    // MARK: - 核心倒计时 Hero 卡片
    private var countdownHeroCard: some View {
        VStack(spacing: 20) {
            CircularProgressView(
                progress: snapshot.lifeProgressRatio,
                lineWidth: 18,
                primaryColor: .orange,
                secondaryColor: .purple,
                title: "人生已度过",
                subtitle: "目标设为 \(snapshot.targetAge) 岁"
            )
            .frame(width: 220, height: 220)
            .padding(.top, 8)
            
            // 精确统计数据网格
            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("已走过时光")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text("\(snapshot.passedLifeDays)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("天")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider().frame(height: 38)
                
                VStack(spacing: 4) {
                    Text("预计尚剩余")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text("\(snapshot.remainingLifeDays)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("天")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider().frame(height: 38)
                
                VStack(spacing: 4) {
                    Text("总规划时间")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text("\(snapshot.totalLifeDays)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("天")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.bottom, 6)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 3)
        )
    }
    
    // MARK: - 多维度时间感知
    private var dimensionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("多维度时间流逝")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .padding(.leading, 4)
            
            VStack(spacing: 12) {
                TimeDimensionCard(
                    title: "\(snapshot.currentYear) 年度进程",
                    icon: "calendar",
                    currentPassed: snapshot.yearPassedDays,
                    total: snapshot.yearTotalDays,
                    unit: "天",
                    ratio: snapshot.yearProgressRatio,
                    accentColor: .blue
                )
                
                TimeDimensionCard(
                    title: "\(snapshot.currentMonth) 月度进程",
                    icon: "calendar.badge.clock",
                    currentPassed: snapshot.monthPassedDays,
                    total: snapshot.monthTotalDays,
                    unit: "天",
                    ratio: snapshot.monthProgressRatio,
                    accentColor: .teal
                )
                
                TimeDimensionCard(
                    title: "今日流逝进程",
                    icon: "sun.max",
                    currentPassed: 24 - snapshot.dayRemainingHours,
                    total: 24,
                    unit: "小时",
                    ratio: snapshot.dayProgressRatio,
                    accentColor: .indigo
                )
            }
        }
    }
    
    // MARK: - 今日哲学寄语
    private var todayQuotePreview: some View {
        let quote = PhilosophyQuoteRepository.todayQuote(for: currentTime)
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "quote.opening")
                    .foregroundColor(.orange)
                Text("今日生命随想")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
                Spacer()
            }
            
            Text(quote.content)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            HStack {
                Spacer()
                Text("— \(quote.author) \(quote.source)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}
