//
//  ProjectViewModel.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import Foundation
import Combine

class ProjectViewModel: ObservableObject {
    @Published var projectService: ProjectService
    @Published var taskService: TaskService
    
    init(projectService: ProjectService, taskService: TaskService) {
        self.projectService = projectService
        self.taskService = taskService
    }
    
    // MARK: - Project Management
    
    func createProject(name: String, description: String, startDate: Date, endDate: Date?, color: String) {
        let project = Project(
            name: name,
            description: description,
            startDate: startDate,
            endDate: endDate,
            color: color
        )
        projectService.addProject(project)
    }
    
    func updateProjectProgress(_ project: Project) {
        let tasks = taskService.tasks(for: project.id)
        guard !tasks.isEmpty else {
            var updatedProject = project
            updatedProject.progress = 0.0
            projectService.updateProject(updatedProject)
            return
        }
        
        let completedTasks = tasks.filter { $0.status == .completed }.count
        let progress = Double(completedTasks) / Double(tasks.count)
        
        var updatedProject = project
        updatedProject.progress = progress
        projectService.updateProject(updatedProject)
    }
    
    func addMilestone(to project: Project, title: String, dueDate: Date) {
        let milestone = ProjectMilestone(title: title, dueDate: dueDate)
        projectService.addMilestone(to: project.id, milestone: milestone)
    }
    
    func toggleMilestoneCompletion(_ project: Project, milestone: ProjectMilestone) {
        var updatedMilestone = milestone
        updatedMilestone.isCompleted.toggle()
        projectService.updateMilestone(in: project.id, milestone: updatedMilestone)
    }
    
    func deleteProject(_ project: Project) {
        // Also delete associated tasks
        let projectTasks = taskService.tasks(for: project.id)
        projectTasks.forEach { taskService.deleteTask($0) }
        projectService.deleteProject(project)
    }
    
    // MARK: - Timeline/Gantt Data
    
    func projectsForTimeline() -> [(project: Project, position: CGFloat, width: CGFloat)] {
        let sortedProjects = projectService.projects.sorted { $0.startDate < $1.startDate }
        guard !sortedProjects.isEmpty else { return [] }
        
        let earliestDate = sortedProjects.first?.startDate ?? Date()
        let latestDate = sortedProjects.compactMap { $0.endDate }.max() ?? Date()
        
        let totalDays = Calendar.current.dateComponents([.day], from: earliestDate, to: latestDate).day ?? 1
        
        return sortedProjects.compactMap { project in
            guard let endDate = project.endDate else { return nil }
            
            let startDays = Calendar.current.dateComponents([.day], from: earliestDate, to: project.startDate).day ?? 0
            let projectDays = Calendar.current.dateComponents([.day], from: project.startDate, to: endDate).day ?? 1
            
            let position = CGFloat(startDays) / CGFloat(max(totalDays, 1))
            let width = CGFloat(projectDays) / CGFloat(max(totalDays, 1))
            
            return (project: project, position: position, width: width)
        }
    }
    
    // MARK: - Analytics
    
    var totalProjects: Int {
        projectService.projects.count
    }
    
    var activeProjects: Int {
        projectService.activeProjects().count
    }
    
    var averageProgress: Double {
        projectService.averageProgress()
    }
    
    func tasksForProject(_ project: Project) -> [Task] {
        taskService.tasks(for: project.id)
    }
}

