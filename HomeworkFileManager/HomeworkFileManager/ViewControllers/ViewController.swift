//
//  ViewController.swift
//  HomeworkFileManager
//
//  Created by Kirill Manuilenko on 8.02.23.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    //MARK: - Outlet and Variables
    let fileManager = FileManager.default
    var catalogArray: [URL]?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CatalogCell.self, forCellReuseIdentifier: CatalogCell.key)
        return tableView
    }()
    
    lazy var currentCatalog: URL = {
            fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            catalogArray = try fileManager.contentsOfDirectory(at: currentCatalog, includingPropertiesForKeys: nil).filter{$0.lastPathComponent != ".DS_Store"}
        } catch {
            fatalError("Unable to read directory")
        }
        setupTableView()
        configureItems()
    }
    
    //MARK: - Method
    
    //Setup UITableView
    func setupTableView() {
        view.addSubview(tableView)
        //make constraint
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(100)
            make.bottom.equalToSuperview()
        }
    }

    //Custom Navigation Bar
    func configureItems() {
        navigationItem.title = "Catalog Browser"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "folder.badge.plus"),
            style: .done,
            target: self,
            action: #selector(addAlertCreateNewCatalog))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
        
    //Add Alert with creating a new catalog
    @objc func addAlertCreateNewCatalog() {
        let alertNewCatalog = UIAlertController(title: "Create a new catalog", message: "Print a name", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            guard let nameCatalog = alertNewCatalog.textFields?.first?.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) else { return }
            guard !nameCatalog.isEmpty else { return }
            guard self.catalogArray?.contains(where: { $0.lastPathComponent == nameCatalog }) == false else {
                self.addAlertDirectoryError()
                return
            }
            
            let newFolder = self.currentCatalog.appending(path: nameCatalog)
            try? self.fileManager.createDirectory(at: newFolder, withIntermediateDirectories: false)
            self.catalogArray?.append(newFolder)
            self.tableView.reloadData()
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
    
}

//MARK: - Extension
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        catalogArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogCell.key, for: indexPath) as? CatalogCell else { return UITableViewCell() }
        cell.nameCatalogLabel.text = catalogArray?[indexPath.row].lastPathComponent
        return cell
    }
    
    
}
