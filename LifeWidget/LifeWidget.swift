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
        let snapshot = LifeCalculator.calculate(birthDate: sampleBirth, targetAge: 80, asOf: Date())
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
        // 优先读取 AppGroup；若无法访问（如未配置证书权限），则平滑降级至标准偏好设置
        let groupDefaults = UserDefaults(suiteName: AppSettings.appGroupIdentifier)
        let standardDefaults = UserDefaults.standard
        
        var savedTimestamp = groupDefaults?.double(forKey: "user_birth_date") ?? 0
        if savedTimestamp == 0 {
            savedTimestamp = standardDefaults.double(forKey: "user_birth_date")
        }
        
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
        
        var savedTargetAge = groupDefaults?.integer(forKey: "user_target_age") ?? 0
        if savedTargetAge == 0 {
            savedTargetAge = standardDefaults.integer(forKey: "user_target_age")
        }
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

// 统一的跨版本小组件背景修饰符
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
        .description("向死而生，实时感知生命、年度与今日的时光流逝。")
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
