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
    
    func placeholder(in context: Context) -> LifeWidgetEntry {
        let sampleBirth = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
        let sampleTogether = Calendar.current.date(byAdding: .day, value: -520, to: Date())
        let snapshot = LifeCalculator.calculate(
            birthDate: sampleBirth,
            targetAge: 80,
            isTogetherEnabled: true,
            togetherDate: sampleTogether,
            partnerName: "TA",
            asOf: Date()
        )
        let quote = PhilosophyQuoteRepository.todayQuote()
        return LifeWidgetEntry(date: Date(), snapshot: snapshot, quote: quote)
    }

    func getSnapshot(in context: Context, completion: @escaping (LifeWidgetEntry) -> Void) {
        let entry = currentEntry(for: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LifeWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entry = currentEntry(for: currentDate)
        
        // 设定每小时整点自动刷新一次
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate.addingTimeInterval(3600)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    private func currentEntry(for date: Date) -> LifeWidgetEntry {
        let groupDefaults = UserDefaults(suiteName: AppSettings.appGroupIdentifier)
        let standardDefaults = UserDefaults.standard
        
        // 1. 出生日期
        var savedBirth = groupDefaults?.double(forKey: "user_birth_date") ?? 0
        if savedBirth == 0 {
            savedBirth = standardDefaults.double(forKey: "user_birth_date")
        }
        let birthDate: Date
        if savedBirth > 0 {
            birthDate = Date(timeIntervalSince1970: savedBirth)
        } else {
            var components = DateComponents()
            components.year = 2000
            components.month = 1
            components.day = 1
            birthDate = Calendar.current.date(from: components) ?? date
        }
        
        // 2. 目标年龄
        var savedTargetAge = groupDefaults?.integer(forKey: "user_target_age") ?? 0
        if savedTargetAge == 0 {
            savedTargetAge = standardDefaults.integer(forKey: "user_target_age")
        }
        let targetAge = savedTargetAge > 0 ? savedTargetAge : 80
        
        // 3. 在一起纪念日
        let hasTogetherConfig = groupDefaults?.object(forKey: "is_together_enabled") != nil || standardDefaults.object(forKey: "is_together_enabled") != nil
        let isTogetherEnabled: Bool
        if hasTogetherConfig {
            isTogetherEnabled = groupDefaults?.bool(forKey: "is_together_enabled") ?? standardDefaults.bool(forKey: "is_together_enabled")
        } else {
            isTogetherEnabled = true
        }
        
        var savedTogether = groupDefaults?.double(forKey: "user_together_date") ?? 0
        if savedTogether == 0 {
            savedTogether = standardDefaults.double(forKey: "user_together_date")
        }
        let togetherDate: Date? = savedTogether > 0 ? Date(timeIntervalSince1970: savedTogether) : Calendar.current.date(byAdding: .day, value: -520, to: date)
        
        let partnerName = groupDefaults?.string(forKey: "user_partner_name") ?? standardDefaults.string(forKey: "user_partner_name") ?? "TA"
        
        let snapshot = LifeCalculator.calculate(
            birthDate: birthDate,
            targetAge: targetAge,
            isTogetherEnabled: isTogetherEnabled,
            togetherDate: togetherDate,
            partnerName: partnerName,
            asOf: date
        )
        let quote = PhilosophyQuoteRepository.todayQuote(for: date)
        
        return LifeWidgetEntry(date: date, snapshot: snapshot, quote: quote)
    }
}

/// 核心小组件入口视图
struct LifeWidgetEntryView: View {
    var entry: LifeTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
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
        .widgetContainerBackground()
    }
}

extension View {
    func widgetContainerBackground() -> some View {
        if #available(iOS 17.0, *) {
            return AnyView(
                self.containerBackground(for: .widget) {
                    Color(UIColor.secondarySystemBackground)
                }
            )
        } else {
            return AnyView(
                self.background(Color(UIColor.secondarySystemBackground))
            )
        }
    }
}

/// 小组件元数据声明
struct LifeCountdownWidget: Widget {
    let kind: String = "LifeCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeTimelineProvider()) { entry in
            LifeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("人生倒计时")
        .description("向死而生，感知生命流逝与相伴时光。")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
        .contentMarginsDisabled()
    }
}
