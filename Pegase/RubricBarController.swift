import AppKit
import Charts
import SwiftDate


final class RubricBarController: CommonGraph
{
    public weak var delegate: FilterDelegate?
    
    @IBOutlet weak var tableViewRubrique: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet weak var modeRubrique: NSButton!
    @IBOutlet var chartView: BarChartView!

    @IBOutlet weak var splitView: NSSplitView!
    
    let hourSeconds = 3600.0 * 24.0 // one day

    
    var startDate = Date()
    var endDate = Date()
    
    let formatterPrice: NumberFormatter = {
        let _formatter = NumberFormatter()
        _formatter.locale = Locale.current
        _formatter.numberStyle = .currency
        return _formatter
    }()
    
    let formatterDate: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM yy", options: 0, locale: Locale.current)
        return fmt
    }()
    
    let context = mainObjectContext

    @objc dynamic var mainContext: NSManagedObjectContext! = mainObjectContext
    @objc dynamic var customSortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]
    
    var label  = [String]()
    var dataArray = [DataGraph]()
    var nameRubrique = ""
    var objectifRubrique = 0.0
    
    public override func viewDidDisappear()
    {
        super.viewDidDisappear()
        NotificationCenter.remove(instance: self, name: .updateAccount)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window!.title = "Rubrique Bar"
    }
    
    override func viewWillAppear()
    {
        super.viewWillAppear()
        
        DispatchQueue.main.async(execute: {() -> Void in
            self.chartView.animate(xAxisDuration: 1)
        })
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.receive( instance: self, selector: #selector(updateChangeAccount(_:)), name: .updateAccount)
               
        Rubric.shared.getAllDatas()
        self.arrayController.sortDescriptors = customSortDescriptors
        self.arrayController.filterPredicate = NSPredicate(format: "account == %@", currentAccount!)
        self.arrayController.setSelectionIndex(0)
        
        self.tableViewRubrique.selectRowIndexes([0], byExtendingSelection: false)
        
        self.modeRubrique.title = "Rubrique"
        self.modeRubrique.bezelStyle = .texturedSquare
        self.modeRubrique.isBordered = false //Important
        self.modeRubrique.wantsLayer = true
        self.modeRubrique.layer?.backgroundColor = NSColor.systemBlue.cgColor
        
        if self.sliderViewController == nil {
            self.sliderViewController = SliderViewHorizontalController(nibName: "SliderViewHorizontalController", bundle: nil)
            self.sliderViewController?.delegate = self
        }
        
        self.splitView.addSubview((sliderViewController?.view)!, positioned: .above, relativeTo: splitView)
        
        self.initChart()
        self.updateAccount ()
    }
    
    @objc func updateChangeAccount(_ note: Notification) {
        
        updateAccount ()
        setDataHorizontal()
    }
    
    private func initChart() {
        // MARK: General
        chartView.delegate = self
        
        chartView.pinchZoomEnabled          = false
        chartView.doubleTapToZoomEnabled    = false
        chartView.drawBarShadowEnabled      = false
        chartView.drawGridBackgroundEnabled = true
        chartView.drawValueAboveBarEnabled  = false
        chartView.drawBordersEnabled = true
        chartView.noDataText = Localizations.Chart.No_chart_Data_Available
        chartView.gridBackgroundColor = .windowBackgroundColor
        chartView.fitBars                   = true

        // MARK: xAxis
        let xAxis                      = chartView.xAxis
        xAxis.granularity = 1
        xAxis.gridLineWidth = 1.0
        xAxis.labelFont      = NSFont(name: "HelveticaNeue-Light", size: CGFloat(12.0))!
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor           = .labelColor

        // MARK: leftAxis
        let leftAxis                   = chartView.leftAxis
        leftAxis.labelFont             = NSFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        leftAxis.labelCount            = 6
        leftAxis.drawGridLinesEnabled  = true
        leftAxis.granularityEnabled    = true
        leftAxis.granularity           = 1
        leftAxis.valueFormatter        = CurrencyValueFormatter()
        leftAxis.labelTextColor        = .labelColor
        leftAxis.gridLineWidth = 1.0

        // MARK: rightAxis
        chartView.rightAxis.enabled    = false
        
        // MARK: legend
        initializeLegend(chartView.legend)

        // MARK: description
        chartView.chartDescription?.enabled  = false
    }
    
    override func initializeLegend(_ legend: Legend) {
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside = true
        legend.xOffset = 10.0
        legend.yEntrySpace = 0.0
        legend.font = NSFont(name: "HelveticaNeue-Light", size: CGFloat(11.0))!
        legend.textColor = NSColor.labelColor
    }

    /// R??cup??re les donn??es entre 2 dates puis les additionnent.
    /// Les dates proviennent du slider
    /// https://stackoverflow.com/questions/40657193/swift-3-sum-value-with-group-by-of-an-array-of-objects
    private func updateChartData()
    {
        dataArray.removeAll()
        guard nameRubrique != "" else { return }
        
        (startDate, endDate) = (sliderViewController?.calcStartEndDate())!
        
        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let p2 = NSPredicate(format: "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.rubric.name == %@).@count > 0", nameRubrique)

        let p3 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p4 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3, p4])
        
        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
        
        do {
            listTransactions = try context!.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }
        
        delegate?.updateListeTransactions( liste: listTransactions)
        
        // grouped by month/year
        var name = ""
        var value = 0.0
        var color = NSColor.blue
        var section = ""

        for listTransaction in listTransactions {
            
            section = listTransaction.sectionIdentifier!
            let sousOperations = listTransaction.sousOperations?.allObjects  as! [EntitySousOperations]
            value = 0.0
            for sousOperation in sousOperations where (sousOperation.category?.rubric!.name)! == nameRubrique {
                name  = (sousOperation.category?.rubric!.name)!
                value += sousOperation.amount
                color = sousOperation.category?.rubric?.color as! NSColor
            }
            self.dataArray.append( DataGraph(section: section, name: name, value: value, color: color))
        }
        self.dataArray = self.dataArray.sorted(by: { $0.name < $1.name })
        self.dataArray = self.dataArray.sorted(by: { $0.section < $1.section })
    }
    
    private func addLimit() {
        
        chartView.leftAxis.removeAllLimitLines()
        let llXAxis = ChartLimitLine(limit: objectifRubrique, label: "Objectif : " + nameRubrique)
        llXAxis.lineColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        llXAxis.valueTextColor = NSColor.blue
        llXAxis.valueFont = NSFont.systemFont(ofSize: CGFloat(12.0))
        llXAxis.labelPosition = .bottomRight
        
        let leftAxis = chartView.leftAxis
        leftAxis.addLimitLine(llXAxis)
    }
    
    private func setDataCount() {
        
        guard dataArray.isEmpty == false else {
            chartView.data = nil
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            return }
        
        // MARK: BarChartDataEntry
        var entriesData = [BarChartDataEntry]()

        var colors : [NSColor] = []
        label.removeAll()
        
        var components = DateComponents()
        var dateString = ""

        var i = 0

        var value = [Double]()
        let allSection = Set<String>(dataArray.map { $0.section })
        let allKeySection = allSection.sorted()
        
        for keySection in allKeySection {
            let dataSections = dataArray.filter({ $0.section == keySection })
            value.removeAll()
            
            let color = dataSections[0].color
            
            for dataSection in dataSections  {
                value.append(abs(dataSection.value))
            }
            
            entriesData.append(BarChartDataEntry(x: Double(i), yValues: value))
            colors.append(color)
            
            let numericSection = Int(dataSections[0].section)
            components.year = numericSection! / 100
            components.month = numericSection! % 100
            
            if let date = Calendar.current.date(from: components) {
                dateString = formatterDate.string(from: date)
            }
            label.append(dateString)
            i += 1
        }
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: label)
        
        if chartView.data == nil {
            // MARK: BarChartDataSet
            var dataSet = BarChartDataSet()
            
            dataSet = BarChartDataSet(entries: entriesData, label: "D??pense")
            dataSet.colors = colors
            dataSet.valueFormatter = DefaultValueFormatter(formatter: formatterPrice)
            dataSet.stackLabels = [nameRubrique]
            dataSet.barBorderWidth = 1.0
            
            var dataSets = [BarChartDataSet]()
            dataSets.append(dataSet)
            
            // MARK: BarChartData
            let data = BarChartData(dataSets: dataSets)
            
            data.setValueFormatter(DefaultValueFormatter(formatter: formatterPrice))
            data.setValueFont(NSFont(name: "HelveticaNeue-Light", size: CGFloat(8.0))!)
            data.setValueTextColor(NSColor.black)
            chartView.data = data
            
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            
        } else {
            var dataSet = BarChartDataSet()
            
            dataSet = (chartView.data!.dataSets[0] as! BarChartDataSet )
            dataSet.colors = colors
            dataSet.replaceEntries( entriesData )
            
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            chartView.animate(xAxisDuration: 1)
        }
    }
}

