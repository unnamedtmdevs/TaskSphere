//
//  SettingsView.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @ObservedObject var taskService: TaskService
    @ObservedObject var projectService: ProjectService
    @ObservedObject var teamService: TeamService
    
    @State private var showingResetConfirmation = false
    @State private var showingClearDataConfirmation = false
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Settings Sections
                    VStack(spacing: 24) {
                        // Data & Storage
                        settingsSection(title: "Data & Storage") {
                            SettingsStatRow(
                                icon: "checkmark.circle.fill",
                                title: "Tasks",
                                value: "\(taskService.tasks.count)",
                                color: .appAccent
                            )
                            
                            SettingsStatRow(
                                icon: "folder.fill",
                                title: "Projects",
                                value: "\(projectService.projects.count)",
                                color: .statusInProgress
                            )
                            
                            SettingsStatRow(
                                icon: "person.3.fill",
                                title: "Team Members",
                                value: "\(teamService.teamMembers.count)",
                                color: .statusCompleted
                            )
                        }
                        
                        // About
                        settingsSection(title: "About") {
                            SettingsInfoRow(
                                icon: "info.circle.fill",
                                title: "Version",
                                value: "1.0.0"
                            )
                            
                            SettingsInfoRow(
                                icon: "app.fill",
                                title: "App Name",
                                value: "TaskSphere"
                            )
                        }
                        
                        // Actions
                        settingsSection(title: "Actions") {
                            SettingsActionRow(
                                icon: "arrow.counterclockwise.circle.fill",
                                title: "Reset App",
                                color: .orange,
                                action: {
                                    showingResetConfirmation = true
                                }
                            )
                            
                            SettingsActionRow(
                                icon: "trash.fill",
                                title: "Clear All Data",
                                color: .red,
                                action: {
                                    showingClearDataConfirmation = true
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .alert("Reset App", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetApp()
            }
        } message: {
            Text("This will return you to the onboarding screen. Your data will be preserved.")
        }
        .alert("Clear All Data", isPresented: $showingClearDataConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all tasks, projects, and team members. This action cannot be undone.")
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Manage your preferences")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color.appSecondary)
            .cornerRadius(12)
        }
    }
    
    private func resetApp() {
        withAnimation {
            hasCompletedOnboarding = false
        }
    }
    
    private func clearAllData() {
        taskService.resetAllTasks()
        projectService.resetAllProjects()
        teamService.resetAllTeamMembers()
    }
}

// MARK: - Settings Row Components

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.appAccent)
                .frame(width: 28)
            
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .appAccent))
        }
        .padding()
    }
}

struct SettingsStatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 28)
            
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.appAccent)
                .frame(width: 28)
            
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
    }
}

struct SettingsActionRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(color)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            taskService: TaskService(),
            projectService: ProjectService(),
            teamService: TeamService()
        )
    }
}

