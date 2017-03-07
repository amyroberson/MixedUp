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
        guard let jsonData = data else { return .failure(.system(error!))}
        do {
            let jsonDict = try MixedUpAPI.jsonToDictionary(jsonData)
            return MixedUpAPI.getColorsFromDictionary(jsonDict, inContext: (self.coreDataStack.privateQueueContext))
        } catch {
            return .failure(.system(error))
        }
    }
    
    func fetchMainQueueColors(predicate: NSPredicate? = nil,
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
    
    //currently reading from file until the server is ready for production use
    func getAllColors(completion: @escaping (ResourceResult<[Color]>) -> ()){
        DispatchQueue.global(qos: .default).async {
            let fileURL = Bundle.main.url(forResource: "colors",
                                          withExtension: ".json")!
            do {
                
                let data = try Data(contentsOf: fileURL)
                var result = self.processColorRequest(data: data, error: nil)
                switch result{
                case .success(let colors):
                    let privateQueueContext = self.coreDataStack.privateQueueContext
                    privateQueueContext.performAndWait({
                        try! privateQueueContext.obtainPermanentIDs(for: colors)
                    })
                    let objectIDs = colors.map{ $0.objectID }
                    let predicate = NSPredicate(format: "self IN %@", objectIDs)
                    let sortByName = NSSortDescriptor(key: "displayName", ascending: true)
                    try self.coreDataStack.saveChanges()
                    let mainQueueColors = try self.fetchMainQueueColors(predicate: predicate, sortDescriptors: [sortByName])
                    result = .success(mainQueueColors)
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
