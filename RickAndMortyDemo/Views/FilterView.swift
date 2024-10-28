import UIKit

// MARK: - FilterViewDelegate
protocol FilterViewDelegate: AnyObject {
    func didReceiveFilters(_ filters: [CharacterSearchType])
}

// MARK: - FilterView
final class FilterView: UIView {
    // Status Section
    let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .setGilroy(14, type: .bold)
        label.textColor = .rmWhite
        label.text = "Status"
        label.textAlignment = .center
        return label
    }()
    let statusButtons: [UIButton] = {
        (0...2).map {
            let button = UIButton.systemButton(with: UIImage(), target: nil, action: nil)
            button.tag = $0
            button.cornerRadius(6)
            button.backgroundColor = .rmBlackSecondary
            button.snp.makeConstraints { make in
                make.height.width.equalTo(18)
            }
            return button
        }
    }()
    private(set) lazy var statusButtonsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: statusButtons)
        view.axis = .vertical
        view.spacing = 6
        view.alignment = .fill
        view.distribution = .fillEqually
        return view
    }()
    let statusLabelsStackView: UIStackView = {
        let texts = ["Alive", "Dead", "Unknown"]
        let labels = (0...2).map {
            let label = UILabel()
            label.text = texts[$0]
            label.font = .setGilroy(12)
            
            switch $0 {
            case 0:
                label.textColor = .rmGreen
            case 1:
                label.textColor = .rmRed
            case 2:
                label.textColor = .rmYellow
            case _:
                break
            }
            
            return label
        }
        
        let view = UIStackView(arrangedSubviews: labels)
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .leading
        view.distribution = .fillEqually
        return view
    }()
    let statusView: UIView = {
        let view = UIView()
        view.backgroundColor = .rmBlackBG.withAlphaComponent(0.9)
        view.cornerRadius(8)
        return view
    }()
    // Species Section
    let speciesLabel: UILabel = {
        let label = UILabel()
        label.font = .setGilroy(14, type: .bold)
        label.textColor = .rmWhite
        label.text = "Species"
        label.textAlignment = .center
        return label
    }()
    let speciesTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .rmBlackBG.withAlphaComponent(0.9)
        field.font = .setGilroy(16)
        field.tintColor = .rmWhite
        field.textColor = .rmWhite
        field.attributedPlaceholder = NSAttributedString(
            string: "Species...",
            attributes: [
                .foregroundColor: UIColor.rmWhite.withAlphaComponent(0.75),
                .font: UIFont.setGilroy(16)
            ]
        )
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
        field.cornerRadius(8)
        return field
    }()
    // Type Section
    let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .setGilroy(14, type: .bold)
        label.textColor = .rmWhite
        label.text = "Type"
        label.textAlignment = .center
        return label
    }()
    let typeTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .rmBlackBG.withAlphaComponent(0.9)
        field.font = .setGilroy(16)
        field.tintColor = .rmWhite
        field.textColor = .rmWhite
        field.attributedPlaceholder = NSAttributedString(
            string: "Type...",
            attributes: [
                .foregroundColor: UIColor.rmWhite.withAlphaComponent(0.75),
                .font: UIFont.setGilroy(16)
            ]
        )
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
        field.cornerRadius(8)
        return field
    }()
    // Gender Section
    let genderLabel: UILabel = {
        let label = UILabel()
        label.font = .setGilroy(14, type: .bold)
        label.textColor = .rmWhite
        label.text = "Gender"
        label.textAlignment = .center
        return label
    }()
    let genderButtons: [UIButton] = {
        (0...3).map {
            let button = UIButton.systemButton(with: UIImage(), target: nil, action: nil)
            button.tag = $0
            button.cornerRadius(6)
            button.backgroundColor = .rmBlackSecondary
            button.snp.makeConstraints { make in
                make.height.width.equalTo(18)
            }
            return button
        }
    }()
    private(set) lazy var genderButtonsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: genderButtons)
        view.axis = .vertical
        view.spacing = 6
        view.alignment = .fill
        view.distribution = .fillEqually
        return view
    }()
    let genderLabelsStackView: UIStackView = {
        let texts = ["Female", "Male", "Genderless", "Unknown"]
        let labels = (0...3).map {
            let label = UILabel()
            label.text = texts[$0]
            label.font = .setGilroy(12)
            label.textColor = .rmWhite
            return label
        }
        
        let view = UIStackView(arrangedSubviews: labels)
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .leading
        view.distribution = .fillEqually
        return view
    }()
    let genderView: UIView = {
        let view = UIView()
        view.backgroundColor = .rmBlackBG.withAlphaComponent(0.9)
        view.cornerRadius(8)
        return view
    }()
    private(set) var currentStatus: CharacterSearchType?
    private(set) var currentSpecies: CharacterSearchType?
    private(set) var currentType: CharacterSearchType?
    private(set) var currentGender: CharacterSearchType?
    weak var delegate: FilterViewDelegate?
    var isShowing: Bool = false
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        
        // Delegates
        typeTextField.delegate = self
        speciesTextField.delegate = self
        
        // Targets
        statusButtons.forEach { $0.addTarget(self, action: #selector(statusTapped), for: .touchUpInside) }
        genderButtons.forEach { $0.addTarget(self, action: #selector(genderTapped), for: .touchUpInside) }
        speciesTextField.addTarget(self, action: #selector(interactionWithSpeciesField), for: .editingChanged)
        typeTextField.addTarget(self, action: #selector(interactionWithTypeField), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    func resetAll() {
        statusButtons.forEach { $0.setImage(nil, for: .normal) }
        genderButtons.forEach { $0.setImage(nil, for: .normal) }
        speciesTextField.text = ""
        typeTextField.text = ""
        
        currentStatus = nil
        currentSpecies = nil
        currentType = nil
        currentGender = nil
    }
    
    private func sendFilters() {
        var filters: [CharacterSearchType] = []
        
        if let currentStatus {
            filters.append(currentStatus)
        }
        
        if let currentSpecies {
            filters.append(currentSpecies)
        }
        
        if let currentType {
            filters.append(currentType)
        }
        
        if let currentGender {
            filters.append(currentGender)
        }
        
        delegate?.didReceiveFilters(filters)
    }
    
    // MARK: - Actions
    @objc
    private func statusTapped(_ sender: UIButton) {
        statusButtons.forEach { $0.setImage(nil, for: .normal) }
        
        let status: CharacterSearchType
        switch sender.tag {
        case 0:
            status = .status(status: .alive)
        case 1:
            status = .status(status: .dead)
        case 2:
            status = .status(status: .unknown)
        case _:
            return
        }
        
        if
            let currentStatus,
            currentStatus.characterStatus! == status.characterStatus! {
            self.currentStatus = nil
            sender.setImage(nil, for: .normal)
        } else {
            self.currentStatus = status
            sender.setImage(.check, for: .normal)
        }
        sendFilters()
    }
    
    @objc
    private func genderTapped(_ sender: UIButton) {
        genderButtons.forEach { $0.setImage(nil, for: .normal) }
        
        let gender: CharacterSearchType
        switch sender.tag {
        case 0:
            gender = .gender(gender: .female)
        case 1:
            gender = .gender(gender: .male)
        case 2:
            gender = .gender(gender: .genderless)
        case _:
            gender = .gender(gender: .unknown)
        }
        
        if
            let currentGender,
            currentGender.characterGender! == gender.characterGender! {
            self.currentGender = nil
            sender.setImage(nil, for: .normal)
        } else {
            self.currentGender = gender
            sender.setImage(.check, for: .normal)
        }
        sendFilters()
    }
    
    @objc
    private func interactionWithTypeField() {
        guard let text = typeTextField.text, !text.isEmpty else {
            currentType = nil
            sendFilters()
            return
        }
        currentType = CharacterSearchType.type(type: text)
        sendFilters()
    }
    
    @objc
    private func interactionWithSpeciesField() {
        guard let text = speciesTextField.text, !text.isEmpty else {
            currentSpecies = nil
            sendFilters()
            return
        }
        currentSpecies = CharacterSearchType.species(species: text)
        sendFilters()
    }
}

// MARK: - TextField Delegate
extension FilterView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
}

// MARK: - Layout
extension FilterView {
    private func layout() {
        backgroundColor = .rmBlackSecondary.withAlphaComponent(0.9)
        cornerRadius(12)
        
        [
            statusLabel,
            statusView,
            speciesLabel,
            speciesTextField,
            typeLabel,
            typeTextField,
            genderLabel,
            genderView
        ].forEach {
            addSubview($0)
        }
        
        // StatusView Subviews
        statusView.addSubview(statusButtonsStackView)
        statusView.addSubview(statusLabelsStackView)
        
        statusButtonsStackView.snp.makeConstraints { make in
            let offset = 12
            
            make.top.leading.equalToSuperview().offset(offset)
            make.bottom.equalToSuperview().offset(-offset)
            make.width.equalTo(18)
        }
        
        statusLabelsStackView.snp.makeConstraints { make in
            let leadingOffset = 6
            let offset = 12
            
            make.top.equalToSuperview().offset(offset)
            make.trailing.equalToSuperview().offset(-offset)
            make.bottom.equalToSuperview().offset(-offset)
            make.leading.equalTo(statusButtonsStackView.snp.trailing).offset(leadingOffset)
        }
        
        // GenderView Subviews
        genderView.addSubview(genderButtonsStackView)
        genderView.addSubview(genderLabelsStackView)
        
        genderButtonsStackView.snp.makeConstraints { make in
            let offset = 12
            
            make.top.leading.equalToSuperview().offset(offset)
            make.bottom.equalToSuperview().offset(-offset)
            make.width.equalTo(18)
        }
        
        genderLabelsStackView.snp.makeConstraints { make in
            let leadingOffset = 6
            let offset = 12
            
            make.top.equalToSuperview().offset(offset)
            make.trailing.equalToSuperview().offset(-offset)
            make.bottom.equalToSuperview().offset(-offset)
            make.leading.equalTo(genderButtonsStackView.snp.trailing).offset(leadingOffset)
        }
        
        // Subviews
        statusLabel.snp.makeConstraints { make in
            let offset = 12
            
            make.top.leading.equalTo(offset)
            make.trailing.equalToSuperview().offset(-offset)
        }
        
        statusView.snp.makeConstraints { make in
            let horizontalOffset = 12
            let topOffset = 6
            
            make.top.equalTo(statusLabel.snp.bottom).offset(topOffset)
            make.leading.equalToSuperview().offset(horizontalOffset)
            make.trailing.equalToSuperview().offset(-horizontalOffset)
            make.height.equalTo(90)
        }
        
        speciesLabel.snp.makeConstraints { make in
            let offset = 12
            
            make.top.equalTo(statusView.snp.bottom).offset(offset)
            make.leading.equalTo(offset)
            make.trailing.equalToSuperview().offset(-offset)
        }
        
        speciesTextField.snp.makeConstraints { make in
            let horizontalOffset = 12
            let topOffset = 6
            
            make.top.equalTo(speciesLabel.snp.bottom).offset(topOffset)
            make.leading.equalToSuperview().offset(horizontalOffset)
            make.trailing.equalToSuperview().offset(-horizontalOffset)
            make.height.equalTo(40)
        }
        
        typeLabel.snp.makeConstraints { make in
            let offset = 12
            
            make.top.equalTo(speciesTextField.snp.bottom).offset(offset)
            make.leading.equalTo(offset)
            make.trailing.equalToSuperview().offset(-offset)
        }
        
        typeTextField.snp.makeConstraints { make in
            let horizontalOffset = 12
            let topOffset = 6
            
            make.top.equalTo(typeLabel.snp.bottom).offset(topOffset)
            make.leading.equalToSuperview().offset(horizontalOffset)
            make.trailing.equalToSuperview().offset(-horizontalOffset)
            make.height.equalTo(40)
        }
        
        genderLabel.snp.makeConstraints { make in
            let offset = 12
            
            make.top.equalTo(typeTextField.snp.bottom).offset(offset)
            make.leading.equalTo(offset)
            make.trailing.equalToSuperview().offset(-offset)
        }
        
        genderView.snp.makeConstraints { make in
            let offset = 12
            let topOffset = 6
            
            make.top.equalTo(genderLabel.snp.bottom).offset(topOffset)
            make.leading.equalToSuperview().offset(offset)
            make.trailing.equalToSuperview().offset(-offset)
            make.height.equalTo(114)
            make.bottom.equalToSuperview().offset(-offset)
        }
    }
}
