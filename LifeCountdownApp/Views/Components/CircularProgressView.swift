import SwiftUI

/// 高品质环形进度条视图
struct CircularProgressView: View {
    let progress: Double // 0.0 ~ 1.0
    var lineWidth: CGFloat = 16
    var primaryColor: Color = Color.orange
    var secondaryColor: Color = Color.purple
    var title: String = "人生已度过"
    var subtitle: String? = nil
    
    var body: some View {
        ZStack {
            // 背景轨道
            Circle()
                .stroke(Color.primary.opacity(0.08), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            
            // 渐变进度环
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [primaryColor, secondaryColor, primaryColor]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // 环内文字数据
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text(String(format: "%.2f%%", progress * 100))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(lineWidth / 2)
    }
}
