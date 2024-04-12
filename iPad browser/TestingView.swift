//
//  TestingView.swift
//  iPad browser
//
//  Created by Caedmon Myers on 8/9/23.
//

import SwiftUI
import UIKit
import WebKit
import Combine
import Firebase
import FirebaseFirestore


struct Suggestion: Identifiable, Codable {
    var id: String    // This will hold the Firestore document ID
    var url: String
}

class SuggestionsViewModel: ObservableObject {
    @Published var suggestions = [Suggestion]()
    private var db = Firestore.firestore()
    
    func randomString(length: Int) -> String {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    

    func fetchData() {
        db.collection("Suggestions").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }

            self.suggestions = documents.map { (queryDocumentSnapshot) -> Suggestion in
                let data = queryDocumentSnapshot.data()
                let id = data["uid"] as? String ?? ""
                let url = data["url"] as? String ?? ""
                return Suggestion(id: id, url: url)
            }
        }
    }
    
    
    func addSuggestion(url: String) {
        // Create a new Suggestion
        
        //UIPasteboard.general.string = self.BLEinfo.sendRcvLog
        var newSuggestion = "\(defaults.string(forKey: "email") ?? "Email not found") - \(url))"
        
        var docID = "\(defaults.string(forKey: "email") ?? "Email not found") - \(url.replacingOccurrences(of: "/", with: "-+|slash|+-"))"
        
        // Add the new Suggestion to Firestore
        
        let ref = db.collection("Suggestions").document(docID)
        ref.setData(["uid": newSuggestion, "url": url]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

}


class NavigationState : NSObject, ObservableObject {
    @Published var currentURL : URL?
    @Published var webViews : [WKWebView] = []
    @Published var selectedWebView : WKWebView?
    @Published var selectedWebViewTitle: String = ""
    
    @discardableResult func createNewWebView(withRequest request: URLRequest, fromFirestore: Bool = false) -> WKWebView {
        let wv = WKWebView()
        wv.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        wv.navigationDelegate = self
        webViews.append(wv)
        selectedWebView = wv
        wv.load(request)
        
        // Only add the new WebView to Firestore if it's not being recreated from Firestore
        if !fromFirestore, let url = request.url {
            addTabToFirestore(url: url, title: wv.title ?? "Loading...")
        }

        return wv
    }

    
    private var db = Firestore.firestore()
    
    func randomString(length: Int) -> String {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

    func addTabToFirestore(url: URL, title: String) {
        
        // Check if the tab is already in Firestore
        let tabsRef = Firestore.firestore().collection("Tabs")
        tabsRef.whereField("url", isEqualTo: url.absoluteString).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if querySnapshot!.documents.isEmpty {
                    // The tab is not in Firestore, so add it
                    let documentID = "\(defaults.string(forKey: "email")) - \(self.randomString(length: 6))"
                    
                    let db = Firestore.firestore()
                    let ref = db.collection("TabsDontExist").document(documentID)
                    ref.setData([
                        "uid": documentID,
                        "title": title,
                        "url": url.absoluteString
                    ]) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    // Remove a tab from Firestore
    func removeTabFromFirestore(id: String) {
        db.collection("Tabs").document(id).delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    // Fetch all tabs from Firestore
    func fetchTabsFromFirestore() {
        db.collection("Tabs").getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
            } else {
                self.webViews.removeAll()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let urlString = data["url"] as? String, let url = URL(string: urlString) {
                        let request = URLRequest(url: url)
                        self.createNewWebView(withRequest: request, fromFirestore: true) // Marking the WebView as one being recreated from Firestore
                    }
                }
            }
        }
    }
}

extension NavigationState : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Get the URL of the link that was clicked
        if let url = webView.url {
            
            // Check if the URL has the `target` attribute set to `_blank`
            if url.absoluteString.contains("target=_blank") {
                // Open the link in a new tab
                createNewWebView(withRequest: URLRequest(url: url))
            }
        }
    }
}

