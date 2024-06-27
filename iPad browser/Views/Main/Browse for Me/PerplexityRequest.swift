//
//  PerplexityRequest.swift
//  Perplexity API
//
//  Created by Caedmon Myers on 20/6/24.
//

import SwiftUI

func getChatCompletion(prompt: String) async throws -> String {
    // Define the API endpoint and the model to use
    let url = URL(string: "https://api.perplexity.ai/chat/completions")!
    
    // Define the parameters for the request
    let parameters: [String: Any] = [
        "model": "llama-3-sonar-small-32k-online",
        "messages": [
            ["role": "system", "content": "Be precise. Answer in several paragraphs. Format your response using markdown. Include bullet points for key information."],
            ["role": "user", "content": prompt]
        ]
    ]
    
    // Serialize parameters to JSON data
    let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
    
    let apiKey = UserDefaults.standard.string(forKey: "apiKey")
    
    // Create the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 10
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.httpBody = postData
    
    // Perform the request
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // Check the HTTP response status code
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    // Decode the JSON response
    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
    
    // Extract the assistant's response from the JSON data
    if let dictionary = jsonResponse as? [String: Any],
       let choices = dictionary["choices"] as? [[String: Any]],
       let firstChoice = choices.first,
       let message = firstChoice["message"] as? [String: Any],
       let content = message["content"] as? String {
        return content
    } else {
        throw URLError(.cannotParseResponse)
    }
}
