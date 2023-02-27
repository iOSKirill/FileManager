
//  ViewController.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 8.02.23.
//

import UIKit
import SnapKit
import KeychainSwift

//MARK: - Enum -

enum SelectionCells {
    case on
    case off
}

class ViewController: UIViewController {

    //MARK: - Outlet and Variables -
    
    var fileManager: ManagerProtocol = Manager()
    let keyChain = KeychainSwift()
    let imagePicker = UIImagePickerController()
    var addChooseAnButton = UIBarButtonItem()
    var addCellSelectionButton = UIBarButtonItem()
    var addCellSelectionFillButton = UIBarButtonItem()
    var addDeleteSelectedSellButton = UIBarButtonItem()
    var selectionCellsState: SelectionCells = .off
    var stateSegmentedControl = 0
    var selectedCellsArray: [IndexPath] = []

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
        
        fileManager.checkingFilesInDocuments()
        setupConstraint()
        configureItems()
        switcherView()
        print(fileManager.currentCatalogURL)
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
        stateSegmentedControl = segmentedControl.selectedSegmentIndex
    }
    
    func switcherView() {
        tableView.isHidden = tableOrCollectionViewSegmentControl.selectedSegmentIndex == 1
        collectionView.isHidden = tableOrCollectionViewSegmentControl.selectedSegmentIndex != 1
    }

    //Custom Navigation Bar
    func configureItems() {
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "\(fileManager.currentCatalogURL.lastPathComponent.description)"
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
    }
    
    //Remove Selection Cell
    @objc func removeSelectedSellAction() {
        navigationItem.rightBarButtonItems = [addChooseAnButton, addCellSelectionButton]
        selectionCellsState = .off
        addChooseAnButton.isEnabled = true
        tableView.allowsMultipleSelection = false
        collectionView.allowsMultipleSelection = false
        //Deselect
        for index in selectedCellsArray {
            tableView.deselectRow(at: index, animated: true)
            collectionView.deselectItem(at: index, animated: true)
        }
        fileManager.arrayURlDelete.removeAll()
    }
    
    //Delete Selection Cell
    @objc func deleteSelectedSellAction() {
        navigationItem.rightBarButtonItems = [addChooseAnButton, addCellSelectionButton]
        selectionCellsState = .off
        addChooseAnButton.isEnabled = true
        tableView.allowsMultipleSelection = false
        collectionView.allowsMultipleSelection = false
        fileManager.deleteSelectedSell(tableView, collectionView)
    }
    
    //Cell Selection
    @objc func cellSelectionAction() {
        navigationItem.setRightBarButtonItems([addChooseAnButton, addCellSelectionFillButton,addDeleteSelectedSellButton], animated: false)
        selectionCellsState = .on
        addDeleteSelectedSellButton.isEnabled = false
        addChooseAnButton.isEnabled = false
        tableView.allowsMultipleSelection = true
        collectionView.allowsMultipleSelection = true
    }
        
    //Add Alert with creating a new catalog
    func addAlertCreateNewCatalog() {
        let alertNewCatalog = UIAlertController(title: "Create a new catalog", message: "Print a name", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            guard let nameCatalog = alertNewCatalog.textFields?.first?.text?.trimmingCharacters(in: NSCharacterSet.whitespaces), !nameCatalog.isEmpty else { return }
            if !self.fileManager.createNewCatalog(nameCatalog: nameCatalog) {
                self.addAlertDirectoryError()
            }
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
        fileManager.sectionEntry(section: section)
    }
    
    //Name section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        fileManager.sectionTitle(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogImageCell.key, for: indexPath) as? CatalogImageCell else { return UITableViewCell() }
            cell.thumbnailImage.image = UIImage(contentsOfFile: fileManager.displayImageInCellsTableView()[indexPath.row].url.path)?.preparingThumbnail(of: .init(width: 50, height: 50))
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogFolderCell.key, for: indexPath) as? CatalogFolderCell else { return UITableViewCell() }
            cell.nameCatalogLabel.text = fileManager.displayFolderInCellsTableView()[indexPath.row].url.lastPathComponent
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch selectionCellsState {
        case .off:
            tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.section == 0 {
                let imageVC = ImageViewController(nibName: ImageViewController.key, bundle: nil)
                guard let firstImage = UIImage(contentsOfFile:fileManager.displayImageInCellsTableView()[indexPath.row].url.path) else { return }
                imageVC.imageArray.insert(firstImage, at: 0)
                let firstUrl = fileManager.displayImageInCellsTableView()[indexPath.row].url
                
                fileManager.fileCatalog.forEach { i in
                    if let fullImage = UIImage(contentsOfFile: i.url.path), i.url != firstUrl {
                        imageVC.imageArray.append(fullImage)
                    }
                }
                present(imageVC, animated: true)
            } else {
                guard let folderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainCatalog") as? ViewController else { return }
                folderVC.fileManager.currentCatalogURL = fileManager.displayFolderInCellsTableView()[indexPath.row].url
                folderVC.title = fileManager.displayFolderInCellsTableView()[indexPath.row].url.lastPathComponent
                folderVC.stateSegmentedControl = stateSegmentedControl
                navigationController?.pushViewController(folderVC, animated: true)
            }
        case .on:
            //Add Cell Index
            fileManager.deleteCells(indexPath: indexPath)
            selectedCellsArray.append(indexPath)
            addDeleteSelectedSellButton.isEnabled = fileManager.arrayURlDelete.count > 0
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
        }
    }
    
    //Delete Сell Index
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        fileManager.deselectCells(indexPath: indexPath)
        addDeleteSelectedSellButton.isEnabled = fileManager.arrayURlDelete.count != 0
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imageURL = info[.imageURL] as? URL,
        let editImage = info[.editedImage] as? UIImage else { return }
        
        let newImageURL = fileManager.createNewImage(url: imageURL)
        let data = editImage.jpegData(compressionQuality: 1)
        try? data?.write(to: newImageURL)
        fileManager.appendImageIFileCatalog(url: newImageURL)
        
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
        fileManager.sectionEntry(section: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCatalogImageCell.key, for: indexPath) as? CollectionCatalogImageCell else { return UICollectionViewCell () }
            cell.thumbnailImage.image = UIImage(contentsOfFile: fileManager.displayImageInCellsTableView()[indexPath.row].url.path)?.preparingThumbnail(of: .init(width: 50, height: 50))
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCatalogFolderCell.key, for: indexPath) as? CollectionCatalogFolderCell else { return UICollectionViewCell () }
            cell.nameCatalogLabel.text = fileManager.displayFolderInCellsTableView()[indexPath.row].url.lastPathComponent
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch selectionCellsState {
        case .off:
            collectionView.deselectItem(at: indexPath, animated: false)
            if indexPath.section == 0 {
                let imageVC = ImageViewController(nibName: ImageViewController.key, bundle: nil)
                guard let firstImage = UIImage(contentsOfFile:fileManager.displayImageInCellsTableView()[indexPath.row].url.path) else { return }
                imageVC.imageArray.insert(firstImage, at: 0)
                let firstUrl = fileManager.displayImageInCellsTableView()[indexPath.row].url
                
                fileManager.fileCatalog.forEach { i in
                    if let fullImage = UIImage(contentsOfFile: i.url.path), i.url != firstUrl {
                        imageVC.imageArray.append(fullImage)
                    }
                }
                present(imageVC, animated: true)
            } else {
                guard let folderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainCatalog") as? ViewController else { return }
                folderVC.fileManager.currentCatalogURL = fileManager.displayFolderInCellsTableView()[indexPath.row].url
                folderVC.title = fileManager.displayFolderInCellsTableView()[indexPath.row].url.lastPathComponent
                folderVC.stateSegmentedControl = stateSegmentedControl
                navigationController?.pushViewController(folderVC, animated: true)
            }
        case .on:
            //Add Cell Index
            fileManager.deleteCells(indexPath: indexPath)
            selectedCellsArray.append(indexPath)
            addDeleteSelectedSellButton.isEnabled = fileManager.arrayURlDelete.count > 0
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        fileManager.deselectCells(indexPath: indexPath)
        addDeleteSelectedSellButton.isEnabled = fileManager.arrayURlDelete.count != 0
        tableView.deselectRow(at: indexPath, animated: true)
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
