//
//  Task.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import Foundation

enum TaskPriority: Int, Codable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    case urgent = 3
    
    var title: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
    
    var heatmapValue: Double {
        switch self {
        case .low: return 0.25
        case .medium: return 0.5
        case .high: return 0.75
        case .urgent: return 1.0
        }
    }
}

enum TaskStatus: String, Codable, CaseIterable {
    case todo = "To Do"
    case inProgress = "In Progress"
    case review = "Review"
    case completed = "Completed"
}

struct Task: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var priority: TaskPriority
    var status: TaskStatus
    var dueDate: Date?
    var projectId: UUID?
    var assignedTeamMemberIds: [UUID]
    var createdDate: Date
    var completedDate: Date?
    var tags: [String]
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        priority: TaskPriority = .medium,
        status: TaskStatus = .todo,
        dueDate: Date? = nil,
        projectId: UUID? = nil,
        assignedTeamMemberIds: [UUID] = [],
        createdDate: Date = Date(),
        completedDate: Date? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.dueDate = dueDate
        self.projectId = projectId
        self.assignedTeamMemberIds = assignedTeamMemberIds
        self.createdDate = createdDate
        self.completedDate = completedDate
        self.tags = tags
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && status != .completed
    }
    
    var urgencyScore: Double {
        var score = priority.heatmapValue
        
        if let dueDate = dueDate {
            let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
            if daysUntilDue < 0 {
                score += 0.5 // Overdue bonus
            } else if daysUntilDue <= 3 {
                score += 0.3 // Due soon bonus
            }
        }
        
        return min(score, 1.0)
    }
}

