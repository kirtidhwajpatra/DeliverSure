# DeliverSure - Offline-First Delivery System

DeliverSure is a production-grade iOS prototype demonstrating a **Reliable, Offline-First** architecture for delivery applications. It features a deterministic "Brain" (Sync Engine) that guarantees data integrity and exactly-once processing even in the face of network failures and app crashes.

## 🧠 The DeliverSure Brain
At the heart of the app is the **Sync Engine**, designed strictly for engineering reliability:
- **Durable Action Queue**: All intentions (Capture, Seal) are written to a file-backed append-only log (`action_queue.json`) before any network attempt.
- **Offline-First**: The UI never talks to the network. It only queues actions. The Brain synchronizes them when connectivity allows.
- **Crash Recovery**: If the app is force-killed while "Saving...", the Brain resumes from the persistent queue upon relaunch.
- **Idempotency**: Every action has a unique ID, ensuring safely retryable requests.

## 🏗 Architecture
The app follows a strict **Unidirectional Data Flow**:
1.  **UI**: Visualizes local state (e.g., `QUEUED`) immediately.
2.  **AppStore**: The central source of truth for UI data.
3.  **SyncEngine**: The orchestrator managing background threads and network I/O.
4.  **ActionQueue**: The persistence layer.

### State Machine
The backend follows a strict lifecycle:
`CREATED` → `PROOF_COLLECTED` → `SEALED` → `QUEUED` → `UPLOADING` → `COMMITTED`

## 🚀 Getting Started
1.  Open `DeliverSure.xcodeproj` in Xcode 14+.
2.  Run on iPhone Simulator.
3.  **Try Offline Mode**:
    - Toggle the "Connectivity" switch to Offline.
    - Complete a delivery.
    - Kill the app.
    - Relaunch and go Online to watch it sync.

## 📂 Key Files
- `SyncEngine.swift`: The event-driven orchestrator.
- `ActionQueue.swift`: The file-system persistence layer.
- `NetworkService.swift`: Simulates real-world latency and idempotency.

---
*Designed for reliability in low-connectivity environments.*