struct TestingWebView : UIViewRepresentable {
    
    @ObservedObject var navigationState : NavigationState
    
    func makeUIView(context: Context) -> UIView  {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let webView = navigationState.selectedWebView else {
            return
        }
        webView.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        
        // Set the frame again to ensure the webView resizes correctly
        webView.frame = CGRect(origin: .zero, size: uiView.bounds.size)
        
        if webView != uiView.subviews.first {
            uiView.subviews.forEach { $0.removeFromSuperview() }
            uiView.addSubview(webView)
        }
    }
}


struct TestingView: View {
    @ObservedObject var navigationState = NavigationState()
    
    @ObservedObject var pinnedNavigationState = NavigationState()
    
    @StateObject private var searchSuggestions = SuggestionsViewModel()
    
    @State var hideSidebar = false
    
    @State var changeColorSheet = false
    
    @State private var startColor: Color = Color.purple
    @State private var endColor: Color = Color.pink
    
    @State var hoverSidebarButton = false
    @State var hoverPaintbrush = false
    @State var hoverReloadButton = false
    @State var hoverForwardButton = false
    @State var hoverBackwardButton = false
    @State var hoverNewTab = false
    
    @State var commandBarShown = false
    
    @State var searchInSidebar = ""
    
    
    @State var tabBarShown = false
    
    @State var newTabSearch = ""
    
    @State var hoverTab = WKWebView()
    @State var currentTabNum = 0
    
    
    @State var hoverCloseTab = WKWebView()
    
    
    @State var hoverSidebarSearchField = false
    
    enum FocusedField {
        case commandBar, tabBar, none
    }
    
    @State var reloadTitles = false
    
    @FocusState private var focusedField: FocusedField?
    
    @State var hoverTinySpace = false
    
    
    @State var screenWidth = UIScreen.main.bounds.width
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
//    @State var filteredWebsites: [Website] {
//        filterWebsites(input: searchInSidebar, websites: loadWebsites())
//    }
    
//    @State var webSuggestions: [WebsiteSuggestion] = loadWebsites()
    
    
    @State private var selectedIndex: Int? = 0
    
