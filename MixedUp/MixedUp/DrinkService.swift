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
    
    var coreDataStack: CoreDataStack? = nil
    
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
            return .failure((error!) as! (Errors))
        }
        
        do{
            let jsonDict = try MixedUpAPI.jsonToDictionary(jsonData)
            return MixedUpAPI.getDrinksFromDictionary(jsonDict, inContext: (self.coreDataStack?.privateQueueContext)!)
        } catch {
            print(error)
            return .failure((error) as! (Errors))
        }
    }
    
    internal func fetchMainQueueDrinks(predicate: NSPredicate? = nil,
                                      sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Drink] {
        
        let fetchRequest = NSFetchRequest<Drink>(entityName: "Drink")
        fetchRequest.sortDescriptors = sortDescriptors
        
        let mainQueueContext = self.coreDataStack?.mainQueueContext
        var mainQueueDrink: [Drink]?
        var fetchRequestError: Error?
        mainQueueContext?.performAndWait({
            do {
                mainQueueDrink = try mainQueueContext?.fetch(fetchRequest)
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
    
    func getIBADrinks(json: Data, completion: @escaping (ResourceResult<[Drink]>) -> ()){
        let url = URL(string: "www.example.com/0/drinks?isIBAOfficial=true")!
        let request = requestBuilder(url: url, method: "GET")
        let task = session.dataTask(with: request,  completionHandler: {
            (data, response, error) -> Void in
            
            var result = self.processDrinkRequest(data: data, error: error as NSError?)
            
            if case .success(let drinks) = result {
                let privateQueueContext = self.coreDataStack?.privateQueueContext
                privateQueueContext?.performAndWait({
                    try! privateQueueContext?.obtainPermanentIDs(for: drinks)
                })
                let objectIDs = drinks.map{ $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                let sortByDateTaken = NSSortDescriptor(key: "createdAt", ascending: false)
                
                do {
                    try self.coreDataStack?.saveChanges()
                    
                    let mainQueueDrinks = try self.fetchMainQueueDrinks(predicate: predicate,
                                                                      sortDescriptors: [sortByDateTaken])
                    result = .success(mainQueueDrinks)
                }
                catch let error {
                    result = .failure(error as! Errors)
                }
            }
            completion(result)
        })
        task.resume()
    }
    
}