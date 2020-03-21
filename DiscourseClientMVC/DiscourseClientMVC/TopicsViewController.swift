//
//  TopicsViewController.swift
//  DiscourseClientMVC
//
//  Created by Ricardo González Pacheco on 17/03/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
}

enum TopicsError: Error {
    case malformedURL
    case empty
}

class TopicsViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        var table = UITableView(frame: .zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 75
        return table
    }()
    
    var topics = [Topic]()
    
    let topicsDetailVC = TopicsDetailViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addTopicButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addTopicButtonTapped))
        addTopicButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = addTopicButton
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.systemGray3
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        fetchTopics { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                case .success(let topics):
                    self?.topics = topics
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    /*  Creo que loadView() es para llamarlo desde otro VC, no funciona si hago la llamada directamente aquí en el viewDidLoad  */
    
    @objc func addTopicButtonTapped() {
        let createTopicVC = CreateTopicViewController()
        createTopicVC.createTopicDelegate = self
        self.navigationController?.pushViewController(createTopicVC, animated: true)
    }
    
    func fetchTopics(completion: @escaping (Result<[Topic], Error>) -> Void) {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        guard let url = URL(string: "https://mdiscourse.keepcoding.io/latest.json") else {
            completion(.failure(TopicsError.malformedURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("ricardo", forHTTPHeaderField: "Api-Username")
        
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in // Not in main queue
            
            if let response = response as? HTTPURLResponse, response.statusCode >= 400, response.statusCode < 500, let data = data {
                
                print(response.statusCode)
                if let errorResponse = try? JSONDecoder().decode(DiscourseApiError.self, from: data) {
                    var allErrors = ""
                    if let someErrors = errorResponse.errors {
                        for each in 0...someErrors.count {
                            allErrors += someErrors[each]
                            allErrors.append("/-/")
                        }
                    }
                    self?.showAlert(title: "Error", message: allErrors)
                    return
                }
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(TopicsError.empty))
                return
            }
            
            guard let topicResponse = try? JSONDecoder().decode(TopicResponse.self, from: data) else {
                if let error = error {
                    completion(.failure(error))
                }
                return
            }
            completion(.success(topicResponse.topicList.topics))
        }
        task.resume()
    }
}



extension TopicsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let topicsDetailVC = TopicsDetailViewController(topic: topics[indexPath.row])
        topicsDetailVC.deleteDelegate = self
        self.navigationController?.pushViewController(topicsDetailVC, animated: true)
        //topicsDetailVC.modalPresentationStyle = .fullScreen
        //topicsDetailVC.modalTransitionStyle = .partialCurl
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TopicsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = topics[indexPath.row].title
        cell.textLabel?.textColor = UIColor.black
        cell.backgroundColor = UIColor.systemGray4
        cell.indentationLevel = 2
        cell.separatorInset.bottom = 1
        return cell
    }
    
    
}

extension TopicsViewController: DeleteProtocol{
    func topicDeleted() {
        fetchTopics { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                case .success(let topics):
                    self?.topics = topics
                    self?.tableView.reloadData()
                    self?.showAlert(title: "Success!", message: "Topic deleted")
                }
            }
        }
    }
}

extension TopicsViewController: CreateTopicProtocol{
    func topicCreated(){
        fetchTopics { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                case .success(let topics):
                    self?.topics = topics
                    self?.tableView.reloadData()
                    self?.showAlert(title: "Success!", message: "Topic created")
                }
            }
        }
    }
}

// DOMAIN

struct TopicResponse: Codable {
    let topicList: TopicList
    
    enum CodingKeys: String, CodingKey {
        case topicList = "topic_list"
        
    }
}

struct TopicList: Codable {
    let topics: [Topic]
}


struct Topic: Codable {
    let id: Int
    let title: String
    let postsCount: Int
    let closed: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case postsCount = "posts_count"
        case closed
    }
}

struct DiscourseApiError: Codable, Error {
    let errors: [String]?
    let errorType: String?
    
    enum CodingKeys: String, CodingKey {
        case errors
        case errorType = "error_type"
    }
}
