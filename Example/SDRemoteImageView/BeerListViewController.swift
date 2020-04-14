//
//  BeerListViewController.swift
//  SDRemoteImageView_Example
//
//  Created by 류성두 on 2020/04/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SDRemoteImageView

class BeerListViewController: UIViewController {

    @IBOutlet var tableView:UITableView!
    let dataSource = BeerListDataSource()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        tableView.prefetchDataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.loadMoreBeers()
    }
}

extension BeerListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.row == dataSource.beers.count - 1 }) {
            dataSource.loadMoreBeers()
        }
    }
}


class BeerListDataSource: NSObject, UITableViewDataSource {
    weak var tableView:UITableView!
    var beers:[Beer] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return beers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BeerCell
        let beer = beers[indexPath.row]
        cell.beerImageView.sd.loadImage(from: beer.image_url)
        cell.label.text = beer.name
        return cell
    }
    
    func loadMoreBeers() {
        let page = Int(beers.count / 25) + 1
        let url = URL(string:"https://api.punkapi.com/v2/beers?page=\(page)")!
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            let beer = try? JSONDecoder().decode([Beer].self, from: data!)
            DispatchQueue.main.async { [weak self] in
                self?.beers.append(contentsOf: beer ?? [])
                self?.tableView.reloadData()
            }
        })
        .resume()
    }
}

struct Beer: Codable {
    let image_url:URL
    let name:String
}

class BeerCell:UITableViewCell {
    @IBOutlet var beerImageView:UIImageView!
    @IBOutlet var label: UILabel!
}
