//
//  Search.swift
//  StoreSearch
//
//  Created by 123 on 06.04.2018.
//  Copyright © 2018 123. All rights reserved.
//

import UIKit

typealias SearchComplete = (Bool, NSError?) -> Void

class Search {
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var entityName: String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebooks: return "ebook"
            }
        }
    }
    
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results( [SearchResult] )
    }
    
    fileprivate(set) var state: State = .notSearchedYet
    
    // можно создать модель - DataTask
    let session = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    init() {

    }
}

// MARK: - Networking
extension Search {
    public func cancelOutstandingRequests() {
        print("--> cancel outstanding requests")
        //dataTask?.cancel()
//        self.dataTask = nil
    }
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        dataTask?.cancel()

        if !text.isEmpty {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            state = .loading
            
            let url = iTunesURL(searchText: text, category: category)
            
            dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
                var success = false
                
                if let error = error as NSError?, error.code == -999 {
                    return   // Search was cancelled
                }
                
                //----
                if let jsonData = data, let jsonDictionary = self.parse(json: jsonData)  {
                    var searchResults = self.parse(dictionary: jsonDictionary)
                    
                    DispatchQueue.main.async {
                        if searchResults.isEmpty {
                            self.showAlert("Error localized description \( (response as? HTTPURLResponse)?.description  ?? "")")
                        } else {
                            searchResults.sort(by: <)
                            self.showAlert("\(searchResults.count)")
                        }
                    }
                }
                //----
                
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                    let jsonData = data,
                    let jsonDictionary = self.parse(json: jsonData) {
                    
                    var searchResults = self.parse(dictionary: jsonDictionary)
                    if searchResults.isEmpty {
                        self.state = .noResults
                    } else {
                        searchResults.sort(by: <)
                        self.state = .results(searchResults)
                    }
                    
                    success = true
                }
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(success, (error as NSError?))
                }
            })
            dataTask?.resume()
        }
    }
    
    
    // for tests 
    fileprivate func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Alert from Session", comment: ""),
            message: NSLocalizedString("Parsed data: \(message)", comment: ""),
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        alert.addAction(action)
        
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(alert, animated: true, completion: nil)
    }
    //---
    
    fileprivate func iTunesURL(searchText: String, category: Category) -> URL {
        let entityName = category.entityName
        
        let locale = Locale.current
        let language = locale.languageCode ?? "en"
        let countryCode = locale.regionCode ?? "US"
        
        // method to escape the special characters ((+)(%20) < > )
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@&lang=%@&country=%@",
                   escapedSearchText, entityName, language, countryCode)
        
        let url = URL(string: urlString)
        print("URL: \(url!)")
        return url!
    }
}


// MARK: - Parsing
extension Search {
    
    fileprivate func parse(json data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String : Any]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    fileprivate func parse(dictionary: [String: Any]) -> [SearchResult] {
        guard let array = dictionary["results"] as? [Any] else {
            print("Expected 'results' array")
            return []
        }
        
        var searchResults: [SearchResult] = []
        for resultDict in array {
            if let resultDict = resultDict as? [String: Any] {
                var searchResult: SearchResult?
                
                if let wrapperType = resultDict["wrapperType"] as? String {
                    
                    wrapperType: switch wrapperType {
                    case "track":
                        searchResult = parse(track: resultDict)
                    case "audiobook":
                        searchResult = parse(audiobook: resultDict)
                    case "software":
                        searchResult = parse(software: resultDict)
                    default:
                        break wrapperType
                    }
                    if let result = searchResult {
                        searchResults.append(result)
                    }
                    
                } else if let kind = resultDict["kind"] as? String {
                    kind: switch kind {
                    case "ebook":
                        searchResult = parse(ebook: resultDict)
                        if let result = searchResult {
                            searchResults.append(result)
                        }
                    default:
                        break kind
                    }
                }
                
            }
        }
        return searchResults
    }
    
    fileprivate func parse(track dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    fileprivate func parse(audiobook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    fileprivate func parse(software dictionary: [String: Any]) -> SearchResult {
        
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    fileprivate func parse(ebook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }

        if let genres: Any = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joined(separator: ", ")
        }

        return searchResult
    }
    
}











