import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    @Published var currentCurrency: String = ""
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        determineCurrency(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            currentCurrency = "USD"
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
   
    private func determineCurrency(for location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first, error == nil else { return }
            if let countryCode = placemark.isoCountryCode {
                self.currentCurrency = CurrencyMapper.shared.currency(for: countryCode)
            }
        }
    }
}
