import UIKit

class HeaderTableViewCell: UITableViewCell {

    // Labels to display temperatures
    let currentTempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let minTempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let maxTempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(hex: "#47AB2F")
        contentView.addSubview(currentTempLabel)
        contentView.addSubview(minTempLabel)
        contentView.addSubview(maxTempLabel)
        
        NSLayoutConstraint.activate([
            currentTempLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            currentTempLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            currentTempLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            minTempLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            minTempLabel.leadingAnchor.constraint(equalTo: currentTempLabel.trailingAnchor, constant: 16),
            minTempLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            maxTempLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            maxTempLabel.leadingAnchor.constraint(equalTo: minTempLabel.trailingAnchor, constant: 16),
            maxTempLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            maxTempLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with currentTemp: Double, minTemp: Double, maxTemp: Double) {
        minTempLabel.text = "Min: \(Int(minTemp))°C"
        currentTempLabel.text = "Current: \(Int(currentTemp))°C"
        maxTempLabel.text = "Max: \(Int(maxTemp))°C"
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 {
            self.init(white: 1.0, alpha: 0.0)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
