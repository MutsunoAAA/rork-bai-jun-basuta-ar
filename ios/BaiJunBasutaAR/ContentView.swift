import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var viewModel: ToothBrushingARViewModel = ToothBrushingARViewModel()

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            switch viewModel.currentScreen {
            case .start:
                StartScreenView(
                    isFaceTrackingSupported: viewModel.isFaceTrackingSupported,
                    startAction: viewModel.startSession
                )
            case .experience:
                ARExperienceScreenView(
                    viewModel: viewModel,
                    completeAction: viewModel.completeSession,
                    backAction: viewModel.returnToStart
                )
            case .sparkle:
                SparkleScreenView(
                    onDone: { viewModel.currentScreen = .completion },
                    onRestart: viewModel.restartSession
                )
            case .completion:
                CompletionScreenView(
                    defeatedGermCount: viewModel.defeatedGermCount,
                    surpriseCharacterCount: viewModel.surpriseCharacterCount,
                    playAgainAction: viewModel.restartSession,
                    closeAction: viewModel.returnToStart
                )
            }
        }
        .tint(.blue)
        .animation(.spring(response: 0.42, dampingFraction: 0.9), value: viewModel.currentScreen)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
