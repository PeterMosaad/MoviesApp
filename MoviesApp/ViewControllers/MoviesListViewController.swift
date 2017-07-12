//
//  MoviesListViewController.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/12/17.
//
//

import Foundation
import UIKit

class MoviesListViewController: UIViewController {

  @IBOutlet weak var moviesTableView: UITableView!
  var moviesViewModelList: [MovieViewModel]?
  fileprivate lazy var presenter: MoviesListPresenter = {
    let diProvider = DependeciesProvider.sharedInstance
    return MoviesListPresenter(moviesProvider: diProvider.moviesProvider(),
                               viewController: self,
                               posterBuilder: diProvider.moviesPosterURLBuilder())
  }()

}

extension MoviesListViewController: MoviesListScreen {

  func updateMoviesTable(moviesList: [MovieViewModel]) {
    moviesViewModelList = moviesList
    moviesTableView.reloadData()
  }

  func endTableRefreshing() {
    
  }
}

extension MoviesListViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let list = moviesViewModelList else { return 0}
    return list.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
    if let list = moviesViewModelList, list.count > indexPath.row {
      //cell.textLabel?.text = list[indexPath.row]
    }
    return cell
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
}
