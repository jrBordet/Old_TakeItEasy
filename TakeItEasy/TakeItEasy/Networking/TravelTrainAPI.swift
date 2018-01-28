//
//  TravelTrainAPI.swift
//  ViaggioTreno
//
//  Created by Jean Raphael on 11/11/2017.
//  Copyright © 2017 Jean Raphael. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}

enum CommonError : Error {
    
    case parsingError
    case networkError
}

protocol TravelTrainAPIProtocol {
    static func trainStations(of name: String) -> Observable<[Station]>
    
    static func trainDepartures(of code: String) -> Observable<[Travel?]>
    
    static func trainArrivals(of code: String) -> Observable<[Travel?]>
    
    static func trainSections(of codeDeparture: String, _ codeTrain: String) -> Observable<[Section?]>
}

struct TravelTrainAPI: TravelTrainAPIProtocol {
    
    // MARK: - API Addresses
    
    fileprivate enum Address: String {
        case stations = "autocompletaStazione/"
        case departures = "partenze/"
        case arrivals = "arrivi/"
        case sections = "tratteCanvas/"
        
        var baseURL: String {
            return "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/"
        }
        
        var string: String {
            return "\(baseURL)\(rawValue)"
        }
        
        var url: URL {
            return URL(string: baseURL.appending(rawValue))!
        }
    }
    
    // MARK: - TravelTrainAPIProtocol
    
    /// Retrieve stations by the given string
    /// Example: [Url example](http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/autocompletaStazione/mil)
    /// Return a list of station as
    //    MILANO CENTRALE|S01700
    //    MILANO AFFORI|S01078
    //    MILANO BOVISA FNM|S01642
    /// - Parameter name: the name of the station
    /// - Returns: a collection of Station
    static func trainStations(of name: String) -> Observable<[Station]> {
        return URLSession
            .shared
            .rx
            .data(request: URLRequest(url: Address.stations.url.appendingPathComponent(name)))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { data -> [Station] in
                if let returnData = String(data: data, encoding: .utf8) {
                    let stations = returnData.split(separator: "\n").map({ element -> Station in
                        let station = element.split(separator: "|")
                        
                        return Station(String(station[1]),
                                       name: String(station[0]) as String)
                    })
                    return stations
                }
                return []
        }
    }
    
    /// Perform an Http request to retrieve all the departures from the give station id.
    /// Example:
    /// [Url ecample](http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/partenze/S01700/Mon%20Nov%2020%202017%2008:30:00%20GMT+0100%20)
    /// Mon Nov 20 2017 17:30:00 GMT+0100 (ora solare Europa occidentale)
    ///
    /// - Parameters:
    ///   - code: the station code. Example S01700
    /// - Returns: a collection of Departure
    static func trainDepartures(of code: String) -> Observable<[Travel?]> {
        let urlEncoded =  "\(Address.departures.string)\(code)/\(String(describing: createFormattedDate()))"
        
        return URLSession
            .shared
            .rx
            .json(request: URLRequest(url: URL(string: urlEncoded)!))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ result -> [Travel?] in
                guard let solutions = result as? [Any] else { return [] }
                
                return solutions.map({ value -> Travel? in
                    if let hourDeparture = value as? [String: AnyObject],
                        let hour = hourDeparture["compOrarioPartenza"] as? String,
                        let number = hourDeparture["numeroTreno"] as? Int,
                        let category = hourDeparture["categoria"] as? String,
                        let direction = hourDeparture["destinazione"] as? String,
                        let delay = hourDeparture["compRitardo"] as? [AnyObject],
                        let state = delay[0] as? String {
                        
                        return Travel(number,
                                      category: category,
                                      time: hour,
                                      direction: direction,
                                      state: state)
                    }
                    
                    return nil
                })
            })
    }
    
    /// Perform an Http request to retrieve all the arrivals from the give station id.
    /// Example:
    /// [Url ecample](http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/arrivi/S01700/Mon%20Nov%2020%202017%2008:30:00%20GMT+0100%20)
    /// Mon Nov 20 2017 17:30:00 GMT+0100
    ///
    /// - Parameters:
    ///   - code: the station code. Example S01700
    /// - Returns: a collection of Arrivals
    static func trainArrivals(of code: String) -> Observable<[Travel?]> {
        let urlEncoded =  "\(Address.arrivals.string)\(code)/\(String(describing: createFormattedDate()))"
        
        return URLSession
            .shared
            .rx
            .json(request: URLRequest(url: URL(string: urlEncoded)!))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ result -> [Travel?] in
                guard let solutions = result as? [Any] else { return [] }
                
                return solutions.map({ value -> Travel? in
                    if let dictionary = value as? [String: AnyObject],
                        let number = dictionary["numeroTreno"] as? Int,
                        let category = dictionary["categoria"] as? String,
                        let hour = dictionary["compOrarioArrivo"] as? String,
                        let direction = dictionary["origine"] as? String,
                        let delay = dictionary["compRitardo"] as? [AnyObject],
                        let state = delay[0] as? String {
                        
                        return Travel(number,
                                      category: category,
                                      time: hour,
                                      direction: direction,
                                      state: state)
                    }
                    
                    return nil
                })
            })
    }
    
    /// Perform an Http request to retrieve all the sections from the departure code and train code.
    /// Example:
    /// [Url ecample](http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/tratteCanvas/S06000/666)
    ///
    /// - Parameters:
    ///   - codeDeparture: the station code. Example S06000
    ///   - codeTrain: the station code. Example 6660
    /// - Returns: a collection of TravelDetail
    static func trainSections(of codeDeparture: String, _ codeTrain: String) -> Observable<[Section?]> {
        let urlEncoded = "\(Address.sections.string)\(codeDeparture)/\(codeTrain)"
        
        return URLSession
            .shared
            .rx
            .json(request: URLRequest(url: URL(string: urlEncoded)!))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ result -> [Section?] in
                guard let solutions = result as? [Any] else {
                    return [nil]
                }
                
                return solutions.map({ value -> Section? in
                    if let dictionary = value as? [String: AnyObject],
                        let current = dictionary["stazioneCorrente"] as? Bool,
                        let station = dictionary["stazione"] as? String,
                        let fermata = dictionary["fermata"] as? [String: AnyObject] {
                        
                        let departure = fermata["partenza_teorica"] as? Int ?? 0
                        let arrival = fermata["arrivo_teorico"] as? Int ?? 0

                        let delay = fermata["delay"] as? Int ?? 0
                        
                        return Section(0,
                                            current: current,
                                            departure: departure,
                                            arrival: arrival,
                                            station: station,
                                            delay: delay)
                    }
                    
                    return nil
                })
            })
    }
    
    // MARK: -Privates
    
    /// Create an ecnoded date from now with format EEE MMM dd yyyy HH:mm:ss GMT+0100
    ///
    /// - Returns: a String representing the current date.
    static func createFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd yyyy HH:mm:ss"
        
        return (dateFormatter.string(from: Date()) + " GMT+0100").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
}
