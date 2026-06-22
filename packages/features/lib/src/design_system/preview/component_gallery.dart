// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/spacing_tokens.dart';

/// One named visual state of a component — the analog of a Swift `#Preview`.
///
/// The [build] callback receives **display data only** (the component is fed a
/// fixture view model by the caller); the gallery and specimens reference no
/// engine/date/persistence/`quran` type and draw no muṣḥaf glyph.
class ComponentSpecimen {
  /// Creates a specimen labeled [name], built by [build].
  const ComponentSpecimen({required this.name, required this.build});

  /// A stable, file-safe state name (`enabled`, `weak`, `dueToday`, …) — used as
  /// the golden filename stem and a developer caption, never user-facing copy.
  final String name;

  /// Builds the component in this state from display data only.
  final WidgetBuilder build;
}

/// An ordered, named set of a single component's states — its full `#Preview`
/// set, the analog of a Swift `#Preview` group.
class ComponentStateMatrix {
  /// Groups [specimens] under [component] (the golden subfolder name).
  const ComponentStateMatrix({
    required this.component,
    required this.specimens,
  });

  /// A stable, file-safe component name (`page_card`, `grade_band`, …) — the
  /// golden subfolder.
  final String component;

  /// The component's states in display order.
  final List<ComponentSpecimen> specimens;
}

/// A dumb, host-less viewer that renders a [ComponentStateMatrix] as a labeled
/// vertical list — each specimen in a captioned cell — inside the ambient
/// `ThemeData` and `Directionality`.
///
/// No `go_router` route, no Riverpod store, no engine/date/persistence/`quran`
/// import: a developer (and the golden scaffold) renders any component's full
/// state set in isolation, with no host screen. The caption is the specimen's
/// developer [ComponentSpecimen.name], never user-facing claim copy.
class ComponentGallery extends StatelessWidget {
  /// Creates a gallery for [matrix].
  const ComponentGallery({required this.matrix, super.key});

  /// The state matrix to render.
  final ComponentStateMatrix matrix;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    // A `Material` (not a bare `ColoredBox`) so specimens that expect the
    // ancestor a real host supplies — `ListTile`/`SwitchListTile` and the M3 ink
    // surfaces — render host-less without a "No Material widget found" error.
    return Material(
      color: scheme.surface,
      child: ListView(
        padding: EdgeInsetsDirectional.all(space.space4),
        children: [
          for (final specimen in matrix.specimens) ...[
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: space.space2),
              child: Text(
                specimen.name,
                style:
                    text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Builder(builder: specimen.build),
            ),
            SizedBox(height: space.space6),
          ],
        ],
      ),
    );
  }
}
