//
//  ResponseRendered.swift
//  PollPal
//
//  Created by student on 09/12/25.
//

import Charts
import SwiftUI

struct ResponseRendered: View {
    var question: Question
    var responses: [DResponse]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(question.question_text ?? "Untitled Question")
                .font(.headline)
                .foregroundColor(Color(hex: "1F3A45"))

            Divider()

            // DEBUG: tampilkan semua DResponse untuk question ini
            VStack(alignment: .leading, spacing: 4) {
                Text("DEBUG — Jawaban tersimpan:")
                    .font(.caption).foregroundColor(.red)

                ForEach(responses, id: \.dresponse_id) { r in
                    Text("• \(r.dresponse_answer_text ?? "<empty>")")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.bottom, 8)

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
                    Text(
                        "Unsupported Question Type: \(question.question_type ?? "")"
                    )
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
        let data = counts
        let total = responses.count

        VStack {
            if data.isEmpty {
                Text("No responses yet").foregroundColor(.secondary)
            } else {
                Chart(data, id: \.key) { item in
                    SectorMark(
                        angle: .value("Count", item.value),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Option", item.key))
                    .annotation(position: .overlay) {
                        Text("\(item.value)")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                }
                .chartLegend(position: .bottom, spacing: 20)
                
                // Summary Text
                Text("Total: \(total) Responses")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical)
    }

    // Helper: Count occurrences of each option string
    private var counts: [(key: String, value: Int)] {
        var dict: [String: Int] = [:]
        for r in responses {
            let txt = (r.dresponse_answer_text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !txt.isEmpty {
                dict[txt, default: 0] += 1
            }
        }
        return dict.sorted { $0.value > $1.value }
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
                Chart(data, id: \.label) { item in
                    BarMark(
                        x: .value("Count", item.value),
                        y: .value("Option", item.label) // Label on Y axis for horizontal
                    )
                    .foregroundStyle(Color.orange) // Brand color
                    .annotation(position: .trailing) {
                        Text("\(item.value)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                // IMPORTANT: Make sure axes are visible
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel() // Ensure labels like "Option 1" are shown
                    }
                }
            }
        }
        .padding()
    }

    private var countsSorted: [(label: String, value: Int)] {
        var dict: [String: Int] = [:]
        for r in responses {
            let txt = (r.dresponse_answer_text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !txt.isEmpty {
                dict[txt, default: 0] += 1
            }
        }
        // Sort by highest count first
        return dict.map { (label: $0.key, value: $0.value) }
                   .sorted { $0.value > $1.value }
    }
}

// MARK: - LINEAR SCALE (Vertical Bar Chart)
private struct LinearScaleChart: View {
    let responses: [DResponse]

    var body: some View {
        let data = countsSorted

        VStack {
            if data.isEmpty {
                Text("No responses yet").foregroundColor(.secondary)
            } else {
                Chart(data, id: \.label) { item in
                    BarMark(
                        x: .value("Scale", item.label), // "1", "2", "3"...
                        y: .value("Count", item.value)
                    )
                    .foregroundStyle(Color(hex: "0C4254")) // Brand Dark Teal
                    .annotation(position: .top) {
                        Text("\(item.value)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
    }

    private var countsSorted: [(label: String, value: Int)] {
        var dict: [Int: Int] = [:]
        
        // Initialize 1-5 with 0 to show empty bars too (Optional, makes chart look better)
        for i in 1...5 { dict[i] = 0 }

        for r in responses {
            if let v = Int(r.dresponse_answer_text ?? "") {
                dict[v, default: 0] += 1
            }
        }
        
        // Sort by Scale Number (1 -> 5)
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
