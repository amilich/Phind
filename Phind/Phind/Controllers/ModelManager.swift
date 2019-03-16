//
//  ModelManager.swift
//  Phind
//
//  All direct model manipulations (read and writes) are handled in here.
//
//  Created by Kevin Chang on 2/10/19.
//  Copyright © 2019 Team-7. All rights reserved.
//
import GoogleMaps
import GooglePlaces
import CoreMotion
import UIKit
import RealmSwift
import JustLog

/// The ModelManager class is responsible for reading and writing to our database model (Realm).
public class ModelManager : NSObject {
    
  // Public static fields.
  
  /// Singleton declaration.
  public static let shared = ModelManager()
  
  // Public fields.
  /// Access variable to our Realm database.
  public var realm = AppDelegate().realm
  
  // Private fields
  /// URL session access
  private var sharedURLSession = AppDelegate().sharedUrlSession
  
  /// <section>
  /// All the read methods.
  /// </section>
  
  /// Return most recent location entry.
  public func getMostRecentLocationEntry() -> LocationEntry? {
    
    let locationEntry = realm.objects(LocationEntry.self)
      .sorted(byKeyPath: "start", ascending: false)
      .first
  
    Logger.shared.verbose("Last location entry: \(String(describing: locationEntry))")
    return locationEntry
    
  }
    
  /// Get the 2D coordinate for a given place UUID.
  /// - parameter uuid: String UUID associated with a known place.
  public func getCoordForPlace(uuid: String) -> CLLocationCoordinate2D? {
    
    let placesWithUuid = realm.objects(LocationEntry.self)
      .filter("place_id = %@", uuid)
    if (placesWithUuid.count > 0) {
      return CLLocationCoordinate2D(latitude: placesWithUuid[0].latitude, longitude: placesWithUuid[0].longitude)
    }
    return nil
    
  }
    
  /// Return stored place object with given UUID.
  /// - parameter uuid: String UUID associated with a known place.
  public func getPlaceWithUUID(uuid: String) -> Place? {
    
    let gmsPlaces = realm.objects(Place.self)
      .filter("uuid = %@", uuid)
    if (gmsPlaces.count > 0) {
      return gmsPlaces[0]
    }
    return nil
    
  }
    
  /// Get the GMS place name for a locationEntry by performing lookup on place UUID.
  /// - parameter locationEntry: LocationEntry used to find proper place.
  func getPlace(locationEntry: LocationEntry) -> Place? {
    
    let placeUUID = locationEntry.place_id
    return getPlaceWithUUID(uuid: placeUUID)
    
  }
    
  /// Get the GMS place name for a locationEntry by performing lookup on place UUID.
  /// - parameter locationEntry: LocationEntry used to find proper place UUID.
  func getPlaceLabelForLocationEntry(locationEntry: LocationEntry) -> Place? {
    let placeUUID = locationEntry.place_id
    return getPlaceWithUUID(uuid: placeUUID)
  }
    
  /// Return all location entries from a certain day, limited to max, and ascending default to false.
  public func getLocationEntries(start: Date = Date(), end: Date = Date(), ascending: Bool = false) -> [LocationEntry] {
    
    let locationEntries = realm.objects(LocationEntry.self)
      .filter("start >= %@ AND start < %@", start, end)
      .sorted(byKeyPath: "start", ascending: ascending)
  
    var locationEntriesArr = Array(locationEntries)
    locationEntriesArr.sort(
      by: { $0.start.compare($1.start as Date) == ComparisonResult.orderedAscending }
    )
  
    return locationEntriesArr
        
  }
    
  /// Return all stationary location entries from a certain day, limited to max, and ascending default to false.
  public func getUniqueLocationEntires(from: Date = Date(), ascending: Bool = false) -> [LocationEntry] {
    
    let dayStart = Util.GetLocalizedDayStart(date: from)
    let dayEnd = Util.GetLocalizedDayEnd(date: from)
    let locationEntries = realm.objects(LocationEntry.self).filter("start >= %@ AND start <= %@", dayStart, dayEnd).distinct(by: ["place_id"])
    return Array(locationEntries)
    
  }
  
