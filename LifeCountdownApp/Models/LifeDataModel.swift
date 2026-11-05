import Foundation

/// 人生时间与多维度时间流逝计算器
/// 负责准确推算一生、今年、本月、今日的时间维度指标
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
    /// 根据出生日期、目标预期年龄及指定基准时间（默认当前）计算全量快照
    static func calculate(birthDate: Date, targetAge: Int, asOf currentDate: Date = Date()) -> LifeProgressSnapshot {
        let calendar = Calendar.current
        
        // 计算目标终点日期（出生日期 + targetAge 年）
        let targetDate = calendar.date(byAdding: .year, value: targetAge, to: birthDate) ?? birthDate
        
        // 1. 一生总天数与剩余天数
        let totalDays = max(1, calendar.dateComponents([.day], from: birthDate, to: targetDate).day ?? (targetAge * 365))
        let passedDays = max(0, calendar.dateComponents([.day], from: birthDate, to: currentDate).day ?? 0)
        let remainingDays = max(0, totalDays - passedDays)
        let lifeProgressRatio = min(1.0, max(0.0, Double(passedDays) / Double(totalDays)))
        
        // 2. 一生总月份与当前月份
        let totalMonths = targetAge * 12
        let passedMonths = max(0, calendar.dateComponents([.month], from: birthDate, to: currentDate).month ?? 0)
        let remainingMonths = max(0, totalMonths - passedMonths)
        let currentMonthIndex = min(totalMonths - 1, passedMonths)
        
        // 3. 年度指标
        let year = calendar.component(.year, from: currentDate)
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? currentDate
        let endOfYear = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1)) ?? currentDate
        let yearTotalDays = max(1, calendar.dateComponents([.day], from: startOfYear, to: endOfYear).day ?? 365)
        let yearPassedDays = max(0, calendar.dateComponents([.day], from: startOfYear, to: currentDate).day ?? 0)
        let yearRemainingDays = max(0, yearTotalDays - yearPassedDays)
        let yearProgressRatio = min(1.0, max(0.0, Double(yearPassedDays) / Double(yearTotalDays)))
        
        // 4. 月度指标
        let month = calendar.component(.month, from: currentDate)
        let rangeOfDaysInMonth = calendar.range(of: .day, in: .month, for: currentDate)
        let monthTotalDays = rangeOfDaysInMonth?.count ?? 30
        let dayOfMonth = calendar.component(.day, from: currentDate)
        let monthPassedDays = dayOfMonth
        let monthRemainingDays = max(0, monthTotalDays - monthPassedDays)
        let monthProgressRatio = min(1.0, max(0.0, Double(monthPassedDays) / Double(monthTotalDays)))
        
        // 5. 今日指标
        let startOfDay = calendar.startOfDay(for: currentDate)
        let secondsPassedToday = currentDate.timeIntervalSince(startOfDay)
        let totalSecondsToday: Double = 86400
        let dayProgressRatio = min(1.0, max(0.0, secondsPassedToday / totalSecondsToday))
        let secondsRemainingToday = max(0.0, totalSecondsToday - secondsPassedToday)
        let dayRemainingHours = Int(secondsRemainingToday / 3600)
        let dayRemainingMinutes = Int((secondsRemainingToday.truncatingRemainder(dividingBy: 3600)) / 60)
        
        return LifeProgressSnapshot(
            birthDate: birthDate,
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
