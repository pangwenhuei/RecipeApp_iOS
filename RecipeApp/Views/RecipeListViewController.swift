//
//  RecipeListViewController.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 20/08/2025.
//

import UIKit
import RxSwift


class RecipeListViewController: UIViewController {
    private let tableView = UITableView()
    private let filterPickerView = UIPickerView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let filterLabel = UILabel()
    
    private var viewModel: RecipeListViewModelProtocol!
    private let disposeBag = DisposeBag()
    private var recipes: [Recipe] = []
    private var recipeTypes: [RecipeType] = []
    private var selectedFilterTypeId: String? = nil  // nil = "All Types"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDependencies()
        setupUI()
        bindViewModel()
        viewModel.loadRecipes()
    }
    
    private func setupDependencies() {
        viewModel = AppContainer.shared.container.resolve(RecipeListViewModelProtocol.self)!
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Recipes"
        
        setupNavigationBar()
        setupFilterLabel()
        setupFilterPickerView()
        setupTableView()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addRecipeTapped)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
    }
    
    private func setupFilterLabel() {
        filterLabel.text = "Filter by Type:"
        filterLabel.font = .systemFont(ofSize: 17, weight: .medium)
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterLabel)
    }
    
    private func setupFilterPickerView() {
        filterPickerView.delegate = self
        filterPickerView.dataSource = self
        filterPickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterPickerView)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecipeCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            filterLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            filterLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            filterLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            filterPickerView.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 10),
            filterPickerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            filterPickerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            filterPickerView.heightAnchor.constraint(equalToConstant: 120),
            
            tableView.topAnchor.constraint(equalTo: filterPickerView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.recipes
            .subscribe(onNext: { [weak self] recipes in
                self?.recipes = recipes
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.recipeTypes
            .subscribe(onNext: { [weak self] types in
                self?.recipeTypes = [RecipeType(id: "all", name: "All Types", description: "", imageURL: nil)] + types
                DispatchQueue.main.async {
                    self?.filterPickerView.reloadAllComponents()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                DispatchQueue.main.async {
                    if isLoading {
                        self?.loadingIndicator.startAnimating()
                    } else {
                        self?.loadingIndicator.stopAnimating()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .subscribe(onNext: { [weak self] error in
                DispatchQueue.main.async {
                    self?.showAlert(message: error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func addRecipeTapped() {
        let addRecipeVC = AddRecipeViewController()
        addRecipeVC.onRecipeAdded = { [weak self] newRecipe in
            // Check if the recipe matches the current filter
            if self?.selectedFilterTypeId == nil || self?.selectedFilterTypeId == newRecipe.recipeTypeId {
                // Append to the local list
                self?.recipes.append(newRecipe)
                self?.recipes.sort(by: { $0.createdDate > $1.createdDate })
                DispatchQueue.main.async {
                    let newIndex = self?.recipes.firstIndex(where: { $0.id == newRecipe.id }) ?? 0
                    let indexPath = IndexPath(row: newIndex, section: 0)
                    self?.tableView.insertRows(at: [indexPath], with: .automatic)
                }
            } else {
                // Optionally: Show alert to tell user the recipe was added
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Recipe Added",
                        message: "The new recipe does not match the current filter and won’t appear in the list until the filter is changed.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
        let navController = UINavigationController(rootViewController: addRecipeVC)
        present(navController, animated: true)
    }
    
    @objc private func logoutTapped() {
        let authService = AppContainer.shared.container.resolve(AuthServiceProtocol.self)!
        
        authService.logout()
            .subscribe(onNext: {
                DispatchQueue.main.async {
                    let loginVC = LoginViewController()
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    sceneDelegate?.window?.rootViewController = loginVC
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - RecipeList TableView DataSource and Delegate

extension RecipeListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "RecipeCell")
        let recipe = recipes[indexPath.row]
        
        cell.textLabel?.text = recipe.title
        
        // Find recipe type name
        let recipeType = recipeTypes.first { $0.id == recipe.recipeTypeId }
        cell.detailTextLabel?.text = recipeType?.name ?? "Unknown Type"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recipe = recipes[indexPath.row]
        let detailVC = RecipeDetailViewController(recipe: recipe)
        
        detailVC.recipeDeleted
            .subscribe(onNext: { [weak self] deletedRecipeId in
                guard let self = self else { return }
                self.recipes.removeAll { $0.id == deletedRecipeId }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        detailVC.recipeUpdated
            .subscribe(onNext: { [weak self] updated in
                guard let self = self else { return }
                if let index = self.recipes.firstIndex(where: { $0.id == updated.id }) {
                    self.recipes[index] = updated
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                }
            })
            .disposed(by: disposeBag)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recipe = recipes[indexPath.row]
            viewModel.deleteRecipe(recipe.id)
        }
    }
}

// MARK: - RecipeList PickerView DataSource and Delegate

extension RecipeListViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recipeTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recipeTypes[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedType = recipeTypes[row]
        if selectedType.id == "all" {
            selectedFilterTypeId = nil
            viewModel.filterRecipes(by: nil)
        } else {
            selectedFilterTypeId = selectedType.id
            viewModel.filterRecipes(by: selectedType.id)
        }
    }
}
