//
//  PerplexityRequest.swift
//  Perplexity API
//
//  Created by Caedmon Myers on 20/6/24.
//

import SwiftUI

func getChatCompletion(prompt: String) async -> String {
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
    guard let postData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
        return "Error: Failed to serialize request parameters"
    }
    
    let apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
    
    // Create the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 10
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.httpBody = postData
    
    print("Perplexity API Key:")
    print("Bearer \(apiKey)")
    
    // Perform the request
    guard let (data, response) = try? await URLSession.shared.data(for: request) else {
        return "Error: Failed to perform the request"
    }
    
    // Check the HTTP response status code
    guard let httpResponse = response as? HTTPURLResponse else {
        return "Error: Invalid response from server"
    }
    
    if httpResponse.statusCode != 200 && httpResponse.statusCode != 401 {
        return "Error: Server responded with status code \(httpResponse.statusCode)"
    }
    
    if httpResponse.statusCode == 401 {
        return "Error: Unauthorized. Check your API key."
    }
    
    // Decode the JSON response
    guard let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
        return "Error: Failed to parse server response"
    }
    
    // Extract the assistant's response from the JSON data
    if let choices = jsonResponse["choices"] as? [[String: Any]],
       let firstChoice = choices.first,
       let message = firstChoice["message"] as? [String: Any],
       let content = message["content"] as? String {
        return content
    } else if let error = jsonResponse["error"] as? [String: Any],
              let message = error["message"] as? String {
        return "API Error: \(message)"
    } else {
        return "Error: Unexpected response format"
    }
}
