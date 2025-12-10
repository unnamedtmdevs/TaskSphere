//
//  TaskService.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import Foundation
import Combine

class TaskService: ObservableObject {
    @Published var tasks: [Task] = []
    
    private let tasksKey = "TaskSphere_Tasks"
    
    init() {
        loadTasks()
    }
    
    // MARK: - CRUD Operations
    
    func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: tasksKey),
              let decoded = try? JSONDecoder().decode([Task].self, from: data) else {
            tasks = []
            return
        }
        tasks = decoded
    }
    
    private func saveTasks() {
        guard let encoded = try? JSONEncoder().encode(tasks) else { return }
        UserDefaults.standard.set(encoded, forKey: tasksKey)
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }
    
    // MARK: - Query Operations
    
    func tasks(for projectId: UUID) -> [Task] {
        return tasks.filter { $0.projectId == projectId }
    }
    
    func tasks(assignedTo memberId: UUID) -> [Task] {
        return tasks.filter { $0.assignedTeamMemberIds.contains(memberId) }
    }
    
    func tasks(with status: TaskStatus) -> [Task] {
        return tasks.filter { $0.status == status }
    }
    
    func overdueTasks() -> [Task] {
        return tasks.filter { $0.isOverdue }
    }
    
    func upcomingTasks(days: Int = 7) -> [Task] {
        let endDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate >= Date() && dueDate <= endDate && task.status != .completed
        }
    }
    
    func sortedByUrgency() -> [Task] {
        return tasks.sorted { $0.urgencyScore > $1.urgencyScore }
    }
    
    // MARK: - Statistics
    
    func completionRate() -> Double {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter { $0.status == .completed }.count
        return Double(completed) / Double(tasks.count)
    }
    
    func tasksByPriority() -> [TaskPriority: Int] {
        var result: [TaskPriority: Int] = [:]
        for priority in TaskPriority.allCases {
            result[priority] = tasks.filter { $0.priority == priority }.count
        }
        return result
    }
    
    // MARK: - Reset
    
    func resetAllTasks() {
        tasks = []
        saveTasks()
    }
}

