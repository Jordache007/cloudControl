import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var degrees: UILabel!
    @IBOutlet weak var weatherText: UILabel!
    
    var tableView: UITableView!
    let locationManager = CLLocationManager()
    private var viewModel = CloudControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage(for: "sunny")
        setupTableView()
        startLocationUpdates()
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: view.bounds.height / 2, width: view.bounds.width, height: view.bounds.height / 2), style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        tableView.register(HeaderTableViewCell.self, forCellReuseIdentifier: "headerCell")
        view.addSubview(tableView)
    }
    
    func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func date(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }
    
    func updateUIWithWeather() {
        guard let weather = viewModel.weatherResponse?.weather.first else {
            return
        }
        DispatchQueue.main.async {
            self.degrees.text = "\(Int(self.viewModel.weatherResponse?.main.temp ?? 0))°C"
            self.weatherText.text = weather.main
            self.updateBackgroundImage()
        }
    }

    func updateBackgroundImage() {
        guard let weather = viewModel.weatherResponse?.weather.first?.main.lowercased() else {
            return
        }
        var backgroundImageName: String
        
        switch weather {
        case "clear":
            backgroundImageName = "sunny"
        case "clouds":
            backgroundImageName = "cloudy"
        case "rain":
            backgroundImageName = "rainy"
        case "smoke":
            backgroundImageName = "smoky"
        default:
            backgroundImageName = "default"
        }
        
        DispatchQueue.main.async {
            self.backgroundImage.image = UIImage(named: "forest_\(backgroundImageName)")
        }
    }
    
    func setBackgroundImage(for name: String) {
        DispatchQueue.main.async {
            self.backgroundImage.image = UIImage(named: "forest_\(name)")
        }
    }

    private func fetchWeatherData(_ lat: CLLocationDegrees, _ lon: CLLocationDegrees) {
        viewModel.fetchWeatherData(lat: lat, lon: lon) { result in
            switch result {
            case .success:
                self.updateUIWithWeather()
            case .failure(let error):
                print("Failed to fetch weather data:", error)
            }
        }
    }
    
    private func fetchForeCast(_ lat: CLLocationDegrees, _ lon: CLLocationDegrees) {
        viewModel.fetchForecast(lat: lat, lon: lon) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch forecast data:", error)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationManager.stopUpdatingLocation()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        fetchWeatherData(lat, lon)
        fetchForeCast(lat, lon)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("Location permission granted.")
            locationManager.startUpdatingLocation()
        } else {
            print("Location permission restricted or denied.")
        }
    }
}

extension ViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.forecastData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        let forecast = viewModel.forecastData[indexPath.row]
        
        guard let date = date(from: forecast.dt_txt) else {
            cell.textLabel?.text = ""
            return cell
        }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let weekdayName = calendar.weekdaySymbols[weekday - 1]
        
        cell.textLabel?.text = "\(weekdayName): \(forecast.main.temp_max)°C"
        cell.backgroundColor = UIColor(hex: "#47AB2F")
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        var weatherImageView: UIImageView
        if let existingImageView = cell.contentView.viewWithTag(100) as? UIImageView {
            weatherImageView = existingImageView
        } else {
            weatherImageView = UIImageView()
            weatherImageView.translatesAutoresizingMaskIntoConstraints = false
            weatherImageView.tag = 100
            cell.contentView.addSubview(weatherImageView)
        }
        
        if let weatherCondition = forecast.weather.first?.main.lowercased() {
            switch weatherCondition {
            case "clear":
                weatherImageView.image = UIImage(named: "clear")
            case "rain":
                weatherImageView.image = UIImage(named: "rain")
            case "clouds":
                weatherImageView.image = UIImage(named: "partlysunny")
            case "smoke":
                weatherImageView.image = UIImage(named: "smoke")
            default:
                weatherImageView.image = nil
            }
        }
        
        NSLayoutConstraint.activate([
            weatherImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            weatherImageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            weatherImageView.widthAnchor.constraint(equalToConstant: 40),
            weatherImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? HeaderTableViewCell,
              let weather = viewModel.weatherResponse?.main else {
            return nil
        }
        
        let headerView = UIView()
        headerView.addSubview(headerCell)
        
        headerCell.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerCell.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerCell.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerCell.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerCell.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        headerCell.configure(with: weather.temp, minTemp: weather.temp_min, maxTemp: weather.temp_max)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
