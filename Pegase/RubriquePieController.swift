import AppKit
import Charts


final class RubriquePieController: NSViewController
{
    public weak var delegate: FilterDelegate?
    
    @IBOutlet var chartView: PieChartView!
    @IBOutlet var chartView2: PieChartView!
    @IBOutlet weak var splitView: NSSplitView!
    
    var sliderViewController: SliderViewHorizontalController?
    
    var listeOperations = [EntityOperations]()
    var firstDate: TimeInterval = 0.0
    var lastDate: TimeInterval = 0.0

    
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

    override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self, name: .updateAccount, object: nil)
    }
    
    override func viewWillAppear()
    {
        super.viewWillAppear()
        DispatchQueue.main.async(execute: {() -> Void in
            self.chartView.spin(duration: 1, fromAngle: 0, toAngle: 360.0)
            self.chartView2.spin(duration: 1, fromAngle: 0, toAngle: 360.0)
        })
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.receive(instance: self, name: .updateAccount, selector: #selector(updateChangeAccount(_:)))
        
        self.chartView.delegate = self
        self.chartView2.delegate = self
        
        if self.sliderViewController == nil {
            self.sliderViewController = SliderViewHorizontalController(nibName: "SliderViewHorizontalController", bundle: nil)
            self.sliderViewController?.delegate = self
        }
        
        splitView.addSubview((self.sliderViewController?.view)!, positioned: .above, relativeTo: splitView)
        
        self.updateAccount ()
        self.initChart()
    }
    
    @objc func updateChangeAccount(_ note: Notification) {
        
        updateAccount ()
        self.setDataHorizontal()
        
        DispatchQueue.main.async(execute: {() -> Void in
            self.chartView.spin(duration: 1, fromAngle: 0, toAngle: 360.0)
            self.chartView2.spin(duration: 1, fromAngle: 0, toAngle: 360.0)
        })
    }
    
    func updateAccount () {
        listeOperations = ListeOperations.shared.getAll()
        if listeOperations.count > 0 {
            
            firstDate = (listeOperations.first?.dateOperation?.timeIntervalSince1970)!
            lastDate = (listeOperations.last?.dateOperation?.timeIntervalSince1970)!
            
            sliderViewController?.initData(firstDate: firstDate, lastDate: lastDate)
            sliderViewController?.mySlider.isEnabled = true
            
        } else {
            sliderViewController?.mySlider.isEnabled = false
        }

    }

    private func initChart() {
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let attribut: [ NSAttributedString.Key: Any] =
            [  .font: NSFont(name: "HelveticaNeue-Light", size: 15.0)!,
               .foregroundColor: NSColor.gray,
               .paragraphStyle: paragraphStyle]
        
        var centerText = NSMutableAttributedString(string: "Dépenses")
        centerText.setAttributes(attribut, range: NSRange(location: 0, length: centerText.length))
        
        let legend = chartView.legend
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.font = NSFont(name: "HelveticaNeue-Light", size: CGFloat(14.0))!
        
        self.chartView.centerAttributedText = centerText
        self.chartView.chartDescription?.enabled = false
        self.chartView.noDataText = Localizations.Chart.No_chart_Data_Available
        
        centerText = NSMutableAttributedString(string: "Recettes")
        centerText.setAttributes(attribut, range: NSRange(location: 0, length: centerText.length))
        
        let legend2 = self.chartView2.legend
        legend2.horizontalAlignment = .left
        legend2.verticalAlignment = .top
        legend2.orientation = .vertical
        legend2.font = NSFont(name: "HelveticaNeue-Light", size: CGFloat(14.0))!
        
        self.chartView2.centerAttributedText = centerText
        self.chartView2.chartDescription?.enabled = false
        self.chartView2.noDataText = Localizations.Chart.No_chart_Data_Available
    }
    
    private func updateChartData()
    {
        var dataArrayD = [DataGraph]()
        var dataArrayR = [DataGraph]()

        (startDate, endDate) = (sliderViewController?.calcStartEndDate())!
        
        let p1 = NSPredicate(format: "account == %@", compteCourant!)
        let p3 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p4 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p3, p4])
        
        let fetchRequest = NSFetchRequest<EntityOperations>(entityName: "EntityOperations")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
        
        do {
            listeOperations = try mainObjectContext.fetch(fetchRequest)
            
        } catch {
            print("Error fetching data from CoreData")
        }
        
        var rubrique = ""
        var value = 0.0
        var color = NSColor.blue
        let section = ""

        for listeOperation in listeOperations {
            
            let sousOperations = listeOperation.sousOperations?.allObjects  as! [EntitySousOperations]
            for sousOperation in sousOperations {
                
                value = sousOperation.amount
                rubrique = (sousOperation.category?.rubrique!.name)!
                color = sousOperation.category?.rubrique?.color as! NSColor
                
                if value < 0 {
                    dataArrayD.append( DataGraph( name: rubrique, value: value, color: color))

                } else {
                    dataArrayR.append( DataGraph(section: section, name: rubrique, value: value, color: color))
                }
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
            self.resultArrayR.append(DataGraph(name: key, value: sum, color: data[0].color))
        }
        resultArrayR = resultArrayR.sorted(by: { $0.name < $1.name })
    }
    
    private func setDataCount1()
    {
        guard resultArrayD.count != 0  else {
            chartView.data = nil
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            return }

        // MARK: PieChartDataEntry
        var colors : [NSColor] = []
        var entries : [PieChartDataEntry] = []
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
        dataSet.valueLinePart2Length = 0.5
        dataSet.xValuePosition = .outsideSlice
        dataSet.yValuePosition = .outsideSlice
        dataSet.entryLabelColor = .labelColor
        dataSet.valueColors = [.labelColor]

        // MARK: PieChartData
        let data = PieChartData(dataSet: dataSet)
        
        data.setValueFormatter(DefaultValueFormatter(formatter: formatterPrice))
        data.setValueFont(NSFont(name: "HelveticaNeue-Light", size: CGFloat(11.0))!)
        data.setValueTextColor(NSColor.labelColor)
        self.chartView.data = data
        self.chartView.highlightValues(nil)
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
        for result in resultArrayR {
            entries.append(PieChartDataEntry(value: abs(result.value), label: result.name))
            colors.append(result.color)
        }

        // MARK: PieChartDataSet
        let dataSet = PieChartDataSet(entries: entries, label: "Recettes")
        dataSet.sliceSpace = 2.0
        dataSet.colors = colors
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.4
        dataSet.valueLinePart2Length = 0.5
        dataSet.xValuePosition = .outsideSlice
        dataSet.yValuePosition = .outsideSlice
        dataSet.entryLabelColor = .labelColor

        
        // MARK: PieChartData
        let data = PieChartData(dataSet: dataSet)
        
        data.setValueFormatter(DefaultValueFormatter(formatter: formatterPrice))
        data.setValueFont(NSFont(name: "HelveticaNeue-Light", size: CGFloat(11.0))!)
        data.setValueTextColor(NSColor.labelColor)
        self.chartView2.data = data
        self.chartView2.highlightValues(nil)
    }
    
}

