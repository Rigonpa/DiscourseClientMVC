//
//  UsersViewController.swift
//  DiscourseClientMVC
//
//  Created by Ricardo González Pacheco on 17/03/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit

enum UsersError: Error {
    case empty
    case malformedURL
}

class UsersViewController: UIViewController, NameUpdateProtocol {
    
    var users = [DirectoryItems]()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 100
        return table
    }()
    
    override func viewDidLoad() {
        
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = UIColor.systemGray3
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        fetchUsers { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                case .success(let users):
                    self?.users = users
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func nameUpdated() {
        fetchUsers { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                case .success(let users):
                    self?.users = users
                    self?.tableView.reloadData()
                    self?.showAlert(title: "Success!", message: "Name updated")
                }
            }
        }
    }
    
    func fetchUsers(completion: @escaping (Result<[DirectoryItems], Error>) -> Void) {
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        guard let url = URL(string: "https://mdiscourse.keepcoding.io/directory_items.json?period=weekly&order=topic_count") else {
            completion(.failure(UsersError.malformedURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("ricardo", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) {(data, response, error) in   // No en cola principal
            
            if let response = response as? HTTPURLResponse, response.statusCode >= 400, response.statusCode < 500, let data = data {
                print(response.statusCode)
                
                var allErrors = ""
                if let discourseApiError = try? JSONDecoder().decode(DiscourseApiError.self, from: data) {
                    
                    allErrors = "\(discourseApiError.errorType!) | "
                    for each in 0...discourseApiError.errors!.count {
                        allErrors += discourseApiError.errors![each]
                        allErrors.append("/-/")
                    }
                }
                
                self.showAlert(title: "Error", message: allErrors)
                return
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(UsersError.empty))
                return
            }

            do {
                let usersResponse = try JSONDecoder().decode(UsersListResponse.self, from: data)
                completion(.success(usersResponse.directoryItems))
                return
            } catch (let error) {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let usersDetailVC = UsersDetailViewController(user: users[indexPath.row].user)
        usersDetailVC.nameUpdateDelegate = self
        self.navigationController?.pushViewController(usersDetailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(users[indexPath.row].user.username)"
        
        let stringLong = users[indexPath.row].user.avatar_template
        let replacedString = stringLong.replacingOccurrences(of: "{size}", with: "75")
        let imagePath = "https://mdiscourse.keepcoding.io\(replacedString)"
        
        DispatchQueue.global(qos: .userInteractive).async {
            guard let imageURL = URL(string: imagePath) else { return }
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            DispatchQueue.main.async {
                cell.imageView?.image = UIImage(data: imageData)
                
                cell.textLabel?.textColor = UIColor.black
                cell.backgroundColor = UIColor.systemGray4
                cell.indentationLevel = 2
                cell.separatorInset.bottom = 1
            }
        }
        return cell
    }
}

// DOMAIN
struct UsersListResponse: Codable {
    let directoryItems: [DirectoryItems]
    
    enum CodingKeys: String, CodingKey {
        case directoryItems = "directory_items"
    }
    
}

struct DirectoryItems: Codable {
    let user: UserAttributes
    
}

struct UserAttributes: Codable {
    
    let avatar_template: String
    let id: Int
    let name: String?    // Un día entero perdido por este opcional. No he sabido llegar con el debugger a que me saliera mensaje de que nil en variable name!
    let username: String
    
}

/*
 
 Modelo ya declarado en TopicsViewController.swift
 
 struct DiscourseApiError: Codable{
 let errors: [String]?
 let errorType: String
 
 enum CodingKeys: String, CodingKey {
 case errors
 case errorType = "error_type"
 }
 }
 
 */
