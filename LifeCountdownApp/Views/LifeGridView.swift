import SwiftUI

/// 900格人生画布视图（支持动态寿命计算，以月份为单位）
/// 直观展示时光留下的痕迹与未来的无限可能
struct LifeGridView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var selectedMonthIndex: Int? = nil
    
    // 计算当前人生的进度快照
    private var snapshot: LifeProgressSnapshot {
        LifeCalculator.calculate(birthDate: settings.birthDate, targetAge: settings.targetAge)
    }
    
    // 固定的列数（每年12个月，每行展示12个月即1整年，或者24个月/30个月）
    // 采用每行12列布局，每一行恰好对应人生的一周岁，极其整齐清晰
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 12)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 顶部统计卡片
                    statsHeaderCard
                    
                    // 图例指示条
                    legendBar
                    
                    // 核心网格矩阵
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(0..<snapshot.totalMonths, id: \.self) { index in
                            monthCell(for: index)
                                .onTapGesture {
                                    selectedMonthIndex = index
                                }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    .padding(.horizontal)
                    
                    Text("💡 点击任意方格，查看对应的历法年月与人生阶段")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                }
                .padding(.top, 10)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("人生小格画布")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: Binding<IdentifiableInt?>(
                get: { selectedMonthIndex.map { IdentifiableInt(value: $0) } },
                set: { selectedMonthIndex = $0?.value }
            )) { item in
                MonthDetailSheet(
                    monthIndex: item.value,
                    birthDate: settings.birthDate,
                    currentPassedMonths: snapshot.passedMonths
                )
            }
        }
    }
    
    // MARK: - 顶部统计卡片
    private var statsHeaderCard: some View {
        HStack(spacing: 16) {
            statItem(title: "已度过", count: snapshot.passedMonths, unit: "月", color: .gray)
            Divider().frame(height: 36)
            statItem(title: "正在度过", count: 1, unit: "月", color: .orange)
            Divider().frame(height: 36)
            statItem(title: "余生尚存", count: snapshot.remainingMonths, unit: "月", color: .blue)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .padding(.horizontal)
    }
    
    private func statItem(title: String, count: Int, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(count)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                Text(unit)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 图例
    private var legendBar: some View {
        HStack(spacing: 16) {
            legendItem(color: Color.gray.opacity(0.4), text: "已成过往")
            legendItem(color: Color.orange, text: "此时此刻")
            legendItem(color: Color.primary.opacity(0.08), text: "未来时光")
        }
        .font(.system(size: 11))
        .foregroundColor(.secondary)
    }
    
    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 10, height: 10)
            Text(text)
        }
    }
    
    // MARK: - 单个月份格子
    @ViewBuilder
    private func monthCell(for index: Int) -> some View {
        let isPassed = index < snapshot.passedMonths
        let isCurrent = index == snapshot.passedMonths
        
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(cellColor(isPassed: isPassed, isCurrent: isCurrent))
                .aspectRatio(1.0, contentMode: .fit)
            
            if isCurrent {
                // 当前月份外发光脉动指示
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.orange.opacity(0.8), lineWidth: 1.5)
            }
        }
    }
    
    private func cellColor(isPassed: Bool, isCurrent: Bool) -> Color {
        if isCurrent {
            return Color.orange
        } else if isPassed {
            return Color.secondary.opacity(0.35)
        } else {
            return Color.primary.opacity(0.07)
        }
    }
}

// 辅助包装类，使 Int 遵循 Identifiable 便于弹窗绑定
struct IdentifiableInt: Identifiable {
    let id = UUID()
    let value: Int
}
