//
//  StorageManager.swift
//  Messenger
//
//  Created by Ashish Yadav on 16/11/20.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    
    /*
     /images/ashish-yadav-gmail-com_Profile_Picture.png
     */
    
    ///uploads picture to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data : Data,
                                     fileName : String,
                                     completion : @escaping UploadPictureCompletion) {
        
        storage.child("images/\(fileName)").putData(data, metadata: nil) { (metaData, error) in
            guard error == nil else {
                //failed
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { (url, error) in
                guard let url  = url else {
                    print("Failed to get downloaded URL")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL returned : \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    public enum StorageErrors : Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
}
