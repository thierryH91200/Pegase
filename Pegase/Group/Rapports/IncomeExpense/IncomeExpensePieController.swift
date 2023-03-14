//
//  IncomeExpensePieController.swift
//  Pegase
//
//  Created by thierry hentic on 30/03/2020.
//  Copyright © 2020 thierry hentic. All rights reserved.
//

import AppKit
import Charts

class IncomeExpensePieController: CommonGraph {
    
    public var delegate: FilterDelegate?
    
    @IBOutlet var chartView: PieChartView!
    @IBOutlet var chartView2: PieChartView!
    @IBOutlet weak var splitView: NSSplitView!
    
    var startDate = Date()
    var endDate = Date()
    
    let formatterPrice: NumberFormatter = {
        let _formatter = NumberFormatter()
        _formatter.locale = Locale.current
        _formatter.numberStyle = .currency
        _formatter.maximumFractionDigits = 0
        return _formatter
    }()
    
    var resultArrayExpense = [DataGraph]()
    var resultArrayIncome = [DataGraph]()
    
    override public func viewWillAppear()
    {
        super.viewWillAppear()
        if NSApplication.shared.isCharts == true {
            DispatchQueue.main.async(execute: {() -> Void in
                self.chartView.spin(duration: 1, fromAngle: 0, toAngle: 360.0)
                self.chartView2.spin(duration: 1, fromAngle: 0, toAngle: 360.0)
            })
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        NotificationCenter.receive( self, selector: #selector(updateChangeAccount), name: .updateAccount)
        
        if sliderViewController == nil {
            sliderViewController = SliderViewHorizontalController(nibName: "SliderViewHorizontalController", bundle: nil)
            sliderViewController?.delegate = self
        }
        
        splitView.addSubview((sliderViewController?.view)!, positioned: .above, relativeTo: splitView)
        
        initChart()
        updateAccount ()
    }
    
    @objc func updateChangeAccount(_ note: Notification) {
        
        updateAccount ()
        setDataHorizontal()
    }
    
    func initChart() {
        
        guard NSApplication.shared.isCharts == true else { return }
        
        // MARK: - Chart View Income
        chartView.delegate = self
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let attribut: [ NSAttributedString.Key: Any] =
        [ .font            : NSFont(name  : "HelveticaNeue-Light", size : 15.0)!,
          .foregroundColor : NSColor.textColor,
          .paragraphStyle  : paragraphStyle]
        
        // MARK: - Chart View Expense
        var centerText = NSMutableAttributedString(string: Localizations.General.Income)
        centerText.setAttributes(attribut, range: NSRange(location: 0, length: centerText.length))
        chartView.centerAttributedText = centerText
        
        chartView.chartDescription.enabled = false
        chartView.noDataText = Localizations.Chart.No_chart_Data_Available
        chartView.holeColor = .windowBackgroundColor
        
        // MARK: legend
        let legend = chartView.legend
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.font = NSFont(name: "HelveticaNeue-Light", size: CGFloat(14.0))!
        legend.textColor = .labelColor
        
        // MARK: - Chart View Expenses
        chartView2.delegate = self
        
        centerText = NSMutableAttributedString(string: Localizations.General.Expenses)
        centerText.setAttributes(attribut, range: NSRange(location: 0, length: centerText.length))
        
        chartView2.centerAttributedText = centerText
        chartView2.chartDescription.enabled = false
        chartView2.noDataText = Localizations.Chart.No_chart_Data_Available
        chartView2.holeColor = .windowBackgroundColor
        
        // MARK: legend
        let legend2 = chartView2.legend
        legend2.horizontalAlignment = .left
        legend2.verticalAlignment = .top
        legend2.orientation = .vertical
        legend2.font = NSFont(name: "HelveticaNeue-Light", size: CGFloat(14.0))!
        legend2.textColor = .labelColor
    }
    
    func updateChartData()
    {
        let context = mainObjectContext
        
        var dataArrayExpense = [DataGraph]()
        var dataArrayIncome = [DataGraph]()
        
        (startDate, endDate) = (sliderViewController?.calcStartEndDate())!
        
        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let p2 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p3 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [p1, p2, p3])
        
        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
        
        do {
            listTransactions = try context!.fetch(fetchRequest)
            
        } catch {
            print("Error fetching data from CoreData")
        }
        
        for listTransaction in listTransactions {
            
            let amount = listTransaction.amount
            let nameModePaiement   = listTransaction.paymentMode?.name
            let color = listTransaction.paymentMode?.color as! NSColor
            
            if amount < 0 {
                let data  = DataGraph(name : nameModePaiement!, value : amount, color : color)
                dataArrayExpense.append(data)
            } else {
                let data  = DataGraph(name : nameModePaiement!, value : amount, color : color)
                dataArrayIncome.append(data)
            }
        }
        
        self.resultArrayExpense.removeAll()
        let allKeys = Set<String>(dataArrayExpense.map { $0.name })
        for key in allKeys {
            let data = dataArrayExpense.filter({ $0.name == key })
            let sum = data.map({ $0.value }).reduce(0, +)
            self.resultArrayExpense.append(DataGraph(name: key, value: sum, color: data[0].color))
        }
        self.resultArrayExpense = self.resultArrayExpense.sorted(by: { $0.name < $1.name })
        
        resultArrayIncome.removeAll()
        let allKeysR = Set<String>(dataArrayIncome.map { $0.name })
        for key in allKeysR {
            let data = dataArrayIncome.filter({ $0.name == key })
            let sum = data.map({ $0.value }).reduce(0, +)
            resultArrayIncome.append(DataGraph(name: key, value: sum, color: data[0].color))
        }
        resultArrayIncome = resultArrayIncome.sorted(by: { $0.name < $1.name })
    }
    
    // MARK: setDataExpenses
    func setDataExpenses()
    {
        guard NSApplication.shared.isCharts == true else { return }
        
        guard resultArrayExpense.isEmpty == false  else {
            chartView.data = nil
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            return }
        
        // MARK: PieChartDataEntry
        var colors : [NSColor] = []
        var entries = [PieChartDataEntry]()
        for result in resultArrayExpense {
            entries.append(PieChartDataEntry(value: abs(result.value), label: result.name))
            colors.append(result.color)
        }
        
        // MARK: PieChartDataSet
        let dataSet = PieChartDataSet(entries: entries, label: "Expenses")
        dataSet.sliceSpace = 2.0
        dataSet.colors = colors
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.4
        dataSet.valueLinePart2Length = 1.0
        dataSet.xValuePosition = .outsideSlice
        dataSet.yValuePosition = .outsideSlice
        dataSet.valueLineColor = .labelColor
        dataSet.entryLabelColor = .labelColor
        
        // MARK: PieChartData
        let data = PieChartData(dataSet: dataSet)
        
        data.setValueFont(NSFont(name: "HelveticaNeue-Light", size: CGFloat(11.0))!)
        data.setValueTextColor(NSColor.labelColor)
        
        chartView2.data = data
        data.setValueFormatter(DefaultValueFormatter(formatter: formatterPrice))
    }
    
    // MARK: setDataIncomes
    private func setDataIncomes()
    {
        guard NSApplication.shared.isCharts == true else { return }
        
        guard resultArrayIncome.isEmpty == false else {
            chartView2.data = nil
            chartView2.data?.notifyDataChanged()
            chartView2.notifyDataSetChanged()
            return }
        
        // MARK: PieChartDataEntry
        var colors : [NSColor] = []
        var entries : [PieChartDataEntry] = []
        for result in self.resultArrayIncome {
            entries.append(PieChartDataEntry(value: abs(result.value), label: result.name))
            colors.append(result.color)
        }
        
        // MARK: PieChartDataSet
        let dataSet = PieChartDataSet(entries: entries, label: "Incomes")
        dataSet.sliceSpace = 2.0
        dataSet.colors = colors
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.2
        dataSet.valueLinePart2Length = 1.0
        dataSet.xValuePosition = .outsideSlice
        dataSet.yValuePosition = .outsideSlice
        dataSet.valueLineColor = .labelColor
        dataSet.entryLabelColor = .labelColor
        
        // MARK: PieChartData
        let data = PieChartData(dataSet: dataSet)
        
        data.setValueFont(NSFont(name: "HelveticaNeue-Light", size: CGFloat(11.0))!)
        data.setValueTextColor(NSColor.labelColor)
        
        chartView.data = data
        data.setValueFormatter(DefaultValueFormatter(formatter: formatterPrice))
    }
}

extension IncomeExpensePieController: ChartViewDelegate {
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        guard NSApplication.shared.isCharts == true else { return }
        
        var p5 = NSPredicate()
        if chartView.identifier?.rawValue == "Depense" {
            p5 = NSPredicate(format: "amount < 0")
        } else {
            p5 = NSPredicate(format: "amount >= 0")
        }
        
        let label = (entry as! PieChartDataEntry).label!
        
        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let p2 = NSPredicate(format: "paymentMode.name == %@", label)
        let p3 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p4 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [p1, p2, p3, p4, p5])
        
        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: false)]
        
        self.delegate?.applyFilter( fetchRequest)
    }
}

extension IncomeExpensePieController: SliderHorizontalDelegate {
    
    func setDataHorizontal() {
        self.updateChartData()
        self.setDataExpenses()
        self.setDataIncomes()
    }
}



