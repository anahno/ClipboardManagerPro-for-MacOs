//
//  ContentView.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-04.
//
import SwiftUI
import CoreData

struct ContentView: View {
    let clipboardManager: ClipboardManager
    @EnvironmentObject var lockManager: LockManager
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.isPinned, order: .reverse),
            SortDescriptor(\.timestamp, order: .reverse)
        ],
        animation: .default)
    private var items: FetchedResults<ClipboardItemEntity>

    @State private var copiedItem: ClipboardItemEntity?
    @State private var searchText: String = ""
    @State private var showingPasswordSheet = false

    private var filteredHistory: [ClipboardItemEntity] {
        if searchText.isEmpty {
            return Array(items)
        } else {
            return items.filter { item in
                if let text = item.text_content {
                    return text.localizedCaseInsensitiveContains(searchText)
                }
                return false
            }
        }
    }

    var body: some View {
        if lockManager.isLocked {
            LockScreenView()
        } else {
            mainContentView
        }
    }

    private var mainContentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            searchBar
            
            if items.isEmpty {
                Text("Your clipboard history is empty.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredHistory.isEmpty {
                 Text("No results found.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                historyListView
            }
            
            Spacer()
            bottomButtonsView
        }
        .frame(width: 350, height: 400)
        .sheet(isPresented: $showingPasswordSheet) {
            SetPasswordView()
        }
    }

    private var headerView: some View {
        HStack {
            Text("Clipboard History")
                .font(.headline)
            Spacer()
            
            Button(action: {
                if lockManager.isPasswordSet { lockManager.lock() }
                else { showingPasswordSheet = true }
            }) {
                Image(systemName: lockManager.isPasswordSet ? "lock.fill" : "plus.circle")
            }
            .buttonStyle(PlainButtonStyle()).help(lockManager.isPasswordSet ? "Lock App" : "Set Password")
            
            Button(action: { showingPasswordSheet = true }) {
                Image(systemName: "key.fill")
            }
            .buttonStyle(PlainButtonStyle()).help("Password Settings")
        }
        .padding([.horizontal, .top])
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
            TextField("Search in history...", text: $searchText).textFieldStyle(PlainTextFieldStyle())
        }
        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .background(Color(.windowBackgroundColor)).cornerRadius(8)
        .padding(.init(top: 4, leading: 16, bottom: 12, trailing: 16))
    }

    // <<<<<<< ۱. اضافه کردن ScrollViewReader در اینجا
    private var historyListView: some View {
        ScrollViewReader { proxy in
            List(filteredHistory) { item in
                HStack(alignment: .center) {
                    Button(action: { clipboardManager.togglePin(item: item) }) {
                        Image(systemName: "pin")
                            .symbolVariant(item.isPinned ? .fill : .none)
                            .foregroundColor(item.isPinned ? .accentColor : .gray)
                    }.buttonStyle(PlainButtonStyle())
                    
                    if item.type == "text", let text = item.text_content {
                        TextItemView(text: text)
                            .onTapGesture { copyAction(for: item) }
                    } else if item.type == "image" {
                        ImageItemView(imageData: item.image_data, imageName: item.image_name, originalURLString: item.original_url_string)
                            .onTapGesture { copyAction(for: item) }
                    }
                    
                    Spacer()
                    actionButtons(for: item)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .background(copiedItem?.id == item.id ? Color.blue.opacity(0.2) : Color.clear)
                .cornerRadius(5)
                .id(item.id) // <<<<<<< ۲. مطمئن می‌شویم که هر آیتم یک id برای اسکرول کردن دارد
            }
            .listStyle(PlainListStyle())
            // <<<<<<< ۳. اضافه کردن onChange برای اسکرول خودکار
            .onChange(of: items.count) { _ in
                // فقط زمانی اسکرول کن که کاربر در حال جستجو نباشد
                guard searchText.isEmpty else { return }
                
                if let firstItem = items.first {
                    withAnimation {
                        proxy.scrollTo(firstItem.id, anchor: .top)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func actionButtons(for item: ClipboardItemEntity) -> some View {
        if copiedItem?.id == item.id {
            Image(systemName: "checkmark.circle.fill").foregroundColor(.green).transition(.scale)
        }
        
        if let urlString = item.original_url_string,
           let url = URL(string: urlString),
           FileManager.default.fileExists(atPath: url.path) {
            Button(action: { NSWorkspace.shared.activateFileViewerSelecting([url]) }) {
                Image(systemName: "folder").foregroundColor(.gray)
            }.buttonStyle(PlainButtonStyle()).help("Reveal in Finder")
        } else {
            copyButton(for: item)
        }
        
        Button(action: { clipboardManager.delete(item: item) }) {
            Image(systemName: "trash").foregroundColor(.gray)
        }.buttonStyle(PlainButtonStyle()).help("Delete")
    }

    private func copyButton(for item: ClipboardItemEntity) -> some View {
        Button(action: { copyAction(for: item) }) {
            Image(systemName: "doc.on.doc").foregroundColor(.gray)
        }.buttonStyle(PlainButtonStyle()).help("Copy")
    }
    
    private var bottomButtonsView: some View {
        HStack {
            Button("Clear Unpinned") {
                clipboardManager.clearHistory()
            }.foregroundColor(.red)
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }.padding(.init(top: 8, leading: 16, bottom: 12, trailing: 16))
    }
    
    private func copyAction(for item: ClipboardItemEntity) {
        clipboardManager.copyToClipboard(item: item)
        copiedItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let window = NSApp.keyWindow, window is NSPanel {
                window.close()
            }
            copiedItem = nil
        }
    }
}

struct TextItemView: View {
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text).lineLimit(1).truncationMode(.tail)
            HStack(spacing: 12) {
                Text("\(text.count) characters")
                Text("\(text.components(separatedBy: .newlines).count) lines")
            }.font(.caption).foregroundColor(Color("SyntaxInfoColor"))
        }
    }
}

struct ImageItemView: View {
    let imageData: Data?
    let imageName: String?
    let originalURLString: String?
    
    var body: some View {
        HStack {
            if let data = imageData, let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage).resizable().scaledToFit()
                    .frame(width: 40, height: 40).cornerRadius(4)
            } else {
                Rectangle().fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40).cornerRadius(4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(imageName ?? "Image").font(.callout).lineLimit(1).truncationMode(.middle)
                
                if let data = imageData, let imageRep = NSBitmapImageRep(data: data) {
                    Text("\(imageRep.pixelsWide) x \(imageRep.pixelsHigh)")
                        .font(.caption).foregroundColor(.secondary)
                }
                
                if let urlString = originalURLString, let url = URL(string: urlString),
                   FileManager.default.fileExists(atPath: url.path) {
                    Button(action: { NSWorkspace.shared.activateFileViewerSelecting([url]) }) {
                        Text(url.path.removingPercentEncoding ?? url.path)
                            .font(.caption2).foregroundColor(.accentColor)
                            .lineLimit(1).truncationMode(.middle)
                            .help("Click to reveal in Finder")
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}
