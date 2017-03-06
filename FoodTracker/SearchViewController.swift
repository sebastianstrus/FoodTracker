import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var products : [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
        self.animateTable()
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = 30.0
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        searchField.resignFirstResponder()
        search()
        return true
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        search()
    }
    
    func search() {
        let urlString = "http://matapi.se/foodstuff?query=\(searchField.text!)"
        if let safeUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: safeUrlString) {
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) {
                (maybeData : Data?, response : URLResponse?, error : Error?) in
                if let unwrappedData = maybeData {
                    let options = JSONSerialization.ReadingOptions()
                    do {
                        if let parsedData = try JSONSerialization.jsonObject(with: unwrappedData, options: options) as? Array<Dictionary<String, Any>> {//[String: Any]
                            var tempProducts : [Product] = []
                            DispatchQueue.main.async {
                                for index in 0..<parsedData.count {
                                    let tempProduct = Product()
                                    if let tempName = parsedData[index]["name"] as! String? {
                                        tempProduct.name = tempName
                                    }
                                    if let tempNumber = parsedData[index]["number"] as! Int? {
                                        tempProduct.number = tempNumber
                                    }
                                    tempProducts.append(tempProduct)
                                }
                                self.products = tempProducts
                                self.tableView.reloadData()
                                self.animateTable()
                            }
                        } else {
                            print("Failed to cast from json.")
                        }
                    } catch let parseError {
                        print("Error parsing json: \(parseError)");
                    }
                } else {
                    print("No data.")
                }
            }
            task.resume()
        } else {
            print("Failed to create url.")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = products[indexPath.row].name
        cell.textLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSegue", sender: products[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let guest = segue.destination as! ProductViewController
        guest.product = sender as? Product
        
    }
    
    func animateTable() {
        tableView.reloadData()
        let cells = tableView.visibleCells
        let tableViewHeight = tableView.bounds.size.height
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        var delayCounter = 0
        
        for cell in cells {
            UIView.animate(withDuration: 1.75, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    cell.transform = CGAffineTransform.identity
                }, completion: nil)
            delayCounter += 1
        }
    }
}
