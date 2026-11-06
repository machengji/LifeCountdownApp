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
        // 使用当前真实时间配置计算，绝不使用硬编码的 520 天假数据
        return currentEntry(for: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (LifeWidgetEntry) -> Void) {
        let entry = currentEntry(for: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LifeWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entry = currentEntry(for: currentDate)
        
        // 每半小时刷新一次，保证紧密跟踪
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate.addingTimeInterval(1800)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    private func currentEntry(for date: Date) -> LifeWidgetEntry {
        // 第一优先级：直接从共享磁盘配置文件加载 (最准确，无延迟)
        if let config = AppSettings.loadSharedConfigFromFile() {
            let birthDate = Date(timeIntervalSince1970: config.birthDateTimestamp)
            let togetherDate: Date? = {
                if let ts = config.togetherDateTimestamp, ts > 0 {
                    return Date(timeIntervalSince1970: ts)
                }
                return nil
            }()
            
            let snapshot = LifeCalculator.calculate(
                birthDate: birthDate,
                targetAge: config.targetAge,
                isTogetherEnabled: config.isTogetherEnabled,
                togetherDate: togetherDate,
                partnerName: config.partnerName,
                asOf: date
            )
            let quote = PhilosophyQuoteRepository.todayQuote(for: date)
            return LifeWidgetEntry(date: date, snapshot: snapshot, quote: quote)
        }
        
        // 第二优先级：从候选 AppGroups 及 Standard UserDefaults 读取
        var savedBirth: Double = 0
        var savedTargetAge: Int = 0
        var savedTogetherEnabled: Bool? = nil
        var savedTogether: Double = 0
        var savedPartner: String? = nil
        
        for group in AppSettings.appGroupCandidates {
            if let ud = UserDefaults(suiteName: group) {
                if savedBirth == 0 { savedBirth = ud.double(forKey: AppSettings.Keys.birthDate) }
                if savedTargetAge == 0 { savedTargetAge = ud.integer(forKey: AppSettings.Keys.targetAge) }
                if savedTogetherEnabled == nil && ud.object(forKey: AppSettings.Keys.isTogetherEnabled) != nil {
                    savedTogetherEnabled = ud.bool(forKey: AppSettings.Keys.isTogetherEnabled)
                }
                if savedTogether == 0 { savedTogether = ud.double(forKey: AppSettings.Keys.togetherDate) }
                if savedPartner == nil { savedPartner = ud.string(forKey: AppSettings.Keys.partnerName) }
            }
        }
        
        let standardDefaults = UserDefaults.standard
        if savedBirth == 0 { savedBirth = standardDefaults.double(forKey: AppSettings.Keys.birthDate) }
        if savedTargetAge == 0 { savedTargetAge = standardDefaults.integer(forKey: AppSettings.Keys.targetAge) }
        if savedTogetherEnabled == nil && standardDefaults.object(forKey: AppSettings.Keys.isTogetherEnabled) != nil {
            savedTogetherEnabled = standardDefaults.bool(forKey: AppSettings.Keys.isTogetherEnabled)
        }
        if savedTogether == 0 { savedTogether = standardDefaults.double(forKey: AppSettings.Keys.togetherDate) }
        if savedPartner == nil { savedPartner = standardDefaults.string(forKey: AppSettings.Keys.partnerName) }
        
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
        
        let targetAge = savedTargetAge > 0 ? savedTargetAge : 80
        let isTogetherEnabled = savedTogetherEnabled ?? true
        // 严格遵循业务规则：未配置就是 nil，绝不擅自造假
        let togetherDate: Date? = savedTogether > 0 ? Date(timeIntervalSince1970: savedTogether) : nil
        let partnerName = savedPartner ?? "TA"
        
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
                    ZStack {
                        Color(red: 0.08, green: 0.08, blue: 0.10)
                        RadialGradient(
                            colors: [Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.06), Color.clear],
                            center: .topTrailing,
                            startRadius: 20,
                            endRadius: 200
                        )
                    }
                }
            )
        } else {
            return AnyView(
                self.background(
                    ZStack {
                        Color(red: 0.08, green: 0.08, blue: 0.10)
                        RadialGradient(
                            colors: [Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.06), Color.clear],
                            center: .topTrailing,
                            startRadius: 20,
                            endRadius: 200
                        )
                    }
                )
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
