import UIKit

class Product: NSObject {
    var name:String?
    var number: Int?
    var productImage: NSData? = nil
    var productValue = 0.0
    
    var energyKj = 0.0
    var energyKcal = 0.0
    var protein = 0.0
    var fat = 0.0
    var carbohydrates = 0.0
    
    var compared = false
    
    override var description: String {
        return "ProductName: \(name), number: \(number), productImage: , carbohydrates: \(carbohydrates)"
    }
}