extension RubriquePieController: SliderHorizontalDelegate {
    
    func setDataHorizontal() {
        self.updateChartData()
        self.setDataCount1()
        self.setDataCount2()
    }
}

extension RubriquePieController: ChartViewDelegate {
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        let label = (entry as! PieChartDataEntry).label!
        
        let p1 = NSPredicate(format: "account == %@", compteCourant!)
        let p2 = NSPredicate(format: "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.rubrique.name == %@).@count > 0", label)

        let p3 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p4 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        
        var p5 = NSPredicate()
        if chartView.identifier?.rawValue == "Depense" {
            p5 = NSPredicate(format: "amount < 0")
        } else {
            p5 = NSPredicate(format: "amount >= 0")
        }

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3, p4, p5])
        
        let fetchRequest = NSFetchRequest<EntityOperations>(entityName: "EntityOperations")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: false)]
        
        self.delegate?.applyFilter(fetchRequest: fetchRequest)
    }
    
}

struct DataGraph {
    
    var section = ""
    var name = ""
    var value: Double = 0.0
    var color: NSColor = .orange
    
    init () {
    }
    
    init(section: String = "", name: String, value: Double, color: NSColor = .blue)
    {
        self.section = section
        self.name = name
        self.value  = value
        self.color  = color
    }
    
}

//struct Stack<Element> {
//    var items = [Element]()
//    mutating func push(_ item: Element) {
//        items.append(item)
//    }
//    mutating func pop() -> Element {
//        return items.removeLast()
//    }
//}
