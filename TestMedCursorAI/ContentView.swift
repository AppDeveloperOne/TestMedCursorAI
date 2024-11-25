//
//  ContentView.swift
//  TestMedCursorAI
//
//  Created by AppDeveloperOne on 2024-11-22.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var appointments: [MedicalAppointment]
    
    @State private var showingAddAppointment = false
    
    init() {
        _appointments = Query(sort: \MedicalAppointment.appointmentDate, order: .reverse)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(appointments) { appointment in
                    AppointmentCard(appointment: appointment, modelContext: modelContext)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .onDelete(perform: deleteAppointments)
            }
            .listStyle(.plain)
            .navigationTitle("Medical Appointments")
            .toolbar {
                Button {
                    showingAddAppointment = true
                } label: {
                    Label("Add Appointment", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddAppointment) {
                AddAppointmentView(modelContext: modelContext)
            }
        }
    }
    
    private func deleteAppointments(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(appointments[index])
        }
    }
}

struct AppointmentCard: View {
    let appointment: MedicalAppointment
    let modelContext: ModelContext
    @State private var showingEditSheet = false
    
    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appointment.appointmentDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(appointment.practiceName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                }
                
                Text(appointment.reason)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingEditSheet) {
            EditAppointmentView(appointment: appointment, modelContext: modelContext)
        }
    }
}

#Preview {
    let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: MedicalAppointment.self,
                Doctor.self,
                configurations: config
            )
            
            // Add some sample data
            let doctor = Doctor(name: "Dr. Smith", practiceName: "Sample Clinic")
            container.mainContext.insert(doctor)
            
            let sampleAppointment = MedicalAppointment(
                practiceName: "Sample Clinic",
                appointmentDate: Date(),
                reason: "Annual Checkup",
                doctorName: "Dr. Smith"
            )
            container.mainContext.insert(sampleAppointment)
            
            return container
        } catch {
            fatalError("Failed to create preview container: \(error.localizedDescription)")
        }
    }()
    
    ContentView()
        .modelContainer(previewContainer)
        .preferredColorScheme(.light)
}
