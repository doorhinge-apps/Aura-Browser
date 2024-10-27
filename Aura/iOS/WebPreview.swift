//
// Aura
// WebPreview.swift
//
// Created by Reyna Myers on 26/10/24
//
// Copyright ©2024 DoorHinge Apps.
//


import SwiftUI
import WebKit
import SDWebImage
import SDWebImageSwiftUI
import SwiftData

struct WebPreview: View {
    let namespace: Namespace.ID
    @State var url: String
    @State private var webTitle: String = ""
    @State var webURL = ""
    
    @StateObject var settings = SettingsVariables()
    //@StateObject private var webViewModel = WebViewModel()
    
    @StateObject private var webViewManager = WebViewManager()
    
    var geo: GeometryProxy
    
    @State var faviconSize = CGFloat(20)
    
    @State var tab: (id: UUID, url: String)
    
    @Binding var browseForMeTabs: [String]
    
    @State var colors1 = [
        Color(hex: "EA96FF"), .purple, .indigo,
        Color(hex: "FAE8FF"), Color(hex: "F1C0FD"), Color(hex: "A6A6D6"),
        .indigo, .purple, Color(hex: "EA96FF")
    ]
    
#if !os(macOS)
    @State var webViewBackgroundColor: UIColor? = UIColor.white
    #else
    @State var webViewBackgroundColor: NSColor? = NSColor.white
    #endif
    
    var body: some View {
        VStack {
#if !os(macOS)
            ZStack {
                Color.white.opacity(0.0001)
                
                if browseForMeTabs.contains(tab.id.description) {
                    ZStack {
                        if #available(iOS 18.0, visionOS 2.0, *) {
                            MeshGradient(width: 3, height: 3, points: [
                                .init(0, 0), .init(0.5, 0), .init(1, 0),
                                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                            ], colors: colors1)
                        }
                        else {
                            LinearGradient(colors: Array(colors1.prefix(4)), startPoint: .top, endPoint: .bottom)
                        }
                        
                        VStack {
                            Text("Browse for Me:")
                                .lineLimit(2)
                            
                            Text(unformatURL(url: url))
                                .lineLimit(1)
                        }
                        .scaleEffect(2.0)
                        .foregroundStyle(Color.white)
                            .font(.system(.body, design: .rounded, weight: .bold))
                    }.frame(width: geo.size.width - 50, height: 400)
                }
                else {
                    WebViewMobile(urlString: url, title: $webTitle, webViewBackgroundColor: $webViewBackgroundColor, currentURLString: $webURL, webViewManager: webViewManager)
                        .frame(width: geo.size.width - 50, height: 400)
                        .disabled(true)
                }
                
            }
            .scaleEffect(0.5)
            .frame(width: geo.size.width / 2 - 25, height: 200) // Small size for tappable area
            .clipped()
            .cornerRadius(15)
            
            if browseForMeTabs.contains(tab.id.description) {
                Text(unformatURL(url: url))
                    .foregroundStyle(Color.black)
                    .font(.system(.body, design: .rounded, weight: .regular))
                    .lineLimit(1)
            }
            else {
                HStack {
                    if settings.faviconLoadingStyle {
                        WebImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(url)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: faviconSize, height: faviconSize)
                                .cornerRadius(settings.faviconShape == "square" ? 0: settings.faviconShape == "squircle" ? 5: 100)
                                .padding(.leading, 5)
                            
                        } placeholder: {
                            LoadingAnimations(size: Int(faviconSize), borderWidth: 5.0)
                                .padding(.leading, 5)
                        }
                        .onSuccess { image, data, cacheType in
                            
                        }
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        
                    } else {
                        AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(url)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: faviconSize, height: faviconSize)
                                .cornerRadius(settings.faviconShape == "square" ? 0: settings.faviconShape == "squircle" ? 5: 100)
                                .padding(.leading, 5)
                            
                        } placeholder: {
                            LoadingAnimations(size: Int(faviconSize), borderWidth: 5.0)
                                .padding(.leading, 5)
                        }
                        
                    }
                    
                    Text(webTitle)
                        .foregroundStyle(Color.black)
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
#endif
        }.matchedGeometryEffect(id: tab.id, in: namespace)
    }
}
