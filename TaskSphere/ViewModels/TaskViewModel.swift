//
//  TaskViewModel.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import Foundation
import Combine

class TaskViewModel: ObservableObject {
    @Published var taskService: TaskService
    
    init(taskService: TaskService) {
        self.taskService = taskService
    }
    
    // MARK: - Task Management
    
    func createTask(title: String, description: String, priority: TaskPriority, dueDate: Date?, projectId: UUID?) {
        let task = Task(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate,
            projectId: projectId
        )
        taskService.addTask(task)
    }
    
    func updateTaskStatus(_ task: Task, status: TaskStatus) {
        var updatedTask = task
        updatedTask.status = status
        if status == .completed {
            updatedTask.completedDate = Date()
        }
        taskService.updateTask(updatedTask)
    }
    
    func assignTask(_ task: Task, to memberIds: [UUID]) {
        var updatedTask = task
        updatedTask.assignedTeamMemberIds = memberIds
        taskService.updateTask(updatedTask)
    }
    
    func deleteTask(_ task: Task) {
        taskService.deleteTask(task)
    }
    
    // MARK: - Filtering & Sorting
    
    func tasksByPriority() -> [TaskPriority: [Task]] {
        var result: [TaskPriority: [Task]] = [:]
        for priority in TaskPriority.allCases {
            result[priority] = taskService.tasks.filter { $0.priority == priority }
        }
        return result
    }
    
    func tasksByStatus() -> [TaskStatus: [Task]] {
        var result: [TaskStatus: [Task]] = [:]
        for status in TaskStatus.allCases {
            result[status] = taskService.tasks.filter { $0.status == status }
        }
        return result
    }
    
    func tasksForHeatmap() -> [(task: Task, urgency: Double)] {
        return taskService.tasks
            .filter { $0.status != .completed }
            .map { (task: $0, urgency: $0.urgencyScore) }
            .sorted { $0.urgency > $1.urgency }
    }
    
    // MARK: - Analytics
    
    var totalTasks: Int {
        taskService.tasks.count
    }
    
    var completedTasks: Int {
        taskService.tasks.filter { $0.status == .completed }.count
    }
    
    var overdueTasks: Int {
        taskService.overdueTasks().count
    }
    
    var todayTasks: [Task] {
        let calendar = Calendar.current
        return taskService.tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return calendar.isDateInToday(dueDate) && task.status != .completed
        }
    }
}

