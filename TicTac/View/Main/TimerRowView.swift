//
//  TimerRowView.swift
//  TicTac
//
//  Created by Robert Basamac on 02.10.2022.
//

import SwiftUI

struct TimerRowView: View {
    @EnvironmentObject private var tm: TimerManager
    
    let timer: TimerModel
    
    var body: some View {
        HStack(spacing: 0) {
            titleSection
                        
            CircleButtonView(iconName: "xmark", foregroundColor: .white, backgroundColor: .gray)
                .onTapGesture {
                    tm.stopTimer(timer)
                }
            
            if timer.isRunning {
                progressCircleView
            } else {
                timerDurationView
            }
            
            CircleButtonView(iconName: timer.isRunning != timer.isPaused ? "pause.fill" : "play.fill",
                             foregroundColor: timer.isRunning != timer.isPaused ? .orange : .green,
                             backgroundColor: timer.isRunning != timer.isPaused ? .orange : .green)
                .onTapGesture {
                    timer.isRunning ?
                    (timer.isPaused ?
                     tm.resumeTimer(timer) :
                        tm.pauseTimer(timer))
                    : tm.startTimer(timer)
                }
        }
        .frame(height: 100, alignment: .center)
    }
}

struct TimerRowView_Previews: PreviewProvider {
    static var previews: some View {
        TimerRowView(timer: dev.timer)
            .previewLayout(.sizeThatFits)
    }
}

extension TimerRowView {
    
    private var titleSection: some View {
        Text(timer.title)
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
        
    private var progressCircleView: some View {
        ZStack {
            Circle()
                .stroke(Color.gray, lineWidth: 4)
                .overlay(
                    Circle()
                        .trim(from: 0, to: timer.remainingPercentage)
                        .stroke(Color.orange,
                                style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                        .rotationEffect(Angle(degrees: -90))
                )
            
            ZStack {
                Text("\(timer.displayedTime)")
                    .font(.title2)
                
                HStack(alignment: .center, spacing: 2) {
                    Image(systemName: "bell.fill")
                    Text((timer.alarmTime ?? Date()).asHoursAndMinutes)
                }
                .font(.caption2)
                .foregroundStyle(timer.isPaused ? .tertiary : .primary)
                .foregroundColor(.gray)
                .offset(y: 20)
            }
        }
        .padding(4)
        .frame(width: 110)
    }
    
    private var timerDurationView: some View {
        Text("\(timer.duration.asHoursMinutesSeconds)")
            .font(.title2)
            .frame(width: 110)
    }
}
