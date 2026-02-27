//
//  CityListViewController.swift
//  Test_Task_Weather
//
//  Created by developer on 27.02.26.
//

import UIKit

final class CityListViewController: UIViewController {
    private let viewModel: CityListViewModel
    var onCitySelected: ((String) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(viewModel: CityListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cities"
        view.backgroundColor = .systemBackground

        setupTableView()
        bindViewModel()
        viewModel.load()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.accessibilityIdentifier = "cityList.table"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.onItemUpdated = { [weak self] index in
            let indexPath = IndexPath(row: index, section: 0)
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

extension CityListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        let item = viewModel.item(at: indexPath.row)
        let secondaryText = "\(item.temperatureCelsius) C"
        cell.accessibilityIdentifier = "cityCell.\(item.city)"

        var content = cell.defaultContentConfiguration()
        content.text = item.city
        let attributedSecondaryText = NSMutableAttributedString(string: secondaryText)
        if viewModel.shouldHighlightTemperature(item.temperatureCelsius) {
            let valueRange = NSRange(location: 0, length: secondaryText.count)
            attributedSecondaryText.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: valueRange)
        }
        content.secondaryAttributedText = attributedSecondaryText
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

extension CityListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onCitySelected?(viewModel.item(at: indexPath.row).city)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let updateAction = UIContextualAction(style: .normal, title: "Update") { [weak self] _, _, completion in
            self?.viewModel.updateItem(at: indexPath.row)
            completion(true)
        }
        updateAction.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [updateAction])
    }
}
