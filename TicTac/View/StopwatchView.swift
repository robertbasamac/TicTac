//
//  StopwatchView.swift
//  TicTac
//
//  Created by Robert Basamac on 27.09.2022.
//

import SwiftUI

struct StopwatchView: View {
    @ObservedObject var stopwatch = Stopwatch(duration: 65)
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 6)
                    .frame(width: 150, height: 150)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: stopwatch.remainingPercentage)
                            .stroke(Color.orange,
                                    style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                            .rotationEffect(Angle(degrees: -90))
                    )
                
                VStack {
                    Text("\(stopwatch.message)")
                        .font(.title)
                    
                    
                    HStack {
                        Image(systemName: "bell.fill")
                        Text((stopwatch.alarmTime ?? Date()).asHoursAndMinutes)
                    }
                    .font(.subheadline)
                    .foregroundStyle(stopwatch.isPaused ? .tertiary : .primary)
                    .foregroundColor(.gray)
                    .opacity(stopwatch.isRunning ? 1 : 0)
                }
            }
            .animation(.none, value: stopwatch.isRunning)
            .padding()
            
            HStack(spacing: 10) {
                Button {
                    stopwatch.isRunning ?
                    (stopwatch.isPaused ?
                     stopwatch.resume() :
                        stopwatch.pause())
                    : stopwatch.start()
                } label: {
                    Text(stopwatch.isRunning ?
                         (stopwatch.isPaused ? "Resume" : "Pause")
                         : "Start")
                }
                
                Button(role: .destructive) {
                    stopwatch.stop()
                } label: {
                    Text("Cancel")
                }
            }
        }
    }
}

struct StopwatchView_Previews: PreviewProvider {
    static var previews: some View {
        StopwatchView()
    }
}
