// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// Deterministic, offline test doubles for the `composition` boundaries.
///
/// A non-`dev` library so widget/integration tests in other packages can install
/// [FakeNotificationScheduler] via `overrideWith` and assert the reminder
/// persist-then-schedule and reschedule-convergence contracts (E18) without a
/// device — it records calls and imports no plugin or networking package.
library;

export 'src/testing/fake_notification_scheduler.dart'
    show FakeNotificationScheduler, ScheduledReminder;
