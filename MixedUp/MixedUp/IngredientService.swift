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
            return .failure((error!) as! (Errors))
        }
        
        do{
            let jsonDict = try MixedUpAPI.jsonToDictionary(jsonData)
            return MixedUpAPI.getIngredientsFromDictionary(jsonDict, inContext: (self.coreDataStack.privateQueueContext))
        } catch {
            print(error)
            return .failure((error) as! (Errors))
        }
    }
    
    internal func fetchMainQueueIngredients(predicate: NSPredicate? = nil,
                                            sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Ingredient] {
        
        let fetchRequest = NSFetchRequest<Ingredient>(entityName: "Ingredient")
        fetchRequest.sortDescriptors = sortDescriptors
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueIngredient: [Ingredient]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait({
            do {
                mainQueueIngredient = try mainQueueContext.fetch(fetchRequest)
            }
            catch let error {
                fetchRequestError = error
            }
        })
        
        guard let ingredient = mainQueueIngredient else {
            throw fetchRequestError!
        }
        
        return ingredient
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
    
    
}
