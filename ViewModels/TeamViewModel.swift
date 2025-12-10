//
//  TeamViewModel.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import Foundation
import Combine

class TeamViewModel: ObservableObject {
    @Published var teamService: TeamService
    @Published var taskService: TaskService
    
    init(teamService: TeamService, taskService: TaskService) {
        self.teamService = teamService
        self.taskService = taskService
    }
    
    // MARK: - Team Member Management
    
    func createTeamMember(name: String, email: String, role: MemberRole, avatarColor: String) {
        let member = TeamMember(
            name: name,
            email: email,
            role: role,
            avatarColor: avatarColor
        )
        teamService.addTeamMember(member)
    }
    
    func updateMemberWellness(_ member: TeamMember, steps: Int, sleepHours: Double) {
        let wellnessData = WellnessData(
            stepsToday: steps,
            sleepHoursLastNight: sleepHours,
            lastUpdated: Date()
        )
        teamService.updateWellnessData(for: member.id, wellnessData: wellnessData)
    }
    
    func toggleMemberActive(_ member: TeamMember) {
        var updatedMember = member
        updatedMember.isActive.toggle()
        teamService.updateTeamMember(updatedMember)
    }
    
    func deleteMember(_ member: TeamMember) {
        teamService.deleteTeamMember(member)
    }
    
    // MARK: - Wellness Analytics
    
    var teamWellnessScore: Double {
        teamService.teamWellnessAverage()
    }
    
    var teamWellnessStatus: String {
        let score = teamWellnessScore
        if score >= 0.8 { return "Excellent" }
        if score >= 0.6 { return "Good" }
        if score >= 0.4 { return "Fair" }
        return "Needs Attention"
    }
    
    func membersNeedingAttention() -> [TeamMember] {
        teamService.membersNeedingWellnessAttention()
    }
    
    func wellnessDistribution() -> [(status: String, count: Int)] {
        var excellent = 0
        var good = 0
        var fair = 0
        var needsAttention = 0
        
        for member in teamService.teamMembers {
            guard let wellness = member.wellnessData else { continue }
            let score = wellness.wellnessScore
            
            if score >= 0.8 { excellent += 1 }
            else if score >= 0.6 { good += 1 }
            else if score >= 0.4 { fair += 1 }
            else { needsAttention += 1 }
        }
        
        return [
            (status: "Excellent", count: excellent),
            (status: "Good", count: good),
            (status: "Fair", count: fair),
            (status: "Needs Attention", count: needsAttention)
        ]
    }
    
    // MARK: - Workload Analytics
    
    func memberWorkload(_ member: TeamMember) -> (total: Int, completed: Int, pending: Int) {
        let tasks = taskService.tasks(assignedTo: member.id)
        let completed = tasks.filter { $0.status == .completed }.count
        let pending = tasks.filter { $0.status != .completed }.count
        return (total: tasks.count, completed: completed, pending: pending)
    }
    
    func membersByWorkload() -> [(member: TeamMember, taskCount: Int)] {
        teamService.teamMembers.map { member in
            let taskCount = taskService.tasks(assignedTo: member.id).filter { $0.status != .completed }.count
            return (member: member, taskCount: taskCount)
        }.sorted { $0.taskCount > $1.taskCount }
    }
    
    // MARK: - Statistics
    
    var totalMembers: Int {
        teamService.teamMembers.count
    }
    
    var activeMembers: Int {
        teamService.activeMembers().count
    }
}

