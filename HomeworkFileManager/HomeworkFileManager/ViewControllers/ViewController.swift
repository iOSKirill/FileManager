
//  ViewController.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 8.02.23.
//

import UIKit
import SnapKit

//MARK: - Enum -

enum CatalogCellType: String {
    case image = "Images"
    case folder = "Folders"
}

struct File {
    var type: CatalogCellType
    var url: URL
}

class ViewController: UIViewController {

    //MARK: - Outlet and Variables -
    
    let fileManager = FileManager.default
    let imagePicker = UIImagePickerController()
    var addChooseAnButton = UIBarButtonItem()
    var addCellSelectionButton = UIBarButtonItem()
    var addCellSelectionFillButton = UIBarButtonItem()
    var addDeleteSelectedSellButton = UIBarButtonItem()
    var selectedCellsArray: [IndexPath] = []
    var arrayURlDelete: [URL] = []
    var fileCatalog: [File] = []
    var state = 0
    
    lazy var currentCatalogURL: URL = {
            fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }()

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
        segmentedControl.selectedSegmentIndex = state
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
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionCatalogFolderCell.self, forCellWithReuseIdentifier: CollectionCatalogFolderCell.key)
        collectionView.register(CollectionCatalogImageCell.self, forCellWithReuseIdentifier: CollectionCatalogImageCell.key)
        collectionView.isHidden = true
        view.addSubview(collectionView)
        return collectionView
    }()
    
    //MARK: - Method -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkingFilesInDocuments()
        setupConstraint()
        configureItems()
        switcherView()
        print(currentCatalogURL)
    }
    
    //Check File in Documents
    func checkingFilesInDocuments() {
        do {
            let directoryContent = try fileManager.contentsOfDirectory(at: currentCatalogURL, includingPropertiesForKeys: nil).filter{ $0.lastPathComponent != ".DS_Store" }
            directoryContent.forEach({  $0.hasDirectoryPath ? fileCatalog.append(File(type: .folder, url: $0)) : fileCatalog.append(File(type: .image, url: $0)) })
//            directoryContent.map({ $0.hasDirectoryPath ? fileCatalog.append(File(type: .folder, url: $0)) : fileCatalog.append(File(type: .image, url: $0)) })
        } catch {
           fatalError("Unable to read directory")
        }
    }
    
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
        state = segmentedControl.selectedSegmentIndex
      }
    
    func switcherView() {
        tableView.isHidden = tableOrCollectionViewSegmentControl.selectedSegmentIndex == 1
        collectionView.isHidden = tableOrCollectionViewSegmentControl.selectedSegmentIndex != 1
    }

    //Custom Navigation Bar
    func configureItems() {
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
        for index in selectedCellsArray {
            tableView.deselectRow(at: index, animated: false)
        }
        arrayURlDelete.removeAll()
    }
    
    //Delete Selection Cell
    @objc func deleteSelectedSellAction() {
        fileCatalog = fileCatalog.filter{ !arrayURlDelete.contains($0.url) }
          for url in arrayURlDelete {
              do {
                  try fileManager.removeItem(at: url)
              } catch {
                  fatalError("Error")
              }
              tableView.reloadData()
              collectionView.reloadData()
          }
        tableView.allowsMultipleSelection = false
        collectionView.allowsMultipleSelection = false

        addChooseAnButton.isEnabled = true
        navigationItem.rightBarButtonItems = [addChooseAnButton, addCellSelectionButton]
    }
    
    //Cell Selection
    @objc func cellSelectionAction() {
        navigationItem.setRightBarButtonItems([addChooseAnButton, addCellSelectionFillButton,addDeleteSelectedSellButton], animated: false)
        addChooseAnButton.isEnabled = false
        tableView.allowsMultipleSelection = true
        collectionView.allowsMultipleSelection = true
    }
        
    //Add Alert with creating a new catalog
    func addAlertCreateNewCatalog() {
        let alertNewCatalog = UIAlertController(title: "Create a new catalog", message: "Print a name", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            guard let nameCatalog = alertNewCatalog.textFields?.first?.text?.trimmingCharacters(in: NSCharacterSet.whitespaces), !nameCatalog.isEmpty else { return }
            guard !self.fileCatalog.contains(where: { $0.url.lastPathComponent == nameCatalog }) else {
                self.addAlertDirectoryError()
                return
            }
            
            let newFolder = self.currentCatalogURL.appending(path: nameCatalog)
            try? self.fileManager.createDirectory(at: newFolder, withIntermediateDirectories: false)
            let folderFile = File(type: .folder, url: newFolder)
            self.fileCatalog.append(folderFile)
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
}


//MARK: - Extension -
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    //Count section in TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //What will be stored in which cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return fileCatalog.filter({ $0.type == .image}).count
        } else {
            
            return fileCatalog.filter({ $0.type == .folder }).count
        }
    }
    
    //Name section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0, fileCatalog.filter({ $0.type == .image}).count > 0 {
            return CatalogCellType.image.rawValue
        } else if section == 1, fileCatalog.filter({ $0.type == .folder }).count > 0 {
            return CatalogCellType.folder.rawValue
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.allowsMultipleSelection == false {
            if indexPath.section == 0 {
                let imageVC = ImageViewController(nibName: ImageViewController.key, bundle: nil)
                imageVC.imageCatalog.image = UIImage(contentsOfFile: fileCatalog.filter({ $0.type == .image})[indexPath.row].url.path)
                present(imageVC, animated: true)
            } else {
                guard let folderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainCatalog") as? ViewController else { return }
                folderVC.currentCatalogURL = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
                folderVC.title = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url.lastPathComponent
                folderVC.state = state
                navigationController?.pushViewController(folderVC, animated: true)
            }
        } else {
            //Add Cell Index
            if indexPath.section == 0 {
                selectedCellsArray.append(indexPath)
                let imageDelete = fileCatalog.filter({ $0.type == .image})[indexPath.row].url
                if !arrayURlDelete.contains(imageDelete) {
                    arrayURlDelete.append(imageDelete)
                }
            } else {
                selectedCellsArray.append(indexPath)
                let folderDelete = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
                if !arrayURlDelete.contains(folderDelete) {
                    arrayURlDelete.append(folderDelete)
                }
            }

        }
    }
    
    //Delete Сell Index
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let imageDelete = fileCatalog.filter({ $0.type == .image})[indexPath.row].url
            arrayURlDelete = arrayURlDelete.filter({ $0 != imageDelete })
        } else {
            let folderDelete = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
            arrayURlDelete = arrayURlDelete.filter({ $0 != folderDelete })
        }
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imageURL = info[.imageURL] as? URL,
        let editImage = info[.editedImage] as? UIImage else { return }
        
        let newImageURL = currentCatalogURL.appending(path: imageURL.lastPathComponent)
        let data = editImage.jpegData(compressionQuality: 1)
        try? data?.write(to: newImageURL)
        let imageFile = File(type: .image, url: newImageURL)
        self.fileCatalog.append(imageFile)
        self.tableView.reloadData()
        self.collectionView.reloadData()
        dismiss(animated: true)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return fileCatalog.filter({ $0.type == .image}).count
        } else {
            
            return fileCatalog.filter({ $0.type == .folder }).count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCatalogImageCell.key, for: indexPath) as? CollectionCatalogImageCell else { return UICollectionViewCell () }
            cell.thumbnailImage.image = UIImage(contentsOfFile: fileCatalog.filter({ $0.type == .image})[indexPath.row].url.path)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCatalogFolderCell.key, for: indexPath) as? CollectionCatalogFolderCell else { return UICollectionViewCell () }
            cell.nameCatalogLabel.text = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url.lastPathComponent
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if tableView.allowsMultipleSelection == false {
            if indexPath.section == 0 {
                let imageVC = ImageViewController(nibName: ImageViewController.key, bundle: nil)
                imageVC.imageCatalog.image = UIImage(contentsOfFile: fileCatalog.filter({ $0.type == .image})[indexPath.row].url.path)
                present(imageVC, animated: true)
            } else {
                guard let folderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainCatalog") as? ViewController else { return }
                folderVC.currentCatalogURL = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
                folderVC.title = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url.lastPathComponent
                folderVC.state = state
                navigationController?.pushViewController(folderVC, animated: true)
            }
        } else {
            //Add Cell Index
            if indexPath.section == 0 {
                selectedCellsArray.append(indexPath)
                let imageDelete = fileCatalog.filter({ $0.type == .image})[indexPath.row].url
                if !arrayURlDelete.contains(imageDelete) {
                    arrayURlDelete.append(imageDelete)
                }
            } else {
                selectedCellsArray.append(indexPath)
                let folderDelete = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
                if !arrayURlDelete.contains(folderDelete) {
                    arrayURlDelete.append(folderDelete)
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: 100, height: 100)
        } else {
            return CGSize(width: 80, height: 70)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: 20, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let imageDelete = fileCatalog.filter({ $0.type == .image})[indexPath.row].url
            arrayURlDelete = arrayURlDelete.filter({ $0 != imageDelete })
        } else {
            let folderDelete = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
            arrayURlDelete = arrayURlDelete.filter({ $0 != folderDelete })
        }
    }
   
}
