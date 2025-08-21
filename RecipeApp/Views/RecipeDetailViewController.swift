//
//  RecipeDetailViewController.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 20/08/2025.
//

import UIKit
import RxSwift
import Kingfisher

class RecipeDetailViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let recipeImageView = UIImageView()
    private let titleLabel = UILabel()
    private let typeLabel = UILabel()
    private let ingredientsTextView = UITextView()
    private let stepsTextView = UITextView()
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let recipeSubject: BehaviorSubject<Recipe>
    let recipeDeleted = PublishSubject<String>()
    let recipeUpdated = PublishSubject<Recipe>()
    
    var recipe: Recipe
    private let disposeBag = DisposeBag()
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.recipeSubject = BehaviorSubject(value: recipe)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        recipeSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] updatedRecipe in
                self?.recipe = updatedRecipe
                self?.displayRecipe()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Recipe Details"
        
        setupScrollView()
        setupStackView()
        setupElements()
        setupConstraints()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
    }
    
    private func setupElements() {
        // Image View
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = 12
        recipeImageView.backgroundColor = .systemGray5
        
        // Title Label
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        
        // Type Label
        typeLabel.font = .systemFont(ofSize: 18)
        typeLabel.textColor = .systemBlue
        
        // Ingredients Text View
        let ingredientsLabel = createSectionLabel(text: "Ingredients")
        ingredientsTextView.font = .systemFont(ofSize: 16)
        ingredientsTextView.isEditable = false
        ingredientsTextView.layer.borderColor = UIColor.systemGray4.cgColor
        ingredientsTextView.layer.borderWidth = 1
        ingredientsTextView.layer.cornerRadius = 8
        
        // Steps Text View
        let stepsLabel = createSectionLabel(text: "Steps")
        stepsTextView.font = .systemFont(ofSize: 16)
        stepsTextView.isEditable = false
        stepsTextView.layer.borderColor = UIColor.systemGray4.cgColor
        stepsTextView.layer.borderWidth = 1
        stepsTextView.layer.cornerRadius = 8
        
        // Buttons
        editButton.setTitle("Edit Recipe", for: .normal)
        editButton.backgroundColor = .systemBlue
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.cornerRadius = 8
        editButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        deleteButton.setTitle("Delete Recipe", for: .normal)
        deleteButton.backgroundColor = .systemRed
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.layer.cornerRadius = 8
        deleteButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        // Add to stack view
        stackView.addArrangedSubview(recipeImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(typeLabel)
        stackView.addArrangedSubview(ingredientsLabel)
        stackView.addArrangedSubview(ingredientsTextView)
        stackView.addArrangedSubview(stepsLabel)
        stackView.addArrangedSubview(stepsTextView)
        
        // Create button stack
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10
        buttonStackView.addArrangedSubview(editButton)
        buttonStackView.addArrangedSubview(deleteButton)
        
        stackView.addArrangedSubview(buttonStackView)
        
        // Set constraints for elements
        NSLayoutConstraint.activate([
            recipeImageView.heightAnchor.constraint(equalToConstant: 200),
            ingredientsTextView.heightAnchor.constraint(equalToConstant: 120),
            stepsTextView.heightAnchor.constraint(equalToConstant: 150),
            editButton.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Bind button actions
        editButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.editRecipe()
            })
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.confirmDelete()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func createSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    private func displayRecipe() {
        titleLabel.text = recipe.title
        ingredientsTextView.text = recipe.ingredients.joined(separator: "\n")
        stepsTextView.text = recipe.steps.joined(separator: "\n")
        
        // Load recipe type name
        let recipeTypeService = AppContainer.shared.container.resolve(RecipeTypeServiceProtocol.self)!
        
        recipeTypeService.getRecipeTypes()
            .subscribe(onNext: { [weak self] types in
                let recipeType = types.first { $0.id == self?.recipe.recipeTypeId }
                DispatchQueue.main.async {
                    self?.typeLabel.text = recipeType?.name ?? "Unknown Type"
                }
            })
            .disposed(by: disposeBag)
        
        // Load image if available
        if let imageURLString = recipe.imageURL, let imageURL = URL(string: imageURLString) {
            recipeImageView.kf.setImage(with: imageURL, placeholder: UIImage(systemName: "photo"))
        } else {
            recipeImageView.image = UIImage(systemName: "photo")
        }
    }
    
    private func editRecipe() {
        let addRecipeVC = AddRecipeViewController(recipeToEdit: recipe)
        
        // Provide a callback for when recipe is updated
        addRecipeVC.onRecipeUpdated = { [weak self] updated in
            self?.recipeSubject.onNext(updated)
            self?.recipeUpdated.onNext(updated)
        }
        
        let navController = UINavigationController(rootViewController: addRecipeVC)
        present(navController, animated: true)
    }
    
    private func confirmDelete() {
        let alert = UIAlertController(title: "Delete Recipe", message: "Are you sure you want to delete this recipe?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteRecipe()
        })
        
        present(alert, animated: true)
    }
    
    private func deleteRecipe() {
        let recipeService = AppContainer.shared.container.resolve(RecipeServiceProtocol.self)!
        
        recipeService.deleteRecipe(recipe.id)
            .subscribe(onNext: { [weak self] _ in
                self?.recipeDeleted.onNext(self?.recipe.id ?? "")
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}
