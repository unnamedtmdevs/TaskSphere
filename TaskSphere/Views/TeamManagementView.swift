//
//  TeamManagementView.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import SwiftUI

struct TeamManagementView: View {
    @ObservedObject var viewModel: TeamViewModel
    @State private var showingAddMember = false
    @State private var selectedMember: TeamMember?
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Team Wellness Overview
                if !viewModel.teamService.teamMembers.isEmpty {
                    wellnessOverviewView
                }
                
                // Team Members List
                if viewModel.teamService.teamMembers.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.teamService.teamMembers) { member in
                                TeamMemberCardView(member: member, viewModel: viewModel)
                                    .onTapGesture {
                                        selectedMember = member
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(item: $selectedMember) { member in
            TeamMemberDetailSheet(
                member: member,
                viewModel: viewModel,
                onUpdate: { updatedMember in
                    viewModel.teamService.updateTeamMember(updatedMember)
                },
                onDelete: {
                    viewModel.deleteMember(member)
                    selectedMember = nil
                }
            )
        }
        .sheet(isPresented: $showingAddMember) {
            AddTeamMemberSheet(
                viewModel: viewModel,
                onAdd: { newMember in
                    viewModel.teamService.addTeamMember(newMember)
                    showingAddMember = false
                }
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Team")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(viewModel.teamService.teamMembers.count) members")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Button(action: {
                showingAddMember = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.appAccent)
            }
        }
        .padding()
    }
    
    private var wellnessOverviewView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Team Health Insights")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                // Overall Wellness Score
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.appSecondary, lineWidth: 12)
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(viewModel.teamWellnessScore))
                            .stroke(Color.wellnessColor(for: viewModel.teamWellnessScore), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 2) {
                            Text("\(Int(viewModel.teamWellnessScore * 100))%")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(viewModel.teamWellnessStatus)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                // Wellness Distribution
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.wellnessDistribution(), id: \.status) { item in
                        if item.count > 0 {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(wellnessColorForStatus(item.status))
                                    .frame(width: 8, height: 8)
                                
                                Text(item.status)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                                
                                Text("\(item.count)")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color.appSecondary)
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private func wellnessColorForStatus(_ status: String) -> Color {
        switch status {
        case "Excellent": return .wellnessExcellent
        case "Good": return .wellnessGood
        case "Fair": return .wellnessFair
        default: return .wellnessAttention
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.white.opacity(0.3))
            
            Text("No Team Members")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Tap + to add your first team member")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TeamMemberCardView: View {
    let member: TeamMember
    let viewModel: TeamViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: member.avatarColor))
                    .frame(width: 56, height: 56)
                
                Text(member.initials)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Member Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(member.name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if !member.isActive {
                        Text("Inactive")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
                
                Text(member.role.rawValue)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                
                // Wellness Indicator
                if let wellness = member.wellnessData {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.wellnessColor(for: wellness.wellnessScore))
                        
                        Text(wellness.wellnessStatus)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color.wellnessColor(for: wellness.wellnessScore))
                    }
                }
            }
            
            Spacer()
            
            // Workload Badge
            let workload = viewModel.memberWorkload(member)
            if workload.pending > 0 {
                VStack(spacing: 2) {
                    Text("\(workload.pending)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("tasks")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding()
        .background(Color.appSecondary)
        .cornerRadius(16)
    }
}

// MARK: - Team Member Detail Sheet

struct TeamMemberDetailSheet: View {
    let member: TeamMember
    let viewModel: TeamViewModel
    let onUpdate: (TeamMember) -> Void
    let onDelete: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var editedMember: TeamMember
    @State private var stepsToday: String
    @State private var sleepHours: String
    
    init(member: TeamMember, viewModel: TeamViewModel, onUpdate: @escaping (TeamMember) -> Void, onDelete: @escaping () -> Void) {
        self.member = member
        self.viewModel = viewModel
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _editedMember = State(initialValue: member)
        _stepsToday = State(initialValue: "\(member.wellnessData?.stepsToday ?? 0)")
        _sleepHours = State(initialValue: String(format: "%.1f", member.wellnessData?.sleepHoursLastNight ?? 0.0))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color(hex: editedMember.avatarColor))
                                .frame(width: 100, height: 100)
                            
                            Text(editedMember.initials)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top)
                        
                        // Role
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Role")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 10) {
                                ForEach(MemberRole.allCases, id: \.self) { role in
                                    Button(action: {
                                        editedMember.role = role
                                    }) {
                                        Text(role.rawValue)
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(editedMember.role == role ? Color.appAccent : Color.appSecondary)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        // Wellness Data
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Wellness Data")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Steps Today")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Spacer()
                                    
                                    TextField("0", text: $stepsToday)
                                        .keyboardType(.numberPad)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.trailing)
                                        .padding(8)
                                        .background(Color.appTertiary)
                                        .cornerRadius(8)
                                        .frame(width: 100)
                                }
                                
                                HStack {
                                    Text("Sleep (hours)")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Spacer()
                                    
                                    TextField("0.0", text: $sleepHours)
                                        .keyboardType(.decimalPad)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.trailing)
                                        .padding(8)
                                        .background(Color.appTertiary)
                                        .cornerRadius(8)
                                        .frame(width: 100)
                                }
                            }
                            .padding()
                            .background(Color.appSecondary)
                            .cornerRadius(12)
                        }
                        
                        // Workload
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Workload")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            let workload = viewModel.memberWorkload(member)
                            
                            HStack(spacing: 20) {
                                StatBox(title: "Total", value: "\(workload.total)", color: .appAccent)
                                StatBox(title: "Completed", value: "\(workload.completed)", color: .statusCompleted)
                                StatBox(title: "Pending", value: "\(workload.pending)", color: .statusInProgress)
                            }
                        }
                        
                        // Active Toggle
                        Toggle(isOn: $editedMember.isActive) {
                            Text("Active Member")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .appAccent))
                        .padding()
                        .background(Color.appSecondary)
                        .cornerRadius(12)
                        
                        // Delete Button
                        Button(action: {
                            onDelete()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Delete Member")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle(editedMember.name, displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    // Update wellness data
                    if let steps = Int(stepsToday), let sleep = Double(sleepHours) {
                        editedMember.wellnessData = WellnessData(
                            stepsToday: steps,
                            sleepHoursLastNight: sleep,
                            lastUpdated: Date()
                        )
                    }
                    onUpdate(editedMember)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.appSecondary)
        .cornerRadius(12)
    }
}

