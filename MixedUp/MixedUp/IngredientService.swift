//
//  IngredientService.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/7/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

final class IngredientService{
    
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
    
    func processIngredientRequest(data: Data?, error: NSError?) -> ResourceResult<[Ingredient]>{
        guard let jsonData = data else {
            return .fail((error!))
        }
        
        do{
            let jsonDict = try MixedUpAPI.jsonToDictionary(jsonData)
            return MixedUpAPI.getIngredientsFromDictionary(jsonDict, inContext: (self.coreDataStack.privateQueueContext))
        } catch {
            print(error)
            return .fail((error as NSError))
        }
    }
    
    internal func fetchMainQueueIngredients(predicate: NSPredicate? = nil,
                                            sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Ingredient] {
        
        let fetchRequest = NSFetchRequest<Ingredient>(entityName: Ingredient.entityName)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueIngredients: [Ingredient]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait({
            do {
                mainQueueIngredients = try mainQueueContext.fetch(fetchRequest)
            }
            catch let error {
                fetchRequestError = error
            }
        })
        
        guard let ingredients = mainQueueIngredients else {
            throw fetchRequestError!
        }
        
        return ingredients
    }
    
    func fetchIngredient(ingredient: User, inContext context: NSManagedObjectContext) -> ResourceResult<Ingredient> {
        let dictionary = ingredient.toDictionary()
        
        guard let id = dictionary["id"] as? String else { return .failure(.inValidParameter)}
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ingredient")
        let predicate = NSPredicate(format: "id == \"\(id)\"")
        fetchRequest.predicate = predicate
        
        let fetchedIngredient: [Ingredient] = {
            var ingredients: [Ingredient]!
            context.performAndWait() {
                ingredients = try! context.fetch(fetchRequest) as! [Ingredient]
            }
            return ingredients
        }()
        if let firstIngredient = fetchedIngredient.first {
            return  .success(firstIngredient)
        } else {
            return .failure(.inValidParameter)
        }
        
    }
    
    func createCoreDataIngredient( dictionary: [String: Any], inContext context: NSManagedObjectContext) -> ResourceResult<Ingredient> {
        var ingredient: Ingredient!
        context.performAndWait({ () -> Void in
            ingredient = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                             into: context) as! Ingredient
            ingredient.name = dictionary["name"] as? String ?? ""
            ingredient.id = dictionary["id"] as? String ?? UUID().uuidString
            ingredient.displayName = dictionary["displayName"] as? String ?? ""
            ingredient.isAlcoholic = dictionary["isAlcoholic"] as? Bool ?? false
            
            if let type = dictionary["type"] as? IngredientType {
                let dictionary = type.toDictionary()
                let theType = MixedUpAPI.getIngredientTypeFromDictionary(dictionary, inContext: context)
                ingredient.type = theType
            }
        })
        let result = saveIngredient(ingredient: ingredient, inContext: context)
        if let result = result {
            return .success(result)
        } else {
            return .failure(.failedToSave)
        }
    }
    
    
    
    func createIngredient(ingredient: Ingredient, completion: @escaping (ResourceResult<[Ingredient]>) -> ()){
        let dict = ingredient.toDictionary()
        do{
            let data = try MixedUpAPI.dictionaryToJson(dict)
            let url = URL(string: "www.example.com")!
            var request = requestBuilder(url: url, method: "POST")
            request.httpBody = data
            let task = session.dataTask(with: request,  completionHandler: {
                (data, response, error) -> Void in
                
                var result = self.processIngredientRequest(data: data, error: error as NSError?)
                
                if case .success(let ingredients) = result {
                    let privateQueueContext = self.coreDataStack.privateQueueContext
                    privateQueueContext.performAndWait({
                        try! privateQueueContext.obtainPermanentIDs(for: ingredients)
                    })
                    let objectIDs = ingredients.map{ $0.objectID }
                    let predicate = NSPredicate(format: "self IN %@", objectIDs)
                    
                    do {
                        try self.coreDataStack.saveChanges()
                        
                        let mainQueueIngredients = try self.fetchMainQueueIngredients(predicate: predicate,
                                                                                      sortDescriptors: [])
                        result = .success(mainQueueIngredients)
                    }
                    catch let error {
                        result = .failure(error as! Errors)
                    }
                }
                completion(result)
            })
            task.resume()
        } catch {
            print("toJsonError")
        }
    }
    
    func saveIngredient(ingredient: Ingredient, inContext context:NSManagedObjectContext) -> Ingredient?{
        let privateQueueContext = context
        privateQueueContext.performAndWait({
            try! privateQueueContext.obtainPermanentIDs(for: [ingredient])
        })
        let objectIDs = [ingredient.objectID]
        let predicate = NSPredicate(format: "self IN %@", objectIDs)
        
        do {
            try self.coreDataStack.saveChanges()
            
            let mainQueueIngredients = try self.fetchMainQueueIngredients(predicate: predicate,
                                                                          sortDescriptors: [])
            return mainQueueIngredients.last
        } catch let error {
            print (error)
            return nil
        }
    }
    
    func getIngredientsOfType(type: IngredientType, completion: @escaping (ResourceResult<[Ingredient]>) -> ()){
        let typeID = type.id!
        let string = "https://n9hfoxnwqg.execute-api.us-east-2.amazonaws.com/alpha/ingredients?withTypeIds=\(typeID)"
        let url = URL(string: string)!
        let request = requestBuilder(url: url, method: "GET")
        let task = session.dataTask(with: request,  completionHandler: {
            (data, response, error) -> Void in
            var result = self.processIngredientRequest(data: data, error: error as NSError?)
            
            if case .success(let ingredients) = result {
                let ids = ingredients.map{$0.id}
                let predicate = NSPredicate(format: "id IN %@ ",ids)
                
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueueIngredients = try self.fetchMainQueueIngredients(predicate: predicate, sortDescriptors: [])
                    result = .success(mainQueueIngredients)
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
