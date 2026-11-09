import WidgetKit
import SwiftUI

/// 小组件数据实体条目
struct LifeWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
}

/// 小组件时间轴提供者 (经典稳定 StaticConfiguration，完美兼容全能签与所有侧载工具)
struct LifeTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> LifeWidgetEntry {
        return currentEntry(for: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (LifeWidgetEntry) -> Void) {
        let entry = currentEntry(for: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LifeWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entry = currentEntry(for: currentDate)
        
        // 每 30 分钟刷新一次，确保今日剩余小时与天数实时准确
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate.addingTimeInterval(1800)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    private func currentEntry(for date: Date) -> LifeWidgetEntry {
        // 1. 读取主 App 共享配置（若 AppGroup 通道可用）
        let sharedConfig = AppSettings.loadSharedConfigFromFile()
        
        var udBirth: Double = 0
        var udTargetAge: Int = 0
        var udTogetherEnabled: Bool? = nil
        var udTogetherTs: Double = 0
        var udPartner: String? = nil
        
        for group in AppSettings.appGroupCandidates {
            if let ud = UserDefaults(suiteName: group) {
                if udBirth == 0 { udBirth = ud.double(forKey: AppSettings.Keys.birthDate) }
                if udTargetAge == 0 { udTargetAge = ud.integer(forKey: AppSettings.Keys.targetAge) }
                if udTogetherEnabled == nil && ud.object(forKey: AppSettings.Keys.isTogetherEnabled) != nil {
                    udTogetherEnabled = ud.bool(forKey: AppSettings.Keys.isTogetherEnabled)
                }
                if udTogetherTs == 0 { udTogetherTs = ud.double(forKey: AppSettings.Keys.togetherDate) }
                if udPartner == nil { udPartner = ud.string(forKey: AppSettings.Keys.partnerName) }
            }
        }
        
        let standardDefaults = UserDefaults.standard
        if udBirth == 0 { udBirth = standardDefaults.double(forKey: AppSettings.Keys.birthDate) }
        if udTargetAge == 0 { udTargetAge = standardDefaults.integer(forKey: AppSettings.Keys.targetAge) }
        if udTogetherEnabled == nil && standardDefaults.object(forKey: AppSettings.Keys.isTogetherEnabled) != nil {
            udTogetherEnabled = standardDefaults.bool(forKey: AppSettings.Keys.isTogetherEnabled)
        }
        if udTogetherTs == 0 { udTogetherTs = standardDefaults.double(forKey: AppSettings.Keys.togetherDate) }
        if udPartner == nil { udPartner = standardDefaults.string(forKey: AppSettings.Keys.partnerName) }
        
        // 2. 决定出生日期（共享配置 -> UserDefaults -> 2000-01-01）
        let resolvedBirthDate: Date = {
            if let cfg = sharedConfig, cfg.birthDateTimestamp > 0 {
                return Date(timeIntervalSince1970: cfg.birthDateTimestamp)
            }
            if udBirth > 0 {
                return Date(timeIntervalSince1970: udBirth)
            }
            var comp = DateComponents()
            comp.year = 2000
            comp.month = 1
            comp.day = 1
            return Calendar.current.date(from: comp) ?? date
        }()
        
        // 3. 决定目标寿命
        let resolvedTargetAge: Int = {
            if let cfg = sharedConfig, (40...120).contains(cfg.targetAge) {
                return cfg.targetAge
            }
            if (40...120).contains(udTargetAge) {
                return udTargetAge
            }
            return 80
        }()
        
        // 4. 决定相伴起始日（优先从主 App 共享读取，若全能签跨沙盒隔离未获取，采用用户指定的真实基准日 2025-07-06）
        let resolvedTogetherDate: Date? = {
            if let cfg = sharedConfig, let ts = cfg.togetherDateTimestamp, ts > 0 {
                return Date(timeIntervalSince1970: ts)
            }
            if udTogetherTs > 0 {
                return Date(timeIntervalSince1970: udTogetherTs)
            }
            var comp = DateComponents()
            comp.year = 2025
            comp.month = 7
            comp.day = 6
            return Calendar.current.date(from: comp)
        }()
        
        let resolvedTogetherEnabled: Bool = {
            if let cfg = sharedConfig {
                return cfg.isTogetherEnabled
            }
            return udTogetherEnabled ?? true
        }()
        
        // 5. 决定伴侣称呼
        let resolvedPartnerName: String = {
            if let cfg = sharedConfig, !cfg.partnerName.isEmpty {
                return cfg.partnerName
            }
            if let up = udPartner, !up.isEmpty {
                return up
            }
            return "TA"
        }()
        
        let snapshot = LifeCalculator.calculate(
            birthDate: resolvedBirthDate,
            targetAge: resolvedTargetAge,
            isTogetherEnabled: resolvedTogetherEnabled,
            togetherDate: resolvedTogetherDate,
            partnerName: resolvedPartnerName,
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
        .unredacted() // 强制解除任何系统骨架条灰色遮罩，让所有文字、数字绝对清晰可见！
        .widgetContainerBackground()
    }
}

extension View {
    func widgetContainerBackground() -> some View {
        self.containerBackground(for: .widget) {
            ZStack {
                // 深空星曜底色渐变
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.06, blue: 0.10),
                        Color(red: 0.09, green: 0.10, blue: 0.16)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 右上角浪漫玫瑰星云微光晕染
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.32, blue: 0.55).opacity(0.14),
                        Color.clear
                    ],
                    center: .topTrailing,
                    startRadius: 10,
                    endRadius: 220
                )
                
                // 左下角琥珀流光微光晕染
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.65, blue: 0.18).opacity(0.10),
                        Color.clear
                    ],
                    center: .bottomLeading,
                    startRadius: 15,
                    endRadius: 200
                )
            }
        }
    }
}

/// 小组件元数据声明
struct LifeCountdownWidget: Widget {
    let kind: String = "LifeCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: LifeTimelineProvider()
        ) { entry in
            LifeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("人生与相伴倒计时")
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
