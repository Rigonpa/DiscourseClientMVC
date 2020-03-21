//
//  CreateTopicViewController.swift
//  DiscourseClientMVC
//
//  Created by Ricardo González Pacheco on 18/03/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit

protocol CreateTopicProtocol {
    func topicCreated()
}

class CreateTopicViewController: UIViewController{
    
    var createTopicDelegate: CreateTopicProtocol?
    
    private lazy var titleNewTopicLabel: UILabel = {
        var label = UILabel(frame: .zero)
        label.text = "Title:"
        label.font = UIFont(name: "Verdana-Italic", size: 20)
        label.tintColor = UIColor.darkGray
        return label
    }()
    
    private lazy var  newTopicTitle: UITextField = {
        let field = UITextField(frame: .zero)
        field.font = UIFont(name: "Verdana-Bold", size: 20)
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.cornerRadius = 5.0
        field.textColor = UIColor.black
        return field
    }()
    
    private lazy var  submitButton: UIButton = {
        let btn = UIButton.init(type: .system)
        btn.frame(forAlignmentRect: .zero)
        btn.setTitleShadowColor(UIColor.darkText, for: .normal)
        btn.setTitle("Submit", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.backgroundColor = UIColor.init(red: 30/255, green: 130/255, blue: 250/255, alpha: 1.0)
        btn.layer.cornerRadius = 5.0
        btn.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    
    override func viewDidLoad() {
        self.title = "Create"
        view.backgroundColor = UIColor.systemGray3
        
        view.addSubview(titleNewTopicLabel)
        view.addSubview(newTopicTitle)
        view.addSubview(submitButton)
        
        
        titleNewTopicLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleNewTopicLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 130),
            titleNewTopicLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleNewTopicLabel.widthAnchor.constraint(equalToConstant: 70),
            titleNewTopicLabel.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        
        newTopicTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newTopicTitle.centerYAnchor.constraint(equalTo: titleNewTopicLabel.centerYAnchor),
            newTopicTitle.leadingAnchor.constraint(equalTo: titleNewTopicLabel.trailingAnchor, constant: 15),
            newTopicTitle.heightAnchor.constraint(equalToConstant: 45),
            newTopicTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            submitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 300),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 55),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40)
        ])
        
        
    }
    
    @objc func submitButtonTapped(sender: UIButton!){
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        guard let url = URL(string: "https://mdiscourse.keepcoding.io/posts.json") else {
            showAlert(title: "Error", message: "MalformedURL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("ricardo", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "title" : "\(newTopicTitle.text!)",
            "raw" : "\(newTopicTitle.text!) - raw"
        ]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = bodyData
        
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in // No estamos en cola principal
            if let response = response as? HTTPURLResponse, response.statusCode >= 400, response.statusCode < 500 {
                print(response.statusCode)
                self?.showAlert(title: "Error", message: response.statusCode.description)
            }
            
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                self?.createTopicDelegate?.topicCreated()
                self?.navigationController?.popViewController(animated: true)
            }
        }
        task.resume()
    }
    
}


// DOMAIN
struct TopicsResponse: Codable {
    let id: Int
    let name: String
    let username: String
    let avatar_template: String
}
