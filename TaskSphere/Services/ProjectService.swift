//
//  ProjectService.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import Foundation
import Combine

class ProjectService: ObservableObject {
    @Published var projects: [Project] = []
    
    private let projectsKey = "TaskSphere_Projects"
    
    init() {
        loadProjects()
    }
    
    // MARK: - CRUD Operations
    
    func loadProjects() {
        guard let data = UserDefaults.standard.data(forKey: projectsKey),
              let decoded = try? JSONDecoder().decode([Project].self, from: data) else {
            projects = []
            return
        }
        projects = decoded
    }
    
    private func saveProjects() {
        guard let encoded = try? JSONEncoder().encode(projects) else { return }
        UserDefaults.standard.set(encoded, forKey: projectsKey)
    }
    
    func addProject(_ project: Project) {
        projects.append(project)
        saveProjects()
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
        }
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        saveProjects()
    }
    
    func deleteProjects(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
        saveProjects()
    }
    
    // MARK: - Query Operations
    
    func activeProjects() -> [Project] {
        return projects.filter { $0.status == .active }
    }
    
    func projects(for teamMemberId: UUID) -> [Project] {
        return projects.filter { $0.teamMemberIds.contains(teamMemberId) }
    }
    
    func overdueProjects() -> [Project] {
        return projects.filter { $0.isOverdue }
    }
    
    // MARK: - Milestone Operations
    
    func addMilestone(to projectId: UUID, milestone: ProjectMilestone) {
        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            projects[index].milestones.append(milestone)
            saveProjects()
        }
    }
    
    func updateMilestone(in projectId: UUID, milestone: ProjectMilestone) {
        if let projectIndex = projects.firstIndex(where: { $0.id == projectId }),
           let milestoneIndex = projects[projectIndex].milestones.firstIndex(where: { $0.id == milestone.id }) {
            projects[projectIndex].milestones[milestoneIndex] = milestone
            saveProjects()
        }
    }
    
    func deleteMilestone(from projectId: UUID, milestoneId: UUID) {
        if let projectIndex = projects.firstIndex(where: { $0.id == projectId }) {
            projects[projectIndex].milestones.removeAll { $0.id == milestoneId }
            saveProjects()
        }
    }
    
    // MARK: - Statistics
    
    func averageProgress() -> Double {
        guard !projects.isEmpty else { return 0 }
        let totalProgress = projects.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(projects.count)
    }
    
    func projectsByStatus() -> [ProjectStatus: Int] {
        var result: [ProjectStatus: Int] = [:]
        for status in ProjectStatus.allCases {
            result[status] = projects.filter { $0.status == status }.count
        }
        return result
    }
    
    // MARK: - Reset
    
    func resetAllProjects() {
        projects = []
        saveProjects()
    }
}

