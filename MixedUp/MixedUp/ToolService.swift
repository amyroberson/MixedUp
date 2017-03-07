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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "displayName", ascending: true)]
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
    
    //currently reading from file until the server is ready for production use
    func getAllTools(completion: @escaping (ResourceResult<[Tool]>) -> ()){
        DispatchQueue.global(qos: .default).async {
            let fileURL = Bundle.main.url(forResource: "tools",
                                          withExtension: ".json")!
            do {
                
                let data = try Data(contentsOf: fileURL)
                var result = self.processToolRequest(data: data, error: nil)
                switch result{
                case .success(let tools):
                    let privateQueueContext = self.coreDataStack.privateQueueContext
                    privateQueueContext.performAndWait({
                        try! privateQueueContext.obtainPermanentIDs(for: tools)
                    })
                    let objectIDs = tools.map{ $0.objectID }
                    let predicate = NSPredicate(format: "self IN %@", objectIDs)
                    let sortByName = NSSortDescriptor(key: "displayName", ascending: true)
                    try self.coreDataStack.saveChanges()
                    let mainQueueTools = try self.fetchMainQueueTools(predicate: predicate, sortDescriptors: [sortByName])
                    result = .success(mainQueueTools)
                default:
                    print("couldn't process file")
                }
                completion(result)
            } catch {
                print("Could not read file")
            }
        }
    }
}
