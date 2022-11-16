//
//  RatesStore.swift
//  ExchangeRates
//
//  Created by Robson Moreira on 15/11/22.
//

import Foundation

protocol RatesStoreProtocol: GenericStoreProtocol {
    func fetchFluctuation(by base: String, from symbols: [String], startDate: String, endDate: String, completion: @escaping completion<RateObject<RatesFluctuationObject>?>)
    func fetchTimeseries(by base: String, from symbol: String, startDate: String, endDate: String, completion: @escaping completion<RateObject<RatesHistoricalObject>?>)
}

class RatesStore: GenericStoreRequest, RatesStoreProtocol {
    
    func fetchFluctuation(by base: String, from symbols: [String], startDate: String, endDate: String, completion: @escaping completion<RateObject<RatesFluctuationObject>?>) {
        guard let urlRequest = RatesRouter.fluctuation(base: base, symbols: symbols, startDate: startDate, endDate: endDate).asUrlRequest() else {
            return completion(nil, error)
        }
        request(urlRequest: urlRequest, completion: completion)
    }
    
    func fetchTimeseries(by base: String, from symbol: String, startDate: String, endDate: String, completion: @escaping completion<RateObject<RatesHistoricalObject>?>) {
        guard let urlRequest = RatesRouter.timeseries(base: base, symbol: symbol, startDate: startDate, endDate: endDate).asUrlRequest() else {
            return completion(nil, error)
        }
        request(urlRequest: urlRequest, completion: completion)
    }
}
