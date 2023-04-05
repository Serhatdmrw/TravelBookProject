//
//  ViewController.swift
//  TravelBookProject
//
//  Created by Serhat Demir on 5.04.2023.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Outles
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let viewModel = HomeViewModel()
    var titleArray : [String] = []
    var idArray : [UUID] = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDelegates()
        getData()
        navigationBarButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlaces"), object: nil)
    }
}

// MARK: - Helpers
private extension HomeViewController {
    
    func navigationBarButton() {
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
    }
    
    @objc func addButtonClicked() {
        navigationController?.pushViewController(DetailsViewController(), animated: true)
    }
    
    func addDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.delegate = self
    }
    
    @objc func getData() {
        viewModel.getData()
    }
    
    func makeAlert(titleInput: String, messegaInput: String) {
        let alert = UIAlertController(title: titleInput, message: messegaInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell .defaultContentConfiguration()
        content.text = titleArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(DetailsViewController(), animated: true)
    }
}

// MARK: - HomeViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {
    func didGetDataSuccess(titleArray: [String], idArray: [UUID]) {
        self.titleArray = titleArray
        self.idArray = idArray
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didGetDataFaile(messega: String) {
        self.makeAlert(titleInput: "Error", messegaInput: messega)
    }
}
