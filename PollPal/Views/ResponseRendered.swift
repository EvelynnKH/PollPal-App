
//
//  ResponseRendered.swift
//  PollPal
//
//  Created by student on 09/12/25.
//

import SwiftUI
import Charts

struct ResponseRendered: View {
    var question: Question
    var responses: [DResponse]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(question.question_text ?? "Untitled Question")
                .font(.headline)
                .foregroundColor(Color(hex: "1F3A45"))

            Divider()

            // Card body: beri max height agar tiap soal punya scroll sendiri
            Group {
                switch question.question_type {

                case "Multiple Choice", "Drop Down":
                    PieChartForOptions(responses: responses)
                        .frame(height: 260)

                case "Check Box":
                    CheckboxHorizontalBarChart(responses: responses)
                        .frame(height: 260)

                case "Linear Scale":
                    LinearScaleChart(responses: responses)
                        .frame(height: 260)

                case "Short Answer", "Long Answer", "Paragraph":
                    TextResponsesList(responses: responses)

                default:
                    Text("Unsupported Question Type: \(question.question_type ?? "")")
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
        .padding(.horizontal)
    }
}


// MARK: - PIE CHART (Multiple Choice / Drop Down)
private struct PieChartForOptions: View {
    let responses: [DResponse]

    var body: some View {
        let items = counts.sorted { $0.value > $1.value }

        VStack(alignment: .leading) {
            if items.isEmpty {
                Text("No responses yet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart {
                    ForEach(items, id: \.key) { (label, value) in
                        SectorMark(
                            angle: .value("Count", value),
                            innerRadius: .ratio(0.5),
                            angularInset: 1
                        )
                        .foregroundStyle(by: .value("Option", label))
                        .annotation(position: .overlay, alignment: .center) {
                            // no overlay labels here — keep chart clean
                            EmptyView()
                        }
                    }
                }
                .chartLegend(.visible)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.vertical, 6)
    }

    private var counts: [String: Int] {
        var dict: [String: Int] = [:]
        for r in responses {
            let txt = (r.dresponse_answer_text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if txt.isEmpty { continue }
            dict[txt, default: 0] += 1
        }
        return dict
    }
}


// MARK: - CHECKBOX (Horizontal Bar Chart)
private struct CheckboxHorizontalBarChart: View {
    let responses: [DResponse]

    var body: some View {
        let data = countsSorted

        VStack(alignment: .leading, spacing: 8) {
            if data.isEmpty {
                Text("No responses yet").foregroundColor(.secondary)
            } else {
                ScrollView { // allow internal vertical scroll if too many options
                    Chart {
                        ForEach(data, id: \.label) { item in
                            BarMark(
                                x: .value("Count", item.value),
                                y: .value("Option", item.label)
                            )
                        }
                    }
                    .chartXAxis(.visible)
                    .chartYAxis(.hidden)
                    .frame(height: CGFloat(min(40 * data.count, 220)))
                }
            }
        }
        .padding(.vertical, 6)
    }

    // returns sorted [(label, value)]
    private var countsSorted: [(label: String, value: Int)] {
        var dict: [String: Int] = [:]
        for r in responses {
            let text = r.dresponse_answer_text ?? ""
            let parts = text
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            for p in parts where !p.isEmpty {
                dict[p, default: 0] += 1
            }
        }
        return dict.map { (label: $0.key, value: $0.value) }
            .sorted { $0.value > $1.value }
    }
}


// MARK: - LINEAR SCALE (Vertical Bar Chart)
private struct LinearScaleChart: View {
    let responses: [DResponse]

    var body: some View {
        let data = countsSorted

        VStack(alignment: .leading, spacing: 8) {
            if data.isEmpty {
                Text("No responses yet").foregroundColor(.secondary)
            } else {
                Chart {
                    ForEach(data, id: \.label) { item in
                        BarMark(
                            x: .value("Scale", item.label),
                            y: .value("Count", item.value)
                        )
                    }
                }
                .chartXAxis {
                    AxisMarks(values: data.map { $0.label }) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .frame(height: 220)
            }
        }
        .padding(.vertical, 6)
    }

    // parse numeric answers -> counts; label as string for x-axis
    private var countsSorted: [(label: String, value: Int)] {
        var dict: [Int: Int] = [:]
        for r in responses {
            if let v = Int(r.dresponse_answer_text ?? "") {
                dict[v, default: 0] += 1
            }
        }
        // ensure keys sorted ascending (1..n) even when some missing
        let keys = dict.keys.sorted()
        return keys.map { (label: "\($0)", value: dict[$0] ?? 0) }
    }
}


// MARK: - TEXT RESPONSES (Short / Paragraph)
private struct TextResponsesList: View {
    let responses: [DResponse]

    var body: some View {
        if responses.isEmpty {
            Text("No responses yet").foregroundColor(.secondary)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(responses, id: \.dresponse_id) { r in
                        Text(r.dresponse_answer_text ?? "")
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(8)
                    }
                }
                .padding(.vertical, 6)
            }
            .frame(maxHeight: 260)
        }
    }
}
