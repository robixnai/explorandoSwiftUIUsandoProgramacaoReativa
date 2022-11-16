//
//  RatesFluctuationView.swift
//  ExchangeRates
//
//  Created by Robson Moreira on 15/11/22.
//

import SwiftUI

struct RatesFluctuationView: View {
    
    @StateObject var viewModel = ViewModel()
    
    @State private var searchText = ""
    @State private var viewDidLoad = true
    @State private var isPresentedBaseCurrencyFilter = false
    @State private var isPresentedMultiCurrencyFilter = false
    
    var body: some View {
        NavigationView {
            VStack {
                if case .loading = viewModel.currentState {
                    ProgressView()
                        .scaleEffect(2.2, anchor: .center)
                } else if case .success = viewModel.currentState {
                    baseCurrencyPeriodFilterView
                    ratesFluctuationListView
                } else if case .failure = viewModel.currentState {
                    erroView
                }
            }
            .searchable(text: $searchText, prompt: "Procurar moeda")
            .onChange(of: searchText) { searchText in
                if searchText.isEmpty {
                    viewModel.searchResults = viewModel.ratesFluctuation
                } else {
                    viewModel.searchResults = viewModel.ratesFluctuation.filter {
                        $0.symbol.contains(searchText.uppercased()) ||
                        $0.change.formatter(decimalPlaces: 6).contains(searchText) ||
                        $0.changePct.formatter(decimalPlaces: 6).contains(searchText) ||
                        $0.endRate.formatter(decimalPlaces: 6).contains(searchText)
                    }
                }
            }
            .navigationTitle("Conversão de Moedas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    isPresentedMultiCurrencyFilter.toggle()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .fullScreenCover(isPresented: $isPresentedMultiCurrencyFilter) {
                    MultiCurrenciesFilterView(delegate: self)
                }
            }
        }
        .onAppear {
            if viewDidLoad {
                viewDidLoad.toggle()
                viewModel.doFetchRatesFluctuation(timeRange: .today)
            }
        }
    }
    
    private var baseCurrencyPeriodFilterView: some View {
        HStack(alignment: .center, spacing: 16) {
            Button {
                isPresentedBaseCurrencyFilter.toggle()
            } label: {
                Text(viewModel.baseCurrency)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white, lineWidth: 1)
                    )
            }
            .fullScreenCover(isPresented: $isPresentedBaseCurrencyFilter, content: {
                BaseCurrencyFilterView(delegate: self)
            })
            .background(Color(UIColor.lightGray))
            .cornerRadius(8)
            
            Button {
                viewModel.doFetchRatesFluctuation(timeRange: .today)
            } label: {
                Text("1 dia")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .today ? .blue : .gray)
                    .underline(viewModel.timeRange == .today)
            }
            
            Button {
                viewModel.doFetchRatesFluctuation(timeRange: .thisWeek)
            } label: {
                Text("7 dias")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisWeek ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisWeek)
            }
            
            Button {
                viewModel.doFetchRatesFluctuation(timeRange: .thisMonth)
            } label: {
                Text("1 mês")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisMonth ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisMonth)
            }
            
            Button {
                viewModel.doFetchRatesFluctuation(timeRange: .thisSemester)
            } label: {
                Text("6 meses")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisSemester ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisSemester)
            }
            
            Button {
                viewModel.doFetchRatesFluctuation(timeRange: .thisYear)
            } label: {
                Text("1 ano")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisYear ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisYear)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    private var ratesFluctuationListView: some View {
        List(viewModel.searchResults) { fluctuation in
            NavigationLink(destination: RateFluctuationDetailView(baseCurrency: viewModel.baseCurrency, fromCurrency: fluctuation.symbol)) {
                VStack {
                    HStack(alignment: .center, spacing: 8) {
                        Text("\(fluctuation.symbol) / \(viewModel.baseCurrency)")
                            .font(.system(size: 14, weight: .medium))
                        Text(fluctuation.endRate.formatter(decimalPlaces: 2))
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Text(fluctuation.change.formatter(decimalPlaces: 4, with: true))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(fluctuation.change.color)
                        Text("(\(fluctuation.changePct.toPercentage()))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(fluctuation.changePct.color)
                    }
                    Divider()
                        .padding(.leading, -20)
                        .padding(.trailing, -40)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.white)
        }
        .listStyle(.plain)
    }
    
    private var erroView: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Image(systemName: "wifi.exclamationmark")
                .resizable()
                .frame(width: 60, height: 44)
                .padding(.bottom, 4)
            
            Text("Ocorreu um erro na busca das flutuações das taxas!")
                .font(.headline.bold())
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.doFetchRatesFluctuation(timeRange: .today)
            } label: {
                Text("Tentar novamente?")
            }
            .padding(.top, 4)
            
            Spacer()
        }
        .padding()
    }
}

extension RatesFluctuationView: BaseCurrencyFilterViewDelegate {
    
    func didSelected(_ baseCurrency: String) {
        viewModel.baseCurrency = baseCurrency
        viewModel.doFetchRatesFluctuation(timeRange: .today)
    }
}

extension RatesFluctuationView: MultiCurrenciesFilterViewDelegate {
    
    func didSelected(_ currencies: [String]) {
        viewModel.currencies = currencies
        viewModel.doFetchRatesFluctuation(timeRange: .today)
    }
}

struct RatesFluctuationView_Previews: PreviewProvider {
    static var previews: some View {
        RatesFluctuationView()
    }
}
