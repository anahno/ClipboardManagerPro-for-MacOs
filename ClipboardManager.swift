//
//  ClipboardManager.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-04.
//
//  REBUILT with Core Data - Final Corrected Version v3
//

import SwiftUI
import CoreData

class ClipboardManager {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func startListening() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }

    func stopListening() { timer?.invalidate(); timer = nil }
    
    private func checkForChanges() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        
        lastChangeCount = pasteboard.changeCount
        
        if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage,
           let pngData = image.toPNGData() {
            var imageURL: URL?
            if let fileURLString = pasteboard.string(forType: .fileURL), let url = URL(string: fileURLString) { imageURL = url }
            addItem(type: "image", textContent: nil, imageData: pngData, imageName: imageURL?.lastPathComponent, originalURL: imageURL)
        
        } else if let fileURLString = pasteboard.string(forType: .fileURL), let fileURL = URL(string: fileURLString) {
            if let imageFromFile = imageFrom(url: fileURL), let pngData = imageFromFile.toPNGData() {
                addItem(type: "image", textContent: nil, imageData: pngData, imageName: fileURL.lastPathComponent, originalURL: fileURL)
            }
        
        } else if let newString = pasteboard.string(forType: .string), !newString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if let imageFromFile = imageFrom(pathString: newString), let pngData = imageFromFile.toPNGData() {
                let imageURL = URL(fileURLWithPath: newString)
                addItem(type: "image", textContent: nil, imageData: pngData, imageName: imageURL.lastPathComponent, originalURL: imageURL)
            } else {
                addItem(type: "text", textContent: newString, imageData: nil, imageName: nil, originalURL: nil)
            }
        }
    }
    
    private func addItem(type: String, textContent: String?, imageData: Data?, imageName: String?, originalURL: URL?) {
        let newItem = ClipboardItemEntity(context: context)
        newItem.id = UUID()
        newItem.timestamp = Date()
        newItem.isPinned = false
        newItem.type = type
        newItem.text_content = textContent
        newItem.image_data = imageData
        newItem.image_name = imageName
        newItem.original_url_string = originalURL?.absoluteString
        
        saveContext()
        applyHistoryLimit()
    }
    
    func addImageFromFile(image: NSImage, url: URL) {
        if let pngData = image.toPNGData() {
            addItem(type: "image", textContent: nil, imageData: pngData, imageName: url.lastPathComponent, originalURL: url)
        }
    }
    
    func copyToClipboard(item: ClipboardItemEntity) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        if item.type == "text", let text = item.text_content {
            pasteboard.setString(text, forType: .string)
        } else if item.type == "image", let data = item.image_data, let image = NSImage(data: data) {
            pasteboard.writeObjects([image])
        }
    }

    func togglePin(item: ClipboardItemEntity) {
        item.isPinned.toggle()
        saveContext()
    }

    func delete(item: ClipboardItemEntity) {
        context.delete(item)
        saveContext()
    }

    // <<<<<<< اصلاح نهایی و قطعی برای دکمه Clear Unpinned >>>>>>>
    func clearHistory() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ClipboardItemEntity")
        request.predicate = NSPredicate(format: "isPinned == FALSE")
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        // نتیجه را به صورت لیستی از ID های آبجکت‌های حذف شده می‌خواهیم
        deleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            // ۱. دستور حذف را اجرا می‌کنیم
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            
            // ۲. لیستی از ID های حذف شده را استخراج می‌کنیم
            guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
            
            // ۳. این تغییرات را با context اصلی برنامه ادغام (merge) می‌کنیم
            // این کار به @FetchRequest در SwiftUI اطلاع می‌دهد که UI را به‌روز کند
            let changes = [NSDeletedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            
        } catch {
            print("Failed to clear history with batch delete: \(error)")
        }
    }
    
    private func applyHistoryLimit() {
        let historyLimitKey = "historyLimit"
        let limit = UserDefaults.standard.integer(forKey: historyLimitKey)
        let historyLimit = limit > 0 ? limit : 20
        
        let request = NSFetchRequest<ClipboardItemEntity>(entityName: "ClipboardItemEntity")
        request.predicate = NSPredicate(format: "isPinned == FALSE")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ClipboardItemEntity.timestamp, ascending: true)]
        
        do {
            let unpinnedItems = try context.fetch(request)
            if unpinnedItems.count > historyLimit {
                let itemsToDelete = unpinnedItems.prefix(unpinnedItems.count - historyLimit)
                for item in itemsToDelete {
                    context.delete(item)
                }
                saveContext()
            }
        } catch {
            print("Failed to apply history limit: \(error)")
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func imageFrom(url: URL) -> NSImage? {
        let fileExtension = url.pathExtension.lowercased()
        let imageExtensions = ["png", "jpg", "jpeg", "gif", "tiff", "bmp"]
        if imageExtensions.contains(fileExtension) && FileManager.default.fileExists(atPath: url.path) {
            return NSImage(contentsOf: url)
        }
        return nil
    }
    
    private func imageFrom(pathString: String) -> NSImage? {
        let url: URL?
        if pathString.hasPrefix("file://") { url = URL(string: pathString) }
        else { url = URL(fileURLWithPath: pathString) }
        guard let fileURL = url else { return nil }
        return imageFrom(url: fileURL)
    }
}

extension NSImage {
    func toPNGData() -> Data? {
        guard let tiffRepresentation = self.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
}
