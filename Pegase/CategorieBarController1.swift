import AppKit
import Charts

final class CategorieBarController1: NSViewController
{
    public weak var delegate: FilterDelegate?
    
    @IBOutlet var chartView: BarChartView!
    @IBOutlet weak var splitView: NSSplitView!
    
    var sliderViewController: SliderViewHorizontalController?
    
    private var numericIDs  = [String]()
    private var resultArray = [DataGraph]()
    private var arrayUniqueRubriques   = [String]()
    
    private var listeOperations = [EntityOperations]()
    var firstDate: TimeInterval = 0.0
    var lastDate: TimeInterval = 0.0

    private var startDate = Date()
    private var endDate = Date()
    
    let formatterPrice: NumberFormatter = {
        let _formatter = NumberFormatter()
        _formatter.locale = Locale.current
        _formatter.numberStyle = .currency
        return _formatter
    }()
    
    let formatterDate: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM/yyyy", options: 0, locale: Locale.current)
        return fmt
    }()
    
    public override func viewDidDisappear() {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self, name: .updateAccount, object: nil)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window!.title = "Bar Chart"
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        DispatchQueue.main.async(execute: {() -> Void in
            self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        })
        delegate?.updateListeOperations(liste: [])
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.receive(instance: self, name: .updateAccount, selector: #selector(updateChangeCompte(_:)))
        
        if sliderViewController == nil {
            sliderViewController = SliderViewHorizontalController(nibName: "SliderViewHorizontalController", bundle: nil)
            sliderViewController?.delegate = self
        }
        splitView.addSubview((sliderViewController?.view)!, positioned: .above, relativeTo: splitView)
        
        updateCompte ()
        initChart()
        updateChartData()
        setDataHorizontal()
    }
    
    @objc func updateChangeCompte(_ note: Notification) {
        
        updateCompte ()
        updateChartData()
        setDataHorizontal()
    }
    
    func updateCompte () {
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
        // MARK: General
        chartView.delegate = self
        
        chartView.borderColor = .controlBackgroundColor
        chartView.gridBackgroundColor = .gridColor
        chartView.drawBarShadowEnabled      = false
        chartView.drawValueAboveBarEnabled  = false
        chartView.maxVisibleCount           = 60
        chartView.drawGridBackgroundEnabled = true
        chartView.backgroundColor = .controlBackgroundColor
        chartView.fitBars                   = true
        chartView.drawBordersEnabled = true
        
        chartView.pinchZoomEnabled          = false
        chartView.doubleTapToZoomEnabled    = false
        chartView.dragEnabled               = false
        chartView.noDataText = Localizations.Chart.No_chart_Data_Available
        
        // MARK: xAxis
        let xAxis                      = chartView.xAxis
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity              = 1.0
        xAxis.gridLineWidth = 2.0
        xAxis.labelCount = 20
        xAxis.labelFont                = NSFont(name: "HelveticaNeue-Light", size: CGFloat(14.0))!
        xAxis.labelPosition            = .bottom
        xAxis.labelTextColor           = .labelColor

        
        // MARK: leftAxis
        let leftAxis                   = chartView.leftAxis
        leftAxis.labelFont             = NSFont(name: "HelveticaNeue-Light", size: CGFloat(10.0))!
        leftAxis.labelTextColor        = .labelColor

        leftAxis.labelCount            = 10
        leftAxis.granularityEnabled    = true
        leftAxis.granularity           = 1
        leftAxis.valueFormatter        = CurrencyValueFormatter()
        
        // MARK: rightAxis
        chartView.rightAxis.enabled    = false
        
        // MARK: legend
        let legend                           = chartView.legend
        legend.horizontalAlignment           = .right
        legend.verticalAlignment             = .top
        legend.orientation                   = .vertical
        legend.drawInside                    = true
        legend.font                          = NSFont.systemFont(ofSize: CGFloat(11.0))
        legend.xOffset = 10.0
        legend.yEntrySpace = 0.0
        
        // MARK: description
        chartView.chartDescription?.enabled  = false
    }
    
    /// Récupére les données entre 2 dates.
    /// Les dates proviennent du slider
    /// https://stackoverflow.com/questions/40657193/swift-3-sum-value-with-group-by-of-an-array-of-objects
    private func updateChartData()
    {
        (startDate, endDate) = (sliderViewController?.calcStartEndDate())!
        
        let p1 = NSPredicate(format: "account == %@", compteCourant!)
        let p2 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p3 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [ p1, p2, p3])
        
        let fetchRequest = NSFetchRequest<EntityOperations>(entityName: "EntityOperations")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: true)]
        
        do {
            listeOperations = try mainObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching data from CoreData")
        }

        // Récupere le nom de toutes les rubriques
        // Récupere les datas pour la période choisie
        var setUniqueRubrique     = Set<String>()
        var dataRubrique = [DataGraph]()
        
        for listeOperation in listeOperations {
            
            let id = listeOperation.sectionIdentifier!
            
            let sousOperations = listeOperation.sousOperations?.allObjects  as! [EntitySousOperations]
            for sousOperation in sousOperations {
                
                let value    = sousOperation.amount
                
                let nameRubrique = sousOperation.category?.rubrique?.name
                setUniqueRubrique.insert(nameRubrique!)
                
                let color    = sousOperation.category?.rubrique?.color as! NSColor
                
                let data = DataGraph(section: id, name: nameRubrique!, value: value, color: color)
                dataRubrique.append( data)
            }
        }
        arrayUniqueRubriques = setUniqueRubrique.sorted()
        
        // somme par rubrique pour chaque période
        resultArray.removeAll()
        let allRubriqueKeys = Set<String>(dataRubrique.map { $0.section })
        for keyRubrique in allRubriqueKeys {
            for nameRubrique in arrayUniqueRubriques {
                let data = dataRubrique.filter({ $0.section == keyRubrique && $0.name == nameRubrique  })
                if data.count > 0 {
                    let sum = data.map({ $0.value }).reduce(0, +)
                    resultArray.append(DataGraph(section: keyRubrique ,name: nameRubrique, value: sum, color: data.first!.color))
                } else {
                    resultArray.append(DataGraph(section: keyRubrique ,name: nameRubrique, value: 0, color: NSColor.black))
                }
            }
        }
        resultArray = resultArray.sorted(by: { $0.name < $1.name })
        resultArray = resultArray.sorted(by: { $0.section < $1.section })
    }
    
    private func setDataCount()
    {
        guard resultArray.count != 0 else {
            chartView.data = nil
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            return }
        
        let groupSpace = 0.2
        let barSpace = 0.0
        let barWidth = Double(0.8 / Double(arrayUniqueRubriques.count))
        
        // MARK: BarChartDataEntry
        var entries = [BarChartDataEntry]()
        
        // MARK: ChartDataSet
        let dataSets = (0 ..< arrayUniqueRubriques.count).map { (i) -> BarChartDataSet in
            
            let dataRubrique = resultArray.filter({ $0.name == arrayUniqueRubriques[i]  })
            entries.removeAll()
            for i in 0 ..< dataRubrique.count {
                entries.append(BarChartDataEntry(x: Double(i), y: abs(dataRubrique[i].value)))
            }
            
            let dataSet = BarChartDataSet(entries: entries, label: dataRubrique[0].name)
            dataSet.colors = [dataRubrique[0].color]
            dataSet.drawValuesEnabled = false
            return dataSet
        }
        
        let allKeyIDs = Set<String>(resultArray.map { $0.section })
        self.numericIDs = allKeyIDs.sorted(by: { $0 < $1 })
        var labelDate = [String]()
        
        for numericID in self.numericIDs {
            let numericSection = Int(numericID)
            var components = DateComponents()
            components.year = numericSection! / 100
            components.month = numericSection! % 100
            let date = Calendar.current.date(from: components)
            let dateString = formatterDate.string(from: date!)
            labelDate.append(dateString)
        }
        
        // MARK: BarChartData
        let data = BarChartData(dataSets: dataSets)
        
        data.setValueFormatter(DefaultValueFormatter(formatter: formatterPrice))
        data.setValueFont(NSFont(name: "HelveticaNeue-Light", size: CGFloat(11.0))!)
        data.setValueTextColor(NSColor.black)
        
        data.barWidth = barWidth
        data.groupBars( fromX: Double(0), groupSpace: groupSpace, barSpace: barSpace)
        
        let groupCount = allKeyIDs.count + 1
        let startYear = 0
        let endYear = startYear + groupCount
        
        self.chartView.xAxis.axisMinimum = Double(startYear)
        self.chartView.xAxis.axisMaximum = Double(endYear)
        self.chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labelDate)
        
        self.chartView.data = data
    }
    
}

