import UIKit
import CoreData

class ProductViewController: UIViewController {

    var gravity : UIGravityBehavior!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var energyKjLabel: UILabel!
    @IBOutlet weak var energyKcalLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var carbohydratesLabel: UILabel!
    
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set labels outside of the screen
        energyKjLabel.center = CGPoint(x: view.frame.size.width*2, y: view.frame.size.height/3 + 40)
        energyKcalLabel.center = CGPoint(x: -view.frame.size.width, y: view.frame.size.height/3 + 70)
        proteinLabel.center = CGPoint(x: view.frame.size.width*2, y: view.frame.size.height/3 + 100)
        fatLabel.center = CGPoint(x: -view.frame.size.width, y: view.frame.size.height/3 + 130)
        carbohydratesLabel.center = CGPoint(x: view.frame.size.width*2, y: view.frame.size.height/3 + 160)
        
        if let p = product {
            titleLabel.text = p.name
            if let num = p.number {
                value.text = String(num)
                setDataInView(number: num)
            }
        }

        // Animations
        UIView.beginAnimations("Animate properties", context: nil)
        UIView.setAnimationDuration(2.0)
        energyKjLabel.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/3 + 40)
        energyKcalLabel.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/3 + 70)
        proteinLabel.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/3 + 100)
        fatLabel.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/3 + 130)
        carbohydratesLabel.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/3 + 160)
        UIView.commitAnimations()
    }
    
    @IBAction func addToFavorites(_ sender: UIButton) {
        var alreadyExists: Bool = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if !results.isEmpty {
                for result in results as! [NSManagedObject] {
                    if let number = result.value(forKey: "number") as? Int {
                        if number == product?.number {
                            alreadyExists = true
                        }
                    }
                }
            }
        }
        catch {
            print("error when retrieving")
        }
        
        if !alreadyExists {
            //insert new object
            //let newProduct = Products(context: context) //new syntax
            let newProduct = NSEntityDescription.insertNewObject(forEntityName: "Products", into: context)
            newProduct.setValue(titleLabel.text, forKey: "name")
            newProduct.setValue(product?.number, forKey: "number")
            newProduct.setValue(product?.productImage, forKey: "productImage")
            newProduct.setValue(product?.productValue, forKey: "productValue")
            newProduct.setValue(product?.energyKj, forKey: "energyKj")
            newProduct.setValue(product?.energyKcal, forKey: "energyKcal")
            newProduct.setValue(product?.protein, forKey: "protein")
            newProduct.setValue(product?.fat, forKey: "fat")
            newProduct.setValue(product?.carbohydrates, forKey: "carbohydrates")
            do {
                try context.save()
                print("Saved")
            }
            catch {
                print("Error when saving")
            }
        }
        
        //alert 'object added"
        if let p = product {
            if let n = p.name {
                if !alreadyExists {
                    let alertController = UIAlertController(title: "Nytt näringsämne!", message: "\(n) har sparats!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (result: UIAlertAction) -> Void in
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                else {
                    let alertController = UIAlertController(title: "Information", message: "\(n) finns redan i favoriter!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (result: UIAlertAction) -> Void in
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // set data for one product
    func setDataInView(number: Int) -> () {
        let urlString = "http://matapi.se/foodstuff/\(number)"
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) {
                (maybeData : Data?, response : URLResponse?, error : Error?) in
                if let unwrappedData = maybeData {
                    let options = JSONSerialization.ReadingOptions()
                    do {
                        if let parsedData = try JSONSerialization.jsonObject(with: unwrappedData, options: options) as? Dictionary<String,Any>{//[String: Any] {
                            if let nutrientValues = parsedData["nutrientValues"] as? Dictionary<String, Double> {
                                var majorValue = 0.0
                                if let energyKj = nutrientValues["energyKj"] {
                                    DispatchQueue.main.async {
                                        self.product?.energyKj = energyKj
                                        self.energyKjLabel?.text = "energyKj: \(energyKj)"
                                        majorValue = majorValue + (energyKj/100)
                                    }
                                }
                                if let energyKcal = nutrientValues["energyKcal"] {
                                    DispatchQueue.main.async {
                                        self.product?.energyKcal = energyKcal
                                        self.energyKcalLabel?.text = "energyKcal: \(energyKcal)"
                                        majorValue = majorValue + (energyKcal/10)
                                    }
                                }
                                if let protein = nutrientValues["protein"] {
                                    DispatchQueue.main.async {
                                        self.product?.protein = protein
                                        self.proteinLabel?.text = "protein: \(protein)"
                                        majorValue = majorValue + protein
                                    }
                                }
                                if let fat = nutrientValues["fat"] {
                                    DispatchQueue.main.async {
                                        self.product?.fat = fat
                                        self.fatLabel?.text = "fat: \(fat)"
                                    }
                                }
                                if let carbohydrates = nutrientValues["carbohydrates"] {
                                    DispatchQueue.main.async {
                                        self.product?.carbohydrates = carbohydrates
                                        self.carbohydratesLabel?.text = "carbohydrates: \(carbohydrates)"
                                        majorValue = majorValue + carbohydrates * 5 + 5.5
                                        self.value.text = "Nyttighetsvärde: \(majorValue)"
                                        self.product?.productValue = majorValue
                                    }
                                }
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
        }
    }
}