  /// Find most common or least common place type on a given day
  /// - parameter from: Date to search for
  /// - parameter ascending: Whether to find most or least common place type
  public func mostOrLeastCommonPlaceType(from: Date = Date(), ascending: Bool = false) -> String {
      
    let dayStart = Util.GetLocalizedDayStart(date: from)
    let dayEnd = Util.GetLocalizedDayEnd(date: from)
    let locationEntries = realm.objects(LocationEntry.self)
      .filter("start >= %@ AND start < %@", dayStart, dayEnd)
      .sorted(byKeyPath: "place_id", ascending: ascending)
    if locationEntries.count <= 0{
      return "No Entry"
    }
    
    var emptyDict: [String: Int] = [String: Int]()
    for locationEntry in locationEntries{
      let place_id = locationEntry.place_id
      let identifiedPlace = self.realm.objects(Place.self).filter("uuid = %@", place_id).first
      //check this line
      // TODO make sure length is enough
      let placeType = identifiedPlace!.types[0]
      if var val = emptyDict[placeType] {
        val += 1
        emptyDict[placeType] = val
      } else{
        emptyDict[placeType] = 1
      }
    }
    let mostCommonPlaceType = emptyDict.max { a, b in a.value < b.value }
    return mostCommonPlaceType!.key
        
  }
  
  /// Return the most common location on a particular date
  /// - parameter from: Date to search on
  /// - parameter ascending: Whether to return results in ascending or descending order (default descending)
  public func mostCommonLocation(from: Date = Date(), ascending: Bool = false) -> LocationEntry? {
    
    let dayStart = Util.GetLocalizedDayStart(date: from)
    let dayEnd = Util.GetLocalizedDayEnd(date: from)
    let locationEntries = realm.objects(LocationEntry.self)
      .filter("start >= %@ AND start <= %@", dayStart, dayEnd)
      .sorted(byKeyPath: "place_id", ascending: ascending)
    if locationEntries.count <= 0{
      return nil
    }
    var bestLocationEntry = locationEntries[0]
    var max_count = 0
    var count = 0
    var lastLocationEntry = locationEntries[0]
    for locationEntry in locationEntries{
      if locationEntry.place_id == lastLocationEntry.place_id{
        count += 1
      } else{
        count = 1
      }
      lastLocationEntry = locationEntry
      if count > max_count{
        max_count = count
        bestLocationEntry = locationEntry
      }
    }
    return bestLocationEntry
        
  }
  
  /// Search for a given place name in database
  /// - parameter placeName: Place's name
  public func searchResult(placeName: String = "") -> [Place]? {
    
    let placeEntries = Array(realm.objects(Place.self).filter("name contains[c] %@", placeName))
    return placeEntries
    
  }
  
  /// Return number of times a place has been visited
  /// - parameter place: Place to count
  public func numberVisits(place: Place) -> Int? {
    
    let locationEntries = Array(realm.objects(LocationEntry.self).filter("place_id = %@", place.uuid))
    let numVisits = locationEntries.count
    return numVisits
        
  }
  
  /// Return the last or first time you visited a place
  /// - parameter place: Place you visited
  /// - parameter ascending: Whether to give first or last visit
  public func firstOrLastVisitDate(place: Place, ascending: Bool = false) -> NSDate? {
      
    let placeId = place.uuid
    let locationEntries = Array(realm.objects(LocationEntry.self).filter("place_id = %@", placeId).sorted(byKeyPath: "start", ascending: ascending))
    let lastDate = locationEntries.first!.start
    return lastDate
    
  }
  
  /// Return the locatino history for a given place name
  /// - parameter placeName: Place to find history of
  /// - parameter ascending: Whether to sort ascending or descending
  public func locationHistory(placeName: String = "", ascending: Bool = true) -> [LocationEntry]? {
    let placeEntry = realm.objects(Place.self).filter("name = %@", placeName).first
    let placeId = placeEntry?.uuid
    let locationEntries = realm.objects(LocationEntry.self).filter("place_id = %@", placeId!).sorted(byKeyPath: "start", ascending: ascending)
    
    return Array(locationEntries)
  }
    
  /// Return most recent location entry.
  public func getMostRecentRawCoord() -> RawCoordinates? {
  
    let rawCoordinates = getRawCoords()
    return rawCoordinates.count > 0 ? rawCoordinates[0]  : nil
    
  }
    
