import UIKit
import CoreData

class FavoriteTableViewController: UITableViewController {

    var favoriteProducts : [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteProducts = getDataFromCoreData()
        let backgroundImage = UIImage(named: "background3")
        self.tableView.backgroundView = UIImageView(image: backgroundImage)
        tableView.backgroundColor = UIColor.clear

    }
    
    @IBAction func deleteAll(_ sender: UIBarButtonItem) {
        let isEmpty = favoriteProducts.isEmpty
        let message = isEmpty ? "Inga favoriter." : "Vill du ta bort alla näringsämnen?"
        let alertController = UIAlertController(title: "DELETE ALL ITEMS", message: message, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (result: UIAlertAction) -> Void in
            print("ok")
        }
        let deleteAllAction = UIAlertAction(title: "Delete", style: .destructive) { (result: UIAlertAction) -> Void in
            self.deleteAllData(entity: "Products")
            self.favoriteProducts.removeAll()
            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result: UIAlertAction) -> Void in
            print("cancel")
        }
        if !isEmpty {
            alertController.addAction(deleteAllAction)
            alertController.addAction(cancelAction)
        }
        else {
            alertController.addAction(okAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteAllData(entity: String)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
                try managedContext.save()
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteProducts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FavoriteTableViewCell
        let name = favoriteProducts[indexPath.row].name
        let energyKj = favoriteProducts[indexPath.row].energyKj
        let number = favoriteProducts[indexPath.row].number
        cell.productNameLabel.text = name
        cell.productValueLabel.text = "\(energyKj) kJ."
        cell.number = number
        cell.backgroundColor = UIColor.clear
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavoriteSegue" {
            if let IndexPath = self.tableView.indexPathForSelectedRow {
                let product = favoriteProducts[IndexPath.row]
                (segue.destination as! FavoriteProductViewController).product = product
            }
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
            request.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(request)
                if !results.isEmpty {
                    for result in results as! [NSManagedObject] {
                        if let number = result.value(forKey: "number") as? Int {
                            //TODO: set old and new image that vill change image in CoreData
                            if number == favoriteProducts[indexPath.row].number {//or == unik number
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
            favoriteProducts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoriteProducts = getDataFromCoreData()
        tableView.reloadData()
    }

    //retrieve from Core data
    func getDataFromCoreData() -> [Product] {
        var tempProducts : [Product] = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if !results.isEmpty {
                for result in results as! [NSManagedObject] {
                    let product = Product()
                    if let name = result.value(forKey: "name") as? String {
                        product.name = name
                    }
                    if let number = result.value(forKey: "number") as? Int {
                        product.number = number
                    }
                    if let productValue = result.value(forKey: "productValue") as? Double {
                        product.productValue = productValue
                    }
                    if let energyKj = result.value(forKey: "energyKj") as? Double {
                        product.energyKj = energyKj
                    }
                    if let energyKcal = result.value(forKey: "energyKcal") as? Double {
                        product.energyKcal = energyKcal
                    }
                    if let protein = result.value(forKey: "protein") as? Double {
                        product.protein = protein
                    }
                    if let fat = result.value(forKey: "fat") as? Double {
                        product.fat = fat
                    }
                    if let carbohydrates = result.value(forKey: "carbohydrates") as? Double {
                        product.carbohydrates = carbohydrates
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
}
