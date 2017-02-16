//
//  ColorService.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

final class ColorService{
    
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
    
    func processColorRequest(data: Data?, error: NSError?) -> ResourceResult<[Color]> {
        guard let jsonData = data else { return .fail((error!))}
        
        do {
            let jsonDict = try MixedUpAPI.jsonToDictionary(jsonData)
            return MixedUpAPI.getColorsFromDictionary(jsonDict, inContext: (self.coreDataStack.privateQueueContext))
        } catch {
            print(error)
            return .fail((error as NSError))
        }
        
    }
    
    func fetchMainQueueTypes(predicate: NSPredicate? = nil,
                             sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Color] {
        
        let fetchRequest = NSFetchRequest<Color>(entityName: "Color")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueColor: [Color]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait({
            do {
                mainQueueColor = try mainQueueContext.fetch(fetchRequest)
            }
            catch let error {
                fetchRequestError = error
            }
        })
        
        guard let type = mainQueueColor else {
            throw fetchRequestError!
        }
        
        return type
    }
    
    func getAllColors(completion: @escaping (ResourceResult<[Color]>) -> ()){
        let url = URL(string: "https://n9hfoxnwqg.execute-api.us-east-2.amazonaws.com/alpha/colors")!
        let request = requestBuilder(url: url, method: "GET")
        let task = session.dataTask(with: request,  completionHandler: {
            (data, response, error) -> Void in
            
            var result = self.processColorRequest(data: data, error: error as NSError?)
            
            if case .success(let colors) = result {
                let privateQueueContext = self.coreDataStack.privateQueueContext
                privateQueueContext.performAndWait({
                    try! privateQueueContext.obtainPermanentIDs(for: colors)
                })
                let objectIDs = colors.map{ $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueueTypes = try self.fetchMainQueueTypes(predicate: predicate, sortDescriptors: [])
                    result = .success(mainQueueTypes)
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