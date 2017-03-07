//
//  GlassService.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

final class GlassService{
    
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
    
    func processGlassRequest(data: Data?, error: NSError?) -> ResourceResult<[Glass]> {
        guard let jsonData = data else { return .failure(.system(error!))}
        
        do {
            let jsonDict = try MixedUpAPI.jsonToDictionary(jsonData)
            return MixedUpAPI.getGlassesFromDictionary(jsonDict, inContext: (self.coreDataStack.privateQueueContext))
        } catch {
            print(error)
            return .failure(.system(error))
        }
    }
    
    func fetchMainQueueGlasses(predicate: NSPredicate? = nil,
                               sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Glass] {
        let fetchRequest = NSFetchRequest<Glass>(entityName: "Glass")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueType: [Glass]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait({
            do {
                mainQueueType = try mainQueueContext.fetch(fetchRequest)
            }
            catch let error {
                fetchRequestError = error
            }
        })
        guard let glass = mainQueueType else {
            throw fetchRequestError!
        }
        return glass
    }
    
    //currently reading from file until the server is ready for production use
    func getAllGlasses(completion: @escaping (ResourceResult<[Glass]>) -> ()){
        DispatchQueue.global(qos: .default).async {
            let fileURL = Bundle.main.url(forResource: "glasses",
                                          withExtension: ".json")!
            do {
                
                let data = try Data(contentsOf: fileURL)
                var result = self.processGlassRequest(data: data, error: nil)
                switch result{
                case .success(let glasses):
                    let privateQueueContext = self.coreDataStack.privateQueueContext
                    privateQueueContext.performAndWait({
                        try! privateQueueContext.obtainPermanentIDs(for: glasses)
                    })
                    let objectIDs = glasses.map{ $0.objectID }
                    let predicate = NSPredicate(format: "self IN %@", objectIDs)
                    let sortByName = NSSortDescriptor(key: "displayName", ascending: true)
                    try self.coreDataStack.saveChanges()
                    let mainQueueGlasses = try self.fetchMainQueueGlasses(predicate: predicate, sortDescriptors: [sortByName])
                    result = .success(mainQueueGlasses)
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
