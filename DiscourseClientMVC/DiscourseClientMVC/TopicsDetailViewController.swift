//
//  TopicsDetailViewController.swift
//  DiscourseClientMVC
//
//  Created by Ricardo González Pacheco on 18/03/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit

protocol DeleteProtocol {
    func topicDeleted()
}

class TopicsDetailViewController: UIViewController {
    private var topic: Topic?
    
    var deleteDelegate: DeleteProtocol?
    
    private lazy var postsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Topic posts: \(topic!.postsCount)"
        label.textColor = UIColor.black
        label.font = UIFont(name: "Verdana-Bold", size: 20)
        return label
    }()
    
    private lazy var tituloLabel: UITextView = {
        //        let textView = UITextView(frame: .zero, textContainer: NSTextContainer(size: CGSize(width: 200, height: 200)))
        //        let container = NSTextContainer()
        //        container.maximumNumberOfLines = 5
        //        container.size = CGSize(width: 100, height: 100)
        //        let textView = UITextView(frame: .zero, textContainer: container)
        let textView = UITextView(frame: .zero)
        //        textView.contentSize = CGSize(width: 300, height: 500)
        //        textView.sizeToFit()
        //        textView.centerVertically()
        textView.text = "Topic title: \(topic!.title)"
        textView.textColor = UIColor.black
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = UIFont(name: "Verdana-Bold", size: 20)
        return textView
    }()
    
    
    private lazy var idLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Topic ID: \(topic!.id)"
        label.textColor = UIColor.black
        label.font = UIFont(name: "Verdana-Bold", size: 20)
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        
        let btn = UIButton.init(type: .system)
        btn.frame(forAlignmentRect: .zero)
        btn.setTitle("Delete", for: .normal)
        btn.setTitleColor(UIColor.systemBlue, for: .normal)
        btn.backgroundColor = UIColor.black
        btn.layer.cornerRadius = 5.0
        btn.setTitleShadowColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(isDeleteButtonPressed), for: .touchUpInside)
        
        return btn
    }()
    
    convenience init(topic: Topic) {
        self.init()
        self.topic = topic
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.systemGray3
        title = "Topic Detail"
        
        self.view.addSubview(deleteButton)
        self.view.addSubview(idLabel)
        self.view.addSubview(tituloLabel)
        self.view.addSubview(postsLabel)
        
        self.isDeletable()
        
        //        let centerHorizontally = NSLayoutConstraint(item: deleteButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        //        centerHorizontally.isActive = true
        
        postsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        postsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        postsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        postsLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 40).isActive = true
        postsLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        
        tituloLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tituloLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36).isActive = true
        tituloLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tituloLabel.topAnchor.constraint(equalTo: postsLabel.bottomAnchor, constant: 35).isActive = true
        tituloLabel.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        
        idLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        idLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        idLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        idLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        deleteButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 300).isActive = true
        //        deleteButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
    }
    
    func isDeletable() {
        guard let closed = topic?.closed else { return }
        if closed {
            deleteButton.isHidden = true
        }
    }
    
    @objc func isDeleteButtonPressed(sender: UIButton!) {
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        guard let url = URL(string: "https://mdiscourse.keepcoding.io/t/\(topic!.id).json") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("ricardo", forHTTPHeaderField: "Api-Username")
        
        let task = session.dataTask(with: request) {[weak self] (data, response, error) in  // No estamos en cola principal
            if let response = response as? HTTPURLResponse, response.statusCode >= 400, response.statusCode < 500, let _ = data {
                print(response.statusCode)
                self?.showAlert(title: "Error", message: error?.localizedDescription ?? "")
            }
            
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
            DispatchQueue.main.async {
                self?.deleteDelegate?.topicDeleted()
                self?.navigationController?.popViewController(animated: true)
            }
        }
        task.resume()
    }
}
