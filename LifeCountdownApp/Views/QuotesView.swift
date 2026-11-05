import SwiftUI

/// 哲学箴言与生命随想浏览页
struct QuotesView: View {
    let quotes = PhilosophyQuoteRepository.quotes
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(quotes) { item in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "quote.bubble.fill")
                                    .foregroundColor(.orange.opacity(0.8))
                                Text(item.author)
                                    .font(.system(size: 15, weight: .bold))
                                Spacer()
                                Text(item.source)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(item.content)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .lineSpacing(5)
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                                .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
                        )
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("生命箴言")
        }
    }
}
