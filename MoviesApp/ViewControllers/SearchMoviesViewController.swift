//
//  SearchMoviesViewController.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/12/17.
//
//

import Foundation
import UIKit
import MBProgressHUD

class SearchMoviesViewController: UIViewController {
  
  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var suggestionsTableView: UITableView!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var suggestionTableHeightConstraint: NSLayoutConstraint!
  var suggestionsList: [String]?
  fileprivate lazy var presenter: SearchMoviesPresenter = {
    let diProvider = DependeciesProvider.sharedInstance
    return SearchMoviesPresenter(moviesProvider: diProvider.moviesProvider(),
                                 viewController: self)
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    searchButton.isEnabled = false
  }

  @IBAction func searchButtonPressed(_ sender: Any) {
    guard let text = searchTextField.text else { return }
    presenter.searchButtonClicked(searchQuery: text)
  }
}

extension SearchMoviesViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

    let textFieldText: NSString = (textField.text ?? "") as NSString
    let finalText = textFieldText.replacingCharacters(in: range, with: string)
    searchButton.isEnabled = finalText.characters.count > 0
    presenter.searchTextFieldChanged(text: finalText)
    return true
  }

  func textFieldDidBeginEditing(_ textField: UITextField) {
    var text = ""
    if let textFieldText = searchTextField.text {
      text = textFieldText
    }
    presenter.searchTextFieldChanged(text: text)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard let text = searchTextField.text else { return false}
    presenter.searchButtonClicked(searchQuery: text)
    return true
  }
}

extension SearchMoviesViewController: SearchMoviesScreen {

  func refreshSuggestionsTable(resutls: [String]) {
    suggestionsList = resutls
    suggestionsTableView.reloadData()
    suggestionTableHeightConstraint.constant = CGFloat(resutls.count * 25)
  }

  func showLoadingView() {
    view.endEditing(true)
    let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
    loadingNotification.mode = MBProgressHUDMode.indeterminate
    loadingNotification.label.text = "Loading"
  }

  func hideLoadingView() {
    MBProgressHUD.hide(for: view, animated: true)
  }

  func clearSearchText() {
    view.endEditing(true)
    searchTextField.text = ""
  }

  func showError(message: String) {
    let alert = UIAlertController.init(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }

  func openMoviesListScreen(moviesList: [Movie], searchQuery: String) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let controller = storyboard.instantiateViewController(withIdentifier: "MoviesListViewController") as? MoviesListViewController {
      controller.updateWith(initialMoviesList: moviesList, searchQuery: searchQuery)
      navigationController?.pushViewController(controller, animated: true)
    }
  }
}

extension SearchMoviesViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let list = suggestionsList else { return 0}
    return list.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
    if let list = suggestionsList, list.count > indexPath.row {
      cell.textLabel?.text = list[indexPath.row]
    }
    return cell
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
}

extension SearchMoviesViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let list = suggestionsList, list.count > indexPath.row {
      searchTextField.text = list[indexPath.row]
      presenter.searchButtonClicked(searchQuery: list[indexPath.row])
    }
  }
}
