import Foundation

/// 人生时间、相伴时光与多维度时间流逝计算器
struct LifeProgressSnapshot {
    let birthDate: Date
    let targetDate: Date
    let currentDate: Date
    let targetAge: Int
    
    // MARK: - 一生维度指标
    let totalLifeDays: Int
    let passedLifeDays: Int
    let remainingLifeDays: Int
    let lifeProgressRatio: Double // 0.0 ~ 1.0
    
    // 格子维度（按月计算：1年12个月）
    let totalMonths: Int
    let passedMonths: Int
    let remainingMonths: Int
    let currentMonthIndex: Int
    
    // MARK: - 在一起纪念日与陪伴倒计时
    let isTogetherEnabled: Bool
    let togetherDate: Date?
    let togetherDateFormatted: String?
    let partnerName: String
    let togetherDays: Int? // 已经在一起的天数
    let togetherRemainingDays: Int? // 预期余生携手倒计时天数
    let nextAnniversaryYear: Int? // 下一个周年数（第 X 周年）
    let daysUntilNextAnniversary: Int? // 距离下一个周年纪念日倒计时天数
    let anniversaryProgressRatio: Double? // 当前周年进度比 (0.0 ~ 1.0)
    
    // MARK: - 年度维度指标
    let currentYear: Int
    let yearTotalDays: Int
    let yearPassedDays: Int
    let yearRemainingDays: Int
    let yearProgressRatio: Double
    
    // MARK: - 月度维度指标
    let currentMonth: Int
    let monthTotalDays: Int
    let monthPassedDays: Int
    let monthRemainingDays: Int
    let monthProgressRatio: Double
    
    // MARK: - 今日维度指标
    let dayRemainingHours: Int
    let dayRemainingMinutes: Int
    let dayProgressRatio: Double
}

enum LifeCalculator {
    /// 智能解析用户输入的日期字符串（支持 2023-05-20 / 2023.05.20 / 2023/05/20 / 20230520 / 2023年5月20日）
    /// 若输入为空或无效，如实返回 nil，绝不伪造兜底日期
    static func parseFlexibleDate(_ raw: String) -> Date? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        let calendar = Calendar.current
        
        // 1. 尝试纯 8 位数字格式 YYYYMMDD
        let digitsOnly = trimmed.filter { $0.isNumber }
        if digitsOnly.count == 8, trimmed.count == 8 {
            let yStr = String(digitsOnly.prefix(4))
            let mStr = String(digitsOnly.dropFirst(4).prefix(2))
            let dStr = String(digitsOnly.suffix(2))
            if let y = Int(yStr), let m = Int(mStr), let d = Int(dStr),
               (1900...2100).contains(y), (1...12).contains(m), (1...31).contains(d) {
                var comp = DateComponents()
                comp.year = y
                comp.month = m
                comp.day = d
                if let validDate = calendar.date(from: comp) {
                    return calendar.startOfDay(for: validDate)
                }
            }
        }
        
        // 2. 将常见分隔符统一提取为数字数组 [年, 月, 日]
        let parts = trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
        if parts.count == 3,
           let y = Int(parts[0]),
           let m = Int(parts[1]),
           let d = Int(parts[2]),
           (1900...2100).contains(y), (1...12).contains(m), (1...31).contains(d) {
            var comp = DateComponents()
            comp.year = y
            comp.month = m
            comp.day = d
            if let validDate = calendar.date(from: comp) {
                return calendar.startOfDay(for: validDate)
            }
        }
        
