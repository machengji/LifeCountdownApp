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
    var togetherDateTimestamp: Double
    var partnerName: String
    var lastUpdated: Double
}

/// 用户全局偏好配置与小组件共享数据管理器
final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    static let appGroupIdentifier = "group.com.lifecountdown.app"
    private static let configFileName = "life_config.json"
    
    private let groupDefaults: UserDefaults?
    private let standardDefaults = UserDefaults.standard
    
    private enum Keys {
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
        self.groupDefaults = UserDefaults(suiteName: AppSettings.appGroupIdentifier)
        
        // 优先从共享物理文件加载配置
        if let config = AppSettings.loadSharedConfigFromFile() {
            self.birthDate = Date(timeIntervalSince1970: config.birthDateTimestamp)
            self.targetAge = config.targetAge
            self.userName = config.userName
            self.customMotto = config.customMotto
            self.isTogetherEnabled = config.isTogetherEnabled
            self.togetherDate = Date(timeIntervalSince1970: config.togetherDateTimestamp)
            self.partnerName = config.partnerName
            return
        }
        
        // 降级：从 UserDefaults 读取
        var savedBirth = groupDefaults?.double(forKey: Keys.birthDate) ?? 0
        if savedBirth == 0 {
            savedBirth = standardDefaults.double(forKey: Keys.birthDate)
        }
        if savedBirth > 0 {
            self.birthDate = Date(timeIntervalSince1970: savedBirth)
        } else {
            var components = DateComponents()
            components.year = 2000
            components.month = 1
            components.day = 1
            self.birthDate = Calendar.current.date(from: components) ?? Date()
        }
        
        var savedTargetAge = groupDefaults?.integer(forKey: Keys.targetAge) ?? 0
        if savedTargetAge == 0 {
            savedTargetAge = standardDefaults.integer(forKey: Keys.targetAge)
        }
        self.targetAge = savedTargetAge > 0 ? savedTargetAge : 80
        
        self.userName = groupDefaults?.string(forKey: Keys.userName) ?? standardDefaults.string(forKey: Keys.userName) ?? "探索者"
        self.customMotto = groupDefaults?.string(forKey: Keys.customMotto) ?? standardDefaults.string(forKey: Keys.customMotto) ?? "向死而生，活在当下每一个瞬间。"
        
        let hasTogetherConfig = groupDefaults?.object(forKey: Keys.isTogetherEnabled) != nil || standardDefaults.object(forKey: Keys.isTogetherEnabled) != nil
        if hasTogetherConfig {
            self.isTogetherEnabled = groupDefaults?.bool(forKey: Keys.isTogetherEnabled) ?? standardDefaults.bool(forKey: Keys.isTogetherEnabled)
        } else {
            self.isTogetherEnabled = true
        }
        
        var savedTogether = groupDefaults?.double(forKey: Keys.togetherDate) ?? 0
        if savedTogether == 0 {
            savedTogether = standardDefaults.double(forKey: Keys.togetherDate)
        }
        if savedTogether > 0 {
            self.togetherDate = Date(timeIntervalSince1970: savedTogether)
        } else {
            self.togetherDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        }
        
        self.partnerName = groupDefaults?.string(forKey: Keys.partnerName) ?? standardDefaults.string(forKey: Keys.partnerName) ?? "TA"
        
        // 初始持久化一次
        persistAll()
    }
    
    /// 保存并强力广播刷新小组件
    func persistAll() {
        let birthTs = birthDate.timeIntervalSince1970
        let togetherTs = togetherDate.timeIntervalSince1970
        
        // 1. 写入 UserDefaults (AppGroup 与 Standard 双写)
        groupDefaults?.set(birthTs, forKey: Keys.birthDate)
        standardDefaults.set(birthTs, forKey: Keys.birthDate)
        
        groupDefaults?.set(targetAge, forKey: Keys.targetAge)
        standardDefaults.set(targetAge, forKey: Keys.targetAge)
        
        groupDefaults?.set(userName, forKey: Keys.userName)
        standardDefaults.set(userName, forKey: Keys.userName)
        
        groupDefaults?.set(customMotto, forKey: Keys.customMotto)
        standardDefaults.set(customMotto, forKey: Keys.customMotto)
        
        groupDefaults?.set(isTogetherEnabled, forKey: Keys.isTogetherEnabled)
        standardDefaults.set(isTogetherEnabled, forKey: Keys.isTogetherEnabled)
        
        groupDefaults?.set(togetherTs, forKey: Keys.togetherDate)
        standardDefaults.set(togetherTs, forKey: Keys.togetherDate)
        
        groupDefaults?.set(partnerName, forKey: Keys.partnerName)
        standardDefaults.set(partnerName, forKey: Keys.partnerName)
        
        // 2. 写入 AppGroup 共享磁盘文件 (绕过所有缓存限制，最强稳定性)
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
        
        // 3. 立即重载所有 Widget 时间轴
        notifyWidgetReload()
    }
    
    func notifyWidgetReload() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - 跨进程物理文件直接读写
    static func getSharedFileUrl() -> URL? {
        if let containerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return containerUrl.appendingPathComponent(configFileName)
        }
        return nil
    }
    
    static func saveSharedConfigToFile(_ config: SharedAppConfig) {
        guard let url = getSharedFileUrl() else { return }
        do {
            let data = try JSONEncoder().encode(config)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to save shared config: \(error)")
        }
    }
    
    static func loadSharedConfigFromFile() -> SharedAppConfig? {
        guard let url = getSharedFileUrl(), FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(SharedAppConfig.self, from: data)
        } catch {
            print("Failed to load shared config: \(error)")
            return nil
        }
    }
}
