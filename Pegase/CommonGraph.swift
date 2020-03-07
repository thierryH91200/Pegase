//
//  CommonGraph.swift
//  Pegase
//
//  Created by thierry hentic on 07/03/2020.
//  Copyright © 2020 thierry hentic. All rights reserved.
//

import Cocoa

class CommonGraph: NSViewController {
    
    var listeOperations = [EntityOperations]()
    var firstDate: TimeInterval = 0.0
    var lastDate: TimeInterval = 0.0
    
    var sliderViewController: SliderViewHorizontalController?



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func updateAccount () {
        listeOperations = ListeOperations.shared.entities
        if listeOperations.count == 0 || ListeOperations.shared.ascending == false {
            listeOperations = ListeOperations.shared.getAll()
        }
        if listeOperations.count > 0 {
            
            firstDate = (listeOperations.first?.dateOperation?.timeIntervalSince1970)!
            lastDate = (listeOperations.last?.dateOperation?.timeIntervalSince1970)!
            
            sliderViewController?.initData(firstDate: firstDate, lastDate: lastDate)
            sliderViewController?.mySlider.isEnabled = true
            
        } else {
            sliderViewController?.mySlider.isEnabled = false
        }
        
    }

    
}
