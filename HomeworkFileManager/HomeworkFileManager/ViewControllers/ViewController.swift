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
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CatalogCell.self, forCellReuseIdentifier: CatalogCell.key)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            action: nil)
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    //Add Alert with creating a new catalog
    func addAlertCreateNewCatalog() {
        let alertNewCatalog = UIAlertController(title: "Create a new catalog", message: "Print a name", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
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
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogCell.key, for: indexPath) as? CatalogCell else { return UITableViewCell() }
//        cell.nameCatalogLabel.text = "Kirill"
        return cell
    }
    
    
}
