//
//  IconsPicker.swift
//  iPad browser
//
//  Created by Caedmon Myers on 17/4/24.
//

import SwiftUI
import SwiftData


struct IconsPicker: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    @Binding var currentIcon: String
    
    @State var currentHoverIcon = ""
    
    @FocusState private var searchFocused: Bool
    
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var pinnedNavigationState: NavigationState
    @ObservedObject var favoritesNavigationState: NavigationState
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("prefferedColorScheme") var prefferedColorScheme = "automatic"
    
    @State var allIcons = false
    
    @State var iconSearch = ""
    
    @State var filterApplied: IconFilter = .all
    
    enum IconFilter {
        case all, outline, fill, circle, circleFill
    }
    
    @Binding var selectedSpaceIndex: Int
    var body: some View {
        ZStack {
            if prefferedColorScheme == "dark" || (prefferedColorScheme == "automatic" && colorScheme == .dark) {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
            }
            
            VStack {
                ZStack {
                    TextField("Search for an Icon", text: $iconSearch)
                        .padding(15)
                        .textFieldStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .focused($searchFocused)
                        .onAppear() {
                            searchFocused = true
                        }
                    /*.onChange(of: searchFocused, {
                     if !searchFocused {
                     searchFocused = true
                     }
                     })*/
#if !os(macOS)
                        .textInputAutocapitalization(.never)
                    #endif
                        .autocorrectionDisabled(true)
                }
                .frame(height: 50)
                .padding(10)
#if !os(macOS)
                LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .phone ? [GridItem(), GridItem()]: [GridItem(), GridItem(), GridItem()], alignment: .center) {
                    Button {
                        filterApplied = .all
                    } label: {
                        Text("All")
                            .frame(width: 100)
                    }.buttonStyle(NewButtonStyle(startHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].startHex: "ffffff", endHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].endHex: "000000"))
                        .padding(15)
                        .opacity(filterApplied == .all ? 1.0: 0.5)
                        .scaleEffect(filterApplied == .all ? 1.0: 0.75)
                        .animation(.default, value: filterApplied)
                    
                    Button {
                        filterApplied = .outline
                    } label: {
                        Text("Outline")
                            .frame(width: 100)
                    }.buttonStyle(NewButtonStyle(startHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].startHex: "ffffff", endHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].endHex: "000000"))
                        .padding(15)
                        .opacity(filterApplied == .outline ? 1.0: 0.5)
                        .scaleEffect(filterApplied == .outline ? 1.0: 0.75)
                        .animation(.default, value: filterApplied)
                    
                    Button {
                        filterApplied = .fill
                    } label: {
                        Text("Fill")
                            .frame(width: 100)
                    }.buttonStyle(NewButtonStyle(startHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].startHex: "ffffff", endHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].endHex: "000000"))
                        .padding(15)
                        .opacity(filterApplied == .fill ? 1.0: 0.5)
                        .scaleEffect(filterApplied == .fill ? 1.0: 0.75)
                        .animation(.default, value: filterApplied)
                    
                    Button {
                        filterApplied = .circle
                    } label: {
                        Text("Circle")
                            .frame(width: 100)
                    }.buttonStyle(NewButtonStyle(startHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].startHex: "ffffff", endHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].endHex: "000000"))
                        .padding(15)
                        .opacity(filterApplied == .circle ? 1.0: 0.5)
                        .scaleEffect(filterApplied == .circle ? 1.0: 0.75)
                        .animation(.default, value: filterApplied)
                    
                    Button {
                        filterApplied = .circleFill
                    } label: {
                        Text("Circle Fill")
                            .frame(width: 100)
                    }.buttonStyle(NewButtonStyle(startHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].startHex: "ffffff", endHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].endHex: "000000"))
                        .padding(15)
                        .opacity(filterApplied == .circleFill ? 1.0: 0.5)
                        .scaleEffect(filterApplied == .circleFill ? 1.0: 0.75)
                        .animation(.default, value: filterApplied)
                }
                #else
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], alignment: .center) {
                    Button {
                        filterApplied = .all
                    } label: {
                        Text("All")
                            .frame(width: 100)
                    }.buttonStyle(NewButtonStyle(startHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].startHex: "ffffff", endHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].endHex: "000000"))
                        .padding(15)
                        .opacity(filterApplied == .all ? 1.0: 0.5)
                        .scaleEffect(filterApplied == .all ? 1.0: 0.75)
                        .animation(.default, value: filterApplied)
                    
                    Button {
                        filterApplied = .outline
                    } label: {
                        Text("Outline")
                            .frame(width: 100)
                    }.buttonStyle(NewButtonStyle(startHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].startHex: "ffffff", endHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].endHex: "000000"))
                        .padding(15)
                        .opacity(filterApplied == .outline ? 1.0: 0.5)
                        .scaleEffect(filterApplied == .outline ? 1.0: 0.75)
                        .animation(.default, value: filterApplied)
                    
                    Button {
                        filterApplied = .fill
                    } label: {
                        Text("Fill")
                            .frame(width: 100)
                    }.buttonStyle(NewButtonStyle(startHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].startHex: "ffffff", endHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].endHex: "000000"))
                        .padding(15)
                        .opacity(filterApplied == .fill ? 1.0: 0.5)
                        .scaleEffect(filterApplied == .fill ? 1.0: 0.75)
                        .animation(.default, value: filterApplied)
                    
                    Button {
                        filterApplied = .circle
                    } label: {
                        Text("Circle")
                            .frame(width: 100)
                    }.buttonStyle(NewButtonStyle(startHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].startHex: "ffffff", endHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].endHex: "000000"))
                        .padding(15)
                        .opacity(filterApplied == .circle ? 1.0: 0.5)
                        .scaleEffect(filterApplied == .circle ? 1.0: 0.75)
                        .animation(.default, value: filterApplied)
                    
                    Button {
                        filterApplied = .circleFill
                    } label: {
                        Text("Circle Fill")
                            .frame(width: 100)
                    }.buttonStyle(NewButtonStyle(startHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].startHex: "ffffff", endHex: spaces.count > selectedSpaceIndex ? spaces[selectedSpaceIndex].endHex: "000000"))
                        .padding(15)
                        .opacity(filterApplied == .circleFill ? 1.0: 0.5)
                        .scaleEffect(filterApplied == .circleFill ? 1.0: 0.75)
                        .animation(.default, value: filterApplied)
                }
                #endif
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 8)) {
                            ForEach(sfNewIconOptions.filter { icon in
                                if filterApplied == .all {
                                    return true
                                } else {
                                    switch filterApplied {
                                    case .outline:
                                        return (!icon.contains("outline") && !icon.contains("fill") && !icon.contains("circle"))
                                    case .fill:
                                        return (icon.contains("fill")  && !icon.contains("circle"))
                                    case .circle:
                                        return (icon.contains("circle") && !icon.contains("fill"))
                                    case .circleFill:
                                        return icon.contains("circle.fill")
                                    default:
                                        return true
                                    }
                                }
                            }, id:\.self) { icon in
                                if icon.contains(iconSearch.lowercased()) || icon.replacingOccurrences(of: ".", with: " ").contains(iconSearch.lowercased()) || iconSearch == "" {
                                    Button {
                                        currentIcon = icon
                                        print("Icon: \(icon)")
                                        print("Current Icon: \(currentIcon)")
                                    } label: {
                                        ZStack {
#if !os(visionOS)
                                            Color(.white)
                                                .opacity(currentIcon == icon ? 1.0: currentHoverIcon == icon ? 0.5: 0.0)
                                            #else
                                            Color(.white)
                                                .opacity(currentIcon == icon ? 1.0: 0.0)
                                            #endif
                                            
                                            Image(systemName: icon)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .foregroundStyle(currentIcon == icon ? Color.black: Color.white)
                                                .opacity(currentHoverIcon == icon ? 1.0: 0.7)
                                            
                                        }.frame(width: 50, height: 50).cornerRadius(7)
#if !os(visionOS) && !os(macOS)
                                            .hoverEffect(.lift)
                                            .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                                        #endif
                                            .onHover(perform: { hovering in
                                                if hovering {
                                                    currentHoverIcon = icon
                                                }
                                                else {
                                                    currentHoverIcon = ""
                                                }
                                            })
                                    }
                                }
                            }
                        }
                }.scrollIndicators(.hidden)
                
            }
        }
    }
    
    func saveSpaceData() {
            let savingTodayTabs = navigationState.webViews.compactMap { $0.url?.absoluteString }
            let savingPinnedTabs = pinnedNavigationState.webViews.compactMap { $0.url?.absoluteString }
            let savingFavoriteTabs = favoritesNavigationState.webViews.compactMap { $0.url?.absoluteString }
            
            if !spaces.isEmpty {
                spaces[selectedSpaceIndex].tabUrls = savingTodayTabs
            }
            else {
                modelContext.insert(SpaceStorage(spaceIndex: spaces.count, spaceName: "Untitled", spaceIcon: "circle.fill", favoritesUrls: [], pinnedUrls: [], tabUrls: savingTodayTabs))
            }
            
            do {
                try modelContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
}

