import Foundation
import WidgetKit
import Combine

/// 用户全局偏好配置与小组件共享数据管理器
/// 通过 App Group UserDefaults 保持主 App 与 WidgetKit 小组件之间的数据实时同步
final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    // App Group 标识符（需在 Apple Developer 后台及 Capabilities 中配置）
    static let appGroupIdentifier = "group.com.lifecountdown.app"
    
    private let defaults: UserDefaults
    
    // 键名常量定义
    private enum Keys {
        static let birthDate = "user_birth_date"
        static let targetAge = "user_target_age"
        static let userName = "user_name"
        static let customMotto = "user_custom_motto"
    }
    
    @Published var birthDate: Date {
        didSet {
            defaults.set(birthDate.timeIntervalSince1970, forKey: Keys.birthDate)
            notifyWidgetReload()
        }
    }
    
    @Published var targetAge: Int {
        didSet {
            defaults.set(targetAge, forKey: Keys.targetAge)
            notifyWidgetReload()
        }
    }
    
    @Published var userName: String {
        didSet {
            defaults.set(userName, forKey: Keys.userName)
            notifyWidgetReload()
        }
    }
    
    @Published var customMotto: String {
        didSet {
            defaults.set(customMotto, forKey: Keys.customMotto)
            notifyWidgetReload()
        }
    }
    
    init() {
        // 优先使用 App Group 共享容器，保证 Widget 能够直接读取
        if let groupDefaults = UserDefaults(suiteName: AppSettings.appGroupIdentifier) {
            self.defaults = groupDefaults
        } else {
            self.defaults = UserDefaults.standard
        }
        
        // 读取已存储的设置；若无存储记录，使用明确的初始值
        let savedTimestamp = defaults.double(forKey: Keys.birthDate)
        if savedTimestamp > 0 {
            self.birthDate = Date(timeIntervalSince1970: savedTimestamp)
        } else {
            // 默认设置为 2000年1月1日
            var components = DateComponents()
            components.year = 2000
            components.month = 1
            components.day = 1
            self.birthDate = Calendar.current.date(from: components) ?? Date()
        }
        
        let savedTargetAge = defaults.integer(forKey: Keys.targetAge)
        self.targetAge = savedTargetAge > 0 ? savedTargetAge : 80
        
        self.userName = defaults.string(forKey: Keys.userName) ?? "探索者"
        self.customMotto = defaults.string(forKey: Keys.customMotto) ?? "向死而生，活在当下每一个瞬间。"
    }
    
    /// 当数据变更时通知 WidgetKit 重新计算并刷新桌面小组件
    func notifyWidgetReload() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
