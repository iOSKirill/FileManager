//
//  Manager.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 24.02.23.
//

import Foundation
import UIKit

//MARK: - Protocol -

protocol ManagerProtocol {
    var fileManager: FileManager { get set }
    var fileCatalog: [File] { get set }
    var arrayURlDelete: [URL] { get set }
    var currentCatalogURL: URL { get set }
    
    func checkingFilesInDocuments()
    func deleteSelectedSell(_ tableView: UITableView, _ collectionView: UICollectionView)
    func createNewCatalog(nameCatalog: String, alertDirectoryError: Void)
    func createNewImage(info: [UIImagePickerController.InfoKey : Any])
    func sectionEntry(section: Int) -> Int
    func sectionTitle(section: Int) -> String
    func displayInfoInCells(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    func moveToSelectedImageCell(indexPath: IndexPath,imageVC: ImageViewController)
    func moveToSelectedFolderCell(indexPath: IndexPath,folderVC: ViewController)
    func deleteImageCells(indexPath: IndexPath, addDeleteSelectedSellButton: UIBarButtonItem)
    func deleteFolderCells(indexPath: IndexPath, addDeleteSelectedSellButton: UIBarButtonItem)
    func deselectImageCells(indexPath: IndexPath, addDeleteSelectedSellButton: UIBarButtonItem)
    func deselectFolderCells(indexPath: IndexPath, addDeleteSelectedSellButton: UIBarButtonItem)
    
    func printHello()
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
    func createNewCatalog(nameCatalog: String, alertDirectoryError: Void) {
        guard fileCatalog.contains(where: { $0.url.lastPathComponent == nameCatalog }) else {
            alertDirectoryError
            return
        }
        let newFolder = self.currentCatalogURL.appending(path: nameCatalog)
        try? fileManager.createDirectory(at: newFolder, withIntermediateDirectories: false)
        let folderFile = File(type: .folder, url: newFolder)
        fileCatalog.append(folderFile)
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
    
    //Display images and folders in cells
    func displayInfoInCells(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogImageCell.key, for: indexPath) as? CatalogImageCell else { return UITableViewCell() }
            cell.thumbnailImage.image = UIImage(contentsOfFile: fileCatalog.filter({ $0.type == .image})[indexPath.row].url.path)?.preparingThumbnail(of: .init(width: 50, height: 50))
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogFolderCell.key, for: indexPath) as? CatalogFolderCell else { return UITableViewCell() }
            cell.nameCatalogLabel.text = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url.lastPathComponent
            return cell
        }
    }
    
    //Open ImageViewController
    func moveToSelectedImageCell(indexPath: IndexPath,imageVC: ImageViewController) {
        guard let firstImage = UIImage(contentsOfFile: fileCatalog.filter({ $0.type == .image })[indexPath.row].url.path) else { return }
        imageVC.imageArray.insert(firstImage, at: 0)
        let firstUrl = fileCatalog.filter({ $0.type == .image })[indexPath.row].url
        
        fileCatalog.forEach { i in
            if let fullImage = UIImage(contentsOfFile: i.url.path), i.url != firstUrl {
                imageVC.imageArray.append(fullImage)
            }
        }
    }
    
    //Open ViewController
    func moveToSelectedFolderCell(indexPath: IndexPath,folderVC: ViewController) {
        folderVC.fileManager2.currentCatalogURL = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
        folderVC.title = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url.lastPathComponent
    }
    
    //Delete Image Cells
    func deleteImageCells(indexPath: IndexPath, addDeleteSelectedSellButton: UIBarButtonItem) {
        let imageDelete = fileCatalog.filter({ $0.type == .image})[indexPath.row].url
        if !arrayURlDelete.contains(imageDelete) {
            arrayURlDelete.append(imageDelete)
        }
        addDeleteSelectedSellButton.isEnabled = arrayURlDelete.count > 0
    }
    
    //Delete Folder Cells
    func deleteFolderCells(indexPath: IndexPath, addDeleteSelectedSellButton: UIBarButtonItem) {
        let folderDelete = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
        if !arrayURlDelete.contains(folderDelete) {
            arrayURlDelete.append(folderDelete)
        }
        addDeleteSelectedSellButton.isEnabled = arrayURlDelete.count > 0
    }
    
    //Deselect Image Cells
    func deselectImageCells(indexPath: IndexPath, addDeleteSelectedSellButton: UIBarButtonItem) {
        let imageDelete = fileCatalog.filter({ $0.type == .image})[indexPath.row].url
        arrayURlDelete = arrayURlDelete.filter({ $0 != imageDelete })
        addDeleteSelectedSellButton.isEnabled = arrayURlDelete.count != 0
    }
    
    //Deselect Folder Cells
    func deselectFolderCells(indexPath: IndexPath, addDeleteSelectedSellButton: UIBarButtonItem) {
        let folderDelete = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
        arrayURlDelete = arrayURlDelete.filter({ $0 != folderDelete })
        addDeleteSelectedSellButton.isEnabled = arrayURlDelete.count != 0
    }
    
    //Creating a new image
    func createNewImage(info: [UIImagePickerController.InfoKey : Any]) {
        guard let imageURL = info[.imageURL] as? URL,
        let editImage = info[.editedImage] as? UIImage else { return }
        
        let newImageURL = currentCatalogURL.appending(path: imageURL.lastPathComponent)
        let data = editImage.jpegData(compressionQuality: 1)
        try? data?.write(to: newImageURL)
        let imageFile = File(type: .image, url: newImageURL)
        self.fileCatalog.append(imageFile)
    }
    
    func printHello() {
        print("Hello")
    }
}
