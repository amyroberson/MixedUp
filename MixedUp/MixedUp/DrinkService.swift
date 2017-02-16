//
//  DrinkService.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/7/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

final class DrinkService{
    
    var coreDataStack: CoreDataStack
    
    init(_ coreDataStack: CoreDataStack){
        self.coreDataStack = coreDataStack
    }
    
    fileprivate let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    fileprivate func requestBuilder(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip,identity", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("utf-8", forHTTPHeaderField: "Accept-Charset")
        switch method{
        case "POST", "PUT":
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        default:
            break
        }
        return request
    }
    
    func processDrinkRequest(data: Data?, error: NSError?) -> ResourceResult<[Drink]>{
        guard let jsonData = data else {
            print(error!)
            return .fail(error!)
        }
        
        do{
            let jsonDict = try MixedUpAPI.jsonToDictionary(jsonData)
            let back = MixedUpAPI.getDrinksFromDictionary(jsonDict, inContext: (self.coreDataStack.privateQueueContext))
            return back
        } catch {
            print(error)
            return .fail(error as NSError)
        }
    }
    
    internal func fetchMainQueueDrinks(predicate: NSPredicate? = nil,
                                       sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Drink] {
        
        let fetchRequest = NSFetchRequest<Drink>(entityName: "Drink")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueDrink: [Drink]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait({
            do {
                mainQueueDrink = try mainQueueContext.fetch(fetchRequest)
            }
            catch let error {
                fetchRequestError = error
            }
        })
        
        guard let drink = mainQueueDrink else {
            throw fetchRequestError!
        }
        
        return drink
    }
    
    func createCoreDataDrink(newDrink: Drink, inContext context: NSManagedObjectContext) -> ResourceResult<Drink> {
        
        let dictionary = newDrink.toDictionary()
        
        var drink: Drink!
        context.performAndWait({ () -> Void in
            drink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                        into: context) as! Drink
            let ingredients = dictionary["ingredients"] as? [[String: Any]]
            var actualIngredients: [Ingredient] = []
            if let ingredients = ingredients{
                for theIngredient in ingredients {
                    if let ingredient = MixedUpAPI.getIngredientFromDictionary(theIngredient, inContext: context){
                        actualIngredients.append(ingredient)
                    }
                }
                if actualIngredients.count == ingredients.count {
                    let set: Set<Ingredient> = Set(actualIngredients)
                    drink.ingredients = set as NSSet?
                } else{
                    drink.ingredients = []
                }
            } else {
                drink.ingredients = []
            }
            drink.id = dictionary["id"] as? String ?? UUID().uuidString
            do{
                try self.coreDataStack.saveChanges()
            }catch {
                print("did not save User in coreData")
            }
        })
        return .success(drink)
        
    }
    
    
    func getAllDrinksFromCoreData() -> [Drink]{
        let mainQueueContext = self.coreDataStack.mainQueueContext
        
        let drinksFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Drink")
        var fetchedDrinks: [Drink] = []
        
        do {
            fetchedDrinks = try mainQueueContext.fetch(drinksFetch) as! [Drink]
            return fetchedDrinks
        } catch {
            print("Failed to fetch employees: \(error)")
            return []
        }
    }
    
    func getIBADrinks(completion: @escaping (ResourceResult<[Drink]>) -> ()){
        let url = URL(string: "https://n9hfoxnwqg.execute-api.us-east-2.amazonaws.com/alpha/drinks")!
        let request = requestBuilder(url: url, method: "GET")
        let task = session.dataTask(with: request,  completionHandler: {
            (data, response, error) -> Void in
            
            var result = self.processDrinkRequest(data: data, error: error as NSError?)
            
            if case .success(let drinks) = result {
                let privateQueueContext = self.coreDataStack.privateQueueContext
                privateQueueContext.performAndWait({
                    try! privateQueueContext.obtainPermanentIDs(for: drinks)
                })
                let objectIDs = drinks.map{ $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueueDrinks = try self.fetchMainQueueDrinks(predicate: predicate, sortDescriptors: [])
                    result = .success(mainQueueDrinks)
                }
                catch let error {
                    result = .fail(error as NSError)
                }
            }
            completion(result)
        })
        task.resume()
    }
    
    func getGeneratedDrinks(user: User, completion: @escaping (ResourceResult<[Drink]>) -> ()){
        let inventory = user.inventory?.allObjects as! [Ingredient]
        let names = inventory.map {$0.name!}
        let string = names.joined(separator: ",")
        let stringURL = "https://n9hfoxnwqg.execute-api.us-east-2.amazonaws.com/alpha/drinks?fromInventory=\(string)"
        let url = URL(string: stringURL)!
        let request = requestBuilder(url: url, method: "GET")
        let task = session.dataTask(with: request,  completionHandler: {
            (data, response, error) -> Void in
            var result = self.processDrinkRequest(data: data, error: error as NSError?)
            
            if case .success(let drinks) = result {
                let ids = drinks.map{$0.id}
                let predicate = NSPredicate(format: "id IN %@ ",ids)
                
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueueDrinks = try self.fetchMainQueueDrinks(predicate: predicate, sortDescriptors: [])
                    result = .success(mainQueueDrinks)
                }
                catch let error {
                    result = .fail(error as NSError)
                }
            }
            completion(result)
        })
        task.resume()
        
    }
    
}
