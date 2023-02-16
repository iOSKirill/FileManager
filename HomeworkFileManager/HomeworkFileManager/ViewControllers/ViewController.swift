//
//  ViewController.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 8.02.23.
//

import UIKit
import SnapKit

//MARK: - Enum -

enum CatalogCellType {
    case image
    case folder
}

enum Headers: String {
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
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        view.addSubview(segmentedControl)
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
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
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
        
        tableOrCollectionViewSegmentControl.selectedSegmentIndex = state
        checkingFilesInDocuments()
        setupConstraint()
        configureItems()
        print(currentCatalogURL)
    }
    
    //Check File in Documents
    func checkingFilesInDocuments() {
        do {
            let directoryContent = try fileManager.contentsOfDirectory(at: currentCatalogURL, includingPropertiesForKeys: nil)
            for element in directoryContent where element.lastPathComponent != ".DS_Store" {
                if element.hasDirectoryPath {
                    let folderFile = File(type: .folder, url: element)
                    fileCatalog.append(folderFile)
                } else {
                    let imageFile = File(type: .image, url: element)
                    fileCatalog.append(imageFile)
                }
            }
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

    //Segment Action
    @objc func segmentAction(_ segmentedControl: UISegmentedControl) {
          switch segmentedControl.selectedSegmentIndex {
          case 0:
              tableView.isHidden = false
              collectionView.isHidden = true
          case 1:
              tableView.isHidden = true
              collectionView.isHidden = false
          default:
              break
          }
      }

    //Custom Navigation Bar
    func configureItems() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle"),
            style: .done,
            target: self,
            action: #selector(addAlertChooseAnAction))
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationController?.navigationBar.tintColor = .white
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
            return Headers.image.rawValue
        } else if section == 1, fileCatalog.filter({ $0.type == .folder }).count > 0 {
            return Headers.folder.rawValue
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
        if indexPath.section == 0 {
            let imageVC = ImageViewController(nibName: ImageViewController.key, bundle: nil)
            imageVC.imageCatalog.image = UIImage(contentsOfFile: fileCatalog.filter({ $0.type == .image})[indexPath.row].url.path)
            present(imageVC, animated: true)
        } else {
            guard let folderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainCatalog") as? ViewController else { return }
            folderVC.currentCatalogURL = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
            folderVC.title = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url.lastPathComponent
            navigationController?.pushViewController(folderVC, animated: true)
        }
    }

    //Count section in TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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

        if indexPath.section == 0 {
            let imageVC = ImageViewController(nibName: ImageViewController.key, bundle: nil)
            imageVC.imageCatalog.image = UIImage(contentsOfFile: fileCatalog.filter({ $0.type == .image})[indexPath.row].url.path)
            present(imageVC, animated: true)
        } else {
            guard let folderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainCatalog") as? ViewController else { return }
            folderVC.currentCatalogURL = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url
            folderVC.title = fileCatalog.filter({ $0.type == .folder})[indexPath.row].url.lastPathComponent
            navigationController?.pushViewController(folderVC, animated: true)
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
    
}
