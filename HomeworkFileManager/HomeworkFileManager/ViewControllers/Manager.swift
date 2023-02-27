//
//  Manager.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 24.02.23.
//

import Foundation
import UIKit

//MARK: - Struct -

struct File {
    var type: CatalogCellType
    var url: URL
}

//MARK: - Enum -

enum CatalogCellType: String {
    case image = "Images"
    case folder = "Folders"
}

//MARK: - Protocol -

protocol ManagerProtocol {
    
    var fileCatalog: [File] { get set }
    var arrayURlDelete: [URL] { get set }
    var currentCatalogURL: URL { get set }
    
    func checkingFilesInDocuments()
    func deleteSelectedSell(_ tableView: UITableView, _ collectionView: UICollectionView)
    func createNewCatalog(nameCatalog: String ) -> Bool
    func createNewImage(url: URL) -> URL
    func appendImageIFileCatalog(url: URL)
    func sectionEntry(section: Int) -> Int
    func sectionTitle(section: Int) -> String
    func displayImageInCellsTableView() -> [File]
    func displayFolderInCellsTableView() -> [File]
    func deleteCells(indexPath: IndexPath)
    func deselectCells(indexPath: IndexPath)
}

//MARK: - Class -

class Manager: ManagerProtocol {
    
    //MARK: - Properties -
    
    var fileManager: FileManager = .default
    var fileCatalog: [File] = []
    var arrayURlDelete: [URL] = []
    lazy var currentCatalogURL: URL = {
            fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }()
    
    //MARK: - Methods -
    
    //Check File in Documents
    func checkingFilesInDocuments() {
        do {
            let directoryContent = try fileManager.contentsOfDirectory(at: currentCatalogURL, includingPropertiesForKeys: nil).filter{ $0.lastPathComponent != ".DS_Store" }
            directoryContent.forEach({  $0.hasDirectoryPath ? fileCatalog.append(File(type: .folder, url: $0)) : fileCatalog.append(File(type: .image, url: $0)) })
        } catch {
           fatalError("Unable to read directory")
        }
    }
    
    //Delete Selection Cell
    func deleteSelectedSell(_ tableView: UITableView, _ collectionView: UICollectionView) {
        fileCatalog = fileCatalog.filter{ !arrayURlDelete.contains($0.url) }
          for url in arrayURlDelete {
              do {
                  try fileManager.removeItem(at: url)
              } catch {
                  fatalError("Error")
              }
              arrayURlDelete = arrayURlDelete.filter({ $0 != url })
              tableView.reloadData()
              collectionView.reloadData()
          }
    }
    
    //Creating a new catalog
    func createNewCatalog(nameCatalog: String ) -> Bool {
        guard !fileCatalog.contains(where: { $0.url.lastPathComponent == nameCatalog }) else {
            return false
        }
        let newFolder = currentCatalogURL.appending(path: nameCatalog)
        try? fileManager.createDirectory(at: newFolder, withIntermediateDirectories: false)
        let folderFile = File(type: .folder, url: newFolder)
        fileCatalog.append(folderFile)
        return true
    }
    
    //Creating a new image
    func createNewImage(url: URL) -> URL {
        currentCatalogURL.appending(path: url.lastPathComponent)
    }
    
    func appendImageIFileCatalog(url: URL) {
        let imageFile = File(type: .image, url: url)
        self.fileCatalog.append(imageFile)
    }
    
    //Split photos and folders into sections
    func sectionEntry(section: Int) -> Int {
        if section == 0 {
            return fileCatalog.filter({ $0.type == .image}).count
        } else {

            return fileCatalog.filter({ $0.type == .folder }).count
        }
    }
  
    //Choice of section names
    func sectionTitle(section: Int) -> String {
        if section == 0, fileCatalog.filter({ $0.type == .image}).count > 0 {
            return CatalogCellType.image.rawValue
        } else if section == 1, fileCatalog.filter({ $0.type == .folder }).count > 0 {
            return CatalogCellType.folder.rawValue
        } else {
            return ""
        }
    }
    
    //Display images and folders in cells TableView
    func displayImageInCellsTableView() -> [File] {
        return fileCatalog.filter({ $0.type == .image})
    }

    func displayFolderInCellsTableView() -> [File] {
        return fileCatalog.filter({ $0.type == .folder})
    }

    //Delete Cells
    func deleteCells(indexPath: IndexPath) {
        if indexPath.section == 0 {
            let imageDelete = fileCatalog.filter({ $0.type == .image})[indexPath.row].url
            if !arrayURlDelete.contains(imageDelete) {
                arrayURlDelete.append(imageDelete)
            }
        } else {
            let folderDelete = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
            if !arrayURlDelete.contains(folderDelete) {
                arrayURlDelete.append(folderDelete)
            }
        }
    }
    
    //Deselect Cells
    func deselectCells(indexPath: IndexPath) {
        if indexPath.section == 0 {
            let imageDelete = fileCatalog.filter({ $0.type == .image})[indexPath.row].url
            arrayURlDelete = arrayURlDelete.filter({ $0 != imageDelete })
        } else {
            let folderDelete = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
            arrayURlDelete = arrayURlDelete.filter({ $0 != folderDelete })
        }
    }
    
}
