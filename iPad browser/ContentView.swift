//
//  ContentView.swift
//  iPad browser
//
//  Created by Caedmon Myers on 8/9/23.
//

import SwiftUI

import WebKit




let defaults = UserDefaults.standard


struct Tab: Identifiable, Decodable, Encodable, Equatable {
    let id = UUID()
    var title: String
    var url: String
    var history: Array<String>
    var future: Array<String>
}

struct Website: Codable, Identifiable {
    var id: String { domain }
    let domain: String
    let siteName: String
}


//class EventsViewModel: ObservableObject {
//    @Published var tabs: [Tab] = []
//    
//    private var db = Firestore.firestore()
//    
//    func fetchData() {
//        db.collection("Tabs")
//        //.order(by: "date", descending: false)
//            .addSnapshotListener { (querySnapshot, error) in
//                guard let documents = querySnapshot?.documents else {
//                    print("No documents")
//                    return
//                }
//                
//                self.tabs = documents.map { queryDocumentSnapshot -> Tab in
//                    let data = queryDocumentSnapshot.data()
//                    let id = data["uid"] as? String ?? ""
//                    let title = data["title"] as? String ?? ""
//                    let url = data["url"] as? String ?? ""
//                    let history = data["history"] as? Array<String> ?? [""]
//                    let future = data["future"] as? Array<String> ?? [""]
//                    
//                    return Tab(id: id, title: title, url: url, history: history, future: future)
//                }
//            }
//    }
//}



struct ContentView: View {
    
    //@State var userTabs = [Tab(id: "caedmonmyers@icloud.com - https://apple.com", title: "Apple", url: "https://apple.com", history: ["https://google.com", "https://icloud.com", "https://iphone.com"], future: []), Tab(id: "caedmonmyers@icloud.com - https://gmail.com", title: "Gmail", url: "https://gmail.com", history: ["https://google.com", "https://icloud.com", "https://iphone.com"], future: [])]
    
    @State var userTabs = [Tab(title: "", url: "", history: [], future: [])]
    
    @State var currentUrl = ""
    @State private var currentUrlBinding: URL? = URL(string: "")
    @State var currentTabNum = 0
    
    @State var splitEnabled = false
    @State private var splitUrl: String? = ""
    @State private var splitUrlBinding: URL? = URL(string: "")
    
    @State var hideSidebar = false
    
    @State var hoverTab = UUID()
    
    @State private var startColor: Color = Color.purple
    @State private var endColor: Color = Color.pink
    
    @State var changeColorSheet = false
    
    @State var hoverSidebarButton = false
    @State var hoverPaintbrush = false
    @State var hoverReloadButton = false
    @State var hoverForwardButton = false
    @State var hoverBackwardButton = false
    
    @State var reloadView = false
    
    @State var currentTabId = UUID()
    
