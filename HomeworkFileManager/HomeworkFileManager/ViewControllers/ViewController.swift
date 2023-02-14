//
//  ViewController.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 8.02.23.
//

import UIKit
import SnapKit

//MARK: - Enum

enum CatalogCellType {
    case folder(url: URL)
    case image(url: URL)
}

class ViewController: UIViewController {

    //MARK: - Outlet and Variables
    
    let fileManager = FileManager.default
    let imagePicker = UIImagePickerController()
    lazy var currentCatalogURL: URL = {
            fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }()
    
    private var catalogArray: [CatalogCellType] = []
        
    lazy var catalogObjectsURLS: [URL] = {
        do {
            let catalogURL = try fileManager.contentsOfDirectory(at: currentCatalogURL, includingPropertiesForKeys: nil).filter{ $0.lastPathComponent != ".DS_Store" }
            return catalogURL
        } catch {
            fatalError("Unable to read directory")
        }
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
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CatalogFolderCell.self, forCellReuseIdentifier: CatalogFolderCell.key)
        tableView.register(CatalogImageCell.self, forCellReuseIdentifier: CatalogImageCell.key)
        view.addSubview(tableView)
        return tableView
    }()
    
    //MARK: - Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraint()
        configureItems()
        reloadData()
        print(currentCatalogURL)
    }
    
    //Setup Constraint
    func setupConstraint() {
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(130)
            make.bottom.equalToSuperview()
        }
        
        tableOrCollectionViewSegmentControl.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(90)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
    }
    
    func reloadData() {
        catalogArray.removeAll()
        catalogObjectsURLS.forEach { $0.hasDirectoryPath ? catalogArray.append(.folder(url: $0)) : catalogArray.append(.image(url: $0)) }
        tableView.reloadData()
    }
    
    //Segment Action
    @objc func segmentAction(_ segmentedControl: UISegmentedControl) {
          switch segmentedControl.selectedSegmentIndex {
          case 0:
              tableView.isHidden = false
          case 1:
              tableView.isHidden = true
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
            guard !self.catalogObjectsURLS.contains(where: { $0.lastPathComponent == nameCatalog }) else {
                self.addAlertDirectoryError()
                return
            }
            
            let newFolder = self.currentCatalogURL.appending(path: "\(nameCatalog)/")
            try? self.fileManager.createDirectory(at: newFolder, withIntermediateDirectories: false)
            self.catalogObjectsURLS.append(newFolder)
            self.reloadData()
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

//MARK: - Extension
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        catalogObjectsURLS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch catalogArray[indexPath.row] {
        case .image(let url):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogImageCell.key, for: indexPath) as? CatalogImageCell else { return UITableViewCell() }
            cell.thumbnailImage.image = UIImage(contentsOfFile: url.relativePath)?.preparingThumbnail(of: .init(width: 50, height: 50))
            return cell
        case .folder(let url):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogFolderCell.key, for: indexPath) as? CatalogFolderCell else { return UITableViewCell() }
            cell.nameCatalogLabel.text = url.lastPathComponent
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch catalogArray[indexPath.row] {
        case .image(let url):
            let imageVC = ImageViewController(nibName: ImageViewController.key, bundle: nil)
            imageVC.imageCatalog.image = UIImage(contentsOfFile: url.relativePath)
            present(imageVC, animated: true)
        case .folder(let url):
            guard let folderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainCatalog") as? ViewController else { return }
            folderVC.currentCatalogURL = url
            folderVC.title = url.lastPathComponent
            navigationController?.pushViewController(folderVC, animated: true)
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
        catalogObjectsURLS.append(newImageURL)
        reloadData()
        dismiss(animated: true)
    }
}
