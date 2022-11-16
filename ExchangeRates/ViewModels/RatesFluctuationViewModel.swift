//
//  RatesFluctuationViewModel.swift
//  ExchangeRates
//
//  Created by Robson Moreira on 15/11/22.
//

import Foundation
import SwiftUI
import Combine

extension RatesFluctuationView {
    @MainActor class ViewModel: ObservableObject {
        enum ViewState {
            case start
            case loading
            case success
            case failure
        }
        
        @Published var ratesFluctuation = [RateFluctuationModel]()
        @Published var searchResults = [RateFluctuationModel]()
        @Published var timeRange = TimeRangeEnum.today
        @Published var baseCurrency = "BRL"
        @Published var currencies = [String]()
        @Published var currentState: ViewState = .start
        
        private let dataProvider: RatesFluctuationDataProvider?
        private var cancelables = Set<AnyCancellable>()
        
        init(dataProvider: RatesFluctuationDataProvider = RatesFluctuationDataProvider()) {
            self.dataProvider = dataProvider
        }
        
        func doFetchRatesFluctuation(timeRange: TimeRangeEnum) {
            currentState = .loading
            
            withAnimation {
                self.timeRange = timeRange
            }
            
            let startDate = timeRange.date.toString()
            let endDate = Date().toString()
            dataProvider?.fetchFluctuation(by: baseCurrency, from: currencies, startDate: startDate, endDate: endDate)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.currentState = .success
                    case .failure(_):
                        self.currentState = .failure
                    }
                }, receiveValue: { ratesFluctuation in
                    withAnimation {
                        self.ratesFluctuation = ratesFluctuation.sorted { $0.symbol < $1.symbol }
                        self.searchResults = self.ratesFluctuation
                    }
                }).store(in: &cancelables)
        }
    }
}
