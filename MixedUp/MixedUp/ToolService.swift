//
//  ToolsService.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

final class ToolService{
    
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
    
    func processToolRequest(data: Data?, error: NSError?) -> ResourceResult<[Tool]> {
        guard let jsonData = data else { return .failure(.system(error!))}
        do {
            let jsonDict = try MixedUpAPI.jsonToDictionary(jsonData)
            return MixedUpAPI.getToolsFromDictionary(jsonDict, inContext: (self.coreDataStack.privateQueueContext))
        } catch {
            return .failure(.system(error))
        }
    }
    
    func fetchMainQueueTools(predicate: NSPredicate? = nil,
                             sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Tool] {
        let fetchRequest = NSFetchRequest<Tool>(entityName: "Tool")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueTool: [Tool]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait({
            do {
                mainQueueTool = try mainQueueContext.fetch(fetchRequest)
            }
            catch let error {
                fetchRequestError = error
            }
        })
        guard let type = mainQueueTool else {
            throw fetchRequestError!
        }
        return type
    }
    
    func getAllTools(completion: @escaping (ResourceResult<[Tool]>) -> ()){
        let url = URL(string: "https://n9hfoxnwqg.execute-api.us-east-2.amazonaws.com/alpha/tools")!
        let request = requestBuilder(url: url, method: "GET")
        let task = session.dataTask(with: request,  completionHandler: {
            (data, response, error) -> Void in
            var result = self.processToolRequest(data: data, error: error as NSError?)
            if case .success(let tools) = result {
                let privateQueueContext = self.coreDataStack.privateQueueContext
                privateQueueContext.performAndWait({
                    try! privateQueueContext.obtainPermanentIDs(for: tools)
                })
                let objectIDs = tools.map{ $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                do {
                    try self.coreDataStack.saveChanges()
                    let mainQueueTools = try self.fetchMainQueueTools(predicate: predicate, sortDescriptors: [])
                    result = .success(mainQueueTools)
                }
                catch let error {
                    result = .failure(.system(error))                }
            }
            completion(result)
        })
        task.resume()
    }
}
