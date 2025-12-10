//
//  TaskSphereApp.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import SwiftUI

@main
struct TaskSphereApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @StateObject private var taskService = TaskService()
    @StateObject private var projectService = ProjectService()
    @StateObject private var teamService = TeamService()
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                mainAppView
            } else {
                OnboardingView()
            }
        }
    }
    
    private var mainAppView: some View {
        let taskViewModel = TaskViewModel(taskService: taskService)
        let projectViewModel = ProjectViewModel(projectService: projectService, taskService: taskService)
        let teamViewModel = TeamViewModel(teamService: teamService, taskService: taskService)
        
        return ContentView(
            taskViewModel: taskViewModel,
            projectViewModel: projectViewModel,
            teamViewModel: teamViewModel,
            taskService: taskService,
            projectService: projectService,
            teamService: teamService
        )
    }
}

