//
//  StatsViewController.swift
//  Felix
//
//  Created by Christine Sun on 04/02/2018.
//  Copyright © 2018 Felix Inc. All rights reserved.
//

import UIKit
import CorePlot

enum StatEmotion: Int {
    case HAPPY = 0
    case SAD
    case ANGRY
    case ANXIOUS
}

class StatsViewController: UIViewController {
    
    // Properties - Variables (Data Members)
    
    @IBOutlet var scrollView: UIScrollView!
    
    private let sectionInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    private var m_moods: [CGFloat] = [
        0.9, 0.1, 0.4, 0.3, 0.6, 0.3, 0.2,
        0.8, 0.45, 0.234, 0.3, 0.9, 0.0, 0.9,
        0.8, 1, 0.1, 0.5, 0.34, 0.67, 0.3,
        0.6, 0.6, 0.55, 0.3, 0.9, 0.2, 0.3
    ]
    
    // Methods - Functions (Member functions)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let padding: CGFloat = 15
        let graphSide: CGFloat = 300
        let labelHeight: CGFloat = 50
        let letterHeight: CGFloat = 20
        let mapHeight: CGFloat = 200
        let summaryHeight: CGFloat = 100
        
        let scrollViewHeight = 7.25*padding + graphSide + 3*labelHeight + letterHeight + mapHeight + summaryHeight
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: scrollViewHeight)
        
        // Title Label
        
        var yOrigin = padding
        let screenWidth = self.view.frame.width
        
        let titleLabel0 = UILabel()
        titleLabel0.font = UIFont(name: "Poppins-Bold", size: 18)
        titleLabel0.text = "Daily Sentiment"
        titleLabel0.sizeToFit()
        titleLabel0.frame = CGRect(x: screenWidth/2 - titleLabel0.frame.width/2, y: yOrigin, width: titleLabel0.frame.width, height: labelHeight)
        
        scrollView.addSubview(titleLabel0)
        yOrigin += labelHeight
        
        // Pie Chart
        
        let pieWidth = graphSide + 100
        let pieChart = FXPieChart(frame: CGRect(x: screenWidth/2 - pieWidth/2, y: yOrigin, width: pieWidth, height: graphSide), parent: self)
        
        scrollView.addSubview(pieChart)
        yOrigin += graphSide
        
        // Title Label
        
        let titleLabel1 = UILabel()
        titleLabel1.font = UIFont(name: "Poppins-Bold", size: 18)
        titleLabel1.text = "Weekly Moods"
        titleLabel1.sizeToFit()
        titleLabel1.frame = CGRect(x: screenWidth/2 - titleLabel1.frame.width/2, y: yOrigin, width: titleLabel1.frame.width, height: labelHeight)
        
        scrollView.addSubview(titleLabel1)
        yOrigin += labelHeight + padding
        
        // Label
        
        var letterX = padding + (self.view.frame.width - 2*padding - 8*sectionInsets.left) / 14
        for i in 0 ... 6 {
            let label = UILabel()
            label.font = UIFont(name: "Poppins-Bold", size: 12)
            switch i {
            case 0:
                label.text = "S"
            case 1:
                label.text = "M"
            case 2:
                label.text = "T"
            case 3:
                label.text = "W"
            case 4:
                label.text = "T"
            case 5:
                label.text = "F"
            case 6:
                label.text = "S"
            default:
                break
            }
            label.sizeToFit()
            label.frame = CGRect(x: letterX, y: yOrigin, width: label.frame.width, height: label.frame.height)
            
            scrollView.addSubview(label)
            letterX += (self.view.frame.width - 2*padding) / 7
        }
        
        yOrigin += letterHeight + padding/4
        
        // Heat map
        
        let heatCollection = UICollectionView(frame: CGRect(x: padding, y: yOrigin, width: self.view.frame.width - 2*padding, height: mapHeight), collectionViewLayout: UICollectionViewFlowLayout())
        heatCollection.register(HeatMapCell.self, forCellWithReuseIdentifier: "HeatMapCell")
        heatCollection.backgroundColor = .white
        heatCollection.delegate = self
        heatCollection.dataSource = self
        
        scrollView.addSubview(heatCollection)
        yOrigin += heatCollection.frame.height + padding*2
        
        // Title Label
        
        let titleLabel2 = UILabel()
        titleLabel2.font = UIFont(name: "Poppins-Bold", size: 18)
        titleLabel2.text = "Comments"
        titleLabel2.sizeToFit()
        titleLabel2.frame = CGRect(x: screenWidth/2 - titleLabel2.frame.width/2, y: yOrigin, width: titleLabel2.frame.width, height: labelHeight)
        
        scrollView.addSubview(titleLabel2)
        yOrigin += labelHeight + padding
        
        // Summary
        
        let summaryTextView = UITextView(frame: CGRect(x: screenWidth/2 - heatCollection.frame.width/2, y: yOrigin, width: heatCollection.frame.width, height: summaryHeight))
        summaryTextView.backgroundColor = .clear
        summaryTextView.font = UIFont(name: "Poppins-Regular", size: 16)
        summaryTextView.text = " \"Keep your chin up! Tomorrow will be a better day :) I'll always be here if you want to talk!\""
        
        scrollView.addSubview(summaryTextView)
        
    }

}