    //@State var offsets = [:] as? [WKWebView: CGSize]
    //@State var offsets = [:] as? [String: CGFloat]
    //@State var offsets: [String: CGFloat]? = [:]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                
                HStack(spacing: 0) {
                    VStack {
                        
                        Spacer()
                            .frame(width: 20, height: 20)
                        
                        if hideSidebar {
                            Button {
                                hoverTinySpace.toggle()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    hoverTinySpace = false
                                }
                            } label: {
                                VStack(spacing: 2) {
                                    Circle()
                                        .frame(width: 8, height: 8)
                                    
                                    Circle()
                                        .frame(width: 8, height: 8)
                                    
                                    Circle()
                                        .frame(width: 8, height: 8)
                                    
                                }.padding(.horizontal, 6.5).foregroundStyle(Color.white).hoverEffect(.highlight)
                            }.keyboardShortcut("e", modifiers: .command)
                        }
                        
                        
                        Spacer()
                            .frame(width: 20)
                    }
                    //MARK: - Sidebar Buttons
                    VStack {
                        HStack {
                            Button(action: {
                                Task {
                                    await hideSidebar.toggle()
                                }
                                
                                navigationState.selectedWebView?.reload()
                                navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                
                                navigationState.selectedWebView = navigationState.selectedWebView
                                //navigationState.currentURL = navigationState.currentURL
                                
                                if let unwrappedURL = navigationState.currentURL {
                                    searchInSidebar = unwrappedURL.absoluteString
                                }
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
                                    .hoverEffect(.lift)
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
                                    .hoverEffect(.lift)
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
                                //navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: "https://www.google.com")!))
                                tabBarShown.toggle()
                                commandBarShown = false
                            }, label: {
                                ZStack {
                                    Color(.white)
                                        .opacity(hoverNewTab ? 0.5: 0.0)
                                    
                                    Image(systemName: "plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color.white)
                                        .opacity(hoverNewTab ? 1.0: 0.5)
                                    
                                }.frame(width: 40, height: 40).cornerRadius(7)
                                    .hoverEffect(.lift)
                                    .onHover(perform: { hovering in
                                        if hovering {
                                            hoverNewTab = true
                                        }
                                        else {
                                            hoverNewTab = false
                                        }
                                    })
                            }).keyboardShortcut("t", modifiers: .command)
                            
                            
                            
                            
                            Button(action: {
                                navigationState.selectedWebView?.goBack()
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
                                    .hoverEffect(.lift)
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
                                navigationState.selectedWebView?.goForward()
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
                                    .hoverEffect(.lift)
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
                                navigationState.selectedWebView?.reload()
                                navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                
                                navigationState.selectedWebView = navigationState.selectedWebView
                                //navigationState.currentURL = navigationState.currentURL
                                
                                if let unwrappedURL = navigationState.currentURL {
                                    searchInSidebar = unwrappedURL.absoluteString
                                }
                            }, label: {
                                ZStack {
                                    Color(.white)
                                        .opacity(hoverReloadButton ? 0.5: 0.0)
                                    
                                    Image(systemName: "arrow.clockwise")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color.white)
                                        .opacity(hoverReloadButton ? 1.0: 0.5)
                                    
                                }.frame(width: 40, height: 40).cornerRadius(7)
                                    .hoverEffect(.lift)
                                    .onHover(perform: { hovering in
                                        if hovering {
                                            hoverReloadButton = true
                                        }
                                        else {
                                            hoverReloadButton = false
                                        }
                                    })
                            }).keyboardShortcut("r", modifiers: .command)
                        }
                        
                        
                        //Text(navigationState.currentURL?.absoluteString ?? "")
                        //    .lineLimit(1)
                        
                        //MARK: - Sidebar Searchbar
                        Button {
                            if ((navigationState.currentURL?.absoluteString.isEmpty) == nil) {
                                newTabSearch = ""
                                tabBarShown.toggle()
                                commandBarShown = false
                            }
                            else {
                                commandBarShown.toggle()
                                tabBarShown = false
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(Color(.white).opacity(hoverSidebarSearchField ? 0.3 : 0.15))
                                //.foregroundStyle(navigationState.currentURL?.absoluteString ?? "(none)" == tab.url ? Color(.white).opacity(0.4): hoverTab == tab ? Color(.white).opacity(0.2): Color.clear)
                                    .frame(height: 50)
                                
                                HStack {
                                    Text(navigationState.currentURL?.absoluteString ?? "")
                                        .padding(.leading, 5)
                                        .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                        .lineLimit(1)
                                        .onReceive(timer) { _ in
                                            if !commandBarShown {
                                                if let unwrappedURL = navigationState.selectedWebView?.url {
                                                    searchInSidebar = unwrappedURL.absoluteString
                                                }
                                            }
                                        }
                                    
                                    Spacer() // Pushes the delete button to the edge
                                }
                                
                                
                            }.onHover(perform: { hovering in
                                if hovering {
                                    hoverSidebarSearchField = true
                                }
                                else {
                                    hoverSidebarSearchField = false
                                }
                            })
                        }.keyboardShortcut("l", modifiers: .command)
                        
                        
                        /*
                         TextField("Search or Enter URL", text: $searchInSidebar)
                         .frame(height: 40)
                         .padding(5)
                         .disabled(true)
                         .overlay( /// apply a rounded border
                         RoundedRectangle(cornerRadius: 20)
                         .stroke(.white, lineWidth: 2)
                         )
                         //.onSubmit {
                         //    navigationState.currentURL = URL(string: searchInSidebar)
                         //}
                         .onTapGesture {
                         if searchInSidebar.isEmpty {
                         newTabSearch = ""
                         tabBarShown = true
                         commandBarShown = false
                         }
                         else {
                         tabBarShown = false
                         commandBarShown = true
                         }
                         
                         }*/
                        //MARK: - Tabs
                        //TabBar(navigationState: $navigationState)
                        //TabBar(navigationState: $navigationState, timer: $timer, reloadTitles: $reloadTitles, hoverTab: $hoverTab, searchInSidebar: $searchInSidebar)
                        ScrollView {
                            ForEach(navigationState.webViews, id: \.self) { tab in
                                ZStack {
                                    if reloadTitles {
                                        Color.white.opacity(0.0)
                                    }
                                    
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundStyle(Color(.white).opacity(tab == navigationState.selectedWebView ? 0.5 : hoverTab == tab ? 0.2: 0.0))
                                    //.foregroundStyle(navigationState.currentURL?.absoluteString ?? "(none)" == tab.url ? Color(.white).opacity(0.4): hoverTab == tab ? Color(.white).opacity(0.2): Color.clear)
                                        .frame(height: 50)
                                    
                                    
                                    HStack {
                                        Text(tab.title ?? "Tab not found.")
                                            .lineLimit(1)
                                            .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                            .padding(.leading, 5)
                                            .onReceive(timer) { _ in
                                                reloadTitles.toggle()
                                            }
                                        
                                        Spacer() // Pushes the delete button to the edge
                                        
                                        Button(action: {
                                            if let index = navigationState.webViews.firstIndex(of: tab) {
                                                removeTab(at: index)
                                            }
                                        }) {
                                            if hoverTab == tab || navigationState.selectedWebView == tab {
                                                ZStack {
                                                    Color(.white)
                                                        .opacity(hoverCloseTab == tab ? 0.3: 0.0)
                                                    
                                                    Image(systemName: "xmark")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 15, height: 15)
                                                        .foregroundStyle(Color.white)
                                                        .opacity(hoverCloseTab == tab ? 1.0: 0.8)
                                                    
                                                }.frame(width: 35, height: 35).cornerRadius(7).padding(.trailing, 10)
                                                    .hoverEffect(.lift)
                                                    .onHover(perform: { hovering in
                                                        if hovering {
                                                            hoverCloseTab = tab
                                                        }
                                                        else {
                                                            hoverCloseTab = WKWebView()
                                                        }
                                                    })
                                                
                                            }
                                        }.keyboardShortcut("w", modifiers: .option)
                                    }.contextMenu {
                                        Button {
                                            //
                                        } label: {
                                            Text("Close Tab")
                                        }

                                    }
                                    
                                    
                                }//.hoverEffect(.lift)
                                .onHover(perform: { hovering in
                                    if hovering {
                                        hoverTab = tab
                                    }
                                    else {
                                        hoverTab = WKWebView()
                                    }
                                })
                                .onTapGesture {
                                    navigationState.selectedWebView = tab
                                    navigationState.currentURL = tab.url
                                    
                                    if let unwrappedURL = tab.url {
                                        searchInSidebar = unwrappedURL.absoluteString
                                    }
                                }
                //                .offset(y: offsets[tab.url?.description] ?? 0)
                //                .gesture(
                //                    DragGesture()
                //                        .onChanged { gesture in
                //                            offsets[tab.url?.description] = gesture.translation.height
                //                        }
                //                        .onEnded { _ in
                //                            self.offsets[tab.url?.description] = 0
                //                        }
                //                )
                                
                            }
                        }
                    }.animation(.easeOut).frame(width: hideSidebar ? 0: 300).offset(x: hideSidebar ? -320: 0).padding(.trailing, hideSidebar ? 0: 10)
                    
                    
                    ZStack {
                        Color.white
                            .opacity(0.4)
                            .cornerRadius(10)
                        //MARK: - WebView
                        TestingWebView(navigationState: navigationState)
                        //.frame(width: hideSidebar ? geo.size.width - 40 : geo.size.width - 350)
                            .cornerRadius(10)
                            .onAppear() {
                                //navigationState.selectedWebView.frame = CGRect(origin: .zero, size: geo.size)
                            }
                        
                        //MARK: - Hidden Sidebar Actions
                        if hideSidebar && hoverTinySpace {
                            VStack {
                                HStack {
                                    VStack {
                                        Button(action: {
                                            Task {
                                                await hideSidebar.toggle()
                                            }
                                            
                                            navigationState.selectedWebView?.reload()
                                            navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                            
                                            navigationState.selectedWebView = navigationState.selectedWebView
                                            //navigationState.currentURL = navigationState.currentURL
                                            
                                            if let unwrappedURL = navigationState.currentURL {
                                                searchInSidebar = unwrappedURL.absoluteString
                                            }
                                            
                                            hoverTinySpace = false
                                        }, label: {
                                            ZStack {
                                                //Color(.white)
                                                //    .opacity(hoverSidebarButton ? 0.5: 0.0)
                                                
                                                LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                    .opacity(hoverSidebarButton ? 1.0: 0.8)
                                                
                                                Image(systemName: "sidebar.left")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundStyle(Color.white)
                                                    .opacity(hoverSidebarButton ? 1.0: 0.5)
                                                
                                            }.animation(.smooth).frame(width: 50, height: 50).cornerRadius(75).hoverEffect(.lift)
                                        })
                                        .onHover(perform: { hovering in
                                            if hovering {
                                                hoverSidebarButton = true
                                            }
                                            else {
                                                hoverSidebarButton = false
                                            }
                                        })
                                        
                                        
                                        Button(action: {
                                            navigationState.selectedWebView?.reload()
                                            navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                            
                                            navigationState.selectedWebView = navigationState.selectedWebView
                                            //navigationState.currentURL = navigationState.currentURL
                                            
                                            if let unwrappedURL = navigationState.currentURL {
                                                searchInSidebar = unwrappedURL.absoluteString
                                            }
                                            
                                            hoverTinySpace = false
                                        }, label: {
                                            ZStack {
                                                //Color(.white)
                                                //    .opacity(hoverSidebarButton ? 0.5: 0.0)
                                                
                                                LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                    .opacity(hoverReloadButton ? 1.0: 0.8)
                                                
                                                Image(systemName: "arrow.clockwise")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundStyle(Color.white)
                                                    .opacity(hoverReloadButton ? 1.0: 0.5)
                                                
                                            }.animation(.smooth).frame(width: 50, height: 50).cornerRadius(75).hoverEffect(.lift)
                                        })
                                        .onHover(perform: { hovering in
                                            if hovering {
                                                hoverReloadButton = true
                                            }
                                            else {
                                                hoverReloadButton = false
                                            }
                                        })
                                        
                                        
                                        
                                        Button(action: {
                                            navigationState.selectedWebView?.goBack()
                                            
                                            hoverTinySpace = false
                                        }, label: {
                                            ZStack {
                                                //Color(.white)
                                                //    .opacity(hoverSidebarButton ? 0.5: 0.0)
                                                
                                                LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                    .opacity(hoverBackwardButton ? 1.0: 0.8)
                                                
                                                Image(systemName: "arrow.left")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundStyle(Color.white)
                                                    .opacity(hoverBackwardButton ? 1.0: 0.5)
                                                
                                            }.animation(.smooth).frame(width: 50, height: 50).cornerRadius(75).hoverEffect(.lift)
                                        })
                                        .onHover(perform: { hovering in
                                            if hovering {
                                                hoverBackwardButton = true
                                            }
                                            else {
                                                hoverBackwardButton = false
                                            }
                                        })
                                        
                                        
                                        Button(action: {
                                            navigationState.selectedWebView?.goForward()
                                            
                                            hoverTinySpace = false
                                        }, label: {
                                            ZStack {
                                                //Color(.white)
                                                //    .opacity(hoverSidebarButton ? 0.5: 0.0)
                                                
                                                LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                    .opacity(hoverForwardButton ? 1.0: 0.8)
                                                
                                                Image(systemName: "arrow.right")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundStyle(Color.white)
                                                    .opacity(hoverForwardButton ? 1.0: 0.5)
                                                
                                            }.animation(.smooth).frame(width: 50, height: 50).cornerRadius(75).hoverEffect(.lift)
                                        })
                                        .onHover(perform: { hovering in
                                            if hovering {
                                                hoverForwardButton = true
                                            }
                                            else {
                                                hoverForwardButton = false
                                            }
                                        })
                                        
                                        
                                        
                                        Button(action: {
                                            tabBarShown = true
                                            
                                            hoverTinySpace = false
                                        }, label: {
                                            ZStack {
                                                //Color(.white)
                                                //    .opacity(hoverSidebarButton ? 0.5: 0.0)
                                                
                                                LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                    .opacity(hoverNewTab ? 1.0: 0.8)
                                                
                                                Image(systemName: "plus")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundStyle(Color.white)
                                                    .opacity(hoverNewTab ? 1.0: 0.5)
                                                
                                            }.animation(.smooth).frame(width: 50, height: 50).cornerRadius(75).hoverEffect(.lift)
                                        })
                                        .onHover(perform: { hovering in
                                            if hovering {
                                                hoverNewTab = true
                                            }
                                            else {
                                                hoverNewTab = false
                                            }
                                        })
                                        
                                    }
                                    
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                            }
                        }
                        
                        //MARK: - Tabbar
                        if tabBarShown {
                            ZStack {
                                Color.white
                                
                                VStack {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundStyle(Color.black.opacity(0.3))
                                            //.foregroundStyle(LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing))
                                        
                                        TextField(text: $newTabSearch) {
                                            HStack {
                                                Text("Search or Enter URL...")
                                                    .foregroundStyle(Color.black.opacity(0.3))
                                                    //.foregroundStyle(LinearGradient(colors: [startColor, endColor], startPoint: .leading, endPoint: .trailing))
                                            }
                                        }
                                        .textInputAutocapitalization(.never)
                                    }
                                    
                                    SuggestionsView(newTabSearch: $newTabSearch, suggestionUrls: suggestionUrls)
                                }.padding(15)
                            }.frame(width: 550, height: 300).cornerRadius(10).shadow(color: Color(hex: "0000").opacity(0.5), radius: 20, x: 0, y: 0)
                        }
                        
                        //MARK: - Command Bar
                        else if commandBarShown {
                            ZStack {
                                Color.white
                                
                                VStack {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundStyle(LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing))
                                        
                                        TextField("⌘+L - Search or Enter URL...", text: $searchInSidebar)
                                            .textInputAutocapitalization(.never)
                                            .foregroundStyle(LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing))
                                            .autocorrectionDisabled(true)
                                            .focused($focusedField, equals: .commandBar)
                                            .onAppear() {
                                                focusedField = .commandBar
                                            }
                                            .onDisappear() {
                                                focusedField = .none
                                            }
                                            .onSubmit {
                                                searchSuggestions.addSuggestion(url: newTabSearch)
                                                //navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: searchInSidebar))!))
                                                navigationState.currentURL = URL(string: formatURL(from: searchInSidebar))
                                                
                                                navigationState.selectedWebView?.load(URLRequest(url: URL(string: searchInSidebar)!))
                                                
                                                //navigationState.selectedWebView?.reload()
                                                
                                                commandBarShown = false
                                            }
                                    }
                                    .padding(20)
                                    
                                    ScrollView {
                                        let filteredSuggestions = searchSuggestions.suggestions.filter { suggestion in
                                            suggestion.id.starts(with: defaults.string(forKey: "email") ?? "Email not found") &&
                                            suggestion.url.starts(with: searchInSidebar)
                                        }
                                        
                                        ForEach(Array(filteredSuggestions.enumerated()), id: \.element.id) { index, suggestion in
                                            if suggestion.url != "" {
                                                Button {
                                                    searchInSidebar = suggestion.url
                                                    
                                                    navigationState.currentURL = URL(string: formatURL(from: searchInSidebar))
                                                    
                                                    navigationState.selectedWebView?.load(URLRequest(url: URL(string: searchInSidebar)!))
                                                    
                                                    commandBarShown = false
                                                } label: {
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .foregroundStyle(startColor)
                                                            .frame(height: 50)
                                                        
                                                        HStack {
                                                            Text(suggestion.url)
                                                                .foregroundStyle(Color.foregroundColor(forHex: defaults.string(forKey: "startColorHex") ?? "ffffff"))
                                                            
                                                            Spacer()
                                                                .frame(width: 30, height: 10)
                                                            
                                                            Image(systemName: "arrow.right")
                                                                .foregroundStyle(Color.foregroundColor(forHex: defaults.string(forKey: "startColorHex") ?? "ffffff"))
                                                                .hoverEffect(.highlight)
                                                        }.padding(.horizontal, 15)
                                                        
                                                    }.padding(.horizontal, 20).hoverEffect(.lift)
                                                }
                                            }
                                        }
                                        
                                        
                                    }
                                    
                                }
                            }.frame(width: 550, height: 300).cornerRadius(10).shadow(color: Color(hex: "0000").opacity(0.5), radius: 20, x: 0, y: 0)
                        }
                        
                        
                        Spacer()
                            .frame(width: 20)
                    }
                    
                    
                }.onAppear {
                    if let savedStartColor = getColor(forKey: "startColorHex") {
                        startColor = savedStartColor
                    }
                    if let savedEndColor = getColor(forKey: "endColorHex") {
                        endColor = savedEndColor
                    }
                    
                    searchSuggestions.fetchData()
                }
            }/*.onAppear() {
              if let savedTabs = UserDefaults.standard.data(forKey: "userTabs"),
              let decodedTabs = try? JSONDecoder().decode([Tab].self, from: savedTabs) {
              navigationState.webViews = decodedTabs
              }
              }*/
            .onAppear {
                if let urlsData = UserDefaults.standard.data(forKey: "userTabs"),
                   let urlStringArray = try? JSONDecoder().decode([String].self, from: urlsData) {
                    let urls = urlStringArray.compactMap { URL(string: $0) }
                    for url in urls {
                        let request = URLRequest(url: url)
                        
                        navigationState.createNewWebView(withRequest: request)
                        
                    }
                }
                
                if let urlsData = UserDefaults.standard.data(forKey: "pinnedTabs"),
                   let urlStringArray = try? JSONDecoder().decode([String].self, from: urlsData) {
                    let urls = urlStringArray.compactMap { URL(string: $0) }
                    for url in urls {
                        let request = URLRequest(url: url)
                        
                        pinnedNavigationState.createNewWebView(withRequest: request)
                        
                    }
                }
            }
            .onChange(of: navigationState.webViews) { newValue in
                saveToLocalStorage()
            }
            .onChange(of: pinnedNavigationState.webViews) { newValue in
                saveToLocalStorage()
            }
        }
    } // maybe in the wrong spot
    
    
    func saveToLocalStorage() {
        let urlStringArray = navigationState.webViews.compactMap { $0.url?.absoluteString }
            if let urlsData = try? JSONEncoder().encode(urlStringArray){
            UserDefaults.standard.set(urlsData, forKey: "userTabs")
                
        }
        
        let urlStringArray2 = pinnedNavigationState.webViews.compactMap { $0.url?.absoluteString }
            if let urlsData = try? JSONEncoder().encode(urlStringArray2){
            UserDefaults.standard.set(urlsData, forKey: "pinnedTabs")
                
        }
    }
    
    
    

    
    //MARK: - Functions
    func selectNext() {
        if let index = selectedIndex, index < searchSuggestions.suggestions.count - 2 {
            selectedIndex = index + 1
        }
    }

    func selectPrevious() {
        if let index = selectedIndex, index > 0 {
            selectedIndex = index - 1
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
    
    func removeTab(at index: Int) {
        // If the deleted tab is the currently selected one
        if navigationState.selectedWebView == navigationState.webViews[index] {
            if navigationState.webViews.count > 1 { // Check if there's more than one tab
                if index == 0 { // If the first tab is being deleted, select the next one
                    navigationState.selectedWebView = navigationState.webViews[1]
                } else { // Otherwise, select the previous one
                    navigationState.selectedWebView = navigationState.webViews[index - 1]
                }
            } else { // If it's the only tab, set the selectedWebView to nil
                navigationState.selectedWebView = nil
            }
        }
        
        navigationState.webViews.remove(at: index)
    }
    
    func formatURL(from input: String) -> String {
        // Check if it's already a URL with a scheme
        if let url = URL(string: input), url.scheme != nil {
            return url.absoluteString.hasPrefix("http") ? input : "https://\(input)"
        }
        
        // Check if it's a URL without a scheme
        if let url = URL(string: "https://\(input)"), url.host != nil {
            if url.absoluteString.contains(".") && !url.absoluteString.contains(" ") {
                return url.absoluteString
            }
        }
        
        // Assume it's a search term and format it for Google search
        let searchTerms = input.split(separator: " ").joined(separator: "+")
        return "https://www.google.com/search?q=\(searchTerms)"
    }
    
}

    
    




class CustomUITextField: UITextField {
    
    var onUpArrow: (() -> Void)?
    var onDownArrow: (() -> Void)?
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            guard let key = press.key else { continue }
            
            switch key.keyCode {
            case .keyboardUpArrow:
                onUpArrow?() // Trigger the action for up arrow key
                return
            case .keyboardDownArrow:
                onDownArrow?() // Trigger the action for down arrow key
                return
            default:
                break
            }
        }
        
        super.pressesBegan(presses, with: event)
    }
}

