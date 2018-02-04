//
//  FXPieChart.swift
//  Felix
//
//  Created by Christine Sun on 04/02/2018.
//  Copyright © 2018 Felix Inc. All rights reserved.
//

import UIKit
import CorePlot

class FXPieChart: CPTGraphHostingView {
    
    private var m_parent: CPTPieChartDataSource!
    
    init(frame: CGRect, parent: CPTPieChartDataSource) {
        m_parent = parent
        super.init(frame: frame)
        initPlot()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initPlot()
    }
    
    func initPlot() {
        // Configure Host View
        self.allowPinchScaling = false
        
        // Configure Graph
        let graph = CPTXYGraph(frame: self.bounds)
        self.hostedGraph = graph
        graph.paddingLeft = 0.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0
        graph.paddingBottom = 0.0
        graph.axisSet = nil
        
        let textStyle: CPTMutableTextStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor.black()
        textStyle.fontName = "Poppins-Regular"
        textStyle.fontSize = 16.0
        textStyle.textAlignment = .center
        
        // Configure Chart
        let pieChart = CPTPieChart()
        pieChart.dataSource = m_parent
        pieChart.pieRadius = (min(self.bounds.size.width, self.bounds.size.height) * 0.7) / 2
        //pieChart.identifier = NSString(string: graph.title!)
        pieChart.startAngle = CGFloat.pi / 4
        pieChart.sliceDirection = .clockwise
        pieChart.labelOffset = -0.6 * pieChart.pieRadius
        
        // 3 - Configure border style
        let borderStyle = CPTMutableLineStyle()
        borderStyle.lineColor = CPTColor.white()
        borderStyle.lineWidth = 2.0
        pieChart.borderLineStyle = borderStyle
        
        // 4 - Configure text style
        let pieTextStyle = CPTMutableTextStyle()
        pieTextStyle.color = CPTColor.white()
        pieTextStyle.textAlignment = .center
        pieChart.labelTextStyle = pieTextStyle
        
        // 5 - Add chart to graph
        graph.add(pieChart)
        
        // Configure Legened
        let theLegend = CPTLegend(graph: graph)
        
        // 3 - Configure legend
        theLegend.numberOfColumns = 1
        theLegend.fill = CPTFill(color: CPTColor.white())
        let legendTextStyle = CPTMutableTextStyle()
        legendTextStyle.fontSize = 11
        theLegend.textStyle = legendTextStyle
        
        // 4 - Add legend to graph
        graph.legend = theLegend
        if self.bounds.width > self.bounds.height {
            graph.legendAnchor = .right
            graph.legendDisplacement = CGPoint(x: -20, y: 0.0)
            
        } else {
            graph.legendAnchor = .bottomRight
            graph.legendDisplacement = CGPoint(x: -8.0, y: 8.0)
        }
    }
    
}
