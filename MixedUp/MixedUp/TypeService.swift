//
//  TypeService.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/12/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

final class TypeService{
    
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
    
    func processTypeRequest(data: Data?, error: NSError?) -> ResourceResult<[IngredientType]> {
        guard let jsonData = data else { return .failure(.system(error!))}
        do {
            let jsonDict = try MixedUpAPI.jsonToDictionary(jsonData)
            return MixedUpAPI.getIngredientTypesFromDictionary(jsonDict, inContext: (self.coreDataStack.privateQueueContext))
        } catch {
            print(error)
            return .failure(.system(error))
        }
    }
    
    func fetchMainQueueTypes(predicate: NSPredicate? = nil,
                             sortDescriptors: [NSSortDescriptor]? = nil) throws -> [IngredientType] {
        let fetchRequest = NSFetchRequest<IngredientType>(entityName: "IngredientType")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "displayName", ascending: true)]
        fetchRequest.predicate = predicate
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueType: [IngredientType]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait({
            do {
                mainQueueType = try mainQueueContext.fetch(fetchRequest)
            }
            catch let error {
                fetchRequestError = error
            }
        })
        guard let type = mainQueueType else {
            throw fetchRequestError!
        }
        return type
    }
    
    func getAllTypes(completion: @escaping (ResourceResult<[IngredientType]>) -> ()){
        let url = URL(string: "https://n9hfoxnwqg.execute-api.us-east-2.amazonaws.com/alpha/ingredienttypes")!
        let request = requestBuilder(url: url, method: "GET")
        let task = session.dataTask(with: request,  completionHandler: {
            (data, response, error) -> Void in
            var result = self.processTypeRequest(data: data, error: error as NSError?)
            if case .success(let types) = result {
                let privateQueueContext = self.coreDataStack.privateQueueContext
                privateQueueContext.performAndWait({
                    try! privateQueueContext.obtainPermanentIDs(for: types)
                })
                let objectIDs = types.map{ $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                let sortByName = NSSortDescriptor(key: "displayName", ascending: true)
                do {
                    try self.coreDataStack.saveChanges()
                    let mainQueueTypes = try self.fetchMainQueueTypes(predicate: predicate, sortDescriptors: [sortByName])
                    result = .success(mainQueueTypes)
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
