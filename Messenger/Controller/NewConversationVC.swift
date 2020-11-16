//
//  NewConversationVC.swift
//  Messenger
//
//  Created by Ashish Yadav on 12/11/20.
//

import UIKit

class NewConversationVC: UIViewController {

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
        
        searchBar.delegate = self
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.topItem?.titleView = searchBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    @objc func dismissSelf(){
        self.dismiss(animated: true)
    }
}

extension NewConversationVC : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
