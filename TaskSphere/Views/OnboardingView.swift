//
//  OnboardingView.swift
//  TaskSphere
//
//  Created on Dec 10, 2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $currentPage) {
                    IntroductionPage()
                        .tag(0)
                    
                    TaskManagementPage()
                        .tag(1)
                    
                    ProjectOversightPage()
                        .tag(2)
                    
                    HealthIntegrationPage()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                // Get Started Button
                if currentPage == 3 {
                    Button(action: {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.appAccent)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                    .transition(.opacity)
                }
            }
        }
    }
}

// MARK: - Onboarding Pages

struct IntroductionPage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "app.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.appAccent)
            
            VStack(spacing: 12) {
                Text("Welcome to")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("TaskSphere")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text("Your central hub for task management,\nproject oversight, and team collaboration")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TaskManagementPage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appSecondary)
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        HStack {
                            Circle()
                                .fill(priorityColor(index: index))
                                .frame(width: 12, height: 12)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 120, height: 8)
                        }
                    }
                }
            }
            
            VStack(spacing: 12) {
                Text("Task Prioritization")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Visualize task urgency with our\ninteractive color-coded heatmap")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func priorityColor(index: Int) -> Color {
        switch index {
        case 0: return .priorityHigh
        case 1: return .priorityMedium
        default: return .priorityLow
        }
    }
}

struct ProjectOversightPage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appSecondary)
                    .frame(width: 280, height: 200)
                
                VStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.appAccent.opacity(Double(3 - index) * 0.3))
                                .frame(width: CGFloat(60 + index * 40), height: 24)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            
            VStack(spacing: 12) {
                Text("Project Timelines")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Track progress with Gantt chart\nfunctionality and milestone tracking")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct HealthIntegrationPage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.appSecondary, lineWidth: 20)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.appAccent)
                    
                    Text("75%")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            VStack(spacing: 12) {
                Text("Team Health Insights")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Monitor wellness insights to optimize\nteam productivity and well-being")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