        return nil
    }
    
    /// 将日期格式化为 YYYY.MM.DD
    static func formatDotDate(_ date: Date) -> String {
        let cal = Calendar.current
        let y = cal.component(.year, from: date)
        let m = cal.component(.month, from: date)
        let d = cal.component(.day, from: date)
        return String(format: "%04d.%02d.%02d", y, m, d)
    }
    
    static func calculate(
        birthDate: Date,
        targetAge: Int,
        isTogetherEnabled: Bool = false,
        togetherDate: Date? = nil,
        partnerName: String = "TA",
        asOf currentDate: Date = Date()
    ) -> LifeProgressSnapshot {
        let calendar = Calendar.current
        let startOfBirth = calendar.startOfDay(for: birthDate)
        let startOfCurrent = calendar.startOfDay(for: currentDate)
        
        let targetDate = calendar.date(byAdding: .year, value: targetAge, to: startOfBirth) ?? startOfBirth
        
        // 1. 一生总天数与剩余天数
        let totalDays = max(1, calendar.dateComponents([.day], from: startOfBirth, to: targetDate).day ?? (targetAge * 365))
        let passedDays = max(0, calendar.dateComponents([.day], from: startOfBirth, to: startOfCurrent).day ?? 0)
        let remainingDays = max(0, totalDays - passedDays)
        let lifeProgressRatio = min(1.0, max(0.0, Double(passedDays) / Double(totalDays)))
        
        // 2. 一生总月份与当前月份
        let totalMonths = targetAge * 12
        let passedMonths = max(0, calendar.dateComponents([.month], from: startOfBirth, to: startOfCurrent).month ?? 0)
        let remainingMonths = max(0, totalMonths - passedMonths)
        let currentMonthIndex = min(totalMonths - 1, passedMonths)
        
        // 3. 在一起天数与陪伴倒计时计算
        var calculatedTogetherDays: Int? = nil
        var calculatedTogetherRemainingDays: Int? = nil
        var formattedTogether: String? = nil
        var nextAnnivYear: Int? = nil
        var daysUntilAnniv: Int? = nil
        var annivRatio: Double? = nil
        
        if isTogetherEnabled, let together = togetherDate {
            let startOfTogether = calendar.startOfDay(for: together)
            let days = calendar.dateComponents([.day], from: startOfTogether, to: startOfCurrent).day ?? 0
            calculatedTogetherDays = max(0, days)
            calculatedTogetherRemainingDays = remainingDays
            formattedTogether = formatDotDate(startOfTogether)
            
            // 计算下一个周年纪念日与倒计时
            var yearCount = max(1, (calendar.dateComponents([.year], from: startOfTogether, to: startOfCurrent).year ?? 0) + 1)
            var candidateAnniv = calendar.date(byAdding: .year, value: yearCount, to: startOfTogether) ?? startOfCurrent
            if candidateAnniv < startOfCurrent {
                yearCount += 1
                candidateAnniv = calendar.date(byAdding: .year, value: yearCount, to: startOfTogether) ?? startOfCurrent
            }
            let prevAnniv = calendar.date(byAdding: .year, value: yearCount - 1, to: startOfTogether) ?? startOfTogether
            let totalAnnivSpan = max(1, calendar.dateComponents([.day], from: prevAnniv, to: candidateAnniv).day ?? 365)
            let remAnnivDays = max(0, calendar.dateComponents([.day], from: startOfCurrent, to: candidateAnniv).day ?? 0)
            let passedAnnivDays = max(0, totalAnnivSpan - remAnnivDays)
            
            nextAnnivYear = yearCount
            daysUntilAnniv = remAnnivDays
            annivRatio = min(1.0, max(0.0, Double(passedAnnivDays) / Double(totalAnnivSpan)))
        }
        
        // 4. 年度指标
        let year = calendar.component(.year, from: currentDate)
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? startOfCurrent
        let endOfYear = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1)) ?? startOfCurrent
        let yearTotalDays = max(1, calendar.dateComponents([.day], from: startOfYear, to: endOfYear).day ?? 365)
        let yearPassedDays = max(0, calendar.dateComponents([.day], from: startOfYear, to: startOfCurrent).day ?? 0)
        let yearRemainingDays = max(0, yearTotalDays - yearPassedDays)
        let yearProgressRatio = min(1.0, max(0.0, Double(yearPassedDays) / Double(yearTotalDays)))
        
        // 5. 月度指标
        let month = calendar.component(.month, from: currentDate)
        let rangeOfDaysInMonth = calendar.range(of: .day, in: .month, for: currentDate)
        let monthTotalDays = rangeOfDaysInMonth?.count ?? 30
        let dayOfMonth = calendar.component(.day, from: currentDate)
        let monthPassedDays = dayOfMonth
        let monthRemainingDays = max(0, monthTotalDays - monthPassedDays)
        let monthProgressRatio = min(1.0, max(0.0, Double(monthPassedDays) / Double(monthTotalDays)))
        
        // 6. 今日指标
        let secondsPassedToday = currentDate.timeIntervalSince(startOfCurrent)
        let totalSecondsToday: Double = 86400
        let dayProgressRatio = min(1.0, max(0.0, secondsPassedToday / totalSecondsToday))
        let secondsRemainingToday = max(0.0, totalSecondsToday - secondsPassedToday)
        let dayRemainingHours = Int(secondsRemainingToday / 3600)
        let dayRemainingMinutes = Int((secondsRemainingToday.truncatingRemainder(dividingBy: 3600)) / 60)
        
        return LifeProgressSnapshot(
            birthDate: startOfBirth,
            targetDate: targetDate,
            currentDate: currentDate,
            targetAge: targetAge,
            totalLifeDays: totalDays,
            passedLifeDays: passedDays,
            remainingLifeDays: remainingDays,
            lifeProgressRatio: lifeProgressRatio,
            totalMonths: totalMonths,
            passedMonths: passedMonths,
            remainingMonths: remainingMonths,
            currentMonthIndex: currentMonthIndex,
            isTogetherEnabled: isTogetherEnabled,
            togetherDate: togetherDate,
            togetherDateFormatted: formattedTogether,
            partnerName: partnerName,
            togetherDays: calculatedTogetherDays,
            togetherRemainingDays: calculatedTogetherRemainingDays,
            nextAnniversaryYear: nextAnnivYear,
            daysUntilNextAnniversary: daysUntilAnniv,
            anniversaryProgressRatio: annivRatio,
            currentYear: year,
            yearTotalDays: yearTotalDays,
            yearPassedDays: yearPassedDays,
            yearRemainingDays: yearRemainingDays,
            yearProgressRatio: yearProgressRatio,
            currentMonth: month,
            monthTotalDays: monthTotalDays,
            monthPassedDays: monthPassedDays,
            monthRemainingDays: monthRemainingDays,
            monthProgressRatio: monthProgressRatio,
            dayRemainingHours: dayRemainingHours,
            dayRemainingMinutes: dayRemainingMinutes,
            dayProgressRatio: dayProgressRatio
        )
    }
}
