import UIKit
import SnapKit
import Charts

protocol TBWeightChartTableViewCellDelegate: AnyObject {
    func resetAll(sender: UIButton)
}

final class TBWeightChartTableViewCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Weight Gain Chart".attributedText(.mulishTitle4)
        return label
    }()
    private let yAxisLabel = UILabel()
    private let xAxisLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Weeks".attributedText(.mulishBody4Italic)
        return label
    }()
    private let lineChartView: LineChartView = LineChartView()
    private let resetAllLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Delete All Weight Tracker Data".attributedText(.mulishLink3,
                                                                               additionalAttrsArray: [("Delete All Weight Tracker Data", [.underlineStyle: NSUnderlineStyle.single.rawValue])])
        return label
    }()
    private let resetImageView = UIImageView(image: TBIconList.trash.image(sizeOption: .small))
    weak var delegate: TBWeightChartTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        [titleLabel, lineChartView, yAxisLabel, xAxisLabel, resetAllLabel, resetImageView].forEach(contentView.addSubview)
        let resetLayoutGuide = UILayoutGuide()
        addLayoutGuide(resetLayoutGuide)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(26)
        }
        lineChartView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(319)
            $0.top.equalTo(yAxisLabel.snp.bottom).offset(4)
        }
        yAxisLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(18)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
        }
        xAxisLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(31)
            $0.size.equalTo(CGSize(width: 40, height: 18))
            $0.top.equalTo(lineChartView.snp.bottom).offset(4)
        }
        resetLayoutGuide.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }
        resetAllLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.leading.equalTo(resetLayoutGuide)
            $0.top.equalTo(xAxisLabel.snp.bottom).offset(24)
            $0.bottom.equalToSuperview().inset(24)
        }
        resetImageView.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.centerY.equalTo(resetAllLabel)
            $0.leading.equalTo(resetAllLabel.snp.trailing).offset(4)
            $0.trailing.equalTo(resetLayoutGuide)
        }
        let resetControl = UIControl()
        contentView.addSubview(resetControl)
        resetControl.addTarget(self, action: #selector(resetAllAction(sender:)), for: .touchUpInside)
        resetControl.snp.makeConstraints {
            $0.leading.equalTo(resetAllLabel)
            $0.trailing.equalTo(resetImageView)
            $0.height.equalTo(24)
            $0.centerY.equalTo(resetAllLabel)
        }
        lineChartView.legend.enabled = false
        lineChartView.dragEnabled = false
        lineChartView.autoScaleMinMaxEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.setScaleEnabled(false)
        let xAxis = lineChartView.xAxis
        xAxis.labelFont = TBFontType.mulishBody4.font
        xAxis.labelPosition = .bottom
        xAxis.axisLineWidth = 1
        xAxis.axisLineColor = .Navy
        xAxis.axisMaximum = 42.0
        xAxis.axisMinimum = 0.0
        xAxis.labelCount = 10
        xAxis.gridLineDashLengths = [2, 2]
        xAxis.valueFormatter = XAxisValueFormatter()

        let leftAxis = lineChartView.leftAxis
        leftAxis.labelFont = TBFontType.mulishBody4.font
        leftAxis.axisLineWidth = 1
        leftAxis.axisLineColor = .Navy
        leftAxis.setLabelCount(6, force: true)
        leftAxis.gridLineDashLengths = [2, 2]
        leftAxis.drawGridLinesEnabled = true
        leftAxis.valueFormatter = LeftAxisValueFormatter()

        lineChartView.rightAxis.enabled = false
    }

    func setup(models: [TBWeightTrackerModel]) {
        let models = models.filter({ $0.week >= 0 })

        updateChartLeftAxisUnit(models)
        updateChartLeftAxisValues(models)

        let array = models.map { (model) -> ChartDataEntry in
            return ChartDataEntry(x: model.week, y: model.weight)
        }

        let dataSet = LineChartDataSet(entries: array, label: "")
        dataSet.axisDependency = .left
        dataSet.setColor(.fuchsia500)
        dataSet.setCircleColor(.fuchsia500)
        dataSet.lineWidth = 1
        dataSet.drawCirclesEnabled = false
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.setDrawHighlightIndicators(false)

        var chartData: LineChartData = [dataSet]
        if let firstValue = array.last {
            let point = LineChartDataSet(entries: [firstValue], label: "")
            point.axisDependency = .left
            point.setColor(.fuchsia500)
            point.setCircleColor(.fuchsia500)
            point.lineWidth = 1
            point.circleRadius = 1.5
            point.drawCircleHoleEnabled = false
            point.drawValuesEnabled = false
            chartData.append(point)
        }
        if let lastValue = array.first {
            let point = LineChartDataSet(entries: [lastValue], label: "")
            point.axisDependency = .left
            point.setColor(.fuchsia500)
            point.setCircleColor(.fuchsia500)
            point.lineWidth = 1
            point.circleRadius = 4
            point.circleHoleRadius = 2
            point.circleHoleColor = .fuchsia200
            point.drawCircleHoleEnabled = true
            point.drawValuesEnabled = false
            point.valueFormatter = TBPointValueFormatter()
            point.setDrawHighlightIndicators(false)
            chartData.append(point)
        }
        lineChartView.isUserInteractionEnabled = false
        lineChartView.data = chartData

        setupWeightTrackerMarker()
    }

    private func updateChartLeftAxisUnit(_ models: [TBWeightTrackerModel]) {
        guard let model = models.last else { return }
        yAxisLabel.attributedText = model.unitType.capitalized.attributedText(.mulishBody4Italic)
    }

    private func updateChartLeftAxisValues(_ models: [TBWeightTrackerModel]) {

        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 1

        var axisMinimum: Double = 0
        var axisMaximum: Double = 0
        if let model = models.last,
           let displayString = numberFormatter.string(from: model.weight as NSNumber),
           let value = displayString.components(separatedBy: ".").first,
           let weightValueWithoutDecimal = Double(value) {

            lineChartView.leftAxis.resetCustomAxisMax()
            lineChartView.leftAxis.resetCustomAxisMin()

            axisMinimum = weightValueWithoutDecimal - 5 - (weightValueWithoutDecimal - 5).truncatingRemainder(dividingBy: 5.0)
            axisMaximum = axisMinimum + 25.0
            lineChartView.leftAxis.axisMinimum = axisMinimum
            lineChartView.leftAxis.axisMaximum = axisMaximum
        }

        var maxWeight: Double = models.compactMap { model -> Double in
            guard let displayString = numberFormatter.string(from: model.weight as NSNumber),
                  let value = displayString.components(separatedBy: ".").first,
                  let weightValue = Double(value) else { return 0 }
            return weightValue
        }.max() ?? 0
        if maxWeight > axisMaximum {
            let tempMaxWeight = maxWeight + 5
            let remainWeight = tempMaxWeight.truncatingRemainder(dividingBy: 5.0)
            maxWeight = remainWeight == 0 ? tempMaxWeight : tempMaxWeight + 5 - remainWeight
            let labelCount = Int(maxWeight - axisMinimum)/5 + 1
            lineChartView.leftAxis.setLabelCount(labelCount, force: true)
            lineChartView.leftAxis.axisMaximum = maxWeight
        } else {
            lineChartView.leftAxis.setLabelCount(6, force: true)
            lineChartView.leftAxis.axisMaximum = axisMaximum
        }
    }

    private func setupWeightTrackerMarker() {
        let marker = TBCurrentWeightTrackerMarker(color: .OffWhite,
                                                  font: TBFontType.mulishBody4.font,
                                                  textColor: .fuchsia500,
                                                  insets: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
        marker.chartView = lineChartView
        marker.minimumSize = CGSize(width: 32, height: 24)
        lineChartView.marker = marker
        let highlight = lineChartView.getHighlightByTouchPoint(CGPoint(x: UIDevice.width, y: 0))
        lineChartView.highlightValue(highlight, callDelegate: true)
    }

    @objc private func resetAllAction(sender: UIButton) {
        delegate?.resetAll(sender: sender)
    }
}

extension TBWeightChartTableViewCell {
    final class XAxisValueFormatter: AxisValueFormatter {
        func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String {
            let value = Int(value)
            guard value != 0 else { return "" }
            if value % 4 == 0 {
                return "\(value)"
            } else {
                return ""
            }
        }
    }

    final class LeftAxisValueFormatter: AxisValueFormatter {
        func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String {
            let value = Int(value)
            guard value != 0 else { return "" }
            if value % 5 == 0 {
                return "\(value)"
            } else {
                return ""
            }
        }
    }

    final class TBPointValueFormatter: ValueFormatter {
        func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            guard let valueString = numberFormatter.string(from: value as NSNumber) else {
                return value.keepFractionDigits(digit: 1) + (UserDefaults.standard.isMetricUnit ? " kg." : " lbs.")
            }
            return valueString + (UserDefaults.standard.isMetricUnit ? " kg." : " lbs.")
        }
    }
}
