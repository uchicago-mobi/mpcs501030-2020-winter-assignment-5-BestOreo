//
//  FavoritesViewController.swift
//  assignment_5
//
//  Created by 葛帅琦 on 2/9/20.
//  Copyright © 2020 Shuaiqi Ge. All rights reserved.
//

import UIKit


class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: PlacesFavoritesDelegate?

    @IBAction func dimissTableView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.sharedInstance.listFavorites().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! FavoriteCell
        cell.title.text = DataManager.sharedInstance.listFavorites()[indexPath.row][0]
        cell.subtitle.text = DataManager.sharedInstance.listFavorites()[indexPath.row][1]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.favoritePlace(name: DataManager.sharedInstance.listFavorites()[indexPath.row][0])
        self.dismiss(animated: true)
    }
}

protocol PlacesFavoritesDelegate: class {
    
  func favoritePlace(name: String) -> Void
    
}

