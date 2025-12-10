//
//  Project.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import Foundation

enum ProjectStatus: String, Codable, CaseIterable {
    case planning = "Planning"
    case active = "Active"
    case onHold = "On Hold"
    case completed = "Completed"
    case archived = "Archived"
}

struct ProjectMilestone: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var dueDate: Date
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, dueDate: Date, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }
}

struct Project: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var status: ProjectStatus
    var startDate: Date
    var endDate: Date?
    var milestones: [ProjectMilestone]
    var teamMemberIds: [UUID]
    var color: String // Hex color for visual identification
    var progress: Double // 0.0 to 1.0
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        status: ProjectStatus = .planning,
        startDate: Date = Date(),
        endDate: Date? = nil,
        milestones: [ProjectMilestone] = [],
        teamMemberIds: [UUID] = [],
        color: String = "#FE284A",
        progress: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.status = status
        self.startDate = startDate
        self.endDate = endDate
        self.milestones = milestones
        self.teamMemberIds = teamMemberIds
        self.color = color
        self.progress = progress
    }
    
    var completionPercentage: Int {
        return Int(progress * 100)
    }
    
    var isOverdue: Bool {
        guard let endDate = endDate else { return false }
        return endDate < Date() && status != .completed
    }
    
    var duration: Int {
        guard let endDate = endDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}

