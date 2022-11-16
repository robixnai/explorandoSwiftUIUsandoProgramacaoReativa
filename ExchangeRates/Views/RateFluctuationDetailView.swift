//
//  RateFluctuationDetailView.swift
//  ExchangeRates
//
//  Created by Robson Moreira on 15/11/22.
//

import SwiftUI
import Charts

struct RateFluctuationDetailView: View {
    
    @StateObject var viewModel = ViewModel()
    
    @State var baseCurrency: String
    @State var fromCurrency: String
    @State private var isPresentedBaseCurrencyFilter = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            valuesView
            graphicChartView
            comparationView
        }
        .padding(.leading, 8)
        .padding(.trailing, 8)
        .navigationTitle(viewModel.title)
        .onAppear {
            viewModel.startStateView(baseCurrency: baseCurrency, fromCurrency: fromCurrency, timeRange: .today)
        }
    }
    
    private var valuesView: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(viewModel.endRate.formatter(decimalPlaces: 4))
                .font(.system(size: 22, weight: .bold))
            Text(viewModel.changePct.toPercentage(with: true))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(viewModel.changePct.color)
                .background(viewModel.changePct.color.opacity(0.2))
            Text(viewModel.changeDescription)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(viewModel.change.color)
            Spacer()
        }
        .padding(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
    }
    
    private var graphicChartView: some View {
        VStack {
            periodFilterView
            lineChartView
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
    
    private var periodFilterView: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.doFetchData(from: .today)
            } label: {
                Text("1 dia")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .today ? .blue : .gray)
                    .underline(viewModel.timeRange == .today)
            }
            
            Button {
                viewModel.doFetchData(from: .thisWeek)
            } label: {
                Text("7 dias")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisWeek ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisWeek)
            }
            
            Button {
                viewModel.doFetchData(from: .thisMonth)
            } label: {
                Text("1 mês")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisMonth ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisMonth)
            }
            
            Button {
                viewModel.doFetchData(from: .thisSemester)
            } label: {
                Text("6 meses")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisSemester ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisSemester)
            }
            
            Button {
                viewModel.doFetchData(from: .thisYear)
            } label: {
                Text("1 ano")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisYear ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisYear)
            }
        }
    }
    
    private var lineChartView: some View {
        Chart(viewModel.ratesHistorical) { item in
            LineMark(
                x: .value("Period", item.period),
                y: .value("Rates", item.endRate)
            )
            .interpolationMethod(.catmullRom)
            
            if !viewModel.hasRates {
                RuleMark(
                    y: .value("Conversão Zero", 0)
                )
                .annotation(position: .overlay, alignment: .center) {
                    Text("Sem valores nesse período")
                        .font(.footnote)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                }
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned, values: .stride(by: viewModel.xAxisStride, count: viewModel.xAxisStrideCount)) { date in
                AxisGridLine()
                AxisValueLabel(viewModel.xAxisLabelFormatStyle(for: date.as(Date.self) ?? Date()))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { rate in
                AxisGridLine()
                AxisValueLabel(rate.as(Double.self)?.formatter(decimalPlaces: 3) ?? 0.0.formatter(decimalPlaces: 3))
            }
            
        }
        .chartYScale(domain: viewModel.yAxisMin...viewModel.yAxisMax)
        .frame(height: 260)
        .padding(.trailing, 18)
    }
    
    private var comparationView: some View {
        VStack(spacing: 8) {
            comparationButtonView
            comparationScrollView
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
    
    private var comparationButtonView: some View {
        Button {
            isPresentedBaseCurrencyFilter.toggle()
        } label: {
            Image(systemName: "magnifyingglass")
            Text("Comparar com")
                .font(.system(size: 16))
        }
        .fullScreenCover(isPresented: $isPresentedBaseCurrencyFilter, content: {
            BaseCurrencyFilterView(delegate: self)
        })
        .opacity(viewModel.ratesFluctuation.count == 0 ? 0 : 1)
    }
    
    private var comparationScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.flexible())], alignment: .center) {
                ForEach(viewModel.ratesFluctuation) { fluctuation in
                    Button {
                        viewModel.doComparation(with: fluctuation)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(fluctuation.symbol) / \(baseCurrency)")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            Text(fluctuation.endRate.formatter(decimalPlaces: 4))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            HStack(alignment: .bottom, spacing: 60) {
                                Text(fluctuation.symbol)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                Text(fluctuation.changePct.toPercentage())
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(fluctuation.changePct.color)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
}

extension RateFluctuationDetailView: BaseCurrencyFilterViewDelegate {
    
    func didSelected(_ baseCurrency: String) {
        viewModel.doFilter(by: baseCurrency)
    }
}

struct RateFluctuationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RateFluctuationDetailView(baseCurrency: "BRL", fromCurrency: "USD")
    }
}
