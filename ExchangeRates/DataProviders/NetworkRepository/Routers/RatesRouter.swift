//
//  RatesRouter.swift
//  ExchangeRates
//
//  Created by Robson Moreira on 15/11/22.
//

import Foundation

enum RatesRouter {
    
    case fluctuation(base: String, symbols: [String], startDate: String, endDate: String)
    case timeseries(base: String, symbol: String, startDate: String, endDate: String)
    
    var path: String {
        switch self {
        case .fluctuation: return RatesApi.fluctuation
        case .timeseries: return RatesApi.timeseries
        }
    }
    
    func asUrlRequest() -> URLRequest? {
        guard var url = URL(string: RatesApi.baseUrl) else { return nil }
        
        switch self {
        case .fluctuation(let base, let symbols, let startDate, let endDate):
            url.append(queryItems: [
                URLQueryItem(name: "base", value: base),
                URLQueryItem(name: "symbols", value: symbols.joined(separator: ",")),
                URLQueryItem(name: "start_date", value: startDate),
                URLQueryItem(name: "end_date", value: endDate)
            ])
        case .timeseries(let base, let symbol, let startDate, let endDate):
            url.append(queryItems: [
                URLQueryItem(name: "base", value: base),
                URLQueryItem(name: "symbols", value: symbol),
                URLQueryItem(name: "start_date", value: startDate),
                URLQueryItem(name: "end_date", value: endDate)
            ])
        }
        
        var request = URLRequest(url: url.appendingPathComponent(path), timeoutInterval: Double.infinity)
        request.httpMethod = HttpMethod.get.rawValue
        request.addValue(RatesApi.apiKey, forHTTPHeaderField: "apikey")
        return request
    }
    
}
