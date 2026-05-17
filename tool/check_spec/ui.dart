part of '../check_spec.dart';

final hexColor = RegExp(r'^#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
const themeTopLevelKeys = {r'$schema', 'name', 'version', 'defs', 'theme'};
const themePairKeys = {'light', 'dark'};
const uiSchemaId = 'https://houra.dev/schemas/houra-ui-surface.schema.json';
const uiSurfaceTopLevelKeys = {
  r'$schema',
  'name',
  'version',
  'description',
  'implementation_boundary',
  'theme_refs',
  'screens',
  'actions',
  'states',
  'text_keys',
  'acceptance_flows',
  'release_evidence',
  'limitations',
};
const uiBoundaryKeys = {
  'platform_neutral',
  'server_impact',
  'canonical_behavior_source',
  'implementation_notes',
};
const uiScreenKeys = {
  'id',
  'session',
  'purpose',
  'regions',
  'fields',
  'actions',
};
const uiFieldKeys = {'id', 'label_key', 'input', 'required'};
const uiActionKeys = {
  'id',
  'label_key',
  'requires_auth',
  'api_contracts',
  'busy_state',
  'disabled_when',
  'success_expectation',
  'error_expectation',
};
const uiStateKeys = {'id', 'kind', 'description'};
const uiAcceptanceFlowKeys = {'id', 'description', 'steps'};
const uiAcceptanceStepKeys = {'id', 'screen', 'action', 'expectation'};
const uiReleaseEvidenceKeys = {
  'evidence_class',
  'target_release_candidate',
  'consumer_repos',
  'required_checks',
  'redaction_policy',
  'adoption_boundaries',
};

void checkThemes(List<String> failures) {
  final schema = readJsonObject(File('design/theme.schema.json'), failures);
  if (schema == null) {
    return;
  }
  if (schema[r'$id'] != 'https://houra.dev/schemas/houra-theme.schema.json') {
    failures.add('design/theme.schema.json must use the Houra schema id.');
  }
  final required = schema['required'];
  if (required is! List ||
      !{'name', 'version', 'defs', 'theme'}.every(required.contains)) {
    failures.add(
      'design/theme.schema.json must require name/version/defs/theme.',
    );
  }
  if (schema['additionalProperties'] != false) {
    failures.add(
      'design/theme.schema.json must reject additional top-level properties.',
    );
  }

  final root = Directory('design/themes');
  if (!root.existsSync()) {
    failures.add('Missing design/themes directory.');
    return;
  }

  for (final file in filesUnder(root, '.json')) {
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    checkAllowedKeys(file, json, themeTopLevelKeys, 'theme file', failures);

    final defs = json['defs'];
    final theme = json['theme'];
    if (json['name'] is! String || (json['name'] as String).isEmpty) {
      failures.add('${relative(file)} must include a non-empty name.');
    }
    if (json['version'] is! String || (json['version'] as String).isEmpty) {
      failures.add('${relative(file)} must include a non-empty version.');
    }
    if (defs is! Map) {
      failures.add('${relative(file)} defs must be an object.');
      continue;
    }
    if (theme is! Map) {
      failures.add('${relative(file)} theme must be an object.');
      continue;
    }

    final colorDefs = defs.cast<String, Object?>();
    for (final entry in colorDefs.entries) {
      if (entry.value is! String || (entry.value as String).isEmpty) {
        failures.add('${relative(file)} defs.${entry.key} must be a string.');
      }
    }
    for (final entry in theme.cast<String, Object?>().entries) {
      final pair = entry.value;
      if (pair is! Map) {
        failures.add('${relative(file)} theme.${entry.key} must be an object.');
        continue;
      }
      final colors = pair.cast<String, Object?>();
      checkAllowedKeys(
        file,
        colors,
        themePairKeys,
        'theme.${entry.key}',
        failures,
      );
      for (final variant in ['light', 'dark']) {
        final value = colors[variant];
        if (value is! String ||
            value.isEmpty ||
            (!hexColor.hasMatch(value) && !colorDefs.containsKey(value))) {
          failures.add(
            '${relative(file)} theme.${entry.key}.$variant has '
            'unknown color value.',
          );
        }
      }
    }
  }
}

void checkUiSurfaces(Map<String, String> contracts, List<String> failures) {
  final schema = readJsonObject(
    File('design/ui.surface.schema.json'),
    failures,
  );
  if (schema == null) {
    return;
  }
  if (schema[r'$id'] != uiSchemaId) {
    failures.add(
      'design/ui.surface.schema.json must use the Houra UI schema id.',
    );
  }
  final required = schema['required'];
  if (required is! List ||
      !{
        'name',
        'version',
        'implementation_boundary',
        'screens',
        'actions',
        'states',
        'text_keys',
        'acceptance_flows',
        'release_evidence',
      }.every(required.contains)) {
    failures.add(
      'design/ui.surface.schema.json must require the core UI surface fields.',
    );
  }

  final root = Directory('design/ui-surfaces');
  if (!root.existsSync()) {
    failures.add('Missing design/ui-surfaces directory.');
    return;
  }

  final files = filesUnder(root, '.json').toList();
  if (files.isEmpty) {
    failures.add('No UI surface files found.');
    return;
  }

  for (final file in files) {
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    checkAllowedKeys(file, json, uiSurfaceTopLevelKeys, 'UI surface', failures);
    if (json['name'] is! String || (json['name'] as String).isEmpty) {
      failures.add('${relative(file)} must include a non-empty name.');
    }
    if (json['version'] is! String || (json['version'] as String).isEmpty) {
      failures.add('${relative(file)} must include a non-empty version.');
    }
    checkUiBoundary(file, json['implementation_boundary'], failures);

    final textKeys = readTextKeys(file, json['text_keys'], failures);
    final stateIds = readUiStates(file, json['states'], failures);
    final actionIds = readUiActions(
      file,
      json['actions'],
      textKeys,
      stateIds,
      contracts,
      failures,
    );
    final screenIds = readUiScreens(
      file,
      json['screens'],
      textKeys,
      actionIds,
      failures,
    );
    checkUiAcceptanceFlows(
      file,
      json['acceptance_flows'],
      screenIds,
      actionIds,
      failures,
    );
    checkUiReleaseEvidence(file, json['release_evidence'], failures);
    checkUiThemeRefs(file, json['theme_refs'], failures);
    checkUiLimitations(file, json['limitations'], failures);
  }
}

void checkUiBoundary(File file, Object? value, List<String> failures) {
  if (value is! Map) {
    failures.add(
      '${relative(file)} implementation_boundary must be an object.',
    );
    return;
  }
  final boundary = value.cast<String, Object?>();
  checkAllowedKeys(
    file,
    boundary,
    uiBoundaryKeys,
    'implementation_boundary',
    failures,
  );
  if (boundary['platform_neutral'] != true) {
    failures.add(
      '${relative(file)} implementation_boundary.platform_neutral must be true.',
    );
  }
  if (boundary['server_impact'] != 'none') {
    failures.add(
      '${relative(file)} implementation_boundary.server_impact must be none.',
    );
  }
  if (boundary['canonical_behavior_source'] is! String ||
      (boundary['canonical_behavior_source'] as String).isEmpty) {
    failures.add(
      '${relative(file)} implementation_boundary.canonical_behavior_source must be non-empty.',
    );
  }
  final notes = boundary['implementation_notes'];
  if (notes is! List ||
      notes.isEmpty ||
      notes.any((note) => note is! String || note.isEmpty)) {
    failures.add(
      '${relative(file)} implementation_boundary.implementation_notes must be non-empty strings.',
    );
  }
}

Set<String> readTextKeys(File file, Object? value, List<String> failures) {
  if (value is! Map) {
    failures.add('${relative(file)} text_keys must be an object.');
    return const {};
  }
  final textKeys = value.cast<String, Object?>();
  for (final entry in textKeys.entries) {
    if (entry.value is! String || (entry.value as String).isEmpty) {
      failures.add(
        '${relative(file)} text_keys.${entry.key} must be a non-empty string.',
      );
    }
  }
  return textKeys.keys.toSet();
}

Set<String> readUiStates(File file, Object? value, List<String> failures) {
  if (value is! List || value.isEmpty) {
    failures.add('${relative(file)} states must be a non-empty array.');
    return const {};
  }
  final ids = <String>{};
  for (final item in value) {
    if (item is! Map) {
      failures.add('${relative(file)} states entries must be objects.');
      continue;
    }
    final state = item.cast<String, Object?>();
    checkAllowedKeys(file, state, uiStateKeys, 'state', failures);
    final id = state['id'];
    if (id is! String || id.isEmpty) {
      failures.add('${relative(file)} state.id must be a non-empty string.');
      continue;
    }
    if (!ids.add(id)) {
      failures.add('${relative(file)} duplicates state id: $id');
    }
    if (state['description'] is! String ||
        (state['description'] as String).isEmpty) {
      failures.add(
        '${relative(file)} state.$id description must be non-empty.',
      );
    }
  }
  return ids;
}

Set<String> readUiActions(
  File file,
  Object? value,
  Set<String> textKeys,
  Set<String> stateIds,
  Map<String, String> contracts,
  List<String> failures,
) {
  if (value is! List || value.isEmpty) {
    failures.add('${relative(file)} actions must be a non-empty array.');
    return const {};
  }
  final ids = <String>{};
  for (final item in value) {
    if (item is! Map) {
      failures.add('${relative(file)} actions entries must be objects.');
      continue;
    }
    final action = item.cast<String, Object?>();
    checkAllowedKeys(file, action, uiActionKeys, 'action', failures);
    final id = action['id'];
    if (id is! String || id.isEmpty) {
      failures.add('${relative(file)} action.id must be a non-empty string.');
      continue;
    }
    if (!ids.add(id)) {
      failures.add('${relative(file)} duplicates action id: $id');
    }
    checkUiTextKey(
      file,
      textKeys,
      action['label_key'],
      'action.$id.label_key',
      failures,
    );
    final busyState = action['busy_state'];
    if (busyState is! String || !stateIds.contains(busyState)) {
      failures.add(
        '${relative(file)} action.$id busy_state must reference a state id.',
      );
    }
    final disabledWhen = action['disabled_when'];
    if (action.containsKey('disabled_when') && disabledWhen is! List) {
      failures.add(
        '${relative(file)} action.$id disabled_when must be an array.',
      );
    } else if (disabledWhen is List) {
      for (final condition in disabledWhen) {
        if (condition is! String || !stateIds.contains(condition)) {
          failures.add(
            '${relative(file)} action.$id disabled_when must reference state ids.',
          );
        }
      }
    }
    final apiContracts = action['api_contracts'];
    if (apiContracts is! List) {
      failures.add(
        '${relative(file)} action.$id api_contracts must be an array.',
      );
    } else {
      for (final contract in apiContracts) {
        if (contract is! String || !contracts.containsKey(contract)) {
          failures.add(
            '${relative(file)} action.$id references missing contract: $contract',
          );
        }
      }
    }
  }
  return ids;
}

Set<String> readUiScreens(
  File file,
  Object? value,
  Set<String> textKeys,
  Set<String> actionIds,
  List<String> failures,
) {
  if (value is! List || value.isEmpty) {
    failures.add('${relative(file)} screens must be a non-empty array.');
    return const {};
  }
  final ids = <String>{};
  for (final item in value) {
    if (item is! Map) {
      failures.add('${relative(file)} screens entries must be objects.');
      continue;
    }
    final screen = item.cast<String, Object?>();
    checkAllowedKeys(file, screen, uiScreenKeys, 'screen', failures);
    final id = screen['id'];
    if (id is! String || id.isEmpty) {
      failures.add('${relative(file)} screen.id must be a non-empty string.');
      continue;
    }
    if (!ids.add(id)) {
      failures.add('${relative(file)} duplicates screen id: $id');
    }
    final actions = screen['actions'];
    if (actions is! List || actions.isEmpty) {
      failures.add(
        '${relative(file)} screen.$id actions must be a non-empty array.',
      );
    } else {
      for (final action in actions) {
        if (action is! String || !actionIds.contains(action)) {
          failures.add(
            '${relative(file)} screen.$id references unknown action: $action',
          );
        }
      }
    }
    final fields = screen['fields'];
    if (fields is! List) {
      failures.add('${relative(file)} screen.$id fields must be an array.');
    } else {
      for (final item in fields) {
        if (item is! Map) {
          failures.add(
            '${relative(file)} screen.$id fields entries must be objects.',
          );
          continue;
        }
        final field = item.cast<String, Object?>();
        checkAllowedKeys(file, field, uiFieldKeys, 'field', failures);
        checkUiTextKey(
          file,
          textKeys,
          field['label_key'],
          'screen.$id field.label_key',
          failures,
        );
      }
    }
  }
  return ids;
}

void checkUiAcceptanceFlows(
  File file,
  Object? value,
  Set<String> screenIds,
  Set<String> actionIds,
  List<String> failures,
) {
  if (value is! List || value.isEmpty) {
    failures.add(
      '${relative(file)} acceptance_flows must be a non-empty array.',
    );
    return;
  }
  for (final item in value) {
    if (item is! Map) {
      failures.add(
        '${relative(file)} acceptance_flows entries must be objects.',
      );
      continue;
    }
    final flow = item.cast<String, Object?>();
    checkAllowedKeys(
      file,
      flow,
      uiAcceptanceFlowKeys,
      'acceptance_flow',
      failures,
    );
    final id = flow['id'];
    final steps = flow['steps'];
    if (id is! String || id.isEmpty) {
      failures.add('${relative(file)} acceptance_flow.id must be non-empty.');
    }
    if (steps is! List || steps.isEmpty) {
      failures.add(
        '${relative(file)} acceptance_flow.$id steps must be a non-empty array.',
      );
      continue;
    }
    for (final item in steps) {
      if (item is! Map) {
        failures.add(
          '${relative(file)} acceptance_flow.$id steps entries must be objects.',
        );
        continue;
      }
      final step = item.cast<String, Object?>();
      checkAllowedKeys(
        file,
        step,
        uiAcceptanceStepKeys,
        'acceptance_step',
        failures,
      );
      final screen = step['screen'];
      if (screen is! String || !screenIds.contains(screen)) {
        failures.add(
          '${relative(file)} acceptance_flow.$id step references unknown screen: $screen',
        );
      }
      final action = step['action'];
      if (action != null &&
          (action is! String || !actionIds.contains(action))) {
        failures.add(
          '${relative(file)} acceptance_flow.$id step references unknown action: $action',
        );
      }
    }
  }
}

void checkUiTextKey(
  File file,
  Set<String> textKeys,
  Object? value,
  String label,
  List<String> failures,
) {
  if (value is! String || !textKeys.contains(value)) {
    failures.add('${relative(file)} $label must reference text_keys.');
  }
}

void checkUiReleaseEvidence(File file, Object? value, List<String> failures) {
  if (value is! Map) {
    failures.add('${relative(file)} release_evidence must be an object.');
    return;
  }
  final evidence = value.cast<String, Object?>();
  checkAllowedKeys(
    file,
    evidence,
    uiReleaseEvidenceKeys,
    'release_evidence',
    failures,
  );
  if (evidence['evidence_class'] != 'product-mvp-ui-surface-adoption') {
    failures.add(
      '${relative(file)} release_evidence.evidence_class is invalid.',
    );
  }
  if (evidence['target_release_candidate'] is! String ||
      (evidence['target_release_candidate'] as String).isEmpty) {
    failures.add(
      '${relative(file)} release_evidence.target_release_candidate is required.',
    );
  }
  for (final key in [
    'consumer_repos',
    'required_checks',
    'redaction_policy',
    'adoption_boundaries',
  ]) {
    final list = evidence[key];
    if (list is! List ||
        list.isEmpty ||
        list.any((item) => item is! String || item.isEmpty)) {
      failures.add(
        '${relative(file)} release_evidence.$key must be non-empty strings.',
      );
    }
  }
  final checks = evidence['required_checks'];
  if (checks is List) {
    for (final required in [
      'screen id',
      'action id',
      'duplicate-submit',
      'recoverable error',
      'product-mvp-happy-path',
      'accessibility',
    ]) {
      if (!checks.any((item) => item is String && item.contains(required))) {
        failures.add(
          '${relative(file)} release_evidence.required_checks missing $required.',
        );
      }
    }
  }
  final redaction = evidence['redaction_policy'];
  if (redaction is List) {
    for (final required in ['tokens', 'database URLs', 'private local paths']) {
      if (!redaction.any((item) => item is String && item.contains(required))) {
        failures.add(
          '${relative(file)} release_evidence.redaction_policy missing $required.',
        );
      }
    }
  }
  final boundaries = evidence['adoption_boundaries'];
  if (boundaries is List) {
    for (final required in [
      'component hierarchy',
      'UI-free core',
      'Docker Compose deploy smoke',
      'Matrix full compliance',
    ]) {
      if (!boundaries.any(
        (item) => item is String && item.contains(required),
      )) {
        failures.add(
          '${relative(file)} release_evidence.adoption_boundaries missing $required.',
        );
      }
    }
  }
}

void checkUiThemeRefs(File file, Object? value, List<String> failures) {
  if (value is! List || value.isEmpty) {
    failures.add('${relative(file)} theme_refs must be a non-empty array.');
    return;
  }
  for (final ref in value) {
    if (ref is! String || !File(ref).existsSync()) {
      failures.add(
        '${relative(file)} theme_refs must reference existing files.',
      );
    }
  }
}

void checkUiLimitations(File file, Object? value, List<String> failures) {
  if (value is! List || value.isEmpty) {
    failures.add('${relative(file)} limitations must be a non-empty array.');
    return;
  }
  for (final limitation in value) {
    if (limitation is! String || limitation.isEmpty) {
      failures.add(
        '${relative(file)} limitations must contain non-empty strings.',
      );
    }
  }
}

void checkAllowedKeys(
  File file,
  Map<String, Object?> object,
  Set<String> allowed,
  String label,
  List<String> failures,
) {
  for (final key in object.keys) {
    if (!allowed.contains(key)) {
      failures.add('${relative(file)} $label has unexpected key: $key');
    }
  }
}
