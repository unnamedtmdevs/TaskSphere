//
//  ProjectDetailView.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import SwiftUI

struct ProjectDetailView: View {
    @ObservedObject var viewModel: ProjectViewModel
    @State private var showingAddProject = false
    @State private var selectedProject: Project?
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Projects List
                if viewModel.projectService.projects.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Timeline/Gantt View
                            timelineView
                            
                            // Projects Grid
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.projectService.projects) { project in
                                    ProjectCardView(project: project, viewModel: viewModel)
                                        .onTapGesture {
                                            selectedProject = project
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedProject) { project in
            ProjectDetailSheet(
                project: project,
                viewModel: viewModel,
                onUpdate: { updatedProject in
                    viewModel.projectService.updateProject(updatedProject)
                },
                onDelete: {
                    viewModel.deleteProject(project)
                    selectedProject = nil
                }
            )
        }
        .sheet(isPresented: $showingAddProject) {
            AddProjectSheet(
                viewModel: viewModel,
                onAdd: { newProject in
                    viewModel.projectService.addProject(newProject)
                    showingAddProject = false
                }
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Projects")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(viewModel.projectService.projects.count) projects")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Button(action: {
                showingAddProject = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.appAccent)
            }
        }
        .padding()
    }
    
    private var timelineView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timeline")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.projectService.projects.filter { $0.endDate != nil }) { project in
                        TimelineBarView(project: project)
                    }
                }
                .padding()
                .background(Color.appSecondary)
                .cornerRadius(16)
                .padding(.horizontal)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.white.opacity(0.3))
            
            Text("No Projects")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Tap + to create your first project")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ProjectCardView: View {
    let project: Project
    let viewModel: ProjectViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color(hex: project.color))
                    .frame(width: 12, height: 12)
                
                Text(project.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(project.status.rawValue)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(hex: project.color).opacity(0.3))
                    .cornerRadius(8)
            }
            
            if !project.description.isEmpty {
                Text(project.description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text("\(project.completionPercentage)%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.appTertiary)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: project.color))
                            .frame(width: geometry.size.width * CGFloat(project.progress), height: 8)
                    }
                }
                .frame(height: 8)
            }
            
            // Dates and Milestones
            HStack(spacing: 16) {
                if let endDate = project.endDate {
                    Label(endDate.formatted, systemImage: "calendar")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(project.isOverdue ? .appAccent : .white.opacity(0.5))
                }
                
                Label("\(project.milestones.count) milestones", systemImage: "flag.fill")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding()
        .background(Color.appSecondary)
        .cornerRadius(16)
    }
}

struct TimelineBarView: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(Color(hex: project.color))
                    .frame(width: 8, height: 8)
                
                Text(project.name)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: project.color))
                    .frame(width: CGFloat(project.duration * 3), height: 24)
                    .overlay(
                        Text("\(project.completionPercentage)%")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )
            }
            .frame(height: 24)
        }
    }
}

// MARK: - Project Detail Sheet

struct ProjectDetailSheet: View {
    let project: Project
    let viewModel: ProjectViewModel
    let onUpdate: (Project) -> Void
    let onDelete: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var editedProject: Project
    
    init(project: Project, viewModel: ProjectViewModel, onUpdate: @escaping (Project) -> Void, onDelete: @escaping () -> Void) {
        self.project = project
        self.viewModel = viewModel
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _editedProject = State(initialValue: project)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Status
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(ProjectStatus.allCases, id: \.self) { status in
                                        Button(action: {
                                            editedProject.status = status
                                        }) {
                                            Text(status.rawValue)
                                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(editedProject.status == status ? Color.appAccent : Color.appSecondary)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Milestones
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Milestones")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            if editedProject.milestones.isEmpty {
                                Text("No milestones yet")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.appSecondary)
                                    .cornerRadius(12)
                            } else {
                                ForEach(editedProject.milestones) { milestone in
                                    HStack {
                                        Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(milestone.isCompleted ? .statusCompleted : .white.opacity(0.5))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(milestone.title)
                                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                                .foregroundColor(.white)
                                            
                                            Text(milestone.dueDate.formatted)
                                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.appSecondary)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Tasks in Project
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tasks")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            let projectTasks = viewModel.tasksForProject(project)
                            
                            if projectTasks.isEmpty {
                                Text("No tasks assigned")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.appSecondary)
                                    .cornerRadius(12)
                            } else {
                                ForEach(projectTasks) { task in
                                    HStack {
                                        Circle()
                                            .fill(Color.priorityColor(for: task.priority))
                                            .frame(width: 8, height: 8)
                                        
                                        Text(task.title)
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Text(task.status.rawValue)
                                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding()
                                    .background(Color.appSecondary)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Delete Button
                        Button(action: {
                            onDelete()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Delete Project")
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
            .navigationBarTitle(editedProject.name, displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    onUpdate(editedProject)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Add Project Sheet

struct AddProjectSheet: View {
    let viewModel: ProjectViewModel
    let onAdd: (Project) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days from now
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
                            Text("Project Name")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Enter project name", text: $name)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.appSecondary)
                                .cornerRadius(12)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (Optional)")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Enter description", text: $description)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.appSecondary)
                                .cornerRadius(12)
                        }
                        
                        // Color Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color")
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
                        
                        // Dates
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start Date")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            DatePicker("", selection: $startDate, displayedComponents: [.date])
                                .datePickerStyle(CompactDatePickerStyle())
                                .accentColor(.appAccent)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("End Date")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            DatePicker("", selection: $endDate, displayedComponents: [.date])
                                .datePickerStyle(CompactDatePickerStyle())
                                .accentColor(.appAccent)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("New Project", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    let project = Project(
                        name: name,
                        description: description,
                        startDate: startDate,
                        endDate: endDate,
                        color: selectedColor
                    )
                    onAdd(project)
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

