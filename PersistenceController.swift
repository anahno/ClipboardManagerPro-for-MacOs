//
//  PersistenceController.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-07.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ClipboardManagerPro")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // <<<<<<< اصلاح اصلی و نهایی در این تابع است >>>>>>>
    func deleteAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ClipboardItemEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // نتیجه را به صورت لیستی از ID های آبجکت‌های حذف شده می‌خواهیم
        deleteRequest.resultType = .resultTypeObjectIDs

        do {
            // ۱. دستور حذف را اجرا می‌کنیم
            let result = try container.viewContext.execute(deleteRequest) as? NSBatchDeleteResult
            
            // ۲. لیستی از ID های حذف شده را استخراج می‌کنیم
            guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
            
            // ۳. این تغییرات را با context اصلی برنامه ادغام (merge) می‌کنیم
            // این کار به @FetchRequest در SwiftUI اطلاع می‌دهد که UI را به‌روز کند
            let changes = [NSDeletedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])

        } catch {
            print("Failed to delete all data: \(error)")
        }
    }
}