    var body: some View {
        ZStack {
            //Color(.purple).ignoresSafeArea()
            
            LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            HStack(spacing: 0) {
                // Tab bar
                VStack {
                    HStack {
                        Button(action: {
                            hideSidebar.toggle()
                        }, label: {
                            ZStack {
                                Color(.white)
                                    .opacity(hoverSidebarButton ? 0.5: 0.0)
                                
                                Image(systemName: "sidebar.left")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(Color.white)
                                    .opacity(hoverSidebarButton ? 1.0: 0.5)
                                    
                            }.frame(width: 40, height: 40).cornerRadius(7)
                            .onHover(perform: { hovering in
                                if hovering {
                                    hoverSidebarButton = true
                                }
                                else {
                                    hoverSidebarButton = false
                                }
                            })
                        }).keyboardShortcut("s", modifiers: .command)
                        
                        
                        Button(action: {
                            changeColorSheet = true
                        }, label: {
                            ZStack {
                                Color(.white)
                                    .opacity(hoverPaintbrush ? 0.5: 0.0)
                                
                                Image(systemName: hoverPaintbrush ? "paintbrush.pointed.fill": "paintbrush.pointed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(Color.white)
                                    .opacity(hoverPaintbrush ? 1.0: 0.5)
                                    
                            }.frame(width: 40, height: 40).cornerRadius(7)
                                .onHover(perform: { hovering in
                                if hovering {
                                    hoverPaintbrush = true
                                }
                                else {
                                    hoverPaintbrush = false
                                }
                            })
                        }).keyboardShortcut("e", modifiers: .command)
                            .sheet(isPresented: $changeColorSheet, content: {
                            VStack(spacing: 20) {
                                LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .bottomLeading, endPoint: .topTrailing)
                                    .frame(height: 200)
                                    .cornerRadius(10)
                                
                                VStack {
                                    ColorPicker("Start Color", selection: $startColor)
                                        .onChange(of: startColor) { newValue in
                                            saveColor(color: newValue, key: "startColorHex")
                                        }
                                    
                                    ColorPicker("End Color", selection: $endColor)
                                        .onChange(of: endColor) { newValue in
                                            saveColor(color: newValue, key: "endColorHex")
                                        }
                                }
                                .padding()
                                
                                Spacer()
                            }
                        })
                        
                        Button(action: {
                            // Back page
                        }, label: {
                            ZStack {
                                Color(.white)
                                    .opacity(hoverBackwardButton ? 0.5: 0.0)
                                
                                Image(systemName: "arrow.left")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color.white)
                                    .opacity(hoverBackwardButton ? 1.0: 0.5)
                                    
                            }.frame(width: 40, height: 40).cornerRadius(7)
                            .onHover(perform: { hovering in
                                if hovering {
                                    hoverBackwardButton = true
                                }
                                else {
                                    hoverBackwardButton = false
                                }
                            })
                        }).keyboardShortcut("[", modifiers: .command)
                        
                        Button(action: {
                            
                        }, label: {
                            ZStack {
                                Color(.white)
                                    .opacity(hoverForwardButton ? 0.5: 0.0)
                                
                                Image(systemName: "arrow.right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color.white)
                                    .opacity(hoverForwardButton ? 1.0: 0.5)
                                    
                            }.frame(width: 40, height: 40).cornerRadius(7)
                            .onHover(perform: { hovering in
                                if hovering {
                                    hoverForwardButton = true
                                }
                                else {
                                    hoverForwardButton = false
                                }
                            })
                        }).keyboardShortcut("]", modifiers: .command)
                        
                        
                        
                        Button(action: {
                            reloadView.toggle()
                        }, label: {
                            ZStack {
                                Color(.white)
                                    .opacity(hoverReloadButton ? 0.5: 0.0)
                                
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(Color.white)
                                    .opacity(hoverReloadButton ? 1.0: 0.5)
                                    
                            }.frame(width: 40, height: 40).cornerRadius(7)
                            .onHover(perform: { hovering in
                                if hovering {
                                    hoverReloadButton = true
                                }
                                else {
                                    hoverReloadButton = false
                                }
                            })
                        }).keyboardShortcut("]", modifiers: .command)
                    }
                    
                    /*TextField("Search or Enter URL", text: $currentUrl)
                        .onSubmit {
                            currentUrlBinding = URL(string: currentUrl)
                        }*/
                    
                    ScrollView {
                        ForEach(userTabs, id:\.id) { tab in
                            ZStack {
                                VStack {
                                    ForEach(userTabs, id: \.id) { tab in
                                        HiddenWebView(url: URL(string: tab.url) ?? URL(string: "https://example.com")!)
                                    }
                                }.opacity(0)
                                
                                
                                VStack {
                                    Button(action: {
                                        currentUrl = tab.url
                                        currentUrlBinding = URL(string: currentUrl)
                                        currentTabId = tab.id
                                    }, label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .foregroundStyle(currentTabId == tab.id ? Color(.white).opacity(0.4): hoverTab == tab.id ? Color(.white).opacity(0.2): Color.clear)
                                                .frame(height: 50)
                                            
                                            Text(tab.title)
                                                .foregroundColor(Color.foregroundColor(forHex: ""))
                                            
                                        }//.hoverEffect(.lift)
                                        .onHover(perform: { hovering in
                                            if hovering {
                                                hoverTab = tab.id
                                            }
                                            else {
                                                hoverTab = UUID()
                                            }
                                        })
                                    })
                                }
                            }
                        }
                    }
                }.animation(.easeOut).frame(width: hideSidebar ? 0: 300).offset(x: hideSidebar ? -320: 0).padding(.trailing, hideSidebar ? 0: 10)
                
                // Web view
                VStack {
                    ZStack {
                        ForEach(userTabs, id: \.id) { tab in
                            WebView(url: URL(string: tab.url) ?? URL(string: "https://example.com")!, reload: $reloadView)
                                .opacity(currentTabId == tab.id ? 1.0 : 0.0)
                        }
                    }
                }.cornerRadius(10).animation(.easeOut)
                
            }.padding(.horizontal, 10)
        }.onAppear {
            if let savedStartColor = getColor(forKey: "startColorHex") {
                startColor = savedStartColor
            }
            if let savedEndColor = getColor(forKey: "endColorHex") {
                endColor = savedEndColor
            }
        }
        .onAppear() {
            if let savedTabs = UserDefaults.standard.data(forKey: "userTabs"),
               let decodedTabs = try? JSONDecoder().decode([Tab].self, from: savedTabs) {
                userTabs = decodedTabs
            }
        }
        .onChange(of: userTabs) { newValue in
            saveToLocalStorage()
        }
    }
    
    func saveColor(color: Color, key: String) {
        let uiColor = UIColor(color)
        let hexString = uiColor.toHex()
        defaults.set(hexString, forKey: key)
    }
    
    func getColor(forKey key: String) -> Color? {
        guard let hexString = UserDefaults.standard.string(forKey: key) else {
            return nil
        }
        return Color(hex: hexString)
    }
    
    func saveToLocalStorage() {
        if let encoded = try? JSONEncoder().encode(userTabs) {
            UserDefaults.standard.set(encoded, forKey: "userTabs")
        }
    }
    
    func loadWebsites() -> [Website] {
        guard let url = Bundle.main.url(forResource: "TopDomains", withExtension: "json"), let data = try? Data(contentsOf: url) 
        else {
            return []
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Website].self, from: data)
        } catch {
            print("Error decoding json")
            return []
        }
    }
    
    func filterWebsites(input: String, websites: [Website]) -> [Website] {
        let normalizedInput = input
            .lowercased()
            .replacingOccurrences (of: "www.", with: "")
            .replacingOccurrences (of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "") // Normalize user input
        
        return websites.filter { website in
            website.domain.lowercased().contains(normalizedInput)
        }.prefix(10) // Take at most top 10 results
            .sorted {
                $0.siteName < $1.siteName // Optional: Sort alphabetically by siteName, if desired
            }
    }
}





