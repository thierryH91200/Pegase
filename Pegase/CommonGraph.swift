//
//  CommonGraph.swift
//  Pegase
//
//  Created by thierry hentic on 07/03/2020.
//  Copyright © 2020 thierry hentic. All rights reserved.
//

import Cocoa
import Charts

class CommonGraph: NSViewController {
    
    var listeOperations = [EntityOperations]()
    var firstDate: TimeInterval = 0.0
    var lastDate: TimeInterval = 0.0
    
    var sliderViewController: SliderViewHorizontalController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func initializeLegend(_ legend: Legend) {
        legend.horizontalAlignment           = .left
        legend.verticalAlignment             = .top
        legend.orientation                   = .vertical
        legend.drawInside                    = true
        legend.form                          = .square
        legend.formSize                      = 9.0
        legend.font                          = NSFont.systemFont(ofSize: CGFloat(11.0))
        legend.xEntrySpace                   = 4.0
    }

    
    func updateAccount () {
        listeOperations = ListeOperations.shared.entities
        if listeOperations.isEmpty == true || ListeOperations.shared.ascending == false {
            listeOperations = ListeOperations.shared.getAllDatas()
        }
        if listeOperations.isEmpty == false {
            
            firstDate = (listeOperations.first?.dateOperation?.timeIntervalSince1970)!
            lastDate = (listeOperations.last?.dateOperation?.timeIntervalSince1970)!
            
            sliderViewController?.initData(firstDate: firstDate, lastDate: lastDate)
            sliderViewController?.mySlider.isEnabled = true
            
        } else {
            sliderViewController?.mySlider.isEnabled = false
        }
        
    }

    
}
