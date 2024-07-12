//
//  History.swift
//  Aura
//
//  Created by Reyna Myers on 12/7/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct HistoryView: View {
    @ObservedObject var historyObservable = HistoryObservable()
    
    @AppStorage("faviconShape") var faviconShape = "circle"
    
    var body: some View {
            List {
                ForEach(historyObservable.items) { item in
                    HStack {
                        WebImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(item.websiteURL)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .cornerRadius(faviconShape == "square" ? 0: faviconShape == "squircle" ? 5: 100)
                                .padding(.trailing, 10)
                            
                        } placeholder: {
                            LoadingAnimations(size: 25, borderWidth: 5.0)
                                .padding(.leading, 5)
                        }
                        .onSuccess { image, data, cacheType in
                            
                        }
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        
                        VStack(alignment: .leading) {
                            if let title = item.title {
                                Text(title)
                                    .font(.headline)
                            }
                            Text(item.websiteURL)
                                .font(.subheadline)
                        }
                        Spacer()
                        Text(item.date.formatted())
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: historyObservable.removeItem)
                
                Button(action: {
                    var historyItem = HistoryItem(title: randomString(length: 5), websiteURL: "https://apple.com", date: Date.now)
                    
                    historyObservable.addItem(historyItem)
                }, label: {
                    Text("Add demo item")
                        .foregroundStyle(Color.blue)
                })
            }
            .navigationTitle("History")
            .navigationBarItems(trailing: EditButton())
    }
}

#Preview {
    HistoryView()
}
