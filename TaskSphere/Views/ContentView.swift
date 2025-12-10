//
//  ContentView.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var projectViewModel: ProjectViewModel
    @ObservedObject var teamViewModel: TeamViewModel
    @ObservedObject var taskService: TaskService
    @ObservedObject var projectService: ProjectService
    @ObservedObject var teamService: TeamService
    
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main Content
                TabView(selection: $selectedTab) {
                    DashboardView(
                        taskViewModel: taskViewModel,
                        projectViewModel: projectViewModel,
                        teamViewModel: teamViewModel
                    )
                    .tag(0)
                    
                    TaskListView(
                        viewModel: taskViewModel,
                        projectService: projectService
                    )
                    .tag(1)
                    
                    ProjectDetailView(
                        viewModel: projectViewModel
                    )
                    .tag(2)
                    
                    TeamManagementView(
                        viewModel: teamViewModel
                    )
                    .tag(3)
                    
                    SettingsView(
                        taskService: taskService,
                        projectService: projectService,
                        teamService: teamService
                    )
                    .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom Tab Bar
                customTabBar
            }
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "square.grid.2x2.fill",
                title: "Dashboard",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            TabBarButton(
                icon: "checkmark.circle.fill",
                title: "Tasks",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            TabBarButton(
                icon: "folder.fill",
                title: "Projects",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
            
            TabBarButton(
                icon: "person.3.fill",
                title: "Team",
                isSelected: selectedTab == 3,
                action: { selectedTab = 3 }
            )
            
            TabBarButton(
                icon: "gearshape.fill",
                title: "Settings",
                isSelected: selectedTab == 4,
                action: { selectedTab = 4 }
            )
        }
        .padding(.vertical, 12)
        .background(Color.appSecondary)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .appAccent : .white.opacity(0.5))
                
                Text(title)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .appAccent : .white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Dashboard View

struct DashboardView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var projectViewModel: ProjectViewModel
    @ObservedObject var teamViewModel: TeamViewModel
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerView
                    
                    // Quick Stats
                    quickStatsView
                    
                    // Task Priority Heatmap
                    taskHeatmapWidget
                    
                    // Project Progress
                    projectProgressWidget
                    
                    // Team Wellness
                    teamWellnessWidget
                    
                    // Today's Tasks
                    todayTasksWidget
                }
                .padding()
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Dashboard")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Welcome back!")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var quickStatsView: some View {
        HStack(spacing: 12) {
            QuickStatCard(
                title: "Tasks",
                value: "\(taskViewModel.totalTasks)",
                subtitle: "\(taskViewModel.completedTasks) completed",
                color: .appAccent
            )
            
            QuickStatCard(
                title: "Projects",
                value: "\(projectViewModel.totalProjects)",
                subtitle: "\(projectViewModel.activeProjects) active",
                color: .statusInProgress
            )
            
            QuickStatCard(
                title: "Team",
                value: "\(teamViewModel.totalMembers)",
                subtitle: "\(teamViewModel.activeMembers) active",
                color: .statusCompleted
            )
        }
    }
    
    private var taskHeatmapWidget: some View {
        WidgetContainer(title: "Task Priority Heatmap") {
            let heatmapData = taskViewModel.tasksForHeatmap().prefix(6)
            
            if heatmapData.isEmpty {
                Text("No active tasks")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Array(heatmapData.enumerated()), id: \.element.task.id) { index, item in
                        HeatmapCell(task: item.task, urgency: item.urgency)
                    }
                }
            }
        }
    }
    
    private var projectProgressWidget: some View {
        WidgetContainer(title: "Project Progress") {
            let projects = projectViewModel.projectService.projects.prefix(3)
            
            if projects.isEmpty {
                Text("No projects yet")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(projects) { project in
                        ProjectProgressRow(project: project)
                    }
                }
            }
        }
    }
    
    private var teamWellnessWidget: some View {
        WidgetContainer(title: "Team Health") {
            if teamViewModel.teamService.teamMembers.isEmpty {
                Text("No team members yet")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                HStack(spacing: 20) {
                    // Overall Score
                    ZStack {
                        Circle()
                            .stroke(Color.appTertiary, lineWidth: 10)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(teamViewModel.teamWellnessScore))
                            .stroke(Color.wellnessColor(for: teamViewModel.teamWellnessScore), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 2) {
                            Text("\(Int(teamViewModel.teamWellnessScore * 100))%")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(teamViewModel.teamWellnessStatus)
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    // Distribution
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(teamViewModel.wellnessDistribution().filter { $0.count > 0 }, id: \.status) { item in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(wellnessColorForStatus(item.status))
                                    .frame(width: 6, height: 6)
                                
                                Text("\(item.status): \(item.count)")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    private var todayTasksWidget: some View {
        WidgetContainer(title: "Today's Tasks") {
            if taskViewModel.todayTasks.isEmpty {
                Text("No tasks due today")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(taskViewModel.todayTasks) { task in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.priorityColor(for: task.priority))
                                .frame(width: 8, height: 8)
                            
                            Text(task.title)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(task.status.rawValue)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
    
    private func wellnessColorForStatus(_ status: String) -> Color {
        switch status {
        case "Excellent": return .wellnessExcellent
        case "Good": return .wellnessGood
        case "Fair": return .wellnessFair
        default: return .wellnessAttention
        }
    }
}

// MARK: - Dashboard Components

struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.appSecondary)
        .cornerRadius(16)
    }
}

struct WidgetContainer<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                content
            }
            .padding()
            .background(Color.appSecondary)
            .cornerRadius(16)
        }
    }
}

struct HeatmapCell: View {
    let task: Task
    let urgency: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.priorityColor(for: task.priority))
                    .frame(width: 8, height: 8)
                
                Spacer()
                
                Text("\(Int(urgency * 100))%")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Text(task.title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let dueDate = task.dueDate {
                Text(dueDate.formatted)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(task.isOverdue ? .appAccent : .white.opacity(0.5))
            }
        }
        .padding(12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.priorityColor(for: task.priority).opacity(0.3),
                    Color.priorityColor(for: task.priority).opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
}

struct ProjectProgressRow: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(Color(hex: project.color))
                    .frame(width: 8, height: 8)
                
                Text(project.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(project.completionPercentage)%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appTertiary)
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: project.color))
                        .frame(width: geometry.size.width * CGFloat(project.progress), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(Color.appTertiary.opacity(0.3))
        .cornerRadius(12)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let taskService = TaskService()
        let projectService = ProjectService()
        let teamService = TeamService()
        
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

