//
//  ShoppingListViewController.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 07/05/2025.
//

import UIKit
import Combine

class ShoppingListViewController: UIViewController {
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private(set) weak var segmentControl: UISegmentedControl!
    @IBOutlet private(set) weak var searchBar: UISearchBar!

    var viewModel: ShoppingListViewModelAdaptable?
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
        viewModel?.loadUI()
    }

    @IBAction func didChangeSegment(_ sender: Any) {
        viewModel?.didChangeSegment(selectedIndex: segmentControl.selectedSegmentIndex)
    }

    @IBAction func didTapSort(_ sender: Any) {
        viewModel?.didTapSort()
    }

    @IBAction func didTapAdd(_ sender: Any) {
        viewModel?.didTapAdd()
    }
}

extension ShoppingListViewController {
    private func setupUI() {
        tableView.register(UINib(nibName: ShoppingListCell.identifier, bundle: Bundle(for: Self.self)), forCellReuseIdentifier: ShoppingListCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }

    private func setupBinding() {
        viewModel?.reloadUIHandler.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }.store(in: &cancellables)
    
        viewModel?.shouldHideSegmentUIHandler.sink { [weak self] shouldHide in
            self?.segmentControl.isHidden = shouldHide
        }.store(in: &cancellables)
    }

    private func setupBinding(for cell: ShoppingListCell) {
        cell.didTapCellAccessory.sink { [weak self] index in
            self?.showQuickActions(for: index)
        }.store(in: &cancellables)
    }
}

//MARK: - TableView DataSource and Delegate
extension ShoppingListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.filteredItems.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ShoppingListCell.identifier, for: indexPath) as? ShoppingListCell {
            if let item = viewModel?.filteredItems[indexPath.row] {
                cell.updateUI(with: item, index: indexPath.row)
            }
            setupBinding(for: cell)
            return cell
        }
        return UITableViewCell()
    }
}

extension ShoppingListViewController {
    func showQuickActions(for index: Int) {
        let actionSheet = UIAlertController.actionSheet(title: "Options",
                                                        actions: getQuickActions(index: index))
        present(actionSheet, animated: true)
    }

    func getQuickActions(index: Int) -> [UIAlertAction] {
        ShoppingListQuickAction.allCases.map { action in
            UIAlertAction(title: action.actionTitle, style: .default) { [weak self] _ in
                self?.viewModel?.didTapQuickAction(for: action, index: index)
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension ShoppingListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.didUpdateSearchText(searchText: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
