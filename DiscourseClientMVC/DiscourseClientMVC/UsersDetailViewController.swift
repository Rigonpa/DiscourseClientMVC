//
//  UsersDetailViewController.swift
//  DiscourseClientMVC
//
//  Created by Ricardo González Pacheco on 20/03/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit

protocol NameUpdateProtocol {
    func nameUpdated()
}

enum UserDetailError: Error {
    case empty
    case malformedURL
}

class UsersDetailViewController: UIViewController {
    
    var user: UserAttributes?
    var nameUpdateDelegate: NameUpdateProtocol?
    
    private lazy var idLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "User ID: \(self.user!.id)"
        label.textColor = UIColor.black
        label.font = UIFont(name: "Verdana-Bold", size: 20)
        label.isHidden = true
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Name:"
        label.textColor = UIColor.black
        label.font = UIFont(name: "Verdana-Bold", size: 20)
        label.isHidden = true
        return label
    }()
    
    private lazy var fixedNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        if let name = user!.name {
            label.text = "\(name)"
        }
        label.textColor = UIColor.black
        label.font = UIFont(name: "Verdana-Bold", size: 20)
        label.isHidden = true
        return label
    }()
    
    private lazy var nameValue: UITextField = {
        let text = UITextField(frame: .zero)
        text.textColor = UIColor.black
        text.layer.cornerRadius = 5.0
        text.backgroundColor = UIColor.clear
        text.layer.borderWidth = 1.0
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.font = UIFont(name: "Verdana-Bold", size: 20)
        text.isHidden = true
        if let name = user!.name {
            text.placeholder = "\(name)"
        }
        return text
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Username: \(self.user!.username)"
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Verdana-Bold", size: 20)
        label.isHidden = true
        return label
    }()
    
    private lazy var updateButton: UIButton = {
        
        let btn = UIButton.init(type: .system)
        btn.frame(forAlignmentRect: .zero)
        btn.setTitle("Update", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.backgroundColor = UIColor.orange
        btn.layer.cornerRadius = 5.0
        btn.setTitleShadowColor(UIColor.darkText, for: .normal)
        btn.addTarget(self, action: #selector(isUpdateButtonPressed), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    convenience init(user: UserAttributes){
        self.init()
        self.user = user
    }
    
    /* VIEW DID LOAD */
    override func viewDidLoad() {
        
        self.title = "User Detail"
        
        setupUI()
        
        isNameEditable {[weak self] (result) in
            
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                case .success(let nameEditable):
                    if nameEditable {
                        self?.idLabel.isHidden = false
                        self?.nameLabel.isHidden = false
                        //                        self?.fixedNameLabel.isHidden = false
                        self?.nameValue.isHidden = false
                        self?.usernameLabel.isHidden = false
                        self?.updateButton.isHidden = false
                    } else {
                        self?.idLabel.isHidden = false
                        self?.nameLabel.isHidden = false
                        self?.fixedNameLabel.isHidden = false
                        //                        self?.nameValue.isHidden = false
                        self?.usernameLabel.isHidden = false
                        //                        self?.updateButton.isHidden = false
                    }
                }
            }
        }
    }
    
    func setupUI() {
        
        
        view.addSubview(idLabel)
        view.addSubview(nameLabel)
        view.addSubview(fixedNameLabel)
        view.addSubview(nameValue)
        view.addSubview(usernameLabel)
        view.addSubview(updateButton)
        
        view.backgroundColor = UIColor.systemGray3
        
        
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        fixedNameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameValue.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        // idlabel contraints
        idLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        idLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        idLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        idLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        // nameLabel constraints
        nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        nameLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 40).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        // fixedNameLabel constraints
        fixedNameLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 30).isActive = true
        fixedNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        fixedNameLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        fixedNameLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        
        // nameValue constraints
        nameValue.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 30).isActive = true
        nameValue.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        nameValue.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        nameValue.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        
        // usernameLabel constraints
        usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 40).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        // updateButton constraints
        updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        updateButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 300).isActive = true
        updateButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
    }
    
    func isNameEditable(completion: @escaping (Result<Bool,Error>) -> Void) {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        guard let url = URL(string: "https://mdiscourse.keepcoding.io/users/\(user!.username).json") else {
            completion(.failure(UserDetailError.malformedURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("ricardo", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            if let response = response as? HTTPURLResponse, response.statusCode >= 400, response.statusCode < 500 {
                self?.showAlert(title: "Error", message: response.statusCode.description)
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(UserDetailError.empty))
                return
            }
            
            do {
                let userDetailResponse = try JSONDecoder().decode(UserDetailResponse.self, from: data)
                completion(.success(userDetailResponse.user.canEditName))
                return
            } catch (let error) {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    @objc func isUpdateButtonPressed(){
        
        if nameValue.isEqual("") {
            return
        }
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        guard let url = URL(string: "https://mdiscourse.keepcoding.io/users/\(user!.username)") else {
            self.showAlert(title: "Error", message: UserDetailError.malformedURL.localizedDescription)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("ricardo", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "name" : "\(nameValue.text!)"
        ]
        guard let dataBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = dataBody
        
        let task = session.dataTask(with: request) {[weak self] (data, response, error) in // No estoy en cola principal
            if let response = response as? HTTPURLResponse, response.statusCode >= 400, response.statusCode < 500 {
                self?.showAlert(title: "Error", message: response.statusCode.description)
            }
            
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
            
            guard let data = data else {
                self?.showAlert(title: "Error", message: UserDetailError.empty.localizedDescription)
                return
            }
            
            do{
                let nameUpdateResponse = try JSONDecoder().decode(NameUpdateResponse.self, from: data)
                DispatchQueue.main.async {
                    if nameUpdateResponse.success.lowercased() == "ok" && nameUpdateResponse.user.name == self?.nameValue.text! {
                        self?.nameUpdateDelegate?.nameUpdated()
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
                
            } catch (let error) {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
        task.resume()
    }
}


// DOMAIN

struct UserDetailResponse: Codable {
    let user: UserDetail
}

struct UserDetail: Codable {
    let canEditName: Bool
    
    enum CodingKeys: String, CodingKey {
        case canEditName = "can_edit_name"
    }
}

struct NameUpdateResponse: Codable {
    let success: String
    let user: User
}

struct User: Codable {
    let name: String
}
