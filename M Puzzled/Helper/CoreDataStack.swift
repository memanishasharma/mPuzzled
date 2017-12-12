//
//  CoreDataStack.swift
//  M Puzzled
//
//  Created by Manisha on 18/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack:NSObject{
	// MARK: - Core Data stack
	static let sharedInstance = CoreDataStack()
	private override init() {}
	
	//	lazy var persistentContainer: NSPersistentContainer = {
	//		    /*
	//		     The persistent container for the application. This implementation
	//		     creates and returns a container, having loaded the store for the
	//		     application to it. This property is optional since there are legitimate
	//		     error conditions that could cause the creation of the store to fail.
	//		    */
	//		    let container = NSPersistentContainer(name: "M_Puzzled")
	//		    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
	//		        if let error = error as NSError? {
	//		            // Replace this implementation with code to handle the error appropriately.
	//		            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	//
	//		            /*
	//		             Typical reasons for an error here include:
	//		             * The parent directory does not exist, cannot be created, or disallows writing.
	//		             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
	//		             * The device is out of space.
	//		             * The store could not be migrated to the current model version.
	//		             Check the error message to determine what the actual problem was.
	//		             */
	//		            fatalError("Unresolved error \(error), \(error.userInfo)")
	//		        }
	//		    })
	//		    return container
	//		}()
	//
	//		// MARK: - Core Data Saving support
	//
	//		func saveContext () {
	//			let context = persistentContainer.viewContext
	//			if context.hasChanges {
	//				do {
	//					try context.save()
	//				} catch {
	//					// Replace this implementation with code to handle the error appropriately.
	//					// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	//					let nserror = error as NSError
	//					fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
	//				}
	//			}
	//		}
	lazy var applicationDocumentsDirectory: URL = {
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[urls.count-1]
	}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.appendingPathComponent("M_Puzzled.sqlite")
		
		var failureReason = "There was an error creating or loading the application's saved data."
		do {
			let options = [
				NSMigratePersistentStoresAutomaticallyOption: true,
				NSInferMappingModelAutomaticallyOption: true
			]
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
		} catch let error as NSError {
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
			dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
			
			dict[NSUnderlyingErrorKey] = error
			let wrappedError = NSError(domain: "M_Puzzled", code: 9999, userInfo: dict)
			print("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		} catch {
			print("Unresolved error \(error), \(failureReason)00")
			abort()
		}
		
		return coordinator
	}()
	
	lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()
	
	lazy var managedObjectContextMain: NSManagedObjectContext = {
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.backendContextDidSaved(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
		// managedObjectContext.parentContext = self.managedObjectContext
		return managedObjectContext
	}()
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = Bundle.main.url(forResource: "M_Puzzled", withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()
	
	@objc func backendContextDidSaved(_ notification: Notification) {
		if let sourceManagedObjectContext = notification.object as? NSManagedObjectContext, sourceManagedObjectContext == self.managedObjectContext {
			self.managedObjectContextMain.performAndWait({
				self.managedObjectContextMain.mergeChanges(fromContextDidSave: notification)
			})
		}
	}
	
	func saveContext () {
		let context = self.managedObjectContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
}