// NSTableViewDelegate
extension RubricBarController: NSTableViewDelegate {
    
    public func tableViewSelectionDidChange(_ notification: Notification)
    {
        guard let tableView = notification.object as? NSTableView else { return }
        
        let selectedRow = tableView.selectedRow
        
        if selectedRow >= 0 {
            let quake = arrayController.selectedObjects as! [EntityRubric]
            nameRubrique = quake[0].name!
            objectifRubrique = quake[0].total
            
            self.addLimit()
            self.updateChartData()
            self.setDataCount()
        }
    }
}

extension RubricBarController: SliderHorizontalDelegate {
    func setDataHorizontal() {
        self.updateChartData()
        self.setDataCount()
    }
}

extension RubricBarController: ChartViewDelegate
{
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    {
        var index = highlight.x
        let entryX = entry.x
        
        let firstDate = sliderViewController?.firstDate
        
        index = 1
        var date2 = Date(timeIntervalSince1970: ((index * self.hourSeconds) + firstDate!))
        let idx = Int(entryX)
        date2 = date2 + idx.months
        let startDate = date2.startOfMonth()
        let endDate = date2.endOfMonth()

        let p1 = NSPredicate(format: "account == %@", currentAccount!)
        let p2 = NSPredicate(format: "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.rubric.name == %@).@count > 0", nameRubrique)
        let p3 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p4 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3, p4])

        let fetchRequest = NSFetchRequest<EntityTransactions>(entityName: "EntityTransactions")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: false)]
        
        delegate?.applyFilter(fetchRequest: fetchRequest)
    }
    
    public func chartValueNothingSelected(_ chartView: ChartViewBase)
    {
        print("Nothing RubriqueBarController")
    }
    
}

