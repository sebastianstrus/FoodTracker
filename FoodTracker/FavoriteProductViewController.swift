import UIKit
import CoreData

class FavoriteProductViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var energyKjLabel: UILabel!
    @IBOutlet weak var energyKcalLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var carbohydratesLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createParticles()
        
        energyKjLabel.center = CGPoint(x: view.frame.size.width*2, y: view.frame.size.height/3 + 30)
        energyKcalLabel.center = CGPoint(x: -view.frame.size.width, y: view.frame.size.height/3 + 60)
        proteinLabel.center = CGPoint(x: view.frame.size.width*2, y: view.frame.size.height/3 + 90)
        fatLabel.center = CGPoint(x: -view.frame.size.width, y: view.frame.size.height/3 + 120)
        carbohydratesLabel.center = CGPoint(x: view.frame.size.width*2, y: view.frame.size.height/3 + 150)
        
        if let p = product {
            titleLabel.text = p.name
            
            if let num = p.number {
                setDataInView(number: num)
            }
            energyKjLabel?.text = "energyKj: \(p.energyKj)"
            energyKcalLabel?.text = "energyKcal: \(p.energyKcal)"
            proteinLabel?.text = "protein: \(p.protein)"
            fatLabel?.text = "fat: \(p.fat)"
            carbohydratesLabel?.text = "carbohydrates: \(p.carbohydrates)"
            value.text = "Nyttighetsvärde: \(p.productValue)"
        }
        
        // Animations
        UIView.beginAnimations("Move properties", context: nil)
        UIView.setAnimationDuration(2.0)
        energyKjLabel.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/3 + 20)
        energyKcalLabel.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/3 + 45)
        proteinLabel.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/3 + 70)
        fatLabel.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/3 + 95)
        carbohydratesLabel.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/3 + 120)
        UIView.commitAnimations()
    }
    
    @IBAction func addToCompareButton(_ sender: Any) {
        var alreadyExists: Bool = false
        var itemsInDiagram = 0
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CompProducts")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            itemsInDiagram = results.count
            if !results.isEmpty {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        if name == product?.name {
                            alreadyExists = true
                        }
                    }
                }
            }
        }
        catch {
            print("error when retrieving")
        }
        
        if itemsInDiagram < 8 {
            if !alreadyExists {
                //insert new object
                //let newProduct = Products(context: context) //new syntax
                let newProduct = NSEntityDescription.insertNewObject(forEntityName: "CompProducts", into: context)
                newProduct.setValue(titleLabel.text, forKey: "name")
                newProduct.setValue(product?.energyKj, forKey: "energyKj")
                newProduct.setValue(product?.productValue, forKey: "productValue")
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
                        let alertController = UIAlertController(title: "Information", message: "\(n) har lagts till diagrammet!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) { (result: UIAlertAction) -> Void in
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else {
                        let alertController = UIAlertController(title: "Information", message: "\(n) finns redan i diagrammet!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) { (result: UIAlertAction) -> Void in
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        else {
            let alertController = UIAlertController(title: "Information", message: "Du kan maximalt lägga till åtta näringämnen till diagrammet!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (result: UIAlertAction) -> Void in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraButtonAction(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func fotoLibraryAction(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.6)
        let compressedIPEGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedIPEGImage!, nil, nil, nil)
        saveNotice()
        
        //update image in  Core data for current object
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if !results.isEmpty {
                for result in results as! [NSManagedObject] {
                    if let productImage = result.value(forKey: "productImage") as? String {
                        //TODO: set old and new image that vill change image in CoreData
                        if productImage == "old_image" {//or == unik number
                            result.setValue("new_image", forKey: "productImage")
                            do {
                                try context.save()
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
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        imageView.image = image
        self.dismiss(animated: true, completion: nil);
    }
    
    func saveNotice() {
        let alertController = UIAlertController(title: "Image Saved", message: "Your picture was successfully saved.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setDataInView(number: Int) -> () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if !results.isEmpty {
                for result in results as! [NSManagedObject] {
                    if let number = result.value(forKey: "number") as? Int {
                        if number == self.product?.number {
                            self.product?.number = number
                            self.product?.energyKj = (result.value(forKey: "energyKj") as? Double)!
                            self.product?.energyKcal = (result.value(forKey: "energyKcal") as? Double)!
                            self.product?.protein = (result.value(forKey: "protein") as? Double)!
                            self.product?.fat = (result.value(forKey: "fat") as? Double)!
                            self.product?.carbohydrates = (result.value(forKey: "carbohydrates") as? Double)!
                            self.product?.productValue = (result.value(forKey: "productValue") as? Double)!
                        }
                    }
                }
            }
        }
        catch
        {
            print("error when retrieving")
        }
    }
    
    // Snow ;P
    func createParticles() {
        let view = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        view.contentMode = UIViewContentMode.scaleAspectFill
        //view.image = UIImage(named: "landscape")
        self.view.addSubview(view)
        let cloud = CAEmitterLayer()
        cloud.emitterPosition = CGPoint(x: view.center.x, y: -50)
        cloud.emitterShape = kCAEmitterLayerLine
        cloud.emitterSize = CGSize(width: view.frame.size.width, height: 1)
        let flake = makeEmitterCell()
        cloud.emitterCells = [flake]
        view.layer.addSublayer(cloud)
    }
    func makeEmitterCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contentsScale = 8
        cell.birthRate = 4
        cell.lifetime = 50.0
        cell.velocity = 50
        cell.emissionLongitude = CGFloat.pi
        cell.emissionRange = CGFloat.pi / 4
        cell.spin = 0.5
        cell.spinRange = 1.2
        cell.scaleRange = -0.05
        cell.contents = UIImage(named: "snow")?.cgImage
        return cell
    }
}
