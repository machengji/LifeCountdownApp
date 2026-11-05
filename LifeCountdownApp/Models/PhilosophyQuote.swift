import Foundation

/// 哲学箴言与生命随想数据结构
struct PhilosophyQuote: Identifiable, Codable {
    let id: UUID
    let content: String
    let author: String
    let source: String
    
    init(id: UUID = UUID(), content: String, author: String, source: String = "") {
        self.id = id
        self.content = content
        self.author = author
        self.source = source
    }
}

/// 哲学经典格言库
enum PhilosophyQuoteRepository {
    static let quotes: [PhilosophyQuote] = [
        PhilosophyQuote(
            content: "向死而生。只有当我们真正认识到生命的有限，才能唤醒对生命无限的热爱与珍重。",
            author: "马丁·海德格尔",
            source: "《存在与时间》"
        ),
        PhilosophyQuote(
            content: "你所度过的每一个今日，都是余生中最年轻的一天。",
            author: "梭罗",
            source: "《瓦尔登湖》"
        ),
        PhilosophyQuote(
            content: "不要为不可挽回的昨天叹息，也不要为尚未到来的明天焦虑，专注地活在此刻。",
            author: "马可·奥勒留",
            source: "《沉思录》"
        ),
        PhilosophyQuote(
            content: "生命并不是以你活了多久来衡量，而是以那些令你屏息凝神的瞬间来丈量。",
            author: "塞涅卡",
            source: "《论生命之短暂》"
        ),
        PhilosophyQuote(
            content: "世界上只有一种真正的英雄主义，那就是认清生活的真相后依然热爱生活。",
            author: "罗曼·罗兰",
            source: "《米开朗琪罗传》"
        ),
        PhilosophyQuote(
            content: "未曾哭过长夜的人，不足以语人生；未曾凝视终点的人，不足以明当下。",
            author: "歌德",
            source: "《浮士德》"
        ),
        PhilosophyQuote(
            content: "时间的沙漏永远在流淌，唯有用热爱雕刻的时光，才能对抗虚无。",
            author: "阿尔贝·加缪",
            source: "《局外人》"
        ),
        PhilosophyQuote(
            content: "我们无法延长生命的绝对长度，但可以无限拓展生命的密度与宽度。",
            author: "蒙田",
            source: "《随笔集》"
        )
    ]
    
    /// 根据当前日期稳定获取今日格言（每日固定，次日自动切换）
    static func todayQuote(for date: Date = Date()) -> PhilosophyQuote {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 0
        let index = dayOfYear % quotes.count
        return quotes[index]
    }
}
