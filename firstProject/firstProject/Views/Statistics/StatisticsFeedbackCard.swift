//
//  StatisticsFeedbackCard.swift
//  firstProject
//
//  Created by 임사랑 on 11/18/26.
//

import SwiftUI
 
 struct StatisticsFeedbackCard: View {
     let emotion: Emotion
     let title: String
     let message: String
 
     private enum Metric {
         static let spacing: CGFloat = 12
         static let textSpacing: CGFloat = 2
         static let padding: CGFloat = 16
     }

     @Environment(\.dynamicTypeSize) private var typeSize
     @ScaledMetric(relativeTo: .subheadline) private var auraSize = 40

     private var layout: AnyLayout {
         typeSize.isAccessibilitySize
             ? AnyLayout(VStackLayout(alignment: .leading, spacing: Metric.spacing))
             : AnyLayout(HStackLayout(spacing: Metric.spacing))
     }

     var body: some View {
         layout {
             EmotionAuraView(emotion: emotion, size: auraSize)
 
             VStack(alignment: .leading, spacing: Metric.textSpacing) {
                 Text(title)
                     .font(.footnote)
                     .foregroundStyle(FeeloColor.textSecondary)
                 Text(message)
                     .font(.subheadline)
                     .foregroundStyle(FeeloColor.textPrimary)
                     .fixedSize(horizontal: false, vertical: true)
             }
             .frame(maxWidth: .infinity, alignment: .leading)
         }
         .padding(Metric.padding)
         .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.summary))
         .accessibilityElement(children: .combine)
     }
 }
 
#Preview("주간") {
     ScrollView {
         VStack(spacing: 12) {
             ForEach(Emotion.allCases) { emotion in
                 if let message = emotion.weeklyFeedback {
                     StatisticsFeedbackCard(emotion: emotion, title: "이번 주의 한마디", message: message)
                 }
             }
         }
         .padding(16)
     }
     .background(FeeloColor.bgApp)
 }
 
 #Preview("월간") {
     ScrollView {
         VStack(spacing: 12) {
             ForEach(Emotion.allCases) { emotion in
                 if let message = emotion.monthlyFeedback {
                     StatisticsFeedbackCard(emotion: emotion, title: "이번 달의 한마디", message: message)
                 }
             }
         }
         .padding(16)
     }
     .background(FeeloColor.bgApp)
 }

