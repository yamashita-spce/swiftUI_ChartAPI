//
//  Home.swift
//  ChartsAPI_animation
//
//  Created by yk on 2023/03/16.
//

import SwiftUI
import Charts

struct Home: View {
    //MARK: State Chart Data for Animated Change
    @State var sampleAnalytics: [SiteView] = sample_analytics
    //MARK: View Properties
    @State var currentTab: String = "7days" //__init__
    //MARK: Current Active properties
    @State var currentActiveItem: SiteView? = nil
    @State var plotWidth: CGFloat = 0 //RuleMarKBerが棒グラフの中心に位置調整するためのもの
    
    @State var isLineGraph: Bool = false //グラフのデザインを変更
    
    var body: some View {
        
        NavigationStack{
            VStack{
                //New Charts API
                VStack(alignment: .leading, spacing: 12){
                    HStack{
                        Text("View")
                            .fontWeight(.semibold)
                        
                        Picker("", selection: $currentTab){
                            Text("7 days")
                                .tag("7 days")
                            Text("Week")
                                .tag("Week")
                            Text("Month")
                                .tag("Month")
                        }
                        //MARK: changing Picker style
                        .pickerStyle(.segmented)
                        .padding(.leading, 80)
                    }
                    
                    //reduceの解説 -> https://www.sejuku.net/blog/35561
                    let totalValue = sampleAnalytics.reduce(0.0){particalResult, item in
                        item.views + particalResult
                    }
                    //トータルデータ数の表示
                    Text(totalValue.stringFormat)
                        .font(.largeTitle.bold())
                    
                    AnimatedChart()
                }
                //                .border(Color.red)
                .padding()
                //影を作る
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white.shadow(.drop(radius: 2)))
                }
                
                Toggle("Line Graph", isOn: $isLineGraph)
                    .padding(.top)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationTitle("Swift Chart")
            
            //MARK: Simply updating value for segmented Tab：タブの変更を監視し, 表示するデータの変更し再描画
            .onChange(of: currentTab) { newValue in
                
                sampleAnalytics = sample_analytics
                
                if newValue != "7 days" {
                    for (index, _) in sampleAnalytics.enumerated() {
                        //ここではランダムでデータを生成
                        sampleAnalytics[index].views = .random(in: 1500...10000)
                    }
                }
                //MARK: 再描写
                animationGraph(fromChange: true)
                
            }
            
            //            Spacer()
        }
        .border(Color.blue)
        
        
    }
    
    //@ViewBuilderは一括で一つのViewとして返してくれる便利なプロパティ
    @ViewBuilder func AnimatedChart() -> some View{
        let max = sampleAnalytics.max{ item1, item2 in
            return item2.views > item1.views
        }?.views ?? 0
        
        Chart{
            ForEach(sampleAnalytics){item in
                
                if isLineGraph{
                    //MARK: Line MARK Charts
                    LineMark(
                        x: .value("Hour", item.hour, unit: .hour),
                        y: .value("View", item.animate ? item.views : 0)
                    )
                    //MARK: Gradient Style
                    .foregroundStyle(Color("Blue").gradient)
                    //丸みをつける
                    .interpolationMethod(.catmullRom)
                   
                } else {
                    //MARK: Ber Charts
                    BarMark(
                        x: .value("Hour", item.hour, unit: .hour),
                        y: .value("View", item.animate ? item.views : 0)
                    )
                    //MARK: Gradient Style
                    .foregroundStyle(Color("Blue").gradient)
              
                }
                
                //エリアの色ずけ
                if isLineGraph {
                    AreaMark(
                        x: .value("Hour", item.hour, unit: .hour),
                        y: .value("View", item.animate ? item.views : 0)
                    )
                    //MARK: Gradient Style
                    //opacityで色のぼかしを調整
                    .foregroundStyle(Color("Blue").opacity(0.1).gradient)
                    //丸みをつける
                    .interpolationMethod(.catmullRom)

                }
                
                
                //MARK: ドラックの現在場所から取得したオブジェクト情報をRule Markで表示
                if let currentActiveItem, currentActiveItem.id == item.id{
                    RuleMark(x: .value("Hour", currentActiveItem.hour))
                    //スタイルの編集 dot Style
                        .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [2], dashPhase: 5))
                    //MARK: RuleMarkをBerの中心にセット
                        .offset(x: (self.plotWidth / CGFloat(sampleAnalytics.count)) / 2)
                    
                    //MARK: topに情報を表示
                        .annotation(position: .top ,alignment: .leading,  spacing: 10){
                            VStack(alignment: .leading, spacing: 6){
                                Text("View")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                Text(currentActiveItem.views.stringFormat)
                                    .font(.title3.bold())
                            }
                            
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background{
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(.white.shadow(.drop(radius: 2)))
                            }

                        }
                       
                }
            }
        }
//        .chartXAxis(.hidden)
        //MARK: customizing y-Axis Lenth
        .chartYScale(domain: 0...(max + 3000))
        //MARK: Gesture to highlight current Bar
        //chartOverlayはChartViewの真上にさらにViewを書き込めるViewオブジェクト
        .chartOverlay(content: { proxy in
            //MARK: GeometryReader: https://yosshiblog.jp/swiftui_geometry/ -> Viewそのものの大きさや座標系を取得できる特殊なView, Viewではあるが何か表示されるわけではない
            GeometryReader(content: { innerProxy in
                Rectangle()
                //                    .border(.red)
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                        //MARK: ドラック場所が変化するたびに更新される
                            .onChanged{value in
                                //get current location
                                let location = value.location
                                
                                //Don't forget to include perefect Data Type
                                // axis-x を基準にしてそのDate情報を得る
                                if let date: Date = proxy.value(atX: location.x){
                                    let calender = Calendar.current
                                    let hour = calender.component(.hour, from: date)
                                    
                                    //取得したx軸のデータと一致するオブジェクトを取得
                                    if let currentItem = sampleAnalytics.first(where: {item in
                                        calender.component(.hour, from: item.hour) == hour
                                    }){
                                        //                                        print(currentItem.views)
                                        self.currentActiveItem = currentItem
                                        //chatOverlayのView範囲（基本的に固定値)
                                        self.plotWidth = proxy.plotAreaSize.width
                                        //                                        print(self.plotWidth)
                                    }
                                    
                                    
                                }
                                
                                
                                
                            }.onEnded{value in
                                self.currentActiveItem = nil
                            }
                        
                    )
                
            })
            
            
        })
        .frame(height: 250)
        .onAppear{
            animationGraph()
        }
    }
    
    //MARK: animationグラフ
    func animationGraph(fromChange: Bool = false){
        for (index, _) in sampleAnalytics.enumerated() {
            // for some reason delay is not working
            // useing Dispatch Queue delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)){
                withAnimation(fromChange ? .easeInOut(duration: 0.8) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)){
                    sampleAnalytics[index].animate = true
                }
            }
        }
    }
}


//MARK: extension To Convert Double To String with K,M Nunber Value
extension Double {
    var stringFormat: String {
        if self >= 10000 && self < 999999{
            return String(format: "%.1fK", self / 10000).replacingOccurrences(of: ".0", with: "")
        }
        else if self > 999999{
            return String(format: "%.1fM", self / 10000000).replacingOccurrences(of: ".0", with: "")
        }
        else {
            return String(format: "%.0f", self)
        }
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
