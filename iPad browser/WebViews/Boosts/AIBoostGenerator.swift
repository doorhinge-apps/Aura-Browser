//
//  AIBoostGenerator.swift
//  Aura
//
//  Created by Caedmon Myers on 9/7/24.
//

import SwiftUI
import OpenAI

struct AIBoostGenerator: View {
    @Binding var customInstructions: String
    @Binding var passedClasses: String
    @Binding var text: String
    @Binding var generate: Bool
    
    @State var openAI: OpenAI? = nil
    
    @AppStorage("openAPIKey") var openAPIKey = ""
    
    var body: some View {
        VStack {
            ScrollView {
                Text(text)
            }
        }.onChange(of: generate, {
            if generate {
                generationAction()
                print("Passed Classes: \(passedClasses)")
            }
        })
        .onAppear() {
            openAI = OpenAI(apiToken: openAPIKey)
        }
    }
    
    func generationAction() {
        text = ""
        
        let exampleStuff = passedClasses
        print("Example Stuff: \(exampleStuff)")
        
        generateCSS(inputMessages: exampleStuff, completion: {_ in
            generate = false
        })
    }
    
    func generateCSS(inputMessages: String, completion: @escaping (String) -> Void) {
        let systemInstructions = """
        You will be given several classes and elements from an HTML website. Each class will be given to you as the name of the class followed by the type of element separated by a dash, or in some cases, just the type of element. Your task is to use the provided class names and element types to write custom CSS code to override the default styles of the website and enhance its appearance. In some cases, a website might not use classes for certain elements. If this happens, you will be given just the element type (e.g., "div"). In these cases, apply styles directly to the overall element type instead of a class. Format your response as plain text CSS. Do not use Markdown. Only use the classes or element types given by the user. You must not create new classes.
        """
        
        let query = ChatQuery(model: .gpt3_5Turbo, messages: [
            .init(role: .system, content: systemInstructions),
            //.init(role: .user, content: "Generate CSS for these elements or classes. Only use these: \(inputMessages)")
            .init(role: .user, content: "Style the CSS like this: \(customInstructions). If there are no instructions provided, be creative in changing the CSS. These are your items to style: \(inputMessages)")
        ])
        
        print("Input Messages: ")
        print(inputMessages)
        
        // Call the chat API to get a response
        /*openAI.chats(query: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let chatResult):
                    if let assistantMessage = chatResult.choices.first?.message.content {
                        completion(assistantMessage)
                    } else {
                        completion("Untitled")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    completion("Untitled")
                }
            }
        }*/
        
        openAI?.chatsStream(query: query) { partialResult in
            
            switch partialResult {
            case .success(let result):
                print(result.choices)
                //text = result.choices.description
                text += result.choices.first?.delta.content ?? ""
                text = text.replacingOccurrences(of: "`css", with: "`").replacingOccurrences(of: "```", with: "")
            case .failure(let error):
                print("Failed to produce chunk: \(error)")
            }
        } completion: { error in
            print("Error streaming chat")
        }
    }
}


//#Preview {
//    AIBoostGenerator()
//}