extension StatsViewController: CPTPieChartDataSource {
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return 4
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        return idx+1
    }
    
    func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
        
        switch idx {
        case 0:
            let layer = CPTTextLayer(text: "Happy")
            layer.textStyle = plot.labelTextStyle
            return layer
        case 1:
            let layer = CPTTextLayer(text: "Sad")
            layer.textStyle = plot.labelTextStyle
            return layer
        case 2:
            let layer = CPTTextLayer(text: "Angry")
            layer.textStyle = plot.labelTextStyle
            return layer
        case 3:
            let layer = CPTTextLayer(text: "Anxious")
            layer.textStyle = plot.labelTextStyle
            return layer
        default:
            let layer = CPTTextLayer(text: "Happy")
            layer.textStyle = plot.labelTextStyle
            return layer
        }
        
    }
    
    func sliceFill(for pieChart: CPTPieChart, record idx: UInt) -> CPTFill? {
        switch idx {
            // happy
        case 0:   return CPTFill(color: CPTColor(componentRed:0.22, green:0.90, blue:0.22, alpha:1.00))
            // sad
        case 1:   return CPTFill(color: CPTColor(componentRed:0.22, green:0.22, blue:0.90, alpha:1.00))
            // anxious
        case 2:   return CPTFill(color: CPTColor(componentRed:0.92, green:0.28, blue:0.25, alpha:1.00))
            // angry
        case 3:   return CPTFill(color: CPTColor(componentRed:0.92, green:0.92, blue:0.49, alpha:1.00))
            
        default:  return nil
        }
    }
    
    func legendTitle(for pieChart: CPTPieChart, record idx: UInt) -> String? {
        switch idx {
        case 0:
            return "Happy"
        case 1:
            return "Sad"
        case 2:
            return "Angry"
        case 3:
            return "Anxious"
        default:
            return "Happy"
        }
    }
    
}

extension StatsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = 7
        let width = collectionView.frame.width - sectionInsets.left*CGFloat(itemsPerRow+1)
        let side = width / CGFloat(itemsPerRow)
        
        return CGSize(width: side, height: side)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}

extension StatsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeatMapCell", for: indexPath) as? HeatMapCell else {
            fatalError("dequeued cell is not of type HeatMapCell")
        }
        
        let itemsPerRow = 7
        let width = collectionView.frame.width - sectionInsets.left*CGFloat(itemsPerRow+1)
        let side = width / CGFloat(itemsPerRow)
        
        cell.configure(emotion: StatEmotion(rawValue: indexPath.row/7)!, value: m_moods[indexPath.row], side: side)
        
        return cell
        
    }
    
}
