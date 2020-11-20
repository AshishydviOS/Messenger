//
//  ConversationsVC.swift
//  Messenger
//
//  Created by Ashish Yadav on 12/11/20.
//

import UIKit
import Firebase

class ConversationsVC : UIViewController {
    
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        return table
    }()
    
    private let noConversationLabel : UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                                 target: self, action: #selector(didComposeTapButton))
        
        self.view.addSubview(tableView)
        self.view.addSubview(noConversationLabel)
        
        setupTV(TV: tableView)
        fetchConversations()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc func didComposeTapButton(){
        let vc = NewConversationVC()
        vc.completion = { [weak self] result in
            self?.createNewConversation(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    func createNewConversation(result : [String : String]) {
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        
        let vc = ChatVC(with: email)
        vc.title = name
        if #available(iOS 11.0, *) {
            vc.navigationItem.largeTitleDisplayMode = .never
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupTV(TV : UITableView) {
        TV.delegate = self
        TV.dataSource = self
        TV.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func validateAuth() {
        LogManager.sharedInstance.logVerbose(#file, methodName: #function, logMessage: "User Validation function called")
        //Check if No Firebase user available
        if Firebase.Auth.auth().currentUser == nil {
            LogManager.sharedInstance.logVerbose(#file, methodName: #function, logMessage: "No Current user found. Navigate to login.")
            let vc = LoginVC()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    //MARK: Custom functions
    func fetchConversations() {
        tableView.isHidden = false
    }
    
}

extension ConversationsVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello World"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatVC()
        vc.title = "Ashish Yadav"
        if #available(iOS 11.0, *) {
            vc.navigationItem.largeTitleDisplayMode = .never
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

