//
//  CategoriesViewController.swift
//  DiscourseClientMVC
//
//  Created by Ricardo González Pacheco on 17/03/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit

enum CategoryError: Error {
    case empty
    case malformedURL
    case serverError
}

class CategoriesViewController: UIViewController {
    
    var categories = [TopicCategory]()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.dataSource = self
        table.rowHeight = 75
        return table
    }()
    
    override func viewDidLoad() {
        
        
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor.systemGray3
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        fetchCategories { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                case .success(let categories):
                    //self?.showAlert(title: "Success!", message: "Categories loaded")
                    self?.categories = categories
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchCategories(completion: @escaping (Result<[TopicCategory], Error>) -> Void) {
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        guard let url = URL(string: "https://mdiscourse.keepcoding.io/categories.json") else {
            completion(.failure(CategoryError.malformedURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("ricardo", forHTTPHeaderField: "Api-Username")
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse, response.statusCode >= 400, response.statusCode < 500 {
                completion(.failure(CategoryError.serverError))
                return
            }
            
            if let error = error {
                completion(.failure(error))
            }
            
            do{
                guard let data = data else {
                    completion(.failure(CategoryError.empty))
                    return
                }
                
                let categoryResponse = try JSONDecoder().decode(CategoryResponse.self, from: data)
                completion(.success(categoryResponse.categoryList.categories))
                
            } catch (let error) {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        cell.backgroundColor = UIColor.systemGray4
        cell.indentationLevel = 3
        cell.separatorInset.bottom = 1
        return cell
    }
}



// DOMAIN
struct CategoryResponse: Codable {
    let categoryList: CategoryList
    
    enum CodingKeys: String, CodingKey {
        case categoryList = "category_list"
    }
}

struct CategoryList: Codable {
    let categories: [TopicCategory]
}

struct TopicCategory: Codable {
    let name: String
}
