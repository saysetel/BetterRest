//
//  ContentView.swift
//  BetterRest
//
//  Created by Anastasia Kotova on 27.02.23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUpTime = defaultWakeTime
    @State private var amountOfSleep = 8.0
    @State private var amountOfCoffeeCups = 1
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)
                DatePicker("Please enter a time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .fixedSize()
                Text("Desired amount of sleep")
                    .font(.headline)
                Stepper("\(amountOfSleep.formatted()) hours", value: $amountOfSleep, in: 4...12, step: 0.50)
                    .fixedSize()
                Text("Coffee intake")
                    .font(.headline)
                Stepper(amountOfCoffeeCups == 1 ? "1 cup" : "\(amountOfCoffeeCups) cups", value: $amountOfCoffeeCups, in: 1...20)
                    .fixedSize()
            }
            .navigationTitle("BetterSleep")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: Double(amountOfSleep), coffee: Double(amountOfCoffeeCups))
            
            let sleepTime = wakeUpTime - prediction.actualSleep
            alertTitle = "Bedtime"
            alertMessage = "Your ideal bedtime is \(sleepTime.formatted(date: .omitted, time: .shortened))"
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Something went wrong"
        }
        
        showAlert = true
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
