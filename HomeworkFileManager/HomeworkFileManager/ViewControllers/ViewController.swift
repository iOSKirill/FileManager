
//  ViewController.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 8.02.23.
//

import UIKit
import SnapKit
import KeychainSwift

//MARK: - Enum -

enum CatalogCellType: String {
    case image = "Images"
    case folder = "Folders"
}

enum SelectionCells {
    case on
    case off
}

//MARK: - Struct -

struct File {
    var type: CatalogCellType
    var url: URL
}

class ViewController: UIViewController {

    //MARK: - Outlet and Variables -
    
    var fileManager2: ManagerProtocol = Manager()
    
//    let fileManager = FileManager.default
    let keyChain = KeychainSwift()
    let imagePicker = UIImagePickerController()
    var addChooseAnButton = UIBarButtonItem()
    var addCellSelectionButton = UIBarButtonItem()
    var addCellSelectionFillButton = UIBarButtonItem()
    var addDeleteSelectedSellButton = UIBarButtonItem()
    var selectionCellsState: SelectionCells = .off
    var stateSegmentedControl = 0
    var selectedCellsArray: [IndexPath] = []
//    var arrayURlDelete: [URL] = []
//    var fileCatalog: [File] = []
//    
//    lazy var currentCatalogURL: URL = {
//            fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    }()

    lazy var tableOrCollectionViewSegmentControl: UISegmentedControl = {
        let items = ["TableView", "CollectionView"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor(red: 55/255, green: 100/255, blue: 193/255, alpha: 1)], for: .selected)
        segmentedControl.backgroundColor = UIColor(red: 55/255, green: 100/255, blue: 193/255, alpha: 1)
        segmentedControl.selectedSegmentTintColor = .white
        segmentedControl.layer.borderWidth = 1
        segmentedControl.layer.borderColor = UIColor.white.cgColor
        segmentedControl.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        view.addSubview(segmentedControl)
        segmentedControl.selectedSegmentIndex = stateSegmentedControl
        return segmentedControl
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CatalogFolderCell.self, forCellReuseIdentifier: CatalogFolderCell.key)
        tableView.register(CatalogImageCell.self, forCellReuseIdentifier: CatalogImageCell.key)
        view.addSubview(tableView)
        return tableView
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout  = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.delegate = self
//        collectionView.dataSource = self
        collectionView.register(CollectionCatalogFolderCell.self, forCellWithReuseIdentifier: CollectionCatalogFolderCell.key)
        collectionView.register(CollectionCatalogImageCell.self, forCellWithReuseIdentifier: CollectionCatalogImageCell.key)
        collectionView.isHidden = true
        view.addSubview(collectionView)
        return collectionView
    }()
    
    //MARK: - Method -

    override func viewDidLoad() {
        super.viewDidLoad()
 
        fileManager2.checkingFilesInDocuments()
        setupConstraint()
        configureItems()
        switcherView()
        print(fileManager2.currentCatalogURL)
        
        fileManager2.printHello()
    }
    
    //Check File in Documents
