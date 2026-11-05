import WidgetKit
import SwiftUI

/// 小组件数据实体条目
struct LifeWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
}

/// 小组件时间轴提供者
struct LifeTimelineProvider: TimelineProvider {
    
    // 占位视图展示的数据
    func placeholder(in context: Context) -> LifeWidgetEntry {
        let sampleBirth = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
        let snapshot = LifeCalculator.calculate(birthDate: sampleBirth, targetAge: 80, asOf: Date())
        let quote = PhilosophyQuoteRepository.todayQuote()
        return LifeWidgetEntry(date: Date(), snapshot: snapshot, quote: quote)
    }

    // 小组件图库中快速预览
    func getSnapshot(in context: Context, completion: @escaping (LifeWidgetEntry) -> Void) {
        let entry = currentEntry(for: Date())
        completion(entry)
    }

    // 实际运行时的时间轴生成策略
    func getTimeline(in context: Context, completion: @escaping (Timeline<LifeWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entry = currentEntry(for: currentDate)
        
        // 设定下一次自动刷新时间：每小时整点或每日午夜刷新
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate.addingTimeInterval(3600)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    /// 从 AppGroup UserDefaults 中提取用户设置并计算快照
    private func currentEntry(for date: Date) -> LifeWidgetEntry {
        let defaults = UserDefaults(suiteName: AppSettings.appGroupIdentifier) ?? UserDefaults.standard
        
        let savedTimestamp = defaults.double(forKey: "user_birth_date")
        let birthDate: Date
        if savedTimestamp > 0 {
            birthDate = Date(timeIntervalSince1970: savedTimestamp)
        } else {
            var components = DateComponents()
            components.year = 2000
            components.month = 1
            components.day = 1
            birthDate = Calendar.current.date(from: components) ?? date
        }
        
        let savedTargetAge = defaults.integer(forKey: "user_target_age")
        let targetAge = savedTargetAge > 0 ? savedTargetAge : 80
        
        let snapshot = LifeCalculator.calculate(birthDate: birthDate, targetAge: targetAge, asOf: date)
        let quote = PhilosophyQuoteRepository.todayQuote(for: date)
        
        return LifeWidgetEntry(date: date, snapshot: snapshot, quote: quote)
    }
}

/// 核心小组件入口视图
struct LifeWidgetEntryView: View {
    var entry: LifeTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(snapshot: entry.snapshot)
        case .systemMedium:
            MediumWidgetView(snapshot: entry.snapshot, quote: entry.quote)
        case .systemLarge:
            LargeWidgetView(snapshot: entry.snapshot, quote: entry.quote)
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            LockScreenWidgetView(snapshot: entry.snapshot, quote: entry.quote)
        default:
            SmallWidgetView(snapshot: entry.snapshot)
        }
    }
}

/// 小组件元数据声明
struct LifeCountdownWidget: Widget {
    let kind: String = "LifeCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                LifeWidgetEntryView(entry: entry)
                    .containerBackground(Color(UIColor.secondarySystemBackground), for: .widget)
            } else {
                LifeWidgetEntryView(entry: entry)
                    .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .configurationDisplayName("人生倒计时印迹")
        .description("向死而生，实时感知生命、年度与今日的时光流逝。")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
