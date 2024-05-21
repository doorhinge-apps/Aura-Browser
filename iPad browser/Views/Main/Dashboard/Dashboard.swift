//
//  Dashboard.swift
//  Aura
//
//  Created by Caedmon Myers on 12/5/24.
//

import SwiftUI
import SwiftData

struct Dashboard: View {
    //@AppStorage("startColorHex") var startHex = "8A3CEF"
    //@AppStorage("endColorHex") var endHex = "84F5FE"
    @State var startHex = "8A3CEF"
    @State var endHex = "84F5FE"
    
    @State var reloadWidgets = false
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \DashboardWidget.id) var dashboardWidgets: [DashboardWidget]
    
    //@State var dashboardWidgets = [DashboardWidget(title: "Test", xPosition: 0.0, yPosition: 0.0, width: 100.0, height: 100.0)]
    
    @State var draggingResize = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            ForEach(dashboardWidgets.indices, id: \.self) { index in
                let widget = dashboardWidgets[index] // Create a local mutable copy
                if !reloadWidgets {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing))
                            .offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width/2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height/2))
                        
                        RoundedRectangle(cornerRadius: 10)
                            //.fill(.ultraThinMaterial)
                            .fill(Color.white.opacity(0.25))
                            .offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width/2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height/2))
                        
                        VStack {
                            Text(dashboardWidgets[index].title)
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.white)
                            
                            WeatherWidgetView()
                                .cornerRadius(10)
                                
                        }.offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width/2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height/2))
                        
                        
                        
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                //RoundedRectangle(cornerRadius: 10)
                                VStack(spacing: 2) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .frame(width: 20, height: 4)
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .frame(width: 10, height: 4)
                                    
                                }.rotationEffect(Angle(degrees: -45))
                                    .offset(x: -1, y: -6)
                                //.frame(width: 20, height: 20)
                                    .offset(x: widget.xPosition - CGFloat(dashboardWidgets[index].width/2), y: widget.yPosition - CGFloat(dashboardWidgets[index].height/2))
                                    .gesture(DragGesture()
                                        .onChanged { value in
                                            var updatedWidget = widget
                                            
                                            if !draggingResize {
                                                //updatedWidget.width = Double(value.translation.width)
                                                //updatedWidget.xPosition += value.translation.width - widget.width
                                                
                                                //updatedWidget.height = Double(value.translation.height)
                                                //updatedWidget.yPosition += value.translation.height - widget.height
                                                
                                            }
                                            else {
                                                updatedWidget.width = Double(value.translation.width) + Double(widget.width)
                                                updatedWidget.xPosition += value.translation.width/2
                                                
                                                updatedWidget.height = Double(value.translation.height) + Double(widget.height)
                                                updatedWidget.yPosition += value.translation.height/2
                                            }
                                            if updatedWidget.width > 100 {
                                                //dashboardWidgets[index].xPosition = abs(updatedWidget.xPosition)
                                                dashboardWidgets[index].width = abs(updatedWidget.width)
                                            }
                                            else {
                                                dashboardWidgets[index].width = 100.0
                                            }
                                            if updatedWidget.height > 100.0 {
                                                //dashboardWidgets[index].yPosition = abs(updatedWidget.yPosition)
                                                dashboardWidgets[index].height = abs(updatedWidget.height)
                                            }
                                            else {
                                                dashboardWidgets[index].height = 100.0
                                            }
                                            
                                            Task {
                                                do {
                                                    try await modelContext.save()
                                                }
                                                catch {
                                                    print(error.localizedDescription)
                                                }
                                            }
                                            draggingResize = true
                                        }
                                        .onEnded({ value in
                                            draggingResize = false
                                            reloadWidgets = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
                                                reloadWidgets = false
                                            }
                                        })
                                    )
                            }
                        }
                    }.frame(width: CGFloat(dashboardWidgets[index].width), height: CGFloat(dashboardWidgets[index].height))
                        .gesture(DragGesture()
                            .onChanged { value in
                                var updatedWidget = widget // Make a mutable copy
                                updatedWidget.xPosition = Double(value.location.x)
                                updatedWidget.yPosition = Double(value.location.y)
                                dashboardWidgets[index].xPosition = updatedWidget.xPosition
                                dashboardWidgets[index].yPosition = updatedWidget.yPosition
                                dashboardWidgets[index].height = updatedWidget.height
                                dashboardWidgets[index].width = updatedWidget.width
                                
                                Task {
                                    do {
                                        try await modelContext.save()
                                    }
                                    catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                            .onEnded({ value in
                                reloadWidgets = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
                                    reloadWidgets = false
                                }
                            })
                        )
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        modelContext.insert(DashboardWidget(title: "Test", xPosition: 0.0, yPosition: 0.0, width: 100.0, height: 100.0))
                        do {
                            try modelContext.save()
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
                Spacer()
            }
        }
    }
}


#Preview {
    Dashboard()
}
