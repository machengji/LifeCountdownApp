import Foundation
import WidgetKit
import Combine

/// 共享存储配置数据结构（用于主 App 与 WidgetExtension 物理文件直接共享）
struct SharedAppConfig: Codable {
    var birthDateTimestamp: Double
    var targetAge: Int
    var userName: String
    var customMotto: String
    var isTogetherEnabled: Bool
    var togetherDateTimestamp: Double?
    var partnerName: String
    var lastUpdated: Double
}

/// 用户全局偏好配置与小组件共享数据管理器
final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    static let defaultAppGroup = "group.com.lifecountdown.app"
    private static let configFileName = "life_config.json"
    
    /// 获取当前可能存在的所有 AppGroup 标识符候选（兼容个人免费证书侧载重命名 BundleID 的情况）
    static var appGroupCandidates: [String] {
        var candidates = [defaultAppGroup]
        if let bundleId = Bundle.main.bundleIdentifier {
            let cleanId = bundleId.replacingOccurrences(of: ".LifeWidget", with: "")
            let customGroup = "group.\(cleanId)"
            if !candidates.contains(customGroup) {
                candidates.append(customGroup)
            }
        }
        return candidates
    }
    
    private let standardDefaults = UserDefaults.standard
    
    enum Keys {
        static let birthDate = "user_birth_date"
        static let targetAge = "user_target_age"
        static let userName = "user_name"
        static let customMotto = "user_custom_motto"
        static let isTogetherEnabled = "is_together_enabled"
        static let togetherDate = "user_together_date"
        static let partnerName = "user_partner_name"
    }
    
    @Published var birthDate: Date {
        didSet { persistAll() }
    }
    
    @Published var targetAge: Int {
        didSet { persistAll() }
    }
    
    @Published var userName: String {
        didSet { persistAll() }
    }
    
    @Published var customMotto: String {
        didSet { persistAll() }
    }
    
    @Published var isTogetherEnabled: Bool {
        didSet { persistAll() }
    }
    
    @Published var togetherDate: Date {
        didSet { persistAll() }
    }
    
    @Published var partnerName: String {
        didSet { persistAll() }
    }
    
    init() {
        // 1. 优先从共享物理文件加载配置
        if let config = AppSettings.loadSharedConfigFromFile() {
            self.birthDate = Date(timeIntervalSince1970: config.birthDateTimestamp)
            self.targetAge = config.targetAge
            self.userName = config.userName
            self.customMotto = config.customMotto
            self.isTogetherEnabled = config.isTogetherEnabled
            if let ts = config.togetherDateTimestamp, ts > 0 {
                self.togetherDate = Date(timeIntervalSince1970: ts)
            } else {
                var comp = DateComponents()
                comp.year = 2024
                comp.month = 5
                comp.day = 20
                self.togetherDate = Calendar.current.date(from: comp) ?? Date()
            }
            self.partnerName = config.partnerName
            return
        }
        
        // 2. 尝试从各个候选 AppGroup UserDefaults 或 Standard 读取
        var loadedBirth: Double = 0
        var loadedTargetAge: Int = 0
        var loadedName: String? = nil
        var loadedMotto: String? = nil
        var loadedTogetherEnabled: Bool? = nil
        var loadedTogetherTs: Double = 0
        var loadedPartner: String? = nil
        
        for group in AppSettings.appGroupCandidates {
            if let ud = UserDefaults(suiteName: group) {
                if loadedBirth == 0 { loadedBirth = ud.double(forKey: Keys.birthDate) }
                if loadedTargetAge == 0 { loadedTargetAge = ud.integer(forKey: Keys.targetAge) }
                if loadedName == nil { loadedName = ud.string(forKey: Keys.userName) }
                if loadedMotto == nil { loadedMotto = ud.string(forKey: Keys.customMotto) }
                if loadedTogetherEnabled == nil && ud.object(forKey: Keys.isTogetherEnabled) != nil {
                    loadedTogetherEnabled = ud.bool(forKey: Keys.isTogetherEnabled)
                }
                if loadedTogetherTs == 0 { loadedTogetherTs = ud.double(forKey: Keys.togetherDate) }
                if loadedPartner == nil { loadedPartner = ud.string(forKey: Keys.partnerName) }
            }
        }
        
        // Standard defaults
        if loadedBirth == 0 { loadedBirth = standardDefaults.double(forKey: Keys.birthDate) }
        if loadedTargetAge == 0 { loadedTargetAge = standardDefaults.integer(forKey: Keys.targetAge) }
        if loadedName == nil { loadedName = standardDefaults.string(forKey: Keys.userName) }
        if loadedMotto == nil { loadedMotto = standardDefaults.string(forKey: Keys.customMotto) }
        if loadedTogetherEnabled == nil && standardDefaults.object(forKey: Keys.isTogetherEnabled) != nil {
            loadedTogetherEnabled = standardDefaults.bool(forKey: Keys.isTogetherEnabled)
        }
        if loadedTogetherTs == 0 { loadedTogetherTs = standardDefaults.double(forKey: Keys.togetherDate) }
        if loadedPartner == nil { loadedPartner = standardDefaults.string(forKey: Keys.partnerName) }
        
        if loadedBirth > 0 {
            self.birthDate = Date(timeIntervalSince1970: loadedBirth)
        } else {
            var components = DateComponents()
            components.year = 2000
            components.month = 1
            components.day = 1
            self.birthDate = Calendar.current.date(from: components) ?? Date()
        }
        
        self.targetAge = loadedTargetAge > 0 ? loadedTargetAge : 80
        self.userName = loadedName ?? "探索者"
        self.customMotto = loadedMotto ?? "向死而生，活在当下每一个瞬间。"
        self.isTogetherEnabled = loadedTogetherEnabled ?? true
        
        if loadedTogetherTs > 0 {
            self.togetherDate = Date(timeIntervalSince1970: loadedTogetherTs)
        } else {
            var comp = DateComponents()
            comp.year = 2024
            comp.month = 5
            comp.day = 20
            self.togetherDate = Calendar.current.date(from: comp) ?? Date()
        }
        
        self.partnerName = loadedPartner ?? "TA"
        
        persistAll()
    }
    
    /// 保存并强力广播刷新小组件
    func persistAll() {
        let birthTs = birthDate.timeIntervalSince1970
        let togetherTs = togetherDate.timeIntervalSince1970
        
        // 1. 写入所有可用的 AppGroup UserDefaults
        for group in AppSettings.appGroupCandidates {
            if let ud = UserDefaults(suiteName: group) {
                ud.set(birthTs, forKey: Keys.birthDate)
                ud.set(targetAge, forKey: Keys.targetAge)
                ud.set(userName, forKey: Keys.userName)
                ud.set(customMotto, forKey: Keys.customMotto)
                ud.set(isTogetherEnabled, forKey: Keys.isTogetherEnabled)
                ud.set(togetherTs, forKey: Keys.togetherDate)
                ud.set(partnerName, forKey: Keys.partnerName)
                ud.synchronize()
            }
        }
        
        // 2. 写入 Standard UserDefaults
        standardDefaults.set(birthTs, forKey: Keys.birthDate)
        standardDefaults.set(targetAge, forKey: Keys.targetAge)
        standardDefaults.set(userName, forKey: Keys.userName)
        standardDefaults.set(customMotto, forKey: Keys.customMotto)
        standardDefaults.set(isTogetherEnabled, forKey: Keys.isTogetherEnabled)
        standardDefaults.set(togetherTs, forKey: Keys.togetherDate)
        standardDefaults.set(partnerName, forKey: Keys.partnerName)
        standardDefaults.synchronize()
        
        // 3. 写入 AppGroup 共享磁盘文件
        let config = SharedAppConfig(
            birthDateTimestamp: birthTs,
            targetAge: targetAge,
            userName: userName,
            customMotto: customMotto,
            isTogetherEnabled: isTogetherEnabled,
            togetherDateTimestamp: togetherTs,
            partnerName: partnerName,
            lastUpdated: Date().timeIntervalSince1970
        )
        AppSettings.saveSharedConfigToFile(config)
        
        // 4. 立即请求重载所有 Widget 时间轴
        notifyWidgetReload()
    }
    
    func notifyWidgetReload() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// 计算从相伴起始日到指定日期的自然日天数
    func calculatedTogetherDays(asOf date: Date = Date()) -> Int {
        let cal = Calendar.current
        let startOfTogether = cal.startOfDay(for: togetherDate)
        let startOfCurrent = cal.startOfDay(for: date)
        let diff = cal.dateComponents([.day], from: startOfTogether, to: startOfCurrent).day ?? 0
        return max(0, diff)
    }
    
    // MARK: - 跨进程物理文件直接读写
    static func getSharedFileUrls() -> [URL] {
        var urls: [URL] = []
        for group in appGroupCandidates {
            if let containerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) {
                let fileUrl = containerUrl.appendingPathComponent(configFileName)
                urls.append(fileUrl)
            }
        }
        return urls
    }
    
    static func saveSharedConfigToFile(_ config: SharedAppConfig) {
        guard let data = try? JSONEncoder().encode(config) else { return }
        for url in getSharedFileUrls() {
            try? data.write(to: url, options: .atomic)
        }
    }
    
    static func loadSharedConfigFromFile() -> SharedAppConfig? {
        for url in getSharedFileUrls() {
            if FileManager.default.fileExists(atPath: url.path),
               let data = try? Data(contentsOf: url),
               let config = try? JSONDecoder().decode(SharedAppConfig.self, from: data) {
                return config
            }
        }
        return nil
    }
}
