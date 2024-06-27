//
//  TabOverview.swift
//  Aura
//
//  Created by Caedmon Myers on 25/6/24.
//

import SwiftUI
import WebKit
import SDWebImage
import SDWebImageSwiftUI

struct TabOverview: View {
    @Namespace var namespace
    @State private var offsets: [String: CGSize] = [:] // Track offsets for each item
    @State private var tilts: [String: Double] = [:]
    @State private var zIndexes: [String: Double] = [:]
    @State private var urls: [String] // Make urls a state variable so we can modify it

    init(urls: [String]) {
        self._urls = State(initialValue: urls) // Initialize the state variable
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    LazyVGrid(columns: [GridItem(spacing: 5), GridItem(spacing: 5)], content: {
                        ForEach(urls, id: \.self) { url in
                            let offset = offsets[url, default: .zero]
                            NavigationLink(destination: {
                                if #available(iOS 18.0, *) {
                                    WebsiteView(url: url, parentGeo: geo)
#if !os(macOS)
                                        .navigationTransition(.zoom(sourceID: url, in: namespace))
                                    #endif
                                }
                                else {
                                    WebsiteView(url: url, parentGeo: geo)
                                }
                            }, label: {
                                if #available(iOS 18.0, *) {
                                    WebPreview(url: url, geo: geo)
#if !os(macOS)
                                        .matchedTransitionSource(id: url, in: namespace)
                                    #endif
                                        .rotationEffect(Angle(degrees: tilts[url, default: 0.0]))
                                        .offset(x: offset.width)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { gesture in
                                                    offsets[url] = gesture.translation
                                                    zIndexes[url] = 100
                                                    var tilt = min(Double(abs(gesture.translation.width)) / 20, 15)
                                                    if gesture.translation.width < 0 {
                                                        tilt *= -1
                                                    }
                                                    tilts[url] = tilt
                                                }
                                                .onEnded { gesture in
                                                    zIndexes[url] = 1
                                                    if abs(gesture.translation.width) > 50 {
                                                        withAnimation {
                                                            if gesture.translation.width < 0 {
                                                                offsets[url] = CGSize(width: -500, height: 0)
                                                            } else {
                                                                offsets[url] = CGSize(width: 500, height: 0)
                                                            }
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                                withAnimation {
                                                                    removeItem(url)
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        withAnimation {
                                                            offsets[url] = .zero
                                                            tilts[url] = 0.0
                                                        }
                                                    }
                                                }
                                        )
                                } else {
                                    WebPreview(url: url, geo: geo)
                                        .rotationEffect(Angle(degrees: tilts[url, default: 0.0]))
                                        .offset(x: offset.width)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { gesture in
                                                    offsets[url] = gesture.translation
                                                    zIndexes[url] = 100
                                                    var tilt = min(Double(abs(gesture.translation.width)) / 20, 15)
                                                    if gesture.translation.width < 0 {
                                                        tilt *= -1
                                                    }
                                                    tilts[url] = tilt
                                                }
                                                .onEnded { gesture in
                                                    zIndexes[url] = 1
                                                    if abs(gesture.translation.width) > 100 {
                                                        withAnimation {
                                                            if gesture.translation.width < 0 {
                                                                offsets[url] = CGSize(width: -500, height: 0)
                                                            } else {
                                                                offsets[url] = CGSize(width: 500, height: 0)
                                                            }
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                                withAnimation {
                                                                    removeItem(url)
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        withAnimation {
                                                            offsets[url] = .zero
                                                            tilts[url] = 0.0
                                                        }
                                                    }
                                                }
                                        )
                                }
                            })
                        }
                    })
                    .padding(10)
                }
            }
        }
    }
    
    private func removeItem(_ url: String) {
        urls.removeAll { $0 == url }
        offsets.removeValue(forKey: url)
        tilts.removeValue(forKey: url)
    }
}



struct WebPreview: View {
    @State var url: String
    @State private var webTitle: String = ""
    
    @StateObject var settings = SettingsVariables()
    
    var geo: GeometryProxy
    
    @State var faviconSize = CGFloat(20)
    var body: some View {
        VStack {
#if !os(macOS)
            ZStack {
                WebViewMobile(urlString: url, title: $webTitle)
                    .frame(width: geo.size.width - 50, height: 400)
                    .scaleEffect(0.5)
                    .disabled(true)
                
                Color.white.opacity(0.0001)
                
            }.frame(width: geo.size.width / 2 - 25, height: 200)
                .clipped()
                .cornerRadius(15)
            
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
                        // Success
                        // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                    }
                    .indicator(.activity) // Activity Indicator
                    .transition(.fade(duration: 0.5)) // Fade Transition with duration
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
            #endif
        }
    }
}

#Preview {
    TabOverview(urls: ["https://apple.com", "https://google.com", "https://arc.net"])
}
