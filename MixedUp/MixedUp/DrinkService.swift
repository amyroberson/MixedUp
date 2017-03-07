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
            return .failure(.system(error!))
        }
        
        do{
            let jsonDict = try MixedUpAPI.jsonToDictionary(jsonData)
            let back = MixedUpAPI.getDrinksFromDictionary(jsonDict, inContext: (self.coreDataStack.privateQueueContext))
            return back
        } catch {
            print(error)
            return .failure(.system(error))
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
            let tools = dictionary["tools"] as? [[String:Any]]
            var actualTools: [Tool] = []
            if let tools = tools{
                for theTool in tools {
                    if let tool = MixedUpAPI.getToolFromDictionary(theTool, inContext: context){
                        actualTools.append(tool)
                    }
                }
                if actualTools.count == tools.count {
                    drink.tools = Set(actualTools) as NSSet?
                } else{
                    drink.tools = []
                }
            }  else {
                drink.tools = []
            }
            if let color = dictionary[MixedUpAPI.colorKey] as? [String: Any] {
                drink.color = MixedUpAPI.getColorFromDictionary(color, inContext: context)
            }
            if let glass = dictionary[MixedUpAPI.glassKey] as? [String: Any] {
                drink.glass = MixedUpAPI.getGlassFromDictionary(glass, inContext: context)
            }
            drink.displayName = dictionary["displayName"] as? String ?? ""
            drink.name = drink.displayName?.lowercased()
            drink.stringDescription = dictionary["description"] as? String ?? ""
            drink.id = dictionary["id"] as? String ?? UUID().uuidString
            drink.isAlcoholic = dictionary["isAlcoholic"] as? Bool ?? true
            drink.isIBAOfficial = dictionary["isIBAOfficial"] as? Bool ?? false
            do{
                try self.coreDataStack.saveChanges()
            }catch {
                print(error)
                print("did not save Drink in coreData")
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
    
    //currently reading from file until the server is ready for production use
    func getIBADrinks(completion: @escaping (ResourceResult<[Drink]>) -> ()){
        DispatchQueue.global(qos: .default).async {
            let fileURL = Bundle.main.url(forResource: "drinks",
                                          withExtension: ".json")!
            do {
                
                let data = try Data(contentsOf: fileURL)
                var result = self.processDrinkRequest(data: data, error: nil)
                switch result{
                case .success(let drinks):
                    let privateQueueContext = self.coreDataStack.privateQueueContext
                    privateQueueContext.performAndWait({
                        try! privateQueueContext.obtainPermanentIDs(for: drinks)
                    })
                    let objectIDs = drinks.map{ $0.objectID }
                    let predicate = NSPredicate(format: "self IN %@", objectIDs)
                    let sortByName = NSSortDescriptor(key: "displayName", ascending: true)
                    try self.coreDataStack.saveChanges()
                    let mainQueueDrinks = try self.fetchMainQueueDrinks(predicate: predicate, sortDescriptors: [sortByName])
                    result = .success(mainQueueDrinks)
                default:
                    print("couldn't process file")
                }
                completion(result)
            } catch {
                print("Could not read file")
            }
        }
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
                let sortByName = NSSortDescriptor(key: "displayName", ascending: true)
                
                
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueueDrinks = try self.fetchMainQueueDrinks(predicate: predicate, sortDescriptors: [sortByName])
                    result = .success(mainQueueDrinks)
                }
                catch let error {
                    result = .failure(.system(error))
                }
            }
            completion(result)
        })
        task.resume()
    }
}
