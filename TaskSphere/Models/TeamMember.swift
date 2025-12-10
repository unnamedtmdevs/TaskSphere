//
//  TeamMember.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import Foundation

enum MemberRole: String, Codable, CaseIterable {
    case owner = "Owner"
    case admin = "Admin"
    case member = "Member"
    case viewer = "Viewer"
}

struct WellnessData: Codable, Equatable {
    var stepsToday: Int
    var sleepHoursLastNight: Double
    var lastUpdated: Date
    
    init(stepsToday: Int = 0, sleepHoursLastNight: Double = 0, lastUpdated: Date = Date()) {
        self.stepsToday = stepsToday
        self.sleepHoursLastNight = sleepHoursLastNight
        self.lastUpdated = lastUpdated
    }
    
    var wellnessScore: Double {
        let stepsScore = min(Double(stepsToday) / 10000.0, 1.0) * 0.5
        let sleepScore = min(sleepHoursLastNight / 8.0, 1.0) * 0.5
        return stepsScore + sleepScore
    }
    
    var wellnessStatus: String {
        let score = wellnessScore
        if score >= 0.8 { return "Excellent" }
        if score >= 0.6 { return "Good" }
        if score >= 0.4 { return "Fair" }
        return "Needs Attention"
    }
}

struct TeamMember: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var role: MemberRole
    var avatarColor: String // Hex color for avatar background
    var joinDate: Date
    var wellnessData: WellnessData?
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        role: MemberRole = .member,
        avatarColor: String = "#FE284A",
        joinDate: Date = Date(),
        wellnessData: WellnessData? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.avatarColor = avatarColor
        self.joinDate = joinDate
        self.wellnessData = wellnessData
        self.isActive = isActive
    }
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}

