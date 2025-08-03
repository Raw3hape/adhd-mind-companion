//
//  AIService.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import Foundation

struct AIAnalysisResult {
    let type: ContentType
    let title: String
    let content: String
    let priority: TaskPriority?
    let dueDate: Date?
    let category: String?
    let isImportant: Bool
    
    enum ContentType {
        case task
        case note
    }
}

class AIService: ObservableObject {
    static let shared = AIService()
    
    // Replace with your Vercel deployment URL
    private let baseURL = "https://adhd-mind-companion.vercel.app/api/analyze"
    
    private init() {
        // API key is now stored securely on Vercel
    }
    
    func analyzeText(_ text: String) async throws -> AIAnalysisResult {
        let requestBody: [String: Any] = ["text": text]
        
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw AIServiceError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw AIServiceError.apiError
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let success = json["success"] as? Bool,
              success == true,
              let responseData = json["data"] as? [String: Any] else {
            throw AIServiceError.parsingError
        }
        
        return try parseAIResponse(responseData)
    }
    
    private func parseAIResponse(_ json: [String: Any]) throws -> AIAnalysisResult {
        guard let typeString = json["type"] as? String else {
            throw AIServiceError.parsingError
        }
        
        let type: AIAnalysisResult.ContentType = typeString == "task" ? .task : .note
        
        var title = ""
        var content = ""
        var priority: TaskPriority? = nil
        var dueDate: Date? = nil
        var category: String? = nil
        var isImportant = false
        
        if type == .task, let taskData = json["task"] as? [String: Any] {
            title = taskData["title"] as? String ?? "New Task"
            content = taskData["notes"] as? String ?? ""
            category = taskData["group"] as? String
            
            if let priorityString = taskData["priority"] as? String {
                switch priorityString.lowercased() {
                case "low": priority = .low
                case "medium": priority = .medium
                case "high": priority = .high
                case "urgent": priority = .urgent
                default: priority = .medium
                }
            }
            
            if let dueDateString = taskData["dueDate"] as? String {
                let formatter = ISO8601DateFormatter()
                dueDate = formatter.date(from: dueDateString)
            }
            
            isImportant = priority == .high || priority == .urgent
            
        } else if type == .note, let noteData = json["note"] as? [String: Any] {
            title = noteData["title"] as? String ?? "New Note"
            content = noteData["content"] as? String ?? ""
            category = noteData["category"] as? String
            isImportant = category == "Ideas" || category == "Worries"
        }
        
        // Handle "both" type
        if typeString == "both" {
            if let taskData = json["task"] as? [String: Any] {
                title = taskData["title"] as? String ?? "New Item"
                content = taskData["notes"] as? String ?? ""
                category = taskData["group"] as? String
            }
        }
        
        return AIAnalysisResult(
            type: type,
            title: title,
            content: content,
            priority: priority,
            dueDate: dueDate,
            category: category,
            isImportant: isImportant
        )
    }
}

enum AIServiceError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case apiError
    case parsingError
    case noAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .encodingError:
            return "Failed to encode request"
        case .apiError:
            return "API request failed"
        case .parsingError:
            return "Failed to parse response"
        case .noAPIKey:
            return "No API key provided"
        }
    }
}