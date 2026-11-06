import Foundation
import WidgetKit
import Combine

/// 用户全局偏好配置与小组件共享数据管理器
final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    static let appGroupIdentifier = "group.com.lifecountdown.app"
    
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
    
    // MARK: - 基础生命档案
    @Published var birthDate: Date {
        didSet {
            let timestamp = birthDate.timeIntervalSince1970
            groupDefaults?.set(timestamp, forKey: Keys.birthDate)
            standardDefaults.set(timestamp, forKey: Keys.birthDate)
            notifyWidgetReload()
        }
    }
    
    @Published var targetAge: Int {
        didSet {
            groupDefaults?.set(targetAge, forKey: Keys.targetAge)
            standardDefaults.set(targetAge, forKey: Keys.targetAge)
            notifyWidgetReload()
        }
    }
    
    @Published var userName: String {
        didSet {
            groupDefaults?.set(userName, forKey: Keys.userName)
            standardDefaults.set(userName, forKey: Keys.userName)
            notifyWidgetReload()
        }
    }
    
    @Published var customMotto: String {
        didSet {
            groupDefaults?.set(customMotto, forKey: Keys.customMotto)
            standardDefaults.set(customMotto, forKey: Keys.customMotto)
            notifyWidgetReload()
        }
    }
    
    // MARK: - 在一起纪念日
    @Published var isTogetherEnabled: Bool {
        didSet {
            groupDefaults?.set(isTogetherEnabled, forKey: Keys.isTogetherEnabled)
            standardDefaults.set(isTogetherEnabled, forKey: Keys.isTogetherEnabled)
            notifyWidgetReload()
        }
    }
    
    @Published var togetherDate: Date {
        didSet {
            let timestamp = togetherDate.timeIntervalSince1970
            groupDefaults?.set(timestamp, forKey: Keys.togetherDate)
            standardDefaults.set(timestamp, forKey: Keys.togetherDate)
            notifyWidgetReload()
        }
    }
    
    @Published var partnerName: String {
        didSet {
            groupDefaults?.set(partnerName, forKey: Keys.partnerName)
            standardDefaults.set(partnerName, forKey: Keys.partnerName)
            notifyWidgetReload()
        }
    }
    
    init() {
        self.groupDefaults = UserDefaults(suiteName: AppSettings.appGroupIdentifier)
        
        // 1. 读取出生日期
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
        
        // 2. 读取目标年龄
        var savedTargetAge = groupDefaults?.integer(forKey: Keys.targetAge) ?? 0
        if savedTargetAge == 0 {
            savedTargetAge = standardDefaults.integer(forKey: Keys.targetAge)
        }
        self.targetAge = savedTargetAge > 0 ? savedTargetAge : 80
        
        // 3. 读取用户称谓与座右铭
        self.userName = groupDefaults?.string(forKey: Keys.userName) ?? standardDefaults.string(forKey: Keys.userName) ?? "探索者"
        self.customMotto = groupDefaults?.string(forKey: Keys.customMotto) ?? standardDefaults.string(forKey: Keys.customMotto) ?? "向死而生，活在当下每一个瞬间。"
        
        // 4. 读取在一起配置
        let hasTogetherConfig = groupDefaults?.object(forKey: Keys.isTogetherEnabled) != nil || standardDefaults.object(forKey: Keys.isTogetherEnabled) != nil
        if hasTogetherConfig {
            self.isTogetherEnabled = groupDefaults?.bool(forKey: Keys.isTogetherEnabled) ?? standardDefaults.bool(forKey: Keys.isTogetherEnabled)
        } else {
            self.isTogetherEnabled = true // 默认开启在一起功能
        }
        
        var savedTogetherDate = groupDefaults?.double(forKey: Keys.togetherDate) ?? 0
        if savedTogetherDate == 0 {
            savedTogetherDate = standardDefaults.double(forKey: Keys.togetherDate)
        }
        if savedTogetherDate > 0 {
            self.togetherDate = Date(timeIntervalSince1970: savedTogetherDate)
        } else {
            // 默认设置为 3 年前的纪念日
            self.togetherDate = Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date()
        }
        
        self.partnerName = groupDefaults?.string(forKey: Keys.partnerName) ?? standardDefaults.string(forKey: Keys.partnerName) ?? "TA"
    }
    
    func notifyWidgetReload() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