struct WebView2: UIViewRepresentable {
    var url: URL
    var onURLChange: ((URL) -> Void)? = nil
    
    func makeUIView(context: Context) -> WKWebView  {
        let wkWebView = WKWebView()
        wkWebView.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        let request = URLRequest(url: url)
        wkWebView.load(request)
        return wkWebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Do not reload the URL in updateUIView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView2
        
        init(_ parent: WebView2) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                parent.onURLChange?(url)
            }
            decisionHandler(.allow)
        }
    }
}


struct WebView: UIViewRepresentable{

    var url: URL?     // optional, if absent, one of below search servers used
    @Binding var reload: Bool

    private let urls = [URL(string: "https://google.com/")!, URL(string: "https://bing.com")!]
    private let webview = WKWebView()

    fileprivate func loadRequest(in webView: WKWebView) {
        if let url = url {
            webView.load(URLRequest(url: url))
        } else {
            let index = Int(Date().timeIntervalSince1970) % 2
            webView.load(URLRequest(url: urls[index]))
        }
    }

    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        loadRequest(in: webview)
        webview.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        if reload {
            loadRequest(in: uiView)
            DispatchQueue.main.async {
                self.reload = false     // must be async
            }
        }
    }
}



class WebViewManager: ObservableObject {
    @Published var webViews: [WKWebView] = []
    var urls: [URL] = []

    init(urls: [URL]) {
        self.urls = urls
        for url in urls {
            let webView = WKWebView()
            let request = URLRequest(url: url)
            webView.load(request)
            webViews.append(webView)
        }
    }
}



struct HiddenWebView: UIViewRepresentable {
    var url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let wkWebView = WKWebView()
        let request = URLRequest(url: url)
        wkWebView.load(request)
        return wkWebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No need to update anything for hidden web views.
    }
}





extension UIColor {
    func toHex() -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}




