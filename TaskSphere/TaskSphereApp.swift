//
//  TaskSphereApp.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import SwiftUI

@main
struct TaskSphereApp: App {
    @StateObject private var taskService = TaskService()
    @StateObject private var projectService = ProjectService()
    @StateObject private var teamService = TeamService()
    
    var body: some Scene {
        WindowGroup {
            LaunchCheckView(
                taskService: taskService,
                projectService: projectService,
                teamService: teamService
            )
        }
    }
}
