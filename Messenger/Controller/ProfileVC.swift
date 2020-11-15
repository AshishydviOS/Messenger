//
//  ProfileVC.swift
//  Messenger
//
//  Created by Ashish Yadav on 12/11/20.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {
    
    @IBOutlet weak var profileTV : UITableView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTV(TV: profileTV)
    }
    
    func setupTV(TV : UITableView) {
        TV.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        TV.delegate = self
        TV.dataSource = self
    }
    
}

extension ProfileVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        callLogoutBtn()
    }
    
    func callLogoutBtn() {
        let actionSheet = UIAlertController(title: "", message: "Are you share you want to logout?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            do {
                try Firebase.Auth.auth().signOut()
                let vc = LoginVC()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
            catch {
                print("Failed to log out!")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
}