//    func checkingFilesInDocuments() {
//        do {
//            let directoryContent = try fileManager.contentsOfDirectory(at: currentCatalogURL, includingPropertiesForKeys: nil).filter{ $0.lastPathComponent != ".DS_Store" }
//            directoryContent.forEach({  $0.hasDirectoryPath ? fileCatalog.append(File(type: .folder, url: $0)) : fileCatalog.append(File(type: .image, url: $0)) })
////            directoryContent.map({ $0.hasDirectoryPath ? fileCatalog.append(File(type: .folder, url: $0)) : fileCatalog.append(File(type: .image, url: $0)) })
//        } catch {
//           fatalError("Unable to read directory")
//        }
//    }
    
    //Setup Constraint
    func setupConstraint() {
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(130)
            make.bottom.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(130)
            make.bottom.equalToSuperview()
        }
        
        tableOrCollectionViewSegmentControl.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(90)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    @objc func segmentAction(_ segmentedControl: UISegmentedControl) {
        switcherView()
        stateSegmentedControl = segmentedControl.selectedSegmentIndex
      }
    
    func switcherView() {
        tableView.isHidden = tableOrCollectionViewSegmentControl.selectedSegmentIndex == 1
        collectionView.isHidden = tableOrCollectionViewSegmentControl.selectedSegmentIndex != 1
    }

    //Custom Navigation Bar
    func configureItems() {
        navigationItem.title = "\(fileManager2.currentCatalogURL.lastPathComponent.description)"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let chooseAnButton : UIButton = UIButton.init(type: .custom)
        chooseAnButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        chooseAnButton.addTarget(self, action: #selector(addAlertChooseAnAction), for: .touchUpInside)
        addChooseAnButton = UIBarButtonItem(customView: chooseAnButton)
        
        let cellSelectionButton : UIButton = UIButton.init(type: .custom)
        cellSelectionButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        cellSelectionButton.addTarget(self, action: #selector(cellSelectionAction), for: .touchUpInside)
        addCellSelectionButton = UIBarButtonItem(customView: cellSelectionButton)
        
        let cellSelectionFillButton : UIButton = UIButton.init(type: .custom)
        cellSelectionFillButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        cellSelectionFillButton.addTarget(self, action: #selector(removeSelectedSellAction), for: .touchUpInside)
        addCellSelectionFillButton = UIBarButtonItem(customView: cellSelectionFillButton)
        
        let deleteSelectedSellButton : UIButton = UIButton.init(type: .custom)
        deleteSelectedSellButton.setImage(UIImage(systemName: "trash.circle"), for: .normal)
        deleteSelectedSellButton.addTarget(self, action: #selector(deleteSelectedSellAction), for: .touchUpInside)
        addDeleteSelectedSellButton = UIBarButtonItem(customView: deleteSelectedSellButton)

        navigationItem.rightBarButtonItems = [addChooseAnButton, addCellSelectionButton]
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationController?.navigationBar.tintColor = .white
    }
    
    //Remove Selection Cell
    @objc func removeSelectedSellAction() {
        navigationItem.rightBarButtonItems = [addChooseAnButton, addCellSelectionButton]
        addChooseAnButton.isEnabled = true
        tableView.allowsMultipleSelection = false
        collectionView.allowsMultipleSelection = false
        //Deselect
        for index in selectedCellsArray {
            tableView.deselectRow(at: index, animated: true)
            collectionView.deselectItem(at: index, animated: true)
        }
        fileManager2.arrayURlDelete.removeAll()
        selectionCellsState = .off
    }
    
    //Delete Selection Cell
    @objc func deleteSelectedSellAction() {
//        fileCatalog = fileCatalog.filter{ !arrayURlDelete.contains($0.url) }
//          for url in arrayURlDelete {
//              do {
//                  try fileManager.removeItem(at: url)
//              } catch {
//                  fatalError("Error")
//              }
//              arrayURlDelete = arrayURlDelete.filter({ $0 != url })
//              tableView.reloadData()
//              collectionView.reloadData()
//          }
        fileManager2.deleteSelectedSell(tableView, collectionView)
        
        addChooseAnButton.isEnabled = true
        tableView.allowsMultipleSelection = false
        collectionView.allowsMultipleSelection = false
        selectionCellsState = .off
        navigationItem.rightBarButtonItems = [addChooseAnButton, addCellSelectionButton]
    }
    
    //Cell Selection
    @objc func cellSelectionAction() {
        navigationItem.setRightBarButtonItems([addChooseAnButton, addCellSelectionFillButton,addDeleteSelectedSellButton], animated: false)
        addDeleteSelectedSellButton.isEnabled = false
        addChooseAnButton.isEnabled = false
        tableView.allowsMultipleSelection = true
        collectionView.allowsMultipleSelection = true
        selectionCellsState = .on
    }
        
    //Add Alert with creating a new catalog
    func addAlertCreateNewCatalog() {
        let alertNewCatalog = UIAlertController(title: "Create a new catalog", message: "Print a name", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { [self] _ in
            guard let nameCatalog = alertNewCatalog.textFields?.first?.text?.trimmingCharacters(in: NSCharacterSet.whitespaces), !nameCatalog.isEmpty else { return }
//            guard self.fileCatalog.contains(where: { $0.url.lastPathComponent == nameCatalog }) else {
//                self.addAlertDirectoryError()
//                return
//            }
//            let newFolder = self.currentCatalogURL.appending(path: nameCatalog)
//            try? self.fileManager.createDirectory(at: newFolder, withIntermediateDirectories: false)
//            let folderFile = File(type: .folder, url: newFolder)
//            self.fileCatalog.append(folderFile)
            self.fileManager2.createNewCatalog(nameCatalog: nameCatalog, alertDirectoryError: self.addAlertDirectoryError())
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertNewCatalog.addTextField { textField in
            textField.placeholder = "Folder name"
        }
        
        alertNewCatalog.addAction(okButton)
        alertNewCatalog.addAction(cancelButton)
        present(alertNewCatalog, animated: true)
        
    }
    
    //Add Alert with Directory Error
    func addAlertDirectoryError() {
        let alertError = UIAlertController(title: "Error", message: "Directory exists", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alertError.addAction(okButton)
        alertError.preferredAction = okButton
        present(alertError, animated: true)
    }
    
    //Choose Image
    func chooseImage() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    //Add Alert with a choice of action
    @objc func addAlertChooseAnAction() {
        let alertActions = UIAlertController(title: "Choose an action", message: nil, preferredStyle: .alert)
        let createCatalogButton = UIAlertAction(title: "Create a directory", style: .default) { _ in
            self.addAlertCreateNewCatalog()
        }
        let chooseImageButton = UIAlertAction(title: "Choose an image", style: .default) { _ in
            self.chooseImage()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertActions.addAction(createCatalogButton)
        alertActions.addAction(chooseImageButton)
        alertActions.addAction(cancelButton)
        present(alertActions, animated: true)
    }
    
    //Add Alert Set Password
    func addAlertSecurity() {
        let alertSecurity = UIAlertController(title: "Security", message: "Do you want to set a password?", preferredStyle: .alert)
        let setPasswordButton = UIAlertAction(title: "Set", style: .default) { _ in
            guard let password = alertSecurity.textFields?.first?.text, !password.isEmpty else { return }
            self.keyChain.set(password, forKey: "Password")
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertSecurity.addTextField { textField in
            textField.placeholder = "Password"
        }
        alertSecurity.addAction(setPasswordButton)
        alertSecurity.addAction(cancelButton)
        alertSecurity.preferredAction = setPasswordButton
        present(alertSecurity, animated: true)
    }
    
    //Add Alert Access denied
    func addAlertAccessDenied() {
        let alertAccessDenied = UIAlertController(title: "Access denied", message: "Your password?", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            guard let password = alertAccessDenied.textFields?.first?.text, !password.isEmpty, password == self.keyChain.get("Password") else {
                self.errorPassword()
                return
            }
        }
        alertAccessDenied.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        alertAccessDenied.addAction(okButton)
        present(alertAccessDenied, animated: true)
    }
    
    //Add Alert Error Password
    func errorPassword() {
        let alertErrorPassword = UIAlertController(title: "Error", message: "Password is wrong", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            self.addAlertAccessDenied()
        }
        alertErrorPassword.addAction(okButton)
        present(alertErrorPassword, animated: true)
    }
    
    //Checking if the password is in memory
    func checkingPasswordInMemory() {
        guard let passwordKeyChain = keyChain.get("Password"), !passwordKeyChain.isEmpty else {
            addAlertSecurity()
            return
        }
        addAlertAccessDenied()
    }
}


//MARK: - Extension -
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    //Count section in TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //What will be stored in which cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return fileCatalog.filter({ $0.type == .image}).count
//        } else {
//
//            return fileCatalog.filter({ $0.type == .folder }).count
//        }
        
        fileManager2.sectionEntry(section: section)
    }
    
    //Name section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0, fileCatalog.filter({ $0.type == .image}).count > 0 {
//            return CatalogCellType.image.rawValue
//        } else if section == 1, fileCatalog.filter({ $0.type == .folder }).count > 0 {
//            return CatalogCellType.folder.rawValue
//        } else {
//            return ""
//        }
        fileManager2.sectionTitle(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogImageCell.key, for: indexPath) as? CatalogImageCell else { return UITableViewCell() }
//            cell.thumbnailImage.image = UIImage(contentsOfFile: fileCatalog.filter({ $0.type == .image})[indexPath.row].url.path)?.preparingThumbnail(of: .init(width: 50, height: 50))
//            return cell
//        } else {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogFolderCell.key, for: indexPath) as? CatalogFolderCell else { return UITableViewCell() }
//            cell.nameCatalogLabel.text = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url.lastPathComponent
//            return cell
//        }
        
        fileManager2.displayInfoInCells(tableView: tableView, indexPath: indexPath)
            
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch selectionCellsState {
        case .off:
            tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.section == 0 {
                let imageVC = ImageViewController(nibName: ImageViewController.key, bundle: nil)

//                guard let firstImage = UIImage(contentsOfFile: fileCatalog.filter({ $0.type == .image })[indexPath.row].url.path) else { return }
//                imageVC.imageArray.insert(firstImage, at: 0)
//                let firstUrl = fileCatalog.filter({ $0.type == .image })[indexPath.row].url
//
//                fileCatalog.forEach { i in
//                    if let fullImage = UIImage(contentsOfFile: i.url.path), i.url != firstUrl {
//                        imageVC.imageArray.append(fullImage)
//                    }
//                }
                
                fileManager2.moveToSelectedImageCell(indexPath: indexPath, imageVC: imageVC)
                
                present(imageVC, animated: true)
            } else {
                guard let folderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainCatalog") as? ViewController else { return }
//                folderVC.fileManager2 .currentCatalogURL = fileManager2.fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
//                folderVC.title = fileManager2.fileCatalog.filter({ $0.type == .folder})[indexPath.row].url.lastPathComponent
                fileManager2.moveToSelectedFolderCell(indexPath: indexPath, folderVC: folderVC)
                folderVC.stateSegmentedControl = stateSegmentedControl
                navigationController?.pushViewController(folderVC, animated: true)
            }
        case .on:
            //Add Cell Index
            if indexPath.section == 0 {
                selectedCellsArray.append(indexPath)
//                let imageDelete = fileCatalog.filter({ $0.type == .image})[indexPath.row].url
//                if !arrayURlDelete.contains(imageDelete) {
//                    arrayURlDelete.append(imageDelete)
//                }
                fileManager2.deleteImageCells(indexPath: indexPath, addDeleteSelectedSellButton: addDeleteSelectedSellButton)
//                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
//                addDeleteSelectedSellButton.isEnabled = arrayURlDelete.count > 0
            } else {
                selectedCellsArray.append(indexPath)
//                let folderDelete = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
//                if !arrayURlDelete.contains(folderDelete) {
//                    arrayURlDelete.append(folderDelete)
//                }
                fileManager2.deleteFolderCells(indexPath: indexPath, addDeleteSelectedSellButton: addDeleteSelectedSellButton)
//                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
//                addDeleteSelectedSellButton.isEnabled = arrayURlDelete.count > 0
            }
        }
    }
    
    //Delete Сell Index
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
//            let imageDelete = fileCatalog.filter({ $0.type == .image})[indexPath.row].url
//            arrayURlDelete = arrayURlDelete.filter({ $0 != imageDelete })
//            addDeleteSelectedSellButton.isEnabled = arrayURlDelete.count != 0
            fileManager2.deselectImageCells(indexPath: indexPath, addDeleteSelectedSellButton: addDeleteSelectedSellButton)
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
//            let folderDelete = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
//            arrayURlDelete = arrayURlDelete.filter({ $0 != folderDelete })
//            addDeleteSelectedSellButton.isEnabled = arrayURlDelete.count != 0
            fileManager2.deselectFolderCells(indexPath: indexPath, addDeleteSelectedSellButton: addDeleteSelectedSellButton)
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let imageURL = info[.imageURL] as? URL,
//        let editImage = info[.editedImage] as? UIImage else { return }
//
//        let newImageURL = currentCatalogURL.appending(path: imageURL.lastPathComponent)
//        let data = editImage.jpegData(compressionQuality: 1)
//        try? data?.write(to: newImageURL)
//        let imageFile = File(type: .image, url: newImageURL)
//        self.fileCatalog.append(imageFile)
        fileManager2.createNewImage(info: info)
        self.tableView.reloadData()
        self.collectionView.reloadData()
        dismiss(animated: true)
    }
}

//extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        2
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if section == 0 {
//            return fileCatalog.filter({ $0.type == .image}).count
//        } else {
//
//            return fileCatalog.filter({ $0.type == .folder }).count
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if indexPath.section == 0 {
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCatalogImageCell.key, for: indexPath) as? CollectionCatalogImageCell else { return UICollectionViewCell () }
//            cell.thumbnailImage.image = UIImage(contentsOfFile: fileCatalog.filter({ $0.type == .image})[indexPath.row].url.path)
//            return cell
//        } else {
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCatalogFolderCell.key, for: indexPath) as? CollectionCatalogFolderCell else { return UICollectionViewCell () }
//            cell.nameCatalogLabel.text = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url.lastPathComponent
//            return cell
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        switch selectionCellsState {
//        case .off:
//            collectionView.deselectItem(at: indexPath, animated: false)
//            if indexPath.section == 0 {
//                let imageVC = ImageViewController(nibName: ImageViewController.key, bundle: nil)
//
//                guard let firstImage = UIImage(contentsOfFile: fileCatalog.filter({ $0.type == .image })[indexPath.row].url.path) else { return }
//                imageVC.imageArray.insert(firstImage, at: 0)
//                let firstUrl = fileCatalog.filter({ $0.type == .image })[indexPath.row].url
//
//                fileCatalog.forEach { i in
//                    if let fullImage = UIImage(contentsOfFile: i.url.path), i.url != firstUrl {
//                        imageVC.imageArray.append(fullImage)
//                    }
//                }
//
//                present(imageVC, animated: true)
//            } else {
//                guard let folderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainCatalog") as? ViewController else { return }
//                folderVC.currentCatalogURL = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
//                folderVC.title = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url.lastPathComponent
//                folderVC.stateSegmentedControl = stateSegmentedControl
//                navigationController?.pushViewController(folderVC, animated: true)
//            }
//        case .on:
//            //Add Cell Index
//            if indexPath.section == 0 {
//                selectedCellsArray.append(indexPath)
//                let imageDelete = fileCatalog.filter({ $0.type == .image})[indexPath.row].url
//                if !arrayURlDelete.contains(imageDelete) {
//                    arrayURlDelete.append(imageDelete)
//                }
//                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
//                addDeleteSelectedSellButton.isEnabled = arrayURlDelete.count > 0
//            } else {
//                selectedCellsArray.append(indexPath)
//                let folderDelete = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
//                if !arrayURlDelete.contains(folderDelete) {
//                    arrayURlDelete.append(folderDelete)
//                }
//                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
//                addDeleteSelectedSellButton.isEnabled = arrayURlDelete.count > 0
//            }
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if indexPath.section == 0 {
//            return CGSize(width: 100, height: 100)
//        } else {
//            return CGSize(width: 80, height: 70)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//            return CGSize(width: 20, height: 20)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            let imageDelete = fileCatalog.filter({ $0.type == .image})[indexPath.row].url
//            arrayURlDelete = arrayURlDelete.filter({ $0 != imageDelete })
//            addDeleteSelectedSellButton.isEnabled = arrayURlDelete.count != 0
//            tableView.deselectRow(at: indexPath, animated: true)
//        } else {
//            let folderDelete = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
//            arrayURlDelete = arrayURlDelete.filter({ $0 != folderDelete })
//            addDeleteSelectedSellButton.isEnabled = arrayURlDelete.count != 0
//            tableView.deselectRow(at: indexPath, animated: true)
//        }
//    }
//
//}
