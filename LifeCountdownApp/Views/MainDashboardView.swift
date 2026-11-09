import SwiftUI

/// 首页核心仪表盘视图
struct MainDashboardView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    private var snapshot: LifeProgressSnapshot {
        LifeCalculator.calculate(
            birthDate: settings.birthDate,
            targetAge: settings.targetAge,
            isTogetherEnabled: settings.isTogetherEnabled,
            togetherDate: settings.togetherDate,
            partnerName: settings.partnerName,
            asOf: currentTime
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 问候区
                    greetingHeader
                    
                    // 核心环形倒计时 Hero 卡片
                    countdownHeroCard
                    
                    // 相伴时光纪念日专属卡片
                    if let togetherDays = snapshot.togetherDays {
                        togetherCard(days: togetherDays)
                    }
                    
                    // 多维度时间感知卡片组（一生、今年、本月、今日）
                    dimensionSection
                    
                    // 今日哲学寄语预览
                    todayQuotePreview
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("时间印迹")
            .navigationBarTitleDisplayMode(.inline)
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
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text(settings.customMotto)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.top, 4)
    }
    
    // MARK: - 核心倒计时卡片
    private var countdownHeroCard: some View {
        VStack(spacing: 16) {
            CircularProgressView(
                progress: snapshot.lifeProgressRatio,
                lineWidth: 16,
                primaryColor: .orange,
                secondaryColor: .purple,
                title: "人生已度过",
                subtitle: "目标设为 \(snapshot.targetAge) 岁"
            )
            .frame(width: 200, height: 200)
            .padding(.top, 6)
            
            HStack(spacing: 12) {
                VStack(spacing: 3) {
                    Text("已走过时光")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("\(snapshot.passedLifeDays)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("天")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider().frame(height: 34)
                
                VStack(spacing: 3) {
                    Text("预计尚剩余")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("\(snapshot.remainingLifeDays)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("天")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider().frame(height: 34)
                
                VStack(spacing: 3) {
                    Text("总规划时间")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("\(snapshot.totalLifeDays)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("天")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - 相伴时光与陪伴倒计时卡片
    private func togetherCard(days: Int) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.pink.opacity(0.2), Color.red.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.pink)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text("和 \(snapshot.partnerName) 已经在一起")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        if let dateStr = snapshot.togetherDateFormatted {
                            Text("始于 \(dateStr)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text("\(days)")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.pink)
                        Text("天")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.pink.opacity(0.8))
                    }
                }
            }
            
            Divider()
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("距 \(snapshot.nextAnniversaryYear ?? 1) 周年纪念倒计时")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("剩 \(snapshot.daysUntilNextAnniversary ?? 0) 天")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.pink)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider().frame(height: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("余生陪伴倒计时")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("\(snapshot.togetherRemainingDays ?? snapshot.remainingLifeDays) 天")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - 多维度时间感知
    private var dimensionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("多维度时间流逝")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .padding(.leading, 4)
            
            VStack(spacing: 10) {
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
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "quote.opening")
                    .foregroundColor(.orange)
                Text("今日生命随想")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.orange)
                Spacer()
            }
            
            Text(quote.content)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            HStack {
                Spacer()
                Text("— \(quote.author) \(quote.source)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}
