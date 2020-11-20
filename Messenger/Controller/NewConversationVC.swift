//
//  NewConversationVC.swift
//  Messenger
//
//  Created by Ashish Yadav on 12/11/20.
//

import UIKit

class NewConversationVC: UIViewController {
    
    public var completion : (([String : String]) -> (Void))?
    
    private var users = [[String : String]]()
    private var results = [[String : String]]()
    private var hasFetched = false
    
    private let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
    }()
    
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        return table
    }()
    
    private let NoResultsLabel : UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium )
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(NoResultsLabel)
        view.addSubview(tableView)
        setupTV(TV: tableView)
        
        searchBar.delegate = self
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.topItem?.titleView = searchBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        NoResultsLabel.frame = CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width/2, height: 100)
    }
    
    func setupTV(TV : UITableView) {
        TV.delegate = self
        TV.dataSource = self
        TV.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc func dismissSelf(){
        self.dismiss(animated: true)
    }
}

extension NewConversationVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
    }
}

extension NewConversationVC : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        self.results.removeAll()
        ProgressHandler.sharedInstance.showProgress()
        self.seachUsers(query: text)
    }
    
    func seachUsers(query : String) {
        //Check if array has firebase results
        if hasFetched {
            //if it does : filter
            filterUser(with: query)
        }
        else {
            //if not, fetch then filter
            DatabaseManager.shared.getAllUsers { [weak self] (result) in
                switch result {
                case .success(let value):
                    self?.hasFetched = true
                    self?.users = value
                    self?.filterUser(with: query )
                    break
                case .failure(let error):
                    print("Failed to get users : \(error)")
                    break
                }
            }
        }
        //if it does : filter
        //if not, fetch then filter
        
    }
    
    func filterUser(with term : String){
        //update the UI : either show results or show no results label
        guard hasFetched else {
            return
        }
        ProgressHandler.sharedInstance.hideProgress()
        
        let results : [[String : String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        })
        
        self.results = results
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            self.NoResultsLabel.isHidden = false
            self.tableView.isHidden = true
        }
        else {
            self.NoResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}

