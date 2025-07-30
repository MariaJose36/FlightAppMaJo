//
//  CoreDataManager.swift
//  CodeChallengeFlightApp
//
//  Created by Cincinnati Ai on 7/30/25.
//
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init()  {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoriteModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}

extension CoreDataManager {
    func saveFavoriteFlight(flightNumber: String) {
        let favorite = FavoriteFlight(context: context)
        favorite.flightNumber = flightNumber
        saveContext()
    }
    
    func isFavorite(flightNumber: String) -> Bool {
        let request: NSFetchRequest<FavoriteFlight> = FavoriteFlight.fetchRequest()
        request.predicate = NSPredicate(format: "flightNumber == %@", flightNumber)
        let result = try? context.fetch(request)
        return !(result?.isEmpty ?? true)
    }
    
    func deleteFavorite(flightNumber: String) {
        let request: NSFetchRequest<FavoriteFlight> = FavoriteFlight.fetchRequest()
        request.predicate = NSPredicate(format: "flightNumber == %@", flightNumber)
        if let results = try? context.fetch(request), let toDelete = results.first {
            context.delete(toDelete)
            saveContext()
        }
    }
}
