//
//  Dashboard.swift
//  Aura
//
//  Created by Reyna Myers on 12/5/24.
//
import SwiftUI


struct Dashboard: View {
    @AppStorage("startColorHex") var startHex = "8A3CEF"
    @AppStorage("endColorHex") var endHex = "84F5FE"
    
    @State var startHexSpace: String
    @State var endHexSpace: String
    
    @AppStorage("launchDashboard") var launchDashboard = false
    
    @State var reloadWidgets = false
    @State var reloadOneWidget = DashboardWidget(title: "", xPosition: 0.0, yPosition: 0.0, width: 0.0, height: 0.0)
    @State var dashboardWidgets: [DashboardWidget] = loadDashboardWidgets()
    
    @State var draggingResize = false
    
    @State var editingWidgets = false
    
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("prefferedColorScheme") var prefferedColorScheme = "automatic"
    
    var body: some View {
        ZStack {
            //LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            ForEach(dashboardWidgets.indices, id: \.self) { index in
                let widget = dashboardWidgets[index] // Create a local mutable copy
                if !reloadWidgets {
                //if reloadOneWidget != widget {
                    ZStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.ultraThinMaterial)
                                .opacity(0.75)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                                .offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width / 2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height / 2))
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(colors: [Color(hex: startHexSpace), Color(hex: endHexSpace)], startPoint: .bottomLeading, endPoint: .topTrailing))
                                .opacity(0.5)
                                .offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width / 2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height / 2))
                            
                            if prefferedColorScheme == "dark" || (prefferedColorScheme == "automatic" && colorScheme == .dark) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black.opacity(0.5))
                                    .offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width / 2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height / 2))
                            }
                            
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.25))
                                .offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width / 2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height / 2))
                            
                            VStack {
                                if dashboardWidgets[index].title == "Weather" {
                                    WeatherWidgetView()
                                        .cornerRadius(10)
                                }
                                else if dashboardWidgets[index].title == "Tile Game" {
                                    TileGame(size: dashboardWidgets[index].height < 250 ? 34.5: 69)
                                        .cornerRadius(10)
                                }
                                else if dashboardWidgets[index].title == "Clock" {
                                    Clock()
                                        .cornerRadius(10)
                                }
                            }.offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width / 2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height / 2))
                        }
                        
                        if editingWidgets {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.0001))
                                    .contextMenu(menuItems: {
                                        Menu {
                                            Button(action: {
                                                updateWidgetSize(index: index, size: CGSize(width: 150, height: 150))
                                            }, label: {
                                                Text("Small")
                                            })
                                            
                                            Button(action: {
                                                updateWidgetSize(index: index, size: CGSize(width: 300, height: 150))
                                            }, label: {
                                                Text("Medium")
                                            })
                                            
                                            Button(action: {
                                                updateWidgetSize(index: index, size: CGSize(width: 300, height: 300))
                                            }, label: {
                                                Text("Large")
                                            })
                                            
                                            Button(action: {
                                                updateWidgetSize(index: index, size: CGSize(width: 550, height: 300))
                                            }, label: {
                                                Text("Extra Large")
                                            })
                                        } label: {
                                            Text("Size")
                                        }

                                        Button(role: .destructive, action: {
                                            dashboardWidgets.remove(at: index)
                                        }, label: {
                                            Label("Remove", systemImage: "trash")
                                                .tint(.red)
                                        })
                                    }, preview: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.ultraThinMaterial)
                                                .opacity(0.75)
                                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                                            
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(LinearGradient(colors: [Color(hex: startHexSpace), Color(hex: endHexSpace)], startPoint: .bottomLeading, endPoint: .topTrailing))
                                                .opacity(0.5)
                                            
                                            if prefferedColorScheme == "dark" || (prefferedColorScheme == "automatic" && colorScheme == .dark) {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.black.opacity(0.5))
                                            }
                                            
                                            
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.white.opacity(0.25))
                                            
                                            if dashboardWidgets[index].title == "Weather" {
                                                WeatherWidgetView()
                                                    .cornerRadius(10)
                                            }
                                            else if dashboardWidgets[index].title == "Tile Game" {
                                                TileGame(size: dashboardWidgets[index].height < 250 ? 34.5: 69)
                                                    .cornerRadius(10)
                                            }
                                            else if dashboardWidgets[index].title == "Clock" {
                                                Clock()
                                                    .cornerRadius(10)
                                            }
                                        }.frame(width: CGFloat(dashboardWidgets[index].width), height: CGFloat(dashboardWidgets[index].height))
                                    })
                            }
                            .offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width / 2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height / 2))
                        }
                        
                    }.frame(width: CGFloat(dashboardWidgets[index].width), height: CGFloat(dashboardWidgets[index].height))
                        .gesture(
                            DragGesture()
                            .onChanged { value in
                                if editingWidgets {
                                    var updatedWidget = widget // Make a mutable copy
                                    updatedWidget.xPosition = Double(value.location.x)
                                    updatedWidget.yPosition = Double(value.location.y)
                                    dashboardWidgets[index] = updatedWidget
                                    saveDashboardWidgets(widgets: dashboardWidgets)
                                }
                            }
                            .onEnded({ value in
                                if editingWidgets {
                                    reloadWidgets = true
                                    reloadOneWidget = widget
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
                                        reloadWidgets = false
                                        reloadOneWidget = DashboardWidget(title: "", xPosition: 0.0, yPosition: 0.0, width: 0.0, height: 0.0)
                                    }
                                }
                            })
                        )
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            editingWidgets.toggle()
                        }
                    }, label: {
                        ZStack {
                            Capsule()
                                .fill(.thinMaterial)
                                .environment(\.colorScheme, .dark)
                            
                            Text(editingWidgets ? "Done": "Edit")
                                .foregroundStyle(Color.white)
                        }
                        .frame(width: 75, height: 35)
                    })
                    
                    //Spacer()
                    
                    Menu {
                        Button(action: {
                            let newWidget = DashboardWidget(title: "Weather", xPosition: 0.0, yPosition: 0.0, width: 150.0, height: 150.0)
                            dashboardWidgets.append(newWidget)
                            saveDashboardWidgets(widgets: dashboardWidgets)
                        }, label: {
                            Text("Weather")
                        })
                        
                        Button(action: {
                            let newWidget = DashboardWidget(title: "Tile Game", xPosition: 0.0, yPosition: 0.0, width: 150.0, height: 150.0)
                            dashboardWidgets.append(newWidget)
                            saveDashboardWidgets(widgets: dashboardWidgets)
                        }, label: {
                            Text("Tile Game")
                        })
                        
                        Button(action: {
                            let newWidget = DashboardWidget(title: "Clock", xPosition: 0.0, yPosition: 0.0, width: 150.0, height: 150.0)
                            dashboardWidgets.append(newWidget)
                            saveDashboardWidgets(widgets: dashboardWidgets)
                        }, label: {
                            Text("Clock")
                        })
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.thinMaterial)
                                .environment(\.colorScheme, .dark)
                            
                            Image(systemName: "plus")
                                .foregroundStyle(Color.white)
                        }
                        .frame(height: 35)
                    }
                }.padding(5)
                Spacer()
            }
        }.onChange(of: editingWidgets, perform: { value in
            reloadWidgets = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
                reloadWidgets = false
            }
        })
    }
    
    func updateWidgetSize(index: Int, size: CGSize) {
        dashboardWidgets[index].width = Double(size.width)
        dashboardWidgets[index].height = Double(size.height)
        saveDashboardWidgets(widgets: dashboardWidgets)
        reloadWidgets = true
        reloadOneWidget = dashboardWidgets[index]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            reloadWidgets = false
            reloadOneWidget = DashboardWidget(title: "", xPosition: 0.0, yPosition: 0.0, width: 0.0, height: 0.0)
        }
    }
}

// Helper functions to handle UserDefaults
func loadDashboardWidgets() -> [DashboardWidget] {
    if let data = UserDefaults.standard.data(forKey: "dashboardWidgets") {
        let decoder = JSONDecoder()
        if let widgets = try? decoder.decode([DashboardWidget].self, from: data) {
            return widgets
        }
    }
    return []
}

func saveDashboardWidgets(widgets: [DashboardWidget]) {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(widgets) {
        UserDefaults.standard.set(data, forKey: "dashboardWidgets")
    }
}



