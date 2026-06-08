//
//  PushService.swift
//  PaxCompanion
//
//  APNs subscription manager + Live Activity bridge. The real version would
//  POST the device token to the Pax backend so events from the game tick
//  loop get pushed straight to the right device.
//
//  For the demo, we simulate event arrival by feeding mock events into the
//  same handler the real APNs path would use. This proves the wiring is
//  correct end-to-end (event → ContentState update → Live Activity refresh)
//  without needing actual APNs credentials.
//

import Foundation
import UserNotifications
import ActivityKit

@MainActor
final class PushService: NSObject, ObservableObject {
    static let shared = PushService()

    @Published private(set) var deviceToken: String?
    @Published private(set) var permissionGranted: Bool = false

    private var activeActivity: Activity<GameAttributes>?

    private override init() { super.init() }

    // MARK: - Permissions + token

    func requestPermissionsAndRegister() async {
        let center = UNUserNotificationCenter.current()
        do {
            permissionGranted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            permissionGranted = false
            return
        }
        // The real app would call UIApplication.shared.registerForRemoteNotifications()
        // and hand the resulting Data → hex token to startLiveActivityIfNeeded(). We
        // skip the real APNs round-trip in the demo and use a synthetic token so the
        // UI still has something to show.
        deviceToken = synthesizeMockToken()
    }

    // MARK: - Live Activity lifecycle

    func startLiveActivity(for game: Game, initialEvent: GameEvent) {
        endLiveActivity()
        let attrs = GameAttributes(gameId: game.id, presetTitle: game.presetTitle)
        let state = state(for: game, event: initialEvent)
        do {
            let content = ActivityContent(state: state, staleDate: nil)
            activeActivity = try Activity.request(
                attributes: attrs, content: content, pushType: .token)
        } catch {
            print("[Push] Failed to start activity: \(error)")
        }
    }

    /// Wire the same path the APNs token + content-state push would use:
    /// new event arrives → derive a fresh ContentState → activity.update.
    func ingest(event: GameEvent, for game: Game) async {
        guard let activity = activeActivity else { return }
        let state = state(for: game, event: event)
        await activity.update(ActivityContent(state: state, staleDate: nil))
    }

    func endLiveActivity() {
        guard let activity = activeActivity else { return }
        Task {
            await activity.end(activity.content, dismissalPolicy: .immediate)
        }
        activeActivity = nil
    }

    // MARK: - Internals

    private func state(for game: Game, event: GameEvent) -> GameAttributes.ContentState {
        GameAttributes.ContentState(
            nationEmoji: game.nationEmoji,
            nationName: game.nationName,
            headline: event.kind.headline,
            detail: event.body,
            iconSystemName: event.kind.iconName,
            currentTurn: game.currentTurn,
            totalTurns: game.totalTurns,
            stability: game.stability
        )
    }

    private func synthesizeMockToken() -> String {
        // Same shape as a real APNs token (64 hex chars) so the UI shows
        // something believable in the debug panel without leaking real bytes.
        let bytes = (0..<32).map { _ in UInt8.random(in: 0...255) }
        return bytes.map { String(format: "%02x", $0) }.joined()
    }
}
