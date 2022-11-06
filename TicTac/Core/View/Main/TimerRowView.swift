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
        HStack(spacing: 8) {
            titleSection
            
            timerSection
            
            buttonsSection
        }
        .background(Color(uiColor: .systemBackground))
    }
}

struct TimerRowView_Previews: PreviewProvider {
    static var previews: some View {
        TimerRowView(timer: dev.timer)
            .previewLayout(.sizeThatFits)
            .frame(height: 110)
    }
}

extension TimerRowView {
    
    private var titleSection: some View {
        VStack(spacing: 0) {
            if let category = timer.category {
                HStack {
                    Circle()
                        .frame(width: 8, height: 8)
                    
                    Text(category.title)
                        .font(.system(size: 14, weight: .none, design: .default))
                        .foregroundColor(category.color)
                        .lineLimit(2)
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundColor(category.color)
            }
            
            
            Text(timer.title)
                .font(.system(size: 20, weight: .none, design: .default))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }
    
    @ViewBuilder private var timerSection: some View {
        if timer.isRunning {
            progressCircleView
        } else {
            timerDurationView
        }
    }
    
    @ViewBuilder private var buttonsSection: some View {
        VStack(spacing: 4) {
            if timer.isRunning {
                CircleButtonView(style: .reset)
                    .onTapGesture {
                        withAnimation {
                            tm.stopTimer(timer)
                        }
                    }
            }
            
            CircleButtonView(style: timer.isRunning != timer.isPaused ? .pause : .start)
                .onTapGesture {
                    withAnimation {
                        timer.isRunning ?
                        (timer.isPaused ?
                         tm.resumeTimer(timer) :
                            tm.pauseTimer(timer))
                        : tm.startTimer(timer)
                    }
                }
        }
    }
        
    private var progressCircleView: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.25), lineWidth: 4)
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
        Text("\(timer.duration.asHoursMinutesSecondsShorted)")
            .font(.system(size: 22, weight: .none, design: .default))
            .frame(width: 110, height: 45)
            .background(.gray.opacity(0.25), in: Capsule())
            .frame(width: 110, height: 110)
            .buttonStyle(.borderedProminent)
    }
}
