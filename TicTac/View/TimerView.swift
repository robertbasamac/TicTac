//
//  TimerView.swift
//  TicTac
//
//  Created by Robert Basamac on 28.09.2022.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var tm: TimerManager
    
    @Binding var timer: TimerModel
    
    var body: some View {
        VStack(spacing: 2) {
            Text(timer.title)
                .font(.title3)
            
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 6)
                    .frame(width: 150, height: 150)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: timer.remainingPercentage)
                            .stroke(Color.orange,
                                    style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                            .rotationEffect(Angle(degrees: -90))
                    )
                
                VStack(alignment: .center, spacing: 10) {
                    Text("\(timer.message)")
                        .font(.title)
                    
                    HStack {
                        Image(systemName: "bell.fill")
                        Text((timer.alarmTime ?? Date()).asHoursAndMinutes)
                    }
                    .font(.subheadline)
                    .foregroundStyle(timer.isPaused ? .tertiary : .primary)
                    .foregroundColor(.gray)
                    .opacity(timer.isRunning ? 1 : 0)
                }
            }
            .animation(.none, value: timer.isRunning)
            .padding(10)
            
            HStack(alignment: .center, spacing: 15) {
                Button {
                    timer.isRunning ?
                    (timer.isPaused ?
                     tm.resumeTimer(timer) :
                        tm.pauseTimer(timer))
                    : tm.startTimer(timer)
                } label: {
                    Text(timer.isRunning ?
                         (timer.isPaused ? "Resume" : "Pause")
                         : "Start")
                }
                
                Button(role: .destructive) {
                    tm.stopTimer(timer)
                } label: {
                    Text("Cancel")
                }
            }
            .frame(width: 150, alignment: .center)
        }
        .padding(4)
    }
}


struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(timer: .constant(TimerModel(title: "Test", duration: 100000)))
    }
}
