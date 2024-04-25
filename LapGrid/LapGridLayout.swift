//
//  LapGridLayout.swift
//  LapGrid
//
//  Created by Sergei Laptev on 25/04/2024.
//

import Foundation
import SwiftUI

struct LapGrid: Layout {
    var maxColumns = 2
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) -> CGSize {
        return CGSize(width: proposal.width ?? 0, height: cache.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) {
        guard !subviews.isEmpty else { return }
        
        var spanIndex = 0
        var usedColumns = maxColumns
        var minX = bounds.minX
        var minY = bounds.minY
        var currentLineY: CGFloat = 0
        var totalY: CGFloat = 0
        
        for index in subviews.indices {
            let subviewSpan = cache.spans[spanIndex]
            let minSubviewWidth = (bounds.width - spacing * (CGFloat(maxColumns) - 1)) / CGFloat(maxColumns)
            let subviewWidth = minSubviewWidth * CGFloat(subviewSpan) + spacing * (CGFloat(subviewSpan) - 1)
            let subviewHeight = subviews[index].sizeThatFits(.unspecified).height
            
            if subviewSpan > maxColumns - usedColumns {
                //Place in a new row
                minY = bounds.minY + totalY
                subviews[index].place(
                    at: .init(x: bounds.minX, y: minY),
                    anchor: .topLeading,
                    proposal: .init(width: subviewWidth, height: subviewHeight)
                )
                
                minX = subviewWidth + spacing
                currentLineY = subviewHeight
                totalY = totalY + currentLineY + spacing
                usedColumns = subviewSpan
                spanIndex += 1
            } else {
                //Place in the same row
                subviews[index].place(
                    at: .init(x: minX, y: minY),
                    anchor: .topLeading,
                    proposal: .init(width: subviewWidth, height: subviewHeight)
                )
                
                minX += subviewWidth + spacing
                if subviewHeight > currentLineY {
                    totalY = totalY - currentLineY + subviewHeight
                }
                usedColumns += subviewSpan
                spanIndex += 1
            }
        }
    }
    
    struct CacheData {
        let spans: [Int]
        let height: CGFloat
    }

    func makeCache(subviews: Subviews) -> CacheData {
        let spans = subviews.map { $0[Span.self] }
        let height = maxHeight(subviews: subviews, spans: spans)
        
        return Cache(spans: spans, height: height)
    }
    
    private func maxHeight(subviews: Subviews, spans: [Int]) -> CGFloat {
        guard !subviews.isEmpty else { return 0 }
        
        var spanIndex = 0
        var usedColumns = maxColumns
        var currentLineY: CGFloat = 0
        var totalY: CGFloat = -spacing
        
        for index in subviews.indices {
            let subviewHeight = subviews[index].sizeThatFits(.unspecified).height
            
            if spans[spanIndex] > maxColumns - usedColumns {
                //Place in a new row
                currentLineY = subviewHeight
                totalY = totalY + currentLineY + spacing
                usedColumns = spans[spanIndex]
                spanIndex += 1
            } else {
                //Place in the same row
                if subviewHeight > currentLineY {
                    totalY = totalY - currentLineY + subviewHeight
                }
                usedColumns += spans[spanIndex]
                spanIndex += 1
            }
        }
        
        return totalY
    }
}

private struct Span: LayoutValueKey {
    static let defaultValue: Int = 1
}

extension View {
    func span(_ value: Int) -> some View {
        layoutValue(key: Span.self, value: value)
    }
}