extension CategorieBarController1: SliderHorizontalDelegate {
    func setDataHorizontal() {
        self.updateChartData()
        self.setDataCount()
    }
    
}

extension CategorieBarController1: ChartViewDelegate
{
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    {
        let index = highlight.x
        let dataSetIndex = Int(highlight.dataSetIndex)
        
        let nameRubrique = arrayUniqueRubriques[dataSetIndex]
        
        let numericSection = Int(numericIDs[Int(index)])
        var components = DateComponents()
        components.year = numericSection! / 100
        components.month = numericSection! % 100
        let date = Calendar.current.date(from: components)
        
        let startDate = date!.startOfMonth()
        let endDate = date!.endOfMonth()
        
        let p1 = NSPredicate(format: "account == %@", compteCourant!)
        let p2 = NSPredicate(format: "SUBQUERY(sousOperations, $sousOperation, $sousOperation.category.rubrique.name == %@).@count > 0", nameRubrique)
        let p3 = NSPredicate(format: "dateOperation >= %@", startDate as CVarArg )
        let p4 = NSPredicate(format: "dateOperation <= %@", endDate as CVarArg )
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3, p4])
        
        let fetchRequest = NSFetchRequest<EntityOperations>(entityName: "EntityOperations")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateOperation", ascending: false)]
        
        self.delegate?.applyFilter(fetchRequest: fetchRequest)
    }
    
    public func chartValueNothingSelected(_ chartView: ChartViewBase)
    {
    }
    
}

