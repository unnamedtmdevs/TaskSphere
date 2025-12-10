//
//  TeamService.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import Foundation
import Combine

class TeamService: ObservableObject {
    @Published var teamMembers: [TeamMember] = []
    
    private let teamMembersKey = "TaskSphere_TeamMembers"
    
    init() {
        loadTeamMembers()
    }
    
    // MARK: - CRUD Operations
    
    func loadTeamMembers() {
        guard let data = UserDefaults.standard.data(forKey: teamMembersKey),
              let decoded = try? JSONDecoder().decode([TeamMember].self, from: data) else {
            teamMembers = []
            return
        }
        teamMembers = decoded
    }
    
    private func saveTeamMembers() {
        guard let encoded = try? JSONEncoder().encode(teamMembers) else { return }
        UserDefaults.standard.set(encoded, forKey: teamMembersKey)
    }
    
    func addTeamMember(_ member: TeamMember) {
        teamMembers.append(member)
        saveTeamMembers()
    }
    
    func updateTeamMember(_ member: TeamMember) {
        if let index = teamMembers.firstIndex(where: { $0.id == member.id }) {
            teamMembers[index] = member
            saveTeamMembers()
        }
    }
    
    func deleteTeamMember(_ member: TeamMember) {
        teamMembers.removeAll { $0.id == member.id }
        saveTeamMembers()
    }
    
    func deleteTeamMembers(at offsets: IndexSet) {
        teamMembers.remove(atOffsets: offsets)
        saveTeamMembers()
    }
    
    // MARK: - Query Operations
    
    func activeMembers() -> [TeamMember] {
        return teamMembers.filter { $0.isActive }
    }
    
    func members(with role: MemberRole) -> [TeamMember] {
        return teamMembers.filter { $0.role == role }
    }
    
    func member(withId id: UUID) -> TeamMember? {
        return teamMembers.first { $0.id == id }
    }
    
    // MARK: - Wellness Operations
    
    func updateWellnessData(for memberId: UUID, wellnessData: WellnessData) {
        if let index = teamMembers.firstIndex(where: { $0.id == memberId }) {
            teamMembers[index].wellnessData = wellnessData
            saveTeamMembers()
        }
    }
    
    func teamWellnessAverage() -> Double {
        let membersWithData = teamMembers.compactMap { $0.wellnessData }
        guard !membersWithData.isEmpty else { return 0 }
        let totalScore = membersWithData.reduce(0.0) { $0 + $1.wellnessScore }
        return totalScore / Double(membersWithData.count)
    }
    
    func membersNeedingWellnessAttention() -> [TeamMember] {
        return teamMembers.filter { member in
            guard let wellness = member.wellnessData else { return false }
            return wellness.wellnessScore < 0.4
        }
    }
    
    // MARK: - Statistics
    
    func membersByRole() -> [MemberRole: Int] {
        var result: [MemberRole: Int] = [:]
        for role in MemberRole.allCases {
            result[role] = teamMembers.filter { $0.role == role }.count
        }
        return result
    }
    
    // MARK: - Reset
    
    func resetAllTeamMembers() {
        teamMembers = []
        saveTeamMembers()
    }
}

