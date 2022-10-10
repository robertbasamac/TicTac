//
//  TimerRowView.swift
//  TicTac
//
//  Created by Robert Basamac on 02.10.2022.
//

import SwiftUI

struct TimerRowView: View {
    @EnvironmentObject private var tm: TimerManager
    @Environment(\.editMode) private var editMode
    
    let timer: TimerModel
    
    var body: some View {
        HStack(spacing: 8) {
            titleSection
            
            if timer.isRunning {
                progressCircleView
            } else {
                timerDurationView
            }
            
            if editMode?.wrappedValue == .inactive {
                VStack(spacing: 4) {
                    CircleButtonView(style: .reset)
                        .onTapGesture {
                            tm.stopTimer(timer)
                        }
                    
                    CircleButtonView(style: timer.isRunning != timer.isPaused ? .pause : .start)
                        .onTapGesture {
                            timer.isRunning ?
                            (timer.isPaused ?
                             tm.resumeTimer(timer) :
                                tm.pauseTimer(timer))
                            : tm.startTimer(timer)
                        }
                }
            }
        }
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
            .font(.system(size: 18, weight: .none, design: .default))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
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
                         
            VStack {
                Text("\(timer.duration.asHoursMinutesSecondsShorted)")
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundColor(.gray)
                
                Text("\(timer.displayedTime)")
                    .font(.system(size: 22, weight: .none, design: .default))
                
                HStack(alignment: .center, spacing: 2) {
                    Image(systemName: "bell.fill")
                    Text((timer.alarmTime ?? Date()).asHoursAndMinutes)
                }
                .font(.system(size: 12, weight: .none, design: .default))
                .foregroundStyle(timer.isPaused ? .tertiary : .primary)
                .foregroundColor(.gray)
            }
        }
        .padding(4)
        .frame(width: 110, height: 110)
    }
    
    private var timerDurationView: some View {
        Text("\(timer.duration.asHoursMinutesSeconds)")
            .font(.system(size: 22, weight: .none, design: .rounded))
            .frame(width: 110, height: 110)
    }
}
