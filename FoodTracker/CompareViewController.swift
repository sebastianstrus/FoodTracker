import UIKit
import CoreData
import Charts

class CompareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var tableView: UITableView!
    
    var productsToCompare : [Product] = []
    
    var names: [String] = []
    var energyKjs: [Double] = []
    var productValues: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barChartView.isHidden = true
        productsToCompare = getDataFromCoreData()
        tableView.rowHeight = 30.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 10;
        tableView.layer.borderWidth = 2;
        tableView.layer.borderColor =  UIColor(red:0/255.0, green:0/255.0, blue:255/255.0, alpha: 1.0).cgColor
    }
    
    @IBAction func createChart(_ sender: UIButton) {
        if !productsToCompare.isEmpty {
            names.removeAll()
            energyKjs.removeAll()
            productValues.removeAll()
            barChartView.isHidden = false
            for p in productsToCompare {
                if var name = p.name {
                    // takes only first word
                    name = name.components(separatedBy: " ")[0]
                    if name.characters.count > 6 {
                        let index = name.index(name.startIndex, offsetBy: 5)
                        name = name.substring(to: index)
                        if name.characters.last != " " {
                            name.append(".")
                        }
                    }
                    names.append(name)
                }
                if let energyKj = p.energyKj as? Double {
                    energyKjs.append(energyKj)
                }
                if let productValue = p.productValue as? Double {
                    productValues.append(productValue)
                }
            }
            
            barChartView.delegate = self
            barChartView.noDataText = "You need to provide data for the chart."
            barChartView.chartDescription?.text = "sales vs bought "
            //legend
            let legend = barChartView.legend
            legend.enabled = true
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .top
            legend.orientation = .vertical
            legend.drawInside = true
            legend.yOffset = 10.0;
            legend.xOffset = 10.0;
            legend.yEntrySpace = 0.0;
            let xaxis = barChartView.xAxis
            //xaxis.valueFormatter = axisFormatDelegate
            xaxis.drawGridLinesEnabled = true
            xaxis.labelPosition = .bottom
            xaxis.centerAxisLabelsEnabled = true
            xaxis.valueFormatter = IndexAxisValueFormatter(values:self.names)
            xaxis.granularity = 1
            let leftAxisFormatter = NumberFormatter()
            leftAxisFormatter.maximumFractionDigits = 1
            let yaxis = barChartView.leftAxis
            yaxis.spaceTop = 0.35
            yaxis.axisMinimum = 0
            yaxis.drawGridLinesEnabled = false
            barChartView.rightAxis.enabled = false
            //axisFormatDelegate = self
            setChart()
        }
        else {
            let alertController = UIAlertController(title: "Information", message: "Lägg till minst ett näringsämne!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (result: UIAlertAction) -> Void in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsToCompare.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = productsToCompare[indexPath.row].name
        cell.textLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = productsToCompare[indexPath.row]
        print(product)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CompProducts")
            request.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(request)
                if !results.isEmpty {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            //TODO: set old and new image that vill change image in CoreData
                            if name == productsToCompare[indexPath.row].name {//or == unik number
                                context.delete(result as NSManagedObject)
                                print("deleted")
                                do {
                                    try context.save()
                                    print("saved")
                                }
                                catch {
                                    print("error")
                                }
                            }
                        }
                    }
                }
            }
            catch
            {
                print("error when retrieving")
            }
            productsToCompare.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        productsToCompare = getDataFromCoreData()
        tableView.reloadData()
        //barChartView.isHidden = true
    }
    
    func getDataFromCoreData() -> [Product]{
        var tempProducts : [Product] = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CompProducts")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if !results.isEmpty {
                for result in results as! [NSManagedObject] {
                    let product = Product()
                    
                    if let name = result.value(forKey: "name") as? String {
                        product.name = name
                    }
                    if let energyKj = result.value(forKey: "energyKj") as? Double {
                        product.energyKj = energyKj
                    }
                    if let productValue = result.value(forKey: "productValue") as? Double {
                        product.productValue = productValue
                    }
                    tempProducts.append(product)
                }
            }
        }
        catch
        {
            print("error when retrieving")
        }
        return tempProducts
    }
    
    func setChart() {
        //TODO: Resize chart
        barChartView.noDataText = "You need to provide data for the chart."
        var dataEntries: [BarChartDataEntry] = []
        var dataEntries1: [BarChartDataEntry] = []
        for i in 0..<self.names.count {
            let dataEntry = BarChartDataEntry(x: Double(i) , y: self.energyKjs[i])
            dataEntries.append(dataEntry)
            let dataEntry1 = BarChartDataEntry(x: Double(i) , y: self.self.productValues[i])
            dataEntries1.append(dataEntry1)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Energivärde")
        let chartDataSet1 = BarChartDataSet(values: dataEntries1, label: "Nyttighetsvärde")
        let dataSets: [BarChartDataSet] = [chartDataSet,chartDataSet1]
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        let chartData = BarChartData(dataSets: dataSets)
        let groupSpace = 0.3
        let barSpace = 0.05
        let barWidth = 0.3
        let groupCount = self.names.count
        let startYear = 0
        chartData.barWidth = barWidth;
        barChartView.xAxis.axisMinimum = Double(startYear)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        barChartView.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
        chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
        barChartView.notifyDataSetChanged()
        barChartView.data = chartData
        //background color
        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        //chart animation
        barChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)
    }
}
