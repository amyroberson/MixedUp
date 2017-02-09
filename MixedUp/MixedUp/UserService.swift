//
//  UserService.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/7/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

final class UserService{
    
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
    
    func processUserRequest(data: Data?, error: NSError?) -> ResourceResult<[User]>{
        guard let jsonData = data else {
            return .fail(error!)
        }
        
        do{
            let jsonDict = try MixedUpAPI.jsonToDictionary(jsonData)
            return MixedUpAPI.getUsersFromDictionary(jsonDict, inContext: (self.coreDataStack.privateQueueContext))
        } catch {
            print(error)
            return .fail((error as NSError))
        }
    }
    
    func processCreateUserRequest(data: Data?, error: NSError?) -> ResourceResult<User>{
        guard let jsonData = data else {
            return .fail(error!)
        }
        
        do{
            let jsonDict = try MixedUpAPI.jsonToDictionary(jsonData)
            let result = MixedUpAPI.getUserFromDictionary(jsonDict, inContext: (self.coreDataStack.privateQueueContext))
            if let result = result{
                return .success(result)
            } else {
                return .failure(Errors.invalidJSONData)
            }
            
        } catch {
            print(error)
            return .fail((error as NSError))
        }
    }
    
    internal func fetchMainQueueUsers(predicate: NSPredicate? = nil,
                                      sortDescriptors: [NSSortDescriptor]? = nil) throws -> [User] {
        
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.sortDescriptors = sortDescriptors
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueUser: [User]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait({
            do {
                mainQueueUser = try mainQueueContext.fetch(fetchRequest)
            }
            catch let error {
                fetchRequestError = error
            }
        })
        
        guard let post = mainQueueUser else {
            throw fetchRequestError!
        }
        
        return post
    }
    
    func createUser(user: User, completion: @escaping (ResourceResult<User>) -> ()) {
        let dict = user.toDictionary()
        do{
            let data = try MixedUpAPI.dictionaryToJson(dict)
            let url = URL(string: "https://arcane-journey-22728.herokuapp.com/users/")!
            var request = requestBuilder(url: url, method: "POST")
            request.httpBody = data
            let task = session.dataTask(with: request,  completionHandler: {
                (data, response, error) -> Void in
                
                var result = self.processCreateUserRequest(data: data, error: error as NSError?)
                
                if case .success(let user) = result {
                    let privateQueueContext = self.coreDataStack.privateQueueContext
                    privateQueueContext.performAndWait({
                        try! privateQueueContext.obtainPermanentIDs(for: [user])
                    })
                    let objectIDs = [user.objectID]
                    let predicate = NSPredicate(format: "self IN %@", objectIDs)
                    
                    do {
                        try self.coreDataStack.saveChanges()
                        
                        let mainQueueUser = try self.fetchMainQueueUsers(predicate: predicate,
                                                                          sortDescriptors: [])
                        if mainQueueUser.count > 0 {
                            result = .success(mainQueueUser[0])
                        }
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
    
    func getUser(id: String, completion: @escaping (ResourceResult<[User]>) -> ()) {
        let url = URL(string: "www.example.com/0/users/id")!
        let request = requestBuilder(url: url, method: "Get")
        let task = session.dataTask(with: request,  completionHandler: {
            (data, response, error) -> Void in
            
            var result = self.processUserRequest(data: data, error: error as NSError?)
            
            if case .success(let users) = result {
                let privateQueueContext = self.coreDataStack.privateQueueContext
                privateQueueContext.performAndWait({
                    try! privateQueueContext.obtainPermanentIDs(for: users)
                })
                let objectIDs = users.map{ $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueuePosts = try self.fetchMainQueueUsers(predicate: predicate,
                                                                      sortDescriptors: [])
                    result = .success(mainQueuePosts)
                }
                catch let error {
                    result = .failure(error as! Errors)
                }
            }
            completion(result)
        })
        task.resume()
    }
    
    //user updates inventory, favorite drinks, and during registration
    func updateUser(user: User, caseString: String, completion: @escaping (ResourceResult<[User]>) -> ()) {
        
        let url = URL(string: "www.example.com/0/users/\(user.id)")!
        var request = requestBuilder(url: url, method: "PUT")
        switch caseString{
        case "inventory":
            var ingredients: [[String: Any]] = []
            if let theIngredients = user.inventory?.allObjects as? [Ingredient]{
                for ingredient in theIngredients {
                    let dict = ingredient.toDictionary()
                    ingredients.append(dict)
                }
            }
            let body = "{\"update\": {\"inventory\": user.ingredients}}"
            do{
                let data = try JSONSerialization.data(withJSONObject: body, options: [])
                request.httpBody = data
            } catch {
                print("invalidJSONFormatting")
                return
            }
        default:
            print("invalidPerameters")
            return
        }
        let task = session.dataTask(with: request,  completionHandler: {
            (data, response, error) -> Void in
            
            var result = self.processUserRequest(data: data, error: error as NSError?)
            
            if case .success(let users) = result {
                let privateQueueContext = self.coreDataStack.privateQueueContext
                privateQueueContext.performAndWait({
                    try! privateQueueContext.obtainPermanentIDs(for: users)
                })
                let objectIDs = users.map{ $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueuePosts = try self.fetchMainQueueUsers(predicate: predicate,
                                                                      sortDescriptors: [])
                    result = .success(mainQueuePosts)
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
