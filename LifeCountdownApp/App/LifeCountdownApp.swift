import SwiftUI

@main
struct LifeCountdownApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainDashboardView()
                .tabItem {
                    Label("印迹", systemImage: "hourglass")
                }
                .tag(0)
            
            LifeGridView()
                .tabItem {
                    Label("九百格", systemImage: "square.grid.3x3.fill")
                }
                .tag(1)
            
            QuotesView()
                .tabItem {
                    Label("随想", systemImage: "quote.bubble")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
                .tag(3)
        }
        .tint(.orange)
    }
}
