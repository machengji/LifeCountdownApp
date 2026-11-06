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
    }
    
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
    
    init() {
        self.groupDefaults = UserDefaults(suiteName: AppSettings.appGroupIdentifier)
        
        // 优先读取 AppGroup，不存在时读取标准 UserDefaults
        var savedTimestamp = groupDefaults?.double(forKey: Keys.birthDate) ?? 0
        if savedTimestamp == 0 {
            savedTimestamp = standardDefaults.double(forKey: Keys.birthDate)
        }
        
        if savedTimestamp > 0 {
            self.birthDate = Date(timeIntervalSince1970: savedTimestamp)
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
    }
    
    func notifyWidgetReload() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
