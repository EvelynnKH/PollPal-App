//
//  ResponseRendered.swift
//  PollPal
//
//  Created by student on 09/12/25.
//

import SwiftUI
import Charts

struct ResponseRenderer: View {
    @ObservedObject var question: Question
    let responses: [DResponse]   // data jawaban untuk pertanyaan ini
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // --- JUDUL PERTANYAAN ---
            Text(question.question_text ?? "Untitled Question")
                .font(.headline)
                .foregroundColor(Color(hex: "1F3A45"))

            // --- RENDER BERDASAR TIPE ---
            switch question.safeType {

            case .shortAnswer:
                shortTextList

            case .paragraph:
                paragraphList

            case .multipleChoice, .checkboxes, .dropdown:
                barChartView

            case .linearscale:
                horizontalBarChart

            default:
                Text("Unsupported question type.")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
        .padding(.horizontal)
    }


    // =========================
    // MARK: SHORT TEXT LIST
    // =========================
    private var shortTextList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(responses, id: \.self) { r in
                HStack {
                    Text(r.dresponse_answer_text ?? "-")
                        .foregroundColor(Color(hex: "1F3A45"))
                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.4))
                .cornerRadius(12)
            }
        }
    }

    // =========================
    // MARK: PARAGRAPH LIST
    // =========================
    private var paragraphList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(responses, id: \.self) { r in
                Text(r.dresponse_answer_text ?? "-")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.35))
                    .cornerRadius(12)
            }
        }
    }

    // =========================
    // MARK: BAR CHART (MC, CHECKBOX, DROPDOWN)
    // =========================
    private var barChartView: some View {
        
        let aggregated = aggregateCounts()

        return VStack(alignment: .leading) {
            Text("Hasil Jawaban")
                .font(.headline)

            Chart {
                ForEach(aggregated, id: \.label) { item in
                    BarMark(
                        x: .value("Count", item.value),
                        y: .value("Option", item.label)
                    )
                    .foregroundStyle(Color(hex: "1F3A45"))
                }
            }
            .frame(height: 250)
        }
    }

    // =========================
    // MARK: LINEAR SCALE
    // =========================
    private var horizontalBarChart: some View {
        
        let aggregated = aggregateCounts()

        return VStack(alignment: .leading) {
            Text("Scale Results")
                .font(.headline)

            Chart {
                ForEach(aggregated, id: \.label) { item in
                    BarMark(
                        x: .value("Value", item.value),
                        y: .value("Scale", item.label)
                    )
                }
            }
            .frame(height: 250)
        }
    }


    // ==================================================================
    // MARK: Helper – Count frequency dari semua responses
    // ==================================================================
    private func aggregateCounts() -> [(label: String, value: Int)] {
        var dict: [String: Int] = [:]

        for r in responses {
            let text = r.dresponse_answer_text ?? ""

            // Checkbox → split by comma
            let items = text.contains(",") ? text.components(separatedBy: ",") : [text]

            for item in items {
                let trimmed = item.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty { continue }
                dict[trimmed, default: 0] += 1
            }
        }

        return dict.map { (label: $0.key, value: $0.value) }
    }
}

