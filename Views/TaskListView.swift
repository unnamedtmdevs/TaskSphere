//
//  TaskListView.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @ObservedObject var projectService: ProjectService
    @State private var showingAddTask = false
    @State private var selectedTask: Task?
    @State private var showingTaskDetail = false
    @State private var filterStatus: TaskStatus?
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Filter Pills
                filterPillsView
                
                // Tasks List
                if filteredTasks.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTasks) { task in
                                TaskRowView(task: task, projectService: projectService)
                                    .onTapGesture {
                                        selectedTask = task
                                        showingTaskDetail = true
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailSheet(
                task: task,
                viewModel: viewModel,
                projectService: projectService,
                onUpdate: { updatedTask in
                    viewModel.taskService.updateTask(updatedTask)
                },
                onDelete: {
                    viewModel.deleteTask(task)
                    selectedTask = nil
                }
            )
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskSheet(
                viewModel: viewModel,
                projectService: projectService,
                onAdd: { newTask in
                    viewModel.taskService.addTask(newTask)
                    showingAddTask = false
                }
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tasks")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(filteredTasks.count) tasks")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Button(action: {
                showingAddTask = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.appAccent)
            }
        }
        .padding()
    }
    
    private var filterPillsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterPill(title: "All", isSelected: filterStatus == nil) {
                    filterStatus = nil
                }
                
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    FilterPill(title: status.rawValue, isSelected: filterStatus == status) {
                        filterStatus = status
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.white.opacity(0.3))
            
            Text("No Tasks")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Tap + to create your first task")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var filteredTasks: [Task] {
        if let status = filterStatus {
            return viewModel.taskService.tasks.filter { $0.status == status }
        }
        return viewModel.taskService.tasks
    }
}

struct TaskRowView: View {
    let task: Task
    let projectService: ProjectService
    
    var body: some View {
        HStack(spacing: 12) {
            // Priority Indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.priorityColor(for: task.priority))
                .frame(width: 4, height: 60)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    if let projectId = task.projectId,
                       let project = projectService.projects.first(where: { $0.id == projectId }) {
                        Label(project.name, systemImage: "folder.fill")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                    }
                    
                    if let dueDate = task.dueDate {
                        Label(dueDate.formatted, systemImage: "calendar")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(task.isOverdue ? .appAccent : .white.opacity(0.5))
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Status Badge
            Text(task.status.rawValue)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.statusColor(for: task.status).opacity(0.3))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.appSecondary)
        .cornerRadius(12)
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.appAccent : Color.appSecondary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Task Detail Sheet

struct TaskDetailSheet: View {
    let task: Task
    let viewModel: TaskViewModel
    let projectService: ProjectService
    let onUpdate: (Task) -> Void
    let onDelete: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var editedTask: Task
    
    init(task: Task, viewModel: TaskViewModel, projectService: ProjectService, onUpdate: @escaping (Task) -> Void, onDelete: @escaping () -> Void) {
        self.task = task
        self.viewModel = viewModel
        self.projectService = projectService
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _editedTask = State(initialValue: task)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Priority Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 10) {
                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                    Button(action: {
                                        editedTask.priority = priority
                                    }) {
                                        Text(priority.title)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(editedTask.priority == priority ? Color.priorityColor(for: priority) : Color.appSecondary)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        // Status Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 10) {
                                ForEach(TaskStatus.allCases, id: \.self) { status in
                                    Button(action: {
                                        editedTask.status = status
                                        if status == .completed {
                                            editedTask.completedDate = Date()
                                        }
                                    }) {
                                        Text(status.rawValue)
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(editedTask.status == status ? Color.statusColor(for: status) : Color.appSecondary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        // Description
                        if !editedTask.description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text(editedTask.description)
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.appSecondary)
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Delete Button
                        Button(action: {
                            onDelete()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Delete Task")
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
            .navigationBarTitle(editedTask.title, displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    onUpdate(editedTask)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Add Task Sheet

struct AddTaskSheet: View {
    let viewModel: TaskViewModel
    let projectService: ProjectService
    let onAdd: (Task) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var selectedProject: Project?
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Enter task title", text: $title)
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
                        
                        // Priority
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 10) {
                                ForEach(TaskPriority.allCases, id: \.self) { p in
                                    Button(action: {
                                        priority = p
                                    }) {
                                        Text(p.title)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(priority == p ? Color.priorityColor(for: p) : Color.appSecondary)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        // Due Date Toggle
                        Toggle(isOn: $hasDueDate) {
                            Text("Set Due Date")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .appAccent))
                        
                        if hasDueDate {
                            DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accentColor(.appAccent)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("New Task", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    let task = Task(
                        title: title,
                        description: description,
                        priority: priority,
                        dueDate: hasDueDate ? dueDate : nil,
                        projectId: selectedProject?.id
                    )
                    onAdd(task)
                }
                .disabled(title.isEmpty)
            )
        }
    }
}

