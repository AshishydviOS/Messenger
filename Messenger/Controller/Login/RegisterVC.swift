//
//  RegisterVC.swift
//  Messenger
//
//  Created by Ashish Yadav on 12/11/20.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {

    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let firstNameField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastNameField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let emailField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address ..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password ..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let registerButton : UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "person")
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        //ADD SubView
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        registerButton.addTarget(self,
                                 action: #selector(registerButtonTapped),
                                 for: .touchUpInside)
        
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc func didTapChangeProfilePic() {
        print("Image button tapped!")
        PresentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = (size / 2)
        
        firstNameField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52 )
        
        lastNameField.frame = CGRect(x: 30,
                                  y: firstNameField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52 )
        
        
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52 )
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        registerButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 20,
                                   width: scrollView.width - 60,
                                   height: 52)
    }
    
    //MARK: Firebase register using Email and password
    @objc private func registerButtonTapped(){
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            
            alertUserLoginError()
            return
        }
        
        ProgressHandler.sharedInstance.showProgress()
        DatabaseManager.shared.userExists(with: email) { [weak self] (existing) in
            
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                ProgressHandler.sharedInstance.hideProgress()
            }
            
            if existing {
                //user already exist
                strongSelf.alertUserLoginError(msg: "User already exist")
                return
            }
            
            ProgressHandler.sharedInstance.showProgress()
            Firebase.Auth.auth().createUser(withEmail: email, password: password) { (AuthResult, error) in
                
                DispatchQueue.main.async {
                    ProgressHandler.sharedInstance.hideProgress()
                }
                
                guard  AuthResult != nil, error == nil else {
                    print("Error creating user")
                    return
                }
                
                let chatUser = ChatAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAddress: email)
                
                DatabaseManager.shared.insertUser(with: chatUser) { (success) in
                    if success {
                        //upload Image
                        guard  let image = strongSelf.imageView.image, let data = image.pngData() else {
                            return
                        }
                        
//                        /images/ashish-yadav-gmail-com_Profile_Picture.png
                        let fileName = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { (result) in
                            switch result {
                                case .success(let downloadUrl):
                                    print(downloadUrl)
                                    UDManager.sharedInstance.userProfileUrl = downloadUrl
                                case .failure(let error):
                                    print("Storage Manager error : \(error)")
                            }
                        }
                    }
                }
                strongSelf.navigationController?.dismiss(animated: true)
            }
        }
    }
    
    func alertUserLoginError(msg : String = "Please enter all information to create a new account."){
         let alert = UIAlertController(title: "Woops!",
                                       message: msg,
                                       preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterVC()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RegisterVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        }
        else if textField == lastNameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            registerButtonTapped()
        }
        return true
    }
}

//MARK: Selecting Picture and its delegate results to take the picture or select the photo
//UINavigationControllerDelegate works with UIImagePickerControllerDelegate
extension RegisterVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: Custom Function
    func PresentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self](cameraAction) in
                                                self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self](cameraAction) in
                                                self?.presentPhotoPicker()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: { (cameraAction) in
              
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc              = UIImagePickerController()
        vc.sourceType       = .camera
        vc.delegate         = self
        vc.allowsEditing    = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc              = UIImagePickerController()
        vc.sourceType       = .photoLibrary
        vc.delegate         = self
        vc.allowsEditing    = true
        present(vc, animated: true)
    }
    
    //Calls when user click on cancel while taking the picture or Photo selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    //Calls when user take the photo or select the photo
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        self.imageView.image = selectedImage
        self.dismiss(animated: true)
    }
}
