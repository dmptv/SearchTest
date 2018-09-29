//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by 123 on 04.04.2018.
//  Copyright © 2018 123. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var search: Search!
    
    fileprivate var firstTime = true
    
    fileprivate var downloadTasks = [URLSessionDownloadTask]()
 
// MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        removeConstraints()
    }
    
    fileprivate func setupViews() {
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        scrollView.isPagingEnabled = true
        pageControl.numberOfPages = 0
    }
    
    fileprivate func removeConstraints() {
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        checkState()
        
        scrollView.frame = view.bounds
        pageControl.frame = CGRect(x: 0,
                                   y: view.frame.size.height - pageControl.frame.size.height,
                                   width: view.frame.size.width,
                                   height: pageControl.frame.size.height)
    }
    
    fileprivate func checkState() {
        if firstTime {
            firstTime = false
            
            switch search.state {
            case .notSearchedYet:
                break
            case .loading:
                showSpinner()
            case .noResults:
                showNothingFoundLabel()
            case .results(let list):
                tileButtons(list)
            }
        }
    }
    
    fileprivate func showSpinner() {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.center = CGPoint(x: scrollView.bounds.midX + 0.5, y: scrollView.bounds.midY + 0.5)
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    fileprivate func hideSpinner() {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    public func searchResultsReceived() {
        hideSpinner()
        switch search.state {
        case .notSearchedYet, .loading:
            break
        case .noResults:
            showNothingFoundLabel()
        case .results(let list):
            tileButtons(list)
        }
    }
    
    fileprivate func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = NSLocalizedString("Nothing Found", comment: "")
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        // optimal size - will help for different languagies
        label.sizeToFit()
        var rect = label.frame
        rect.size.width = ceil(rect.size.width/2) * 2    // make even
        rect.size.height = ceil(rect.size.height/2) * 2  // make even
        label.frame = rect
        label.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
        view.addSubview(label)
    }

    deinit {
        print("deinit \(self)")
        for task in downloadTasks {
            task.cancel()
        }
    }
}

// MARK: - Layout Buttons
extension LandscapeViewController {
    fileprivate func tileButtons(_ searchResults: [SearchResult]) {
        // 480 points, 3.5-inch (iPad)
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        
        let scrollViewWidth = scrollView.bounds.size.width
        switch scrollViewWidth {
        case 568:
            // 4-inch device (iPhone 5 models, iPhone SE)
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
        case 667:
            // 4.7-inch device (iPhone 6, 6s, 7)
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
        case 736:
            // 5.5-inch device (iPhone 6/6s/7 Plus)
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
        default:
            break
        }
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        var row = 0
        var column = 0
        var x = marginX
        for (index, searchResult) in searchResults.enumerated() {
            
            let button = UIButton(type: .custom)
            button.tag = 2000 + index
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            downloadImage(for: searchResult, andPlaceOn: button)
            button.frame = CGRect(x: x + paddingHorz,
                                  y: marginY + (CGFloat(row) * itemHeight) + paddingVert,
                                  width: buttonWidth,
                                  height: buttonHeight)
            
            // this places any subsequent button out of the visible range
            // of the scroll view, but that’s the whole point
            scrollView.addSubview(button)
            
            row += 1
            if row == rowsPerPage {
                row = 0; x += itemWidth; column += 1
                if column == columnsPerPage {
                    column = 0; x += marginX * 2
                }
            }
            
            let buttonsPerPage = columnsPerPage * rowsPerPage
            let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
            // calculate the contentSize for the scroll view based on how many buttons fit on a page
            scrollView.contentSize = CGSize(width: CGFloat(numPages) * scrollViewWidth,
                                            height: scrollView.bounds.size.height)
            
            pageControl.numberOfPages = numPages
            pageControl.currentPage = 0
        }
    }

}

// MARK: - Scroll View Delegate
extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let currentPage = Int( (scrollView.contentOffset.x + width/2) / width )
        pageControl.currentPage = currentPage
    }
}

// MARK: - Handles
extension LandscapeViewController {
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations:
            {
                self.scrollView.contentOffset =
                    CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
                            y: 0)
        },
                       completion: nil)
    }
}

// MARK: - Navigation
extension LandscapeViewController {
    
    @objc func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let index = (sender as! UIButton).tag - 2000
                let searchResult = list[index]
                detailViewController.searchResult = searchResult
                detailViewController.isPopUp = true
            }
        }
    }
}

// MARK: - Networking
extension LandscapeViewController {
    fileprivate func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
        if let url = URL(string: searchResult.artworkSmallURL) {
            
            // capture the button with a weak reference
            let downloadTask = URLSession.shared.downloadTask(with: url) { [weak button] url, response, error in
                
                if error == nil,
                    let url = url,
                    let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data) {
                    
                        if let button = button {
                            DispatchQueue.main.async {
                                let img = image.resizedImage(withBounds: CGSize(width: 60, height: 60))
                                button.setImage(img, for: .normal)
                            }
                        }
                }
            }
            downloadTasks.append(downloadTask)
            downloadTask.resume()
        }
    }

}






















