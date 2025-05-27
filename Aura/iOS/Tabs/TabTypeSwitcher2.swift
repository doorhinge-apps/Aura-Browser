//
// Aura
// TabTypeSwitcher2.swift
//
// Created on 26/5/25
//
// Copyright ©2025 DoorHinge Apps.
//


import SwiftUI

struct TabTypeSwitcher: View {
    @EnvironmentObject var mobileTabs: MobileTabsModel
    @State private var dragPercent: Double = 0
    
    @State var offsetIcons = false

    var body: some View {
        HStack {
            Spacer()

            VStack {
                Image(systemName: "star")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 20 +
                        (
                            dragPercent < 60 ? 0:
                            dragPercent < 80 ? ((dragPercent - 60) / 20) * 15:
                            15
                        ),
                        height: 20 +
                        (
                            dragPercent < 60 ? 0:
                            dragPercent < 80 ? ((dragPercent - 60) / 20) * 15:
                            15
                        )
                    )
                    .opacity(mobileTabs.selectedTabsSection == .favorites ? 1.0: 0.4)
                    .foregroundStyle(Color(hex: "4D4D4D"))
                    .onTapGesture {
                        withAnimation {
                            mobileTabs.selectedTabsSection = .favorites
                            dragPercent = 100
                        }
                    }
                    .frame(height: 30)
                    .padding(.vertical, 5)

                Image(systemName: "pin")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 20 +
                        (
                            dragPercent < 45 ? (dragPercent / 45) * 15:
                            dragPercent < 55 ? 15:
                            dragPercent < 70 ? (1 - ((dragPercent - 55) / 15)) * 15:
                            0
                        ),
                        height:  20 +
                        (
                            dragPercent < 45 ? (dragPercent / 45) * 15:
                            dragPercent < 55 ? 15:
                            dragPercent < 70 ? (1 - ((dragPercent - 55) / 15)) * 15:
                            0
                        )
                    )
                    .opacity(mobileTabs.selectedTabsSection == .pinned ? 1.0: 0.4)
                    .foregroundStyle(Color(hex: "4D4D4D"))
                    .onTapGesture {
                        withAnimation {
                            mobileTabs.selectedTabsSection = .pinned
                            dragPercent = 50
                        }
                    }
                    .frame(height: 30)
                    .padding(.vertical, 5)

                Image(systemName: "calendar.day.timeline.left")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 20 + (1 - ((min(max(dragPercent, 20), 40) - 20) / 20)) * 15,
                        height: 20 + (1 - ((min(max(dragPercent, 20), 40) - 20) / 20)) * 15
                    )
                    .opacity(mobileTabs.selectedTabsSection == .tabs ? 1.0: 0.4)
                    .foregroundStyle(Color(hex: "4D4D4D"))
                    .onTapGesture {
                        withAnimation {
                            mobileTabs.selectedTabsSection = .tabs
                            dragPercent = 0
                        }
                    }
                    .frame(height: 30)
                    .padding(.vertical, 5)
            }
            .frame(width: 50, height: 150)
            .background(
                RoundedRectangle(cornerRadius: 50)
                    .fill(.regularMaterial)
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 0)
            )
            .contentShape(RoundedRectangle(cornerRadius: 50))
            .simultaneousGesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        let y = value.location.y
                        let percent = (1 - (y / 150)) * 100
                        dragPercent = max(0, min(100, percent))
                        print(dragPercent)
                        
                        withAnimation {
                            if dragPercent < 35 {
                                mobileTabs.selectedTabsSection = .tabs
                            }
                            else if dragPercent > 65 {
                                mobileTabs.selectedTabsSection = .favorites
                            }
                            else {
                                mobileTabs.selectedTabsSection = .pinned
                            }
                        }
                    }
                    .onEnded({ value in
                        withAnimation(.easeInOut(duration: 1)) {
                            offsetIcons = false
                        }
                        
                        withAnimation {
                            if dragPercent < 35 {
                                dragPercent = 0
                            }
                            else if dragPercent > 65 {
                                dragPercent = 100
                            }
                            else {
                                dragPercent = 50
                            }
                        }
                    })
            )
            .sensoryFeedback(.selection, trigger: mobileTabs.selectedTabsSection)
            .padding(.trailing, 5)
        }
        .padding(2)
    }
}