// MARK: - Add Team Member Sheet

struct AddTeamMemberSheet: View {
    let viewModel: TeamViewModel
    let onAdd: (TeamMember) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var role: MemberRole = .member
    @State private var selectedColor = "#FE284A"
    
    let colorOptions = ["#FE284A", "#3498DB", "#2ECC71", "#F39C12", "#9B59B6", "#1ABC9C"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Enter name", text: $name)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.appSecondary)
                                .cornerRadius(12)
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Enter email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.appSecondary)
                                .cornerRadius(12)
                        }
                        
                        // Role
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Role")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 10) {
                                ForEach(MemberRole.allCases, id: \.self) { r in
                                    Button(action: {
                                        role = r
                                    }) {
                                        Text(r.rawValue)
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(role == r ? Color.appAccent : Color.appSecondary)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        // Avatar Color
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Avatar Color")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 12) {
                                ForEach(colorOptions, id: \.self) { color in
                                    Button(action: {
                                        selectedColor = color
                                    }) {
                                        Circle()
                                            .fill(Color(hex: color))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("New Team Member", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    let member = TeamMember(
                        name: name,
                        email: email,
                        role: role,
                        avatarColor: selectedColor
                    )
                    onAdd(member)
                }
                .disabled(name.isEmpty || email.isEmpty)
            )
        }
    }
}