//struct CustomTextField: UIViewRepresentable {
//    @Binding var text: String
//    var onSubmitTab: (() -> Void)?
//
//    // Add closures for next and previous actions
//    var selectNext: (() -> Void)?
//    var selectPrevious: (() -> Void)?
//    
//    var placeholder: String?
//
//    func makeUIView(context: Context) -> CustomUITextField {
//        let textField = CustomUITextField()
//        
//        // Set up the closures for arrow key actions
//        textField.onUpArrow = {
//            context.coordinator.parent.selectPrevious?()
//        }
//        textField.onDownArrow = {
//            context.coordinator.parent.selectNext?()
//        }
//        
//        textField.autocapitalizationType = .none
//        
//        textField.placeholder = placeholder
//        
//        textField.delegate = context.coordinator
//        context.coordinator.onSubmit = onSubmitTab // Pass the action to the coordinator
//        return textField
//    }
//
//    func updateUIView(_ uiView: CustomUITextField, context: Context) {
//        uiView.text = text
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UITextFieldDelegate {
//        var parent: CustomTextField
//        var onSubmit: (() -> Void)?
//
//        init(_ parent: CustomTextField) {
//            self.parent = parent
//        }
//        
//        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//            if let currentValue = textField.text as NSString? {
//                parent.text = currentValue.replacingCharacters(in: range, with: string)
//            }
//            return true
//        }
//        
//        // Implement the textFieldShouldReturn method
//        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//            textField.resignFirstResponder()  // Resign first responder status
//            onSubmit?() // Call the action when the Return key is pressed
//            return true
//        }
//    }
//}




struct WebsiteSuggestion: Codable {
    var url: String
    var title: String
}


