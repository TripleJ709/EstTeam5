//
//  EmotionBarChart.swift
//  firstProject
//
//  Created by 임사랑 on 11/18/26.
//

import Foundation
import SwiftUI
  
  struct EmotionBarChart: View {
      let items: [(emotion: Emotion, count: Int)]
      let highlighted: Emotion?
  
      private enum Metric {
          static let maxBarHeight: CGFloat = 100
          static let minBarHeight: CGFloat = 4
          static let barWidth: CGFloat = 28
          static let columnSpacing: CGFloat = 5
          static let labelSpacing: CGFloat = 4
          static let padding: CGFloat = 16
          static let barCorner: CGFloat = 8
          static let emptyBarCorner: CGFloat = 4
          static let emptyOpacity = 0.4
      }
  
      private var maxCount: Int {
          max(items.map(\.count).max() ?? 0, 1)
      }
  
      var body: some View {
          HStack(alignment: .bottom, spacing: Metric.columnSpacing) {
              ForEach(items, id: \.emotion) { item in
                  column(emotion: item.emotion, count: item.count)
              }
          }
          .padding(Metric.padding)
          .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.chart))
          .accessibilityElement(children: .ignore)
          .accessibilityLabel("감정 분포")
          .accessibilityValue(accessibilityValue)
      }
  
      private func column(emotion: Emotion, count: Int) -> some View {
          let isHighlighted = emotion == highlighted
          let isEmpty = count == 0
  
          return VStack(spacing: Metric.labelSpacing) {
              Text("\(count)")
                  .font(.footnote.weight(isHighlighted ? .medium : .regular))
                  .foregroundStyle(isEmpty ? FeeloColor.textSecondary : FeeloColor.textPrimary)
  
              bar(emotion: emotion, count: count)
  
              Text(emotion.displayName)
                  .font(.footnote.weight(isHighlighted ? .medium : .regular))
                  .foregroundStyle(isHighlighted ? FeeloColor.textPrimary : FeeloColor.textSecondary)
                  .lineLimit(1)
                  .minimumScaleFactor(0.8)
          }
          .frame(maxWidth: .infinity)
          .opacity(isEmpty ? Metric.emptyOpacity : 1)
      }
  
      private func bar(emotion: Emotion, count: Int) -> some View {
          let corner = count == 0 ? Metric.emptyBarCorner : Metric.barCorner
          return UnevenRoundedRectangle(topLeadingRadius: corner, topTrailingRadius: corner)
              .fill(LinearGradient(colors: [emotion.auraStart, emotion.auraEnd], startPoint: .top, endPoint: .bottom))
              .frame(width: Metric.barWidth, height: barHeight(for: count))
      }
  
      private func barHeight(for count: Int) -> CGFloat {
          let ratio = CGFloat(count) / CGFloat(maxCount)
          return Metric.minBarHeight + (Metric.maxBarHeight - Metric.minBarHeight) * ratio
      }
  
      private var accessibilityValue: String {
          let recorded = items.filter { $0.count > 0 }
          guard !recorded.isEmpty else { return "기록 없음" }
          return recorded.map { "\($0.emotion.displayName) \($0.count)회" }.joined(separator: ", ")
      }
  }
  
  #Preview {
      EmotionBarChart(
          items: [(.joy, 1), (.achievement, 2), (.stable, 1), (.angry, 0), (.fear, 0), (.sad, 1), (.exhausted, 0)],
          highlighted: .achievement
      )
      .padding(16)
      .background(FeeloColor.bgApp)
  }
