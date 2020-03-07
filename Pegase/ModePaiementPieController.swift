import AppKit
import Charts

final class ModePaiementPieController: CommonGraph {
    
    public weak var delegate: FilterDelegate?
    
    @IBOutlet var chartView: PieChartView!
    @IBOutlet var chartView2: PieChartView!
    @IBOutlet weak var splitView: NSSplitView!
    
//    var sliderViewController: SliderViewHorizontalController?
    
//    var listeOperations = [EntityOperations]()
//    var firstDate: TimeInterval = 0.0
//    var lastDate: TimeInterval = 0.0

    var startDate = Date()
    var endDate = Date()
    
    let formatterPrice: NumberFormatter = {
        let _formatter = NumberFormatter()
        _formatter.locale = Locale.current
        _formatter.numberStyle = .currency
        return _formatter
    }()
    
    var resultArrayD = [DataGraph]()
    var resultArrayR = [DataGraph]()

    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self, name: .updateAccount, object: nil)
    }
    
    override public func viewWillAppear()
    {
        super.viewWillAppear()
        DispatchQueue.main.async(execute: {() -> Void in
            self.chartView.spin(duration: 1, fromAngle: 0, toAngle: 360.0)
            self.chartView2.spin(duration: 1, fromAngle: 0, toAngle: 360.0)
        })
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        NotificationCenter.receive(instance: self, name: .updateAccount, selector: #selector(updateChangeCompte(_:)))

        if sliderViewController == nil {
            sliderViewController = SliderViewHorizontalController(nibName: "SliderViewHorizontalController", bundle: nil)
            sliderViewController?.delegate = self
        }
        
        splitView.addSubview((sliderViewController?.view)!, positioned: .above, relativeTo: splitView)
        
        initChart()
        updateAccount ()
    }
    
    @objc func updateChangeCompte(_ note: Notification) {
        
        updateAccount ()
        setDataHorizontal()
    }
    
//    func updateAccount () {
//        listeOperations = ListeOperations.shared.entities
//        if listeOperations.count == 0 || ListeOperations.shared.ascending == false {
//            listeOperations = ListeOperations.shared.getAll()
//        }
//        if listeOperations.count > 0 {
//            
//            firstDate = (listeOperations.first?.dateOperation?.timeIntervalSince1970)!
//            lastDate = (listeOperations.last?.dateOperation?.timeIntervalSince1970)!
//            
//            sliderViewController?.initData(firstDate: firstDate, lastDate: lastDate)
//            sliderViewController?.mySlider.isEnabled = true
//            
//        } else {
//            sliderViewController?.mySlider.isEnabled = false
//        }
//        
//    }

    func initChart() {
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let attribut: [ NSAttributedString.Key: Any] =
          [ .font: NSFont(name: "HelveticaNeue-Light", size: 15.0)!,
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraphStyle]

        // MARK: Chart View
        var centerText = NSMutableAttributedString(string: "Dépenses")
        centerText.setAttributes(attribut, range: NSRange(location: 0, length: centerText.length))
        
        chartView.delegate = self
        chartView.centerAttributedText = centerText
        
        chartView.chartDescription?.enabled = false
        chartView.noDataText = Localizations.Chart.No_chart_Data_Available
//        chartView.backgroundColor = .windowBackgroundColor

        // MARK: legend
        let legend = chartView.legend
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.font = NSFont(name: "HelveticaNeue-Light", size: CGFloat(14.0))!
        legend.textColor = .labelColor


        // MARK: Chart View2
        centerText = NSMutableAttributedString(string: "Recettes")
        centerText.setAttributes(attribut, range: NSRange(location: 0, length: centerText.length))
        
        chartView2.delegate = self
        chartView2.centerAttributedText = centerText
//        chartView2.centert = centerText

        chartView2.chartDescription?.enabled = false
        chartView2.noDataText = Localizations.Chart.No_chart_Data_Available
//        chartView2.backgroundColor = .windowBackgroundColor
        
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
        var dataArrayD = [DataGraph]()
        var dataArrayR = [DataGraph]()

        (startDate, endDate) = (sliderViewController?.calcStartEndDate())!
        
        let p1 = NSPredicate(format: "account == %@", compteCourant!)
        let p2 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p3 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3])
        
        let fetchRequest = NSFetchRequest<EntityOperations>(entityName: "EntityOperations")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
        
        do {
            listeOperations = try mainObjectContext.fetch(fetchRequest)
            
        } catch {
            print("Error fetching data from CoreData")
        }
        
        for listeOperation in listeOperations {

            let amount = listeOperation.amount
            let nameModePaiement   = listeOperation.modePaiement?.name
            let color = listeOperation.modePaiement?.color as! NSColor
            
            if amount < 0 {
                let data  = DataGraph(name : nameModePaiement!, value : amount, color : color)
                dataArrayD.append(data)
            } else {
                let data  = DataGraph(name : nameModePaiement!, value : amount, color : color)
                dataArrayR.append(data)
            }
        }

        self.resultArrayD.removeAll()
        let allKeys = Set<String>(dataArrayD.map { $0.name })
        for key in allKeys {
            let data = dataArrayD.filter({ $0.name == key })
            let sum = data.map({ $0.value }).reduce(0, +)
            self.resultArrayD.append(DataGraph(name: key, value: sum, color: data[0].color))
        }
        self.resultArrayD = self.resultArrayD.sorted(by: { $0.name < $1.name })
        
        resultArrayR.removeAll()
        let allKeysR = Set<String>(dataArrayR.map { $0.name })
        for key in allKeysR {
            let data = dataArrayR.filter({ $0.name == key })
            let sum = data.map({ $0.value }).reduce(0, +)
            resultArrayR.append(DataGraph(name: key, value: sum, color: data[0].color))
        }
        resultArrayR = resultArrayR.sorted(by: { $0.name < $1.name })
    }
    
    func setDataCount1()
    {
        guard resultArrayD.count != 0  else {
            chartView.data = nil
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            return }
        
        // MARK: PieChartDataEntry
        var colors : [NSColor] = []
        var entries = [PieChartDataEntry]()
        for result in resultArrayD {
            entries.append(PieChartDataEntry(value: abs(result.value), label: result.name))
            colors.append(result.color)
        }
        
        // MARK: PieChartDataSet
        let dataSet = PieChartDataSet(entries: entries, label: "Dépenses")
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
        
        data.setValueFormatter(DefaultValueFormatter(formatter: formatterPrice))
        data.setValueFont(NSFont(name: "HelveticaNeue-Light", size: CGFloat(11.0))!)
        data.setValueTextColor(NSColor.labelColor)
        chartView.data = data
        
    }
    
    private func setDataCount2()
    {
        guard resultArrayR.count != 0  else {
            chartView2.data = nil
            chartView2.data?.notifyDataChanged()
            chartView2.notifyDataSetChanged()
            return }
        
        // MARK: PieChartDataEntry
        var colors : [NSColor] = []
        var entries : [PieChartDataEntry] = []
        for result in self.resultArrayR {
            entries.append(PieChartDataEntry(value: abs(result.value), label: result.name))
            colors.append(result.color)
        }

        // MARK: PieChartDataSet
        let dataSet = PieChartDataSet(entries: entries, label: "Recettes")
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
        
        data.setValueFormatter(DefaultValueFormatter(formatter: formatterPrice))
        data.setValueFont(NSFont(name: "HelveticaNeue-Light", size: CGFloat(11.0))!)
        data.setValueTextColor(NSColor.labelColor)
        chartView2.data = data
    }

}

extension ModePaiementPieController: SliderHorizontalDelegate {
    
    func setDataHorizontal() {
        self.updateChartData()
        self.setDataCount1()
        self.setDataCount2()
    }
    
}

extension ModePaiementPieController: ChartViewDelegate {
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        var p5 = NSPredicate()
        if chartView.identifier?.rawValue == "Depense" {
            p5 = NSPredicate(format: "amount < 0")
        } else {
            p5 = NSPredicate(format: "amount >= 0")
        }
        
        let label = (entry as! PieChartDataEntry).label!
        
        let p1 = NSPredicate(format: "account == %@", compteCourant!)
        let p2 = NSPredicate(format: "modePaiement.name == %@", label)
        let p3 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p4 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3, p4, p5 ])
        
        let fetchRequest = NSFetchRequest<EntityOperations>(entityName: "EntityOperations")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: false)]
        
        self.delegate?.applyFilter(fetchRequest: fetchRequest)
    }
    
}
