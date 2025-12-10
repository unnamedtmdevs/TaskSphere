//
//  ColorExtensions.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import SwiftUI

extension Color {
    // MARK: - Theme Colors
    
    static let appBackground = Color(hex: "#1D1F30")
    static let appAccent = Color(hex: "#FE284A")
    static let appSecondary = Color(hex: "#2A2D42")
    static let appTertiary = Color(hex: "#3A3F5C")
    
    // MARK: - Priority Colors
    
    static let priorityLow = Color(hex: "#4ECDC4")
    static let priorityMedium = Color(hex: "#FFE66D")
    static let priorityHigh = Color(hex: "#FF6B6B")
    static let priorityUrgent = Color(hex: "#FE284A")
    
    // MARK: - Status Colors
    
    static let statusTodo = Color(hex: "#95A5A6")
    static let statusInProgress = Color(hex: "#3498DB")
    static let statusReview = Color(hex: "#F39C12")
    static let statusCompleted = Color(hex: "#2ECC71")
    
    // MARK: - Wellness Colors
    
    static let wellnessExcellent = Color(hex: "#2ECC71")
    static let wellnessGood = Color(hex: "#3498DB")
    static let wellnessFair = Color(hex: "#F39C12")
    static let wellnessAttention = Color(hex: "#E74C3C")
    
    // MARK: - Hex Initializer
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - Priority Color Helper
    
    static func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .priorityLow
        case .medium: return .priorityMedium
        case .high: return .priorityHigh
        case .urgent: return .priorityUrgent
        }
    }
    
    // MARK: - Status Color Helper
    
    static func statusColor(for status: TaskStatus) -> Color {
        switch status {
        case .todo: return .statusTodo
        case .inProgress: return .statusInProgress
        case .review: return .statusReview
        case .completed: return .statusCompleted
        }
    }
    
    // MARK: - Wellness Color Helper
    
    static func wellnessColor(for score: Double) -> Color {
        if score >= 0.8 { return .wellnessExcellent }
        if score >= 0.6 { return .wellnessGood }
        if score >= 0.4 { return .wellnessFair }
        return .wellnessAttention
    }
}

// MARK: - Date Extensions

extension Date {
    var timeAgo: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year)y ago"
        }
        if let month = components.month, month > 0 {
            return "\(month)mo ago"
        }
        if let day = components.day, day > 0 {
            return "\(day)d ago"
        }
        if let hour = components.hour, hour > 0 {
            return "\(hour)h ago"
        }
        if let minute = components.minute, minute > 0 {
            return "\(minute)m ago"
        }
        return "Just now"
    }
    
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    var formattedWithTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

