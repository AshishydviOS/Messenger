//
//  ProfileVC.swift
//  Messenger
//
//  Created by Ashish Yadav on 12/11/20.
//

import UIKit
import Firebase
import SDWebImage

class ProfileVC: UIViewController {
    
    @IBOutlet weak var profileTV : UITableView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTV(TV: profileTV)
        profileTV.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        profileTV.tableHeaderView = createTableHeader()
    }
    
    func setupTV(TV : UITableView) {
        TV.delegate = self
        TV.dataSource = self
    }
    
    
    func createTableHeader() -> UIView? {
        let safeEmail = DatabaseManager.shared.safeEmail(emailAddress: UDManager.sharedInstance.userEmail)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/\(fileName)"
        
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = .blue
        let ImageView = UIImageView(frame: CGRect(x: (view.width - 150)/2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        ImageView.contentMode = .scaleAspectFill
        ImageView.layer.borderWidth = 3
        ImageView.layer.borderColor = UIColor.white.cgColor
        ImageView.backgroundColor = .white
        ImageView.layer.masksToBounds = true
        ImageView.layer.cornerRadius = ImageView.width / 2
        headerView.addSubview(ImageView)
        
        StorageManager.shared.downloadURL(for: path) { [weak self] (result) in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let url):
                strongSelf.downloadImage(imageView: ImageView, url: url)
            case .failure(let error):
                print("Failed to get download url : \(error)")
            }
        }
        
        return headerView
    }
    
    func downloadImage(imageView : UIImageView, url : URL) {
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }

            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
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
