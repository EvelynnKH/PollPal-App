//
//  RadioButton.swift
//  PollPal
//
//  Created by student on 27/11/25.
//

import Foundation
import SwiftUI

struct RadioButton: View {
    @Binding var selected: String?
    var value: String

    var body: some View {
        Button(action: { selected = value }) {
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 20, height: 20)
                if selected == value {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
