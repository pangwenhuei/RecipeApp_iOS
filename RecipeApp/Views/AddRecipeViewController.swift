//
//  AddRecipeViewController.swift
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 20/08/2025.
//

import UIKit
import RxSwift

class AddRecipeViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let titleTextField = UITextField()
    private let typePickerView = UIPickerView()
    private let imageURLTextField = UITextField()
    private let ingredientsTextView = UITextView()
    private let stepsTextView = UITextView()
    private let saveButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private var viewModel: AddRecipeViewModelProtocol!
    private let disposeBag = DisposeBag()
    private var recipeTypes: [RecipeType] = []
    var recipeToEdit: Recipe?
    var onRecipeUpdated: ((Recipe) -> Void)?
    var onRecipeAdded: ((Recipe) -> Void)?
    
    convenience init(recipeToEdit: Recipe? = nil) {
        self.init()
        self.recipeToEdit = recipeToEdit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDependencies()
        setupUI()
        bindViewModel()
        
        if let recipe = recipeToEdit {
            populateFields(with: recipe)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupDependencies() {
        viewModel = AppContainer.shared.container.resolve(AddRecipeViewModelProtocol.self)!
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = recipeToEdit != nil ? "Edit Recipe" : "Add Recipe"
        
        setupNavigationBar()
        setupScrollView()
        setupStackView()
        setupFormElements()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
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
    
    private func setupFormElements() {
        // Title Section
        let titleLabel = createLabel(text: "Recipe Title")
        titleTextField.placeholder = "Enter recipe title"
        titleTextField.borderStyle = .roundedRect
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(titleTextField)
        
        // Type Section
        let typeLabel = createLabel(text: "Recipe Type")
        typePickerView.delegate = self
        typePickerView.dataSource = self
        
        stackView.addArrangedSubview(typeLabel)
        stackView.addArrangedSubview(typePickerView)
        
        // Image URL Section
        let imageLabel = createLabel(text: "Image URL (Optional)")
        imageURLTextField.placeholder = "https://example.com/image.jpg"
        imageURLTextField.borderStyle = .roundedRect
        imageURLTextField.keyboardType = .URL
        
        stackView.addArrangedSubview(imageLabel)
        stackView.addArrangedSubview(imageURLTextField)
        
        // Ingredients Section
        let ingredientsLabel = createLabel(text: "Ingredients (one per line)")
        ingredientsTextView.font = .systemFont(ofSize: 16)
        ingredientsTextView.layer.borderColor = UIColor.systemGray4.cgColor
        ingredientsTextView.layer.borderWidth = 1
        ingredientsTextView.layer.cornerRadius = 8
        
        stackView.addArrangedSubview(ingredientsLabel)
        stackView.addArrangedSubview(ingredientsTextView)
        
        // Steps Section
        let stepsLabel = createLabel(text: "Steps (one per line)")
        stepsTextView.font = .systemFont(ofSize: 16)
        stepsTextView.layer.borderColor = UIColor.systemGray4.cgColor
        stepsTextView.layer.borderWidth = 1
        stepsTextView.layer.cornerRadius = 8
        
        stackView.addArrangedSubview(stepsLabel)
        stackView.addArrangedSubview(stepsTextView)
        
        // Save Button
        saveButton.setTitle("Save Recipe", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        
        // Loading Indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(loadingIndicator)
        stackView.addArrangedSubview(saveButton)
        
        // Set text view heights
        NSLayoutConstraint.activate([
            typePickerView.heightAnchor.constraint(equalToConstant: 120),
            ingredientsTextView.heightAnchor.constraint(equalToConstant: 100),
            stepsTextView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            
            // Match width of stackView to scrollView’s visible frame
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
            
            saveButton.heightAnchor.constraint(equalToConstant: 50),

            loadingIndicator.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ])
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }
    
    private func populateFields(with recipe: Recipe) {
        titleTextField.text = recipe.title
        imageURLTextField.text = recipe.imageURL
        ingredientsTextView.text = recipe.ingredients.joined(separator: "\n")
        stepsTextView.text = recipe.steps.joined(separator: "\n")
        
        // Select the correct recipe type in picker
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            if let index = self?.recipeTypes.firstIndex(where: { $0.id == recipe.recipeTypeId }) {
                self?.typePickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.recipeTypes
            .subscribe(onNext: { [weak self] types in
                self?.recipeTypes = types
                DispatchQueue.main.async {
                    self?.typePickerView.reloadAllComponents()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                DispatchQueue.main.async {
                    if isLoading {
                        self?.loadingIndicator.startAnimating()
                        self?.saveButton.setTitle("", for: .normal)
                        self?.saveButton.isEnabled = false
                    } else {
                        self?.loadingIndicator.stopAnimating()
                        self?.saveButton.setTitle("Save Recipe", for: .normal)
                        self?.saveButton.isEnabled = true
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
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.saveRecipe()
            })
            .disposed(by: disposeBag)
    }
    
    private func saveRecipe() {
        guard let title = titleTextField.text, !title.isEmpty,
              !recipeTypes.isEmpty else {
            showAlert(message: "Please fill in all required fields")
            return
        }
        
        let selectedTypeIndex = typePickerView.selectedRow(inComponent: 0)
        let selectedType = recipeTypes[selectedTypeIndex]
        
        let ingredients = ingredientsTextView.text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let steps = stepsTextView.text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let imageURL = imageURLTextField.text?.isEmpty == false ? imageURLTextField.text : nil
        
        if let recipe = recipeToEdit {
            viewModel.updateRecipe(recipe, title: title, typeId: selectedType.id, imageURL: imageURL, ingredients: ingredients, steps: steps)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] updatedRecipe in
                    self?.onRecipeUpdated?(updatedRecipe)
                    self?.dismiss(animated: true)
                }).disposed(by: disposeBag)
        } else {
            viewModel.addRecipe(title: title, typeId: selectedType.id, imageURL: imageURL, ingredients: ingredients, steps: steps)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] newRecipe in
                    self?.onRecipeAdded?(newRecipe)
                    self?.dismiss(animated: true)
                }).disposed(by: disposeBag)
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - AddRecipe PickerView DataSource and Delegate

extension AddRecipeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recipeTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recipeTypes[row].name
    }
}