  /// Return all location entries from a certain day, limited to max, and ascending default to false.
  /// - parameter from: Date to find coords from
  /// - parameter ascending: Whether to return coords ascending or descending
  public func getRawCoords(from: Date = Date(), ascending: Bool = false) -> [RawCoordinates] {
    
    let dayStart = Calendar.current.startOfDay(for: from)
    let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)
    let rawCoordinates = realm.objects(RawCoordinates.self)
      .filter("timestamp >= %@ AND timestamp < %@", dayStart, dayEnd)
      .sorted(byKeyPath: "timestamp", ascending: ascending)
    
    return Array(rawCoordinates)
    
  }
    
  /// <section>
  /// All the write methods.
  /// </section>
    
  /// Close up previous LocationEntry if necessary by adding an end time.
  /// - parameter locationEntry: LocationEntry to close with last location
  public func closeLocationEntry(_ locationEntry: LocationEntry) {
    
    Logger.shared.verbose("Attempt to close location entry.")
    // Close up last location entry if one is provided to this function.
    try! realm.write {
      locationEntry.end = NSDate()
      Logger.shared.verbose("LocationEntry closed.")
    }
    
  }

  /// Convert list of nearby places into Place objects
  /// - parameter placeLikelihoodList: Array of nearby places to be converted
  private func getLikelyPlaceList(placeLikelihoodList: Array<GMSPlaceLikelihood>) -> [Place]{
    
    var likelyPlaces = [Place]()
    for likelihood in placeLikelihoodList {
      let place = likelihood.place
      let likelyPlace = Place()
      likelyPlace.gms_id = place.placeID ?? "" // TODO need default value
      likelyPlace.name = place.name ?? ""
      likelyPlace.address = place.formattedAddress ?? ""
      likelyPlace.latitude = place.coordinate.latitude
      likelyPlace.longitude = place.coordinate.longitude
      likelyPlaces.append(likelyPlace);
    }
    return likelyPlaces
    
  }
    
  /// Create a location entry from a coordinate update, a current movement type, and a start time.
  /// - parameter rawCoordinates: The coordiantes to use for new location entry
  /// - parameter currMovementType: The movement type update for the location entry
  /// - parameter start: Start type for location. Default is current time.
  public func addLocationEntry(_ rawCoordinates: RawCoordinates,
                               _ currMovementType: MovementType,
                               _ start: Date = Date()) -> LocationEntry {
    
    let locationEntry = LocationEntry()
  
    locationEntry.start = start as NSDate
    locationEntry.longitude = rawCoordinates.longitude
    locationEntry.latitude = rawCoordinates.latitude
    locationEntry.movement_type = currMovementType.rawValue
    locationEntry.raw_coordinates.append(rawCoordinates)
    try! self.realm.write {
      self.realm.add(locationEntry)
      Logger.shared.verbose("Add new LocationEntry: (\(locationEntry.uuid))")
    }
    return locationEntry
    
  }
  
  /// Get the place object from a nearest place query
  /// - parameter nearestPlaceResult: The raw JSON response
  private func getPlaceObject(nearestPlaceResult: [String: Any]) -> Place {
    
    // TODO (annamitchell): move API requests to a separate class?
    let place = Place()
    place.address = nearestPlaceResult["vicinity"] as! String
    place.name = nearestPlaceResult["name"] as! String
    Logger.shared.debug("name: \(place.name)")
    if let geometry = nearestPlaceResult["geometry"] as AnyObject? {
      if let location = geometry["location"] as AnyObject? {
        place.latitude = location["lat"] as! Double
        place.longitude = location["lng"] as! Double
        Logger.shared.debug("latitude: \(place.latitude)")
        Logger.shared.debug("longitude: \(place.longitude)")
      }
    }
    place.gms_id = nearestPlaceResult["place_id"] as! String
    place.types = nearestPlaceResult["types"] as! [String]
    Logger.shared.debug("gms id: \(place.gms_id)")
    return place
    
  }
  
  /// Get the nearby places API request response
  /// - parameter data: Data retrieved from API
  /// - parameter response: The response from the request
  /// - parameter error: Error object (if one occurred)
  public func getNearbySearchResponse(data: Data?, response: URLResponse?, error: Error?) -> [AnyObject]? {
    guard error == nil else {
      Logger.shared.debug("Error retrieving place details.")
      return nil
    }
  
    guard let content = data else {
      Logger.shared.debug("No content retrieved.")
      return nil
    }
  
    guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
      Logger.shared.debug("JSON conversion failed.")
      return nil
    }
  
    guard let nearbySearchApiResponse = json["results"] as? [AnyObject]? else {
      Logger.shared.debug("No result found.")
      return nil
    }
  
    return nearbySearchApiResponse
  }
  
  /// Set place ID for a given location entry
  /// - parameter locationEntry: The location entry to assign a place to
  public func assignPlaceIdToLocation(_ locationEntry: LocationEntry) {
  
    let locationUuid = locationEntry.uuid
  
    let nearbySearchUrl = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(locationEntry.latitude),\(locationEntry.longitude)&rankby=distance&key=\(Credentials.GMS_KEY)")!
  
    Logger.shared.debug(nearbySearchUrl.absoluteString)
  
    let nearbySearchTask = sharedURLSession.dataTask(with: nearbySearchUrl) {(data, response, error) in
    
      let nearbySearchResponse = self.getNearbySearchResponse(data: data, response: response, error: error)
      if nearbySearchResponse == nil {
        Logger.shared.debug("No places found for coordinates.")
        return
      }
    
      // look for associated place in Realm; if it doesn't exist, create it
      let nearestPlaceResult = nearbySearchResponse![0] as! [String : Any]
      let gmsId = nearestPlaceResult["place_id"]
      let nearbySearchRealm = try! Realm()
      let place = nearbySearchRealm.objects(Place.self).filter("gms_id = %@", gmsId!).first
    
      // if non-nil place, add place id to location and return immediately
      if place != nil {
        let locationEntry = nearbySearchRealm.objects(LocationEntry.self).filter("uuid = %@", locationUuid).first
      
        try! nearbySearchRealm.write {
          locationEntry?.place_id = place!.uuid
          Logger.shared.debug("Add new LocationEntry: (\(locationEntry!.uuid)) with place_id (\(place!.gms_id))")
        }
        return
      }
    
      let placeObject = self.getPlaceObject(nearestPlaceResult: nearestPlaceResult)
      let placeDetailsRealm = try! Realm()
    
      try! placeDetailsRealm.write {
        placeDetailsRealm.add(placeObject)
      }
    
      let locationEntry = placeDetailsRealm.objects(LocationEntry.self).filter("uuid = %@", locationUuid).first
    
      try! placeDetailsRealm.write {
        locationEntry!.place_id = placeObject.uuid
        Logger.shared.debug("Add new LocationEntry: (\(locationEntry!.uuid)) with place_id (\(placeObject.gms_id))")
      }
    }
    nearbySearchTask.resume()
  }
  
  
  /// Append a RawCoordinates to a LocationEntry.
  /// - parameter locationEntry: LocationEntry to append coord to.
  /// - parameter rawCoord: RawCoordinate to add to locationEntry.
  public func appendRawCoord(_ locationEntry: LocationEntry, _ rawCoord: RawCoordinates) {
    
    try! realm.write {
      locationEntry.raw_coordinates.append(rawCoord)
    }
  
  }
  
  /// Construct a RawCoordinates entry and add it.
  /// - parameter location: The location containing information used to initialize the raw coordinate.
  public func addRawCoord(_ location: CLLocation) -> RawCoordinates {
    
    let rawCoord = RawCoordinates()
    rawCoord.latitude = location.coordinate.latitude
    rawCoord.longitude = location.coordinate.longitude
    rawCoord.timestamp = NSDate()
    try! realm.write {
      realm.add(rawCoord)
    }
    return rawCoord
    
  }
    
}

/// We extend Realm with asynchronous writing functionality so we are able to write to the database in API calls, which may be off the main thread.
/// See https://realm.io/docs/cookbook/swift/object-to-background/ for original source and more information.
extension Realm {
  /// Asynchronously write to Realm from a background thread.
  func writeAsync<T : ThreadConfined>(obj: T, errorHandler: @escaping ((_ error : Swift.Error) -> Void) = { _ in return }, block: @escaping ((Realm, T?) -> Void)) {
    let wrappedObj = ThreadSafeReference(to: obj)
    let config = self.configuration
    DispatchQueue(label: "background").async {
      autoreleasepool {
        do {
          let realm = try Realm(configuration: config)
          let obj = realm.resolve(wrappedObj)
        
          try realm.write {
              block(realm, obj)
          }
        } catch {
          errorHandler(error)
        }
      }
    }
  }
}
