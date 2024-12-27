//
// Aura
// TabTypeSwitcher.swift
//
// Created by Reyna Myers on 4/11/24
//
// Copyright ©2024 DoorHinge Apps.
//


import SwiftUI

struct TabTypeSwitcher: View {
    @EnvironmentObject var mobileTabs: MobileTabsModel
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack {
                Button(action: {
                    withAnimation {
                        mobileTabs.selectedTabsSection = .favorites
                    }
                }, label: {
                    Image(systemName: "star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: mobileTabs.selectedTabsSection == .favorites ? 30: 20, height: mobileTabs.selectedTabsSection == .favorites ? 30: 20)
                        .opacity(mobileTabs.selectedTabsSection == .favorites ? 1.0: 0.4)
                        .foregroundStyle(Color(hex: "4D4D4D"))
                })
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { value in
                            let dragHeight = value.translation.height
                            if dragHeight > 120 {
                                mobileTabs.selectedTabsSection = .tabs
                            } else if dragHeight > 60 {
                                mobileTabs.selectedTabsSection = .pinned
                            }
                            else {
                                mobileTabs.selectedTabsSection = .favorites
                            }
                        }
                )
                .frame(height: 30)
                .padding(.vertical, 5)
                
                Button(action: {
                    withAnimation {
                        mobileTabs.selectedTabsSection = .pinned
                    }
                }, label: {
                    Image(systemName: "pin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: mobileTabs.selectedTabsSection == .pinned ? 30: 20, height: mobileTabs.selectedTabsSection == .pinned ? 30: 20)
                        .opacity(mobileTabs.selectedTabsSection == .pinned ? 1.0: 0.4)
                        .foregroundStyle(Color(hex: "4D4D4D"))
                })
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { value in
                            let dragHeight = value.translation.height
                            if dragHeight > 60 {
                                mobileTabs.selectedTabsSection = .tabs
                            } else if dragHeight < -60 {
                                mobileTabs.selectedTabsSection = .favorites
                            }
                            else {
                                mobileTabs.selectedTabsSection = .pinned
                            }
                        }
                )
                .frame(height: 30)
                .padding(.vertical, 5)
                
                Button(action: {
                    withAnimation {
                        mobileTabs.selectedTabsSection = .tabs
                    }
                }, label: {
                    Image(systemName: "calendar.day.timeline.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: mobileTabs.selectedTabsSection == .tabs ? 30: 20, height: mobileTabs.selectedTabsSection == .tabs ? 30: 20)
                        .opacity(mobileTabs.selectedTabsSection == .tabs ? 1.0: 0.4)
                        .foregroundStyle(Color(hex: "4D4D4D"))
                })
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { value in
                            let dragHeight = value.translation.height
                            if dragHeight < -120 {
                                mobileTabs.selectedTabsSection = .favorites
                            } else if dragHeight < -60 {
                                mobileTabs.selectedTabsSection = .pinned
                            }
                            else {
                                mobileTabs.selectedTabsSection = .tabs
                            }
                        }
                )
                .frame(height: 30)
                .padding(.vertical, 5)
            }
            .frame(width: 50, height: 150)
            .background(
                RoundedRectangle(cornerRadius: 50)
                    .fill(.regularMaterial)
            )
            .padding(.trailing, 5)
        }.padding(2)
    }
}


