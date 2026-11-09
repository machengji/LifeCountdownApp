import WidgetKit
import SwiftUI
import AppIntents

/// 桌面小组件原生长按编辑配置意图（支持全能签/侧载环境下免跨沙盒直接在桌面长按设置）
struct LifeWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "人生与相伴倒计时设置"
    static var description = IntentDescription("长按桌面小组件选择「编辑小组件」，可直接输入相伴日期与出生日期。")

    @Parameter(title: "伴侣称呼", default: "TA")
    var partnerName: String

    @Parameter(title: "相伴起始日 (如 2023-05-20)", default: "")
    var togetherDateText: String

    @Parameter(title: "出生日期 (如 2000-01-01)", default: "")
    var birthDateText: String

    @Parameter(title: "目标寿命 (岁)", default: 80)
    var targetAge: Int
}

/// 小组件数据实体条目
struct LifeWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: LifeProgressSnapshot
    let quote: PhilosophyQuote
}

/// 小组件时间轴提供者 (支持 AppIntent 桌面直接编辑 + 主 App 共享双引擎)
struct LifeTimelineProvider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> LifeWidgetEntry {
        let defaultIntent = LifeWidgetConfigurationIntent()
        return buildEntry(for: Date(), configuration: defaultIntent)
    }

    func snapshot(for configuration: LifeWidgetConfigurationIntent, in context: Context) async -> LifeWidgetEntry {
        return buildEntry(for: Date(), configuration: configuration)
    }

    func timeline(for configuration: LifeWidgetConfigurationIntent, in context: Context) async -> Timeline<LifeWidgetEntry> {
        let currentDate = Date()
        let entry = buildEntry(for: currentDate, configuration: configuration)
        
        // 每 30 分钟刷新一次，确保今日剩余小时与天数实时准确
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate.addingTimeInterval(1800)
        return Timeline(entries: [entry], policy: .after(nextUpdateDate))
    }
    
    private func buildEntry(for date: Date, configuration: LifeWidgetConfigurationIntent) -> LifeWidgetEntry {
        // 1. 读取主 App 共享配置（若 AppGroup 通道已打通）
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
        
        // 2. 决定出生日期：优先使用小组件长按编辑填入的日期 -> 其次主 App 共享文件 -> 其次 UserDefaults -> 初始值 2000-01-01
        let resolvedBirthDate: Date = {
            if let customBirth = LifeCalculator.parseFlexibleDate(configuration.birthDateText) {
                return customBirth
            }
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
            if (40...120).contains(configuration.targetAge) && configuration.targetAge != 80 {
                return configuration.targetAge
            }
            if let cfg = sharedConfig, (40...120).contains(cfg.targetAge) {
                return cfg.targetAge
            }
            if (40...120).contains(udTargetAge) {
                return udTargetAge
            }
            return max(40, min(120, configuration.targetAge))
        }()
        
        // 4. 决定相伴起始日（严禁任何假数据兜底：优先使用小组件长按编辑填入的日期 -> 其次主 App 共享数据 -> 未填则为 nil）
        let resolvedTogetherDate: Date? = {
            if let customTogether = LifeCalculator.parseFlexibleDate(configuration.togetherDateText) {
                return customTogether
            }
            if let cfg = sharedConfig, let ts = cfg.togetherDateTimestamp, ts > 0 {
                return Date(timeIntervalSince1970: ts)
            }
            if udTogetherTs > 0 {
                return Date(timeIntervalSince1970: udTogetherTs)
            }
            return nil
        }()
        
        let resolvedTogetherEnabled: Bool = {
            if resolvedTogetherDate != nil {
                return true
            }
            if let cfg = sharedConfig {
                return cfg.isTogetherEnabled
            }
            return udTogetherEnabled ?? true
        }()
        
        // 5. 决定伴侣称呼
        let trimmedIntentPartner = configuration.partnerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedPartnerName: String = {
            if !trimmedIntentPartner.isEmpty && trimmedIntentPartner != "TA" {
                return trimmedIntentPartner
            }
            if let cfg = sharedConfig, !cfg.partnerName.isEmpty {
                return cfg.partnerName
            }
            if let up = udPartner, !up.isEmpty {
                return up
            }
            return trimmedIntentPartner.isEmpty ? "TA" : trimmedIntentPartner
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
        AppIntentConfiguration(
            kind: kind,
            intent: LifeWidgetConfigurationIntent.self,
            provider: LifeTimelineProvider()
        ) { entry in
            LifeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("人生与相伴倒计时")
        .description("向死而生，珍视相伴。长按小组件点击「编辑」可直接设定相伴纪念日与出生日期。")
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
