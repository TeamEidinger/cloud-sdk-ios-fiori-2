//
//  FUIChartDataDirect.swift
//  Micro Charts
//
//  Created by Xu, Sheng on 2/5/20.
//  Copyright © 2020 sstadelman. All rights reserved.
//

import Foundation
import SwiftUI

public struct ChartLabelAttribute {
    /// Size of the label font in points.
    var fontSize: Double
    
    /// fontWeight is currently fixed at `regular`
    var fontWeight: Double
    
    /// Text color for the label.
    var color: Color
    
    /// True when the associated label(s) should be hidden.
    var isHidden: Bool

    /// Specifies how far from the axis labels should be rendered.
    var offset: Double
}

public struct ChartLineAttribute {

    /// Width of the line in points.
    var width: Double

    /// Color of the line.
    var color: UIColor

    /// Dash pattern for the line. Specifies the length of painted segments, and the gap between them.
    var dashPattern: (length: Int, gap: Int)?

    /// Indicates whether the lines should be displayed or not.
    var isHidden: Bool
}

public struct ChartBarAtrribute {
    /// Color of the line.
    var color: UIColor
    
    /// todo: border line/color
}

public struct ChartPlotItemAtrribute {
    var bar: ChartBarAtrribute
    var label: ChartLabelAttribute
}

public struct ChartAxisAttribute {
    
    /// Properties of the axis title label.
    var titleLabel: ChartLabelAttribute
    
    /// Properties for the axis gridline labels.
    var labels: ChartLabelAttribute
    
    /// Properties for the axis gridlines.
    var gridlines: ChartLineAttribute
    
    /**
    Properties for the axis baseline, which is typically usually 0.
    - Only numeric axes have a baseline.
    */
    var baseline: ChartLineAttribute
}

public class ChartModel: ObservableObject, Identifiable {

    /// data
    @Published public var chartType: ChartType
    /// seires -> category -> dimension
    @Published public var data: [[[Double]]]
    @Published public var titlesForCategory: [[String]]?
    @Published public var titlesForAxis: [String]?
    @Published public var labelsForDimension: [[[String]]]?
    
    /// to be removed
    @Published public var colorsForCategory: [[Color]]?
    
    /// styles
    @Published public var plotAttributes:[[ChartPlotItemAtrribute]]?
    @Published public var axesAttributes:[[ChartAxisAttribute]]?
    @Published public var numOfGridLines: [Int] = [3,3]
    
    // for pinch & zoom
    @Published var displayStartIndex:Int = 0
    @Published var displayEndIndex:Int = 0
    @Published var lastDisplayStartIndex = 0
    @Published var lastDisplayEndIndex:Int = 0
    
    var range: [ClosedRange<Double>]?
    
    public let id = UUID()
    
    public init(chartType: ChartType, data: [[[Double]]], titlesForCategory: [[String]]? = nil, colorsForCategory: [[Color]]? = nil, titlesForAxis: [String]? = nil, labelsForDimension: [[[String]]]? = nil) {
        self.chartType = chartType
        self.data = data
        self.titlesForCategory = titlesForCategory
        self.colorsForCategory = colorsForCategory
        self.titlesForAxis = titlesForAxis
        self.labelsForDimension = labelsForDimension
        
        if let series = data.first, let category = series.first {
            self.displayEndIndex = max(category.count - 1, 0)
            self.lastDisplayEndIndex = self.displayEndIndex
        }
        
        // check if there is data
        if let _ = data.first?.first?.first {
            let range: ClosedRange<Double> = {
                let allValues: [Double] = data.first!.map({ $0.first! })

                var min = allValues.min() ?? 0
                if min > 0 {
                    min = 0
                }
                let max = allValues.max() ?? 1

                //print("ACT ALL VALUES: \(allValues)")
                guard min != max else { return 0...max }
                return min...max
            }()
            
            self.range = [range]
        }
    }
    
    func normalizedValue(for value: Double, seriesIndex: Int) -> Double {
        if let range = range {
            return abs(value) / (range[seriesIndex].upperBound - range[seriesIndex].lowerBound)
        }
        else {
            return 0
        }
    }
}


extension ChartModel {
    func colorAt(seriesIndex: Int, categoryIndex: Int) -> Color {
        guard let tmp = colorsForCategory, seriesIndex < tmp.count else {
            return Color.black
        }
            
        let colors = tmp[seriesIndex]
        if categoryIndex >= colors.count {
            return colors.last!
        }
        else {
            return colors[categoryIndex]
        }
    }
    
    func labelAt(seriesIndex: Int, categoryIndex: Int, dimensionIndex: Int) -> String? {
        guard let tmp = labelsForDimension, seriesIndex < tmp.count, categoryIndex < tmp[seriesIndex].count, dimensionIndex < tmp[seriesIndex][categoryIndex].count else {
            return nil
        }
        
        return tmp[seriesIndex][categoryIndex][dimensionIndex]
    }
    
    func titleAt(seriesIndex: Int, categoryIndex: Int) -> String? {
        guard let tmp = titlesForCategory, seriesIndex < tmp.count, categoryIndex < tmp[seriesIndex].count else {
            return nil
        }
        
        return tmp[seriesIndex][categoryIndex]
    }
    
    func dataItemsIn(seriesIndex: Int, dimensionIndex: Int = 0) -> [MicroChartDataItem] {
        var res: [MicroChartDataItem] = []
        
        guard seriesIndex < data.count, data[seriesIndex].count > 0 else {
        //if seriesIndex > data.count {
            return res
        }
        
        for i in 0 ..< data[seriesIndex].count {
            if data[seriesIndex][i].count > dimensionIndex {
                let value = data[seriesIndex][i][dimensionIndex]
                
                let item = MicroChartDataItem(value: CGFloat(value),
                                              displayValue: labelAt(seriesIndex: seriesIndex, categoryIndex: i, dimensionIndex: dimensionIndex),
                                              label: titleAt(seriesIndex: seriesIndex, categoryIndex: i),
                                              color: colorAt(seriesIndex: seriesIndex, categoryIndex: i))
                res.append(item)
            }
        }
        
        return res
    }
}