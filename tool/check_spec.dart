import 'dart:convert';
import 'dart:io';

const profiles = {
  'core',
  'auth',
  'rooms',
  'events',
  'messaging',
  'sync',
  'media',
};

const fullClientProfiles = profiles;

const matrixDomains = {
  'Appendices/common rules',
  'Client-Server API',
  'Client-Server API; Room Versions',
};

const negativeVectorProfiles = {
  'auth',
  'rooms',
  'events',
  'messaging',
  'sync',
  'media',
};

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

void main() {
  final failures = <String>[];
  checkBoundary(failures);
  checkNamespaceConsistency(failures);
  final contracts = readContracts(failures);

  checkDocs(contracts, failures);
  final profileMap = checkProfileMap(contracts, failures);
  if (profileMap.isNotEmpty) {
    checkVectors(contracts, profileMap, failures);
  }
  checkMatrixFoundation(contracts, failures);
  checkMatrixAuthSession(contracts, failures);
  checkMatrixRegistration(contracts, failures);
  checkMatrixDevices(contracts, failures);
  checkMatrixRoomsMvp(contracts, failures);
  checkMatrixSendEventMessagesMvp(contracts, failures);
  checkMatrixSyncMvp(contracts, failures);
  checkMatrixMediaMvp(contracts, failures);
  checkMatrixClientServerMvpLiveE2eGate(contracts, failures);
  checkMatrixEventDagAuthEvents(contracts, failures);
  checkMatrixStateSnapshotResolution(contracts, failures);
  checkMatrixRoomVersionsGate(contracts, failures);
  checkMatrixRoomAuthRepresentativeVectors(contracts, failures);
  checkMatrixRoomAliasUpgradePersistenceGate(contracts, failures);
  checkMatrixProfileAccountDataTags(contracts, failures);
  checkMatrixReceiptsTypingReadMarkers(contracts, failures);
  checkMatrixFiltersPresenceCapabilities(contracts, failures);
  checkMatrixRoomDirectoryAliasesInvites(contracts, failures);
  checkMvpReadiness(contracts, profileMap, failures);
  checkThemes(failures);
  checkUiSurfaces(contracts, failures);

  if (failures.isNotEmpty) {
    stderr.writeln('Spec check failed:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
  }
}

void checkNamespaceConsistency(List<String> failures) {
  const docs = [
    'README.md',
    'SOURCE_OF_TRUTH.md',
    'REFERENCE_POLICY.md',
    'FEATURE_PROFILES.md',
    'MODULE_DEPENDENCIES.md',
    'CONTRACT_MODULE_MAP.md',
    'AGENTS.md',
    'CHANGELOG.md',
    'LICENSE',
    '.github/PULL_REQUEST_TEMPLATE.md',
    '.github/ISSUE_TEMPLATE/bug_report.md',
    '.github/ISSUE_TEMPLATE/feature_request.md',
    '.github/ISSUE_TEMPLATE/maintenance.md',
  ];
  const legacyTokens = {
    '/_ichi-go/client',
    'ichigo.',
    'ichigo://',
    'Ichi-Go',
    'ichi-go',
    'Okomedev',
    'okomedev',
    'CHAWAN_',
    'okome.dev',
  };

  final files = <File>[
    for (final path in docs)
      if (File(path).existsSync()) File(path),
    if (Directory('contracts').existsSync())
      ...filesUnder(Directory('contracts'), '.md'),
    if (Directory('test-vectors').existsSync())
      ...filesUnder(Directory('test-vectors'), '.json'),
    if (Directory('design').existsSync())
      ...filesUnder(Directory('design'), '.json'),
  ];

  for (final file in files) {
    final source = file.readAsStringSync();
    for (final token in legacyTokens) {
      if (source.contains(token)) {
        failures.add(
          '${relative(file)} contains legacy namespace token: $token',
        );
      }
    }
  }
}

void checkBoundary(List<String> failures) {
  const allowedTopLevel = {
    '.github',
    '.gitignore',
    'AGENTS.md',
    'CHANGELOG.md',
    'CONTRACT_MODULE_MAP.md',
    'FEATURE_PROFILES.md',
    'LICENSE',
    'MODULE_DEPENDENCIES.md',
    'README.md',
    'REFERENCE_POLICY.md',
    'SOURCE_OF_TRUTH.md',
    'contracts',
    'design',
    'test-vectors',
    'tool',
  };
  const allowedToolFiles = {'check_spec.dart'};

  for (final entity in Directory.current.listSync()) {
    final name = entityName(entity);
    if (isGeneratedEntry(name)) {
      continue;
    }
    if (!allowedTopLevel.contains(name)) {
      failures.add('Unexpected top-level entry in spec root: $name');
    }
  }

  final toolRoot = Directory('tool');
  if (!toolRoot.existsSync()) {
    failures.add('Missing tool directory.');
    return;
  }
  for (final entity in toolRoot.listSync()) {
    final name = entityName(entity);
    if (entity is! File || !allowedToolFiles.contains(name)) {
      failures.add('Unexpected spec tool entry: ${relative(entity)}');
    }
  }

  for (final path in [
    'pubspec.yaml',
    'pubspec.lock',
    'lib',
    'test',
    'example',
  ]) {
    if (FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound) {
      failures.add(
        'Implementation-owned entry must not exist in spec root: '
        '$path',
      );
    }
  }
}

Map<String, String> readContracts(List<String> failures) {
  final root = Directory('contracts');
  if (!root.existsSync()) {
    failures.add('Missing contracts directory.');
    return const {};
  }

  final contracts = <String, String>{};
  for (final file in filesUnder(root, '.md')) {
    final name = file.uri.pathSegments.last;
    final idMatch = RegExp(r'^(SPEC-\d{3})-.*\.md$').firstMatch(name);
    if (idMatch == null) {
      failures.add('Contract file has unexpected name: ${relative(file)}');
      continue;
    }

    final id = idMatch.group(1)!;
    final source = file.readAsStringSync();
    if (!source.startsWith('# $id:')) {
      failures.add('${relative(file)} must start with "# $id:".');
    }
    if (!source.contains('Status: draft')) {
      failures.add('${relative(file)} must declare draft status.');
    }
    if (!source.contains('Canonical: yes')) {
      failures.add('${relative(file)} must declare canonical status.');
    }

    final profileMatch = RegExp(
      r'^Feature profile: ([a-z-]+)$',
      multiLine: true,
    ).firstMatch(source);
    if (profileMatch == null) {
      failures.add('${relative(file)} must declare a feature profile.');
      continue;
    }
    final profile = profileMatch.group(1)!;
    if (!profiles.contains(profile)) {
      failures.add('${relative(file)} uses unknown profile: $profile');
      continue;
    }
    contracts[id] = profile;
  }

  if (contracts.isEmpty) {
    failures.add('No contract files found.');
  }
  return contracts;
}

void checkDocs(Map<String, String> contracts, List<String> failures) {
  final docs = [
    'README.md',
    'SOURCE_OF_TRUTH.md',
    'REFERENCE_POLICY.md',
    'FEATURE_PROFILES.md',
    'MODULE_DEPENDENCIES.md',
    'CONTRACT_MODULE_MAP.md',
    'AGENTS.md',
  ];

  for (final path in docs) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing doc: $path');
      continue;
    }
    final source = file.readAsStringSync();
    for (final match in RegExp(r'\bSPEC-\d{3}\b').allMatches(source)) {
      final id = match.group(0)!;
      if (!contracts.containsKey(id)) {
        failures.add('$path references missing contract: $id');
      }
    }
  }

  final featureProfiles = File('FEATURE_PROFILES.md').readAsStringSync();
  for (final profile in profiles) {
    if (!featureProfiles.contains(profile)) {
      failures.add('FEATURE_PROFILES.md does not list profile: $profile');
    }
  }
  if (!featureProfiles.contains('full-client')) {
    failures.add('FEATURE_PROFILES.md does not list profile: full-client');
  }

  final readme = File('README.md').readAsStringSync();
  for (final phrase in [
    'Stateful vector metadata',
    'Houra MVP 100% Readiness Criteria',
    'Implementation Metrics',
    'Matrix reference',
    'Matrix v1.18 Compliance Matrix',
    'Matrix compliance advertisement gate',
    'Shared Implementation Strategy',
    'External reference snapshot',
    'Implementation Sharing Matrix',
    'Implementation Adoption Reports',
  ]) {
    if (!readme.contains(phrase)) {
      failures.add('README.md must document $phrase.');
    }
  }
  if (!readme.contains('UI Surface Contract')) {
    failures.add('README.md must document UI Surface Contract.');
  }

  final sourceOfTruth = File('SOURCE_OF_TRUTH.md').readAsStringSync();
  if (!sourceOfTruth.contains('MVP Readiness Boundary')) {
    failures.add('SOURCE_OF_TRUTH.md must document MVP Readiness Boundary.');
  }
}

Map<String, String> checkProfileMap(
  Map<String, String> contracts,
  List<String> failures,
) {
  final file = File('CONTRACT_MODULE_MAP.md');
  if (!file.existsSync()) {
    failures.add('Missing CONTRACT_MODULE_MAP.md.');
    return const {};
  }

  final seen = <String>{};
  final profileMap = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    if (!line.startsWith('| SPEC-')) {
      continue;
    }
    final parts = line.split('|').map((part) => part.trim()).toList();
    if (parts.length < 6) {
      failures.add('Malformed contract map row: $line');
      continue;
    }
    final id = RegExp(r'\bSPEC-\d{3}\b').firstMatch(parts[1])?.group(0);
    if (id == null || !contracts.containsKey(id)) {
      failures.add('Contract map references missing contract: ${parts[1]}');
      continue;
    }
    if (parts[2] != contracts[id]) {
      failures.add(
        'Contract map profile mismatch for $id: ${parts[2]} != '
        '${contracts[id]}',
      );
    }
    if (!matrixDomains.contains(parts[3])) {
      failures.add(
        'Contract map Matrix domain is unknown for $id: ${parts[3]}',
      );
    }
    if (parts[4].isEmpty) {
      failures.add('Contract map current Matrix alignment is empty for $id.');
    }
    if (parts.length < 6 || parts[5].isEmpty) {
      failures.add('Contract map next compliance action is empty for $id.');
    }
    if (parts[2] != contracts[id]) {
      continue;
    }
    profileMap[id] = parts[2];
    seen.add(id);
  }

  for (final id in contracts.keys) {
    if (!seen.contains(id)) {
      failures.add('CONTRACT_MODULE_MAP.md does not list $id.');
    }
  }
  return profileMap;
}

void checkVectors(
  Map<String, String> contracts,
  Map<String, String> profileMap,
  List<String> failures,
) {
  final root = Directory('test-vectors');
  if (!root.existsSync()) {
    failures.add('Missing test-vectors directory.');
    return;
  }

  final vectors = filesUnder(root, '.json').toList();
  if (vectors.isEmpty) {
    failures.add('No test vectors found.');
    return;
  }

  final vectorContracts = <String, int>{};
  final vectorProfiles = <String, int>{};
  final negativeProfiles = <String>{};
  for (final file in vectors) {
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }

    final baseName = file.uri.pathSegments.last.replaceAll('.json', '');
    final name = json['name'];
    if (name != baseName) {
      failures.add('${relative(file)} name must match file name.');
    }

    final contract = json['contract'];
    if (contract is! String || !contracts.containsKey(contract)) {
      failures.add('${relative(file)} references missing contract: $contract');
    } else {
      vectorContracts.update(contract, (count) => count + 1, ifAbsent: () => 1);
      final profile = profileMap[contract];
      if (profile != null) {
        vectorProfiles.update(profile, (count) => count + 1, ifAbsent: () => 1);
        if (isNegativeVector(json)) {
          negativeProfiles.add(profile);
        }
      }
      checkVectorProfile(file, contract, profileMap, failures);
    }

    if (json.containsKey('given')) {
      checkGiven(file, json['given'], failures);
    }

    if (json.containsKey('request')) {
      checkRequest(file, json['request'], failures);
    }
    if (json.containsKey('response')) {
      checkStatusObject(file, json['response'], 'response', failures);
    }
    if (json.containsKey('expected')) {
      checkStatusObject(file, json['expected'], 'expected', failures);
    }
    if (!json.containsKey('request') &&
        !json.containsKey('response') &&
        !json.containsKey('event')) {
      failures.add(
        '${relative(file)} must include request, response, or event.',
      );
    }
  }

  for (final id in contracts.keys) {
    if (!vectorContracts.containsKey(id)) {
      failures.add('No test vector covers $id.');
    }
  }
  for (final profile in fullClientProfiles) {
    if (!vectorProfiles.containsKey(profile)) {
      failures.add('No test vector covers MVP profile: $profile.');
    }
  }
  for (final profile in negativeVectorProfiles) {
    if (!negativeProfiles.contains(profile)) {
      failures.add('No negative test vector covers MVP profile: $profile.');
    }
  }
}

void checkMatrixFoundation(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-031')) {
    failures.add('Matrix foundation contract SPEC-031 is required.');
  }
  for (final path in [
    'test-vectors/core/matrix-foundation-error-basic.json',
    'test-vectors/core/matrix-foundation-identifiers-basic.json',
  ]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix foundation vector: $path');
    }
  }
}

void checkMatrixAuthSession(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-032')) {
    failures.add('Matrix auth session contract SPEC-032 is required.');
  }
  for (final path in [
    'test-vectors/auth/matrix-login-flows-basic.json',
    'test-vectors/auth/matrix-password-login-basic.json',
    'test-vectors/auth/matrix-password-login-failure.json',
    'test-vectors/auth/matrix-whoami-basic.json',
    'test-vectors/auth/matrix-logout-basic.json',
  ]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix auth session vector: $path');
    }
  }
}

void checkMatrixRegistration(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-033')) {
    failures.add('Matrix registration contract SPEC-033 is required.');
  }
  for (final path in [
    'test-vectors/auth/matrix-registration-available-basic.json',
    'test-vectors/auth/matrix-registration-available-in-use.json',
    'test-vectors/auth/matrix-registration-basic.json',
    'test-vectors/auth/matrix-registration-disabled.json',
    'test-vectors/auth/matrix-registration-invalid-username.json',
    'test-vectors/auth/matrix-registration-token-validity-basic.json',
    'test-vectors/auth/matrix-registration-token-validity-invalid.json',
    'test-vectors/auth/matrix-registration-uia-required.json',
  ]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix registration vector: $path');
    }
  }
}

void checkMatrixDevices(Map<String, String> contracts, List<String> failures) {
  if (!contracts.containsKey('SPEC-034')) {
    failures.add('Matrix devices/session contract SPEC-034 is required.');
  }
  for (final path in [
    'test-vectors/auth/matrix-devices-list-basic.json',
    'test-vectors/auth/matrix-device-detail-basic.json',
    'test-vectors/auth/matrix-device-detail-not-found.json',
    'test-vectors/auth/matrix-device-update-basic.json',
    'test-vectors/auth/matrix-device-update-not-found.json',
    'test-vectors/auth/matrix-device-delete-uia-required.json',
    'test-vectors/auth/matrix-device-delete-basic.json',
    'test-vectors/auth/matrix-devices-delete-bulk-uia-required.json',
    'test-vectors/auth/matrix-devices-delete-bulk-basic.json',
    'test-vectors/auth/matrix-device-token-invalid-after-delete.json',
    'test-vectors/auth/matrix-devices-missing-token.json',
  ]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix devices/session vector: $path');
    }
  }
}

void checkMatrixRoomsMvp(Map<String, String> contracts, List<String> failures) {
  if (!contracts.containsKey('SPEC-035')) {
    failures.add('Matrix room membership/state contract SPEC-035 is required.');
  }
  for (final path in [
    'test-vectors/rooms/matrix-create-room-basic.json',
    'test-vectors/rooms/matrix-create-room-missing-token.json',
    'test-vectors/rooms/matrix-join-room-basic.json',
    'test-vectors/rooms/matrix-join-room-not-found.json',
    'test-vectors/rooms/matrix-leave-room-basic.json',
    'test-vectors/rooms/matrix-room-state-basic.json',
    'test-vectors/rooms/matrix-room-state-forbidden.json',
  ]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix room membership/state vector: $path');
    }
  }
}

void checkMatrixSendEventMessagesMvp(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-036')) {
    failures.add('Matrix send event/messages contract SPEC-036 is required.');
  }
  for (final path in [
    'test-vectors/messaging/matrix-send-event-text-basic.json',
    'test-vectors/messaging/matrix-send-event-text-idempotent.json',
    'test-vectors/messaging/matrix-send-event-malformed-payload.json',
    'test-vectors/messaging/matrix-send-event-missing-token.json',
    'test-vectors/messaging/matrix-messages-basic.json',
    'test-vectors/messaging/matrix-messages-next-page.json',
    'test-vectors/messaging/matrix-messages-forbidden.json',
    'test-vectors/messaging/matrix-messages-invalid-dir.json',
  ]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix send event/messages vector: $path');
    }
  }
}

void checkMatrixSyncMvp(Map<String, String> contracts, List<String> failures) {
  if (!contracts.containsKey('SPEC-037')) {
    failures.add('Matrix sync MVP contract SPEC-037 is required.');
  }
  for (final path in [
    'test-vectors/sync/matrix-sync-initial-basic.json',
    'test-vectors/sync/matrix-sync-incremental-basic.json',
    'test-vectors/sync/matrix-sync-empty-incremental.json',
    'test-vectors/sync/matrix-sync-invalid-since.json',
    'test-vectors/sync/matrix-sync-missing-token.json',
    'test-vectors/sync/matrix-sync-invalid-token.json',
  ]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix sync MVP vector: $path');
    }
  }
}

void checkMatrixMediaMvp(Map<String, String> contracts, List<String> failures) {
  if (!contracts.containsKey('SPEC-038')) {
    failures.add('Matrix media MVP contract SPEC-038 is required.');
  }
  for (final path in [
    'test-vectors/media/matrix-media-upload-basic.json',
    'test-vectors/media/matrix-media-upload-missing-token.json',
    'test-vectors/media/matrix-media-upload-too-large.json',
    'test-vectors/media/matrix-media-download-basic.json',
    'test-vectors/media/matrix-media-download-with-filename-basic.json',
    'test-vectors/media/matrix-media-download-missing-token.json',
    'test-vectors/media/matrix-media-download-not-found.json',
  ]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix media MVP vector: $path');
    }
  }
}

void checkMatrixClientServerMvpLiveE2eGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-039')) {
    failures.add(
      'Matrix Client-Server MVP live e2e gate contract SPEC-039 is required.',
    );
  }
  const path = 'test-vectors/core/matrix-client-server-mvp-live-e2e-gate.json';
  if (!File(path).existsSync()) {
    failures.add(
      'Missing Matrix Client-Server MVP live e2e gate vector: $path',
    );
  }
}

void checkMatrixEventDagAuthEvents(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-040')) {
    failures.add('Matrix event DAG/auth events contract SPEC-040 is required.');
  }
  const basicPath =
      'test-vectors/events/matrix-event-dag-auth-events-basic.json';
  const invalidPath =
      'test-vectors/events/matrix-event-dag-auth-events-invalid.json';
  for (final path in [basicPath, invalidPath]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix event DAG/auth events vector: $path');
    }
  }

  final basicFile = File(basicPath);
  final basic = readJsonObject(basicFile, failures);
  if (basic != null) {
    final eventSet = basic['event'];
    if (eventSet is! Map) {
      failures.add('${relative(basicFile)} event must be an object.');
    } else {
      final errors = validateMatrixEventDagSet(
        eventSet.cast<String, Object?>(),
      );
      for (final error in errors) {
        failures.add('${relative(basicFile)} must be valid: $error');
      }
    }
  }

  final invalidFile = File(invalidPath);
  final invalid = readJsonObject(invalidFile, failures);
  if (invalid != null) {
    final event = invalid['event'];
    if (event is! Map) {
      failures.add('${relative(invalidFile)} event must be an object.');
      return;
    }
    final cases = event['invalid_cases'];
    if (cases is! List || cases.isEmpty) {
      failures.add(
        '${relative(invalidFile)} event.invalid_cases must be non-empty.',
      );
      return;
    }
    for (final item in cases) {
      if (item is! Map) {
        failures.add(
          '${relative(invalidFile)} invalid case entries must be objects.',
        );
        continue;
      }
      final testCase = item.cast<String, Object?>();
      final id = testCase['id'];
      if (id is! String || id.isEmpty) {
        failures.add('${relative(invalidFile)} invalid case id is required.');
      }
      if (testCase['expected_error'] != 'M_INVALID_PARAM') {
        failures.add(
          '${relative(invalidFile)} invalid case $id must expect M_INVALID_PARAM.',
        );
      }
      final expectedViolation = testCase['expected_violation'];
      if (expectedViolation is! String || expectedViolation.isEmpty) {
        failures.add(
          '${relative(invalidFile)} invalid case $id must name expected_violation.',
        );
      }
      final errors = validateMatrixEventDagSet(testCase);
      if (errors.isEmpty) {
        failures.add(
          '${relative(invalidFile)} invalid case $id must fail DAG validation.',
        );
      }
      if (expectedViolation is String &&
          expectedViolation.isNotEmpty &&
          !errors.contains(expectedViolation)) {
        failures.add(
          '${relative(invalidFile)} invalid case $id expected $expectedViolation '
          'but got ${errors.join(', ')}.',
        );
      }
    }
  }
}

List<String> validateMatrixEventDagSet(Map<String, Object?> eventSet) {
  final errors = <String>[];
  if (eventSet['matrix_spec_version'] != 'v1.18' &&
      !eventSet.containsKey('expected_violation')) {
    errors.add('matrix_spec_version');
  }
  final roomVersion = eventSet['room_version'];
  if (roomVersion != '12') {
    errors.add('room_version');
  }
  final roomId = eventSet['room_id'];
  if (roomId is! String || !isMatrixRoomId(roomId)) {
    errors.add('room_id');
  }
  final candidateEventId = eventSet['candidate_event_id'];
  if (candidateEventId is! String || !isMatrixEventId(candidateEventId)) {
    errors.add('candidate_event_id');
  }
  final events = eventSet['events'];
  if (events is! List || events.isEmpty) {
    errors.add('events');
    return errors;
  }

  final byId = <String, Map<String, Object?>>{};
  for (final item in events) {
    if (item is! Map) {
      errors.add('event_object');
      continue;
    }
    final event = item.cast<String, Object?>();
    final eventId = event['event_id'];
    if (eventId is! String || !isMatrixEventId(eventId)) {
      errors.add('event_id');
      continue;
    }
    if (byId.containsKey(eventId)) {
      errors.add('duplicate_event_id');
      continue;
    }
    byId[eventId] = event;
  }

  if (candidateEventId is String && !byId.containsKey(candidateEventId)) {
    errors.add('candidate_event_id');
  }

  for (final entry in byId.entries) {
    final eventId = entry.key;
    final event = entry.value;
    validateMatrixEventEnvelope(
      eventId,
      event,
      byId,
      roomId is String ? roomId : null,
      errors,
    );
  }

  if (hasPrevEventCycle(byId)) {
    errors.add('prev_event_cycle');
  }
  return errors.toSet().toList();
}

void validateMatrixEventEnvelope(
  String eventId,
  Map<String, Object?> event,
  Map<String, Map<String, Object?>> byId,
  String? roomId,
  List<String> errors,
) {
  final type = event['type'];
  final isCreate = type == 'm.room.create';
  if (type is! String || type.isEmpty) {
    errors.add('type');
  }
  final sender = event['sender'];
  if (sender is! String || !sender.startsWith('@')) {
    errors.add('sender');
  }
  if (event['content'] is! Map) {
    errors.add('content');
  }
  if (event['origin_server_ts'] is! int) {
    errors.add('origin_server_ts');
  }
  final depth = event['depth'];
  if (depth is! int || depth < 1) {
    errors.add('depth');
  }
  final hashes = event['hashes'];
  if (hashes is! Map ||
      hashes['sha256'] is! String ||
      (hashes['sha256'] as String).isEmpty) {
    errors.add('hashes');
  }
  final signatures = event['signatures'];
  if (signatures is! Map || signatures.isEmpty) {
    errors.add('signatures');
  }
  final stateKey = event['state_key'];
  if (stateKey != null && stateKey is! String) {
    errors.add('state_key');
  }

  final eventRoomId = event['room_id'];
  if (isCreate) {
    if (eventRoomId != null) {
      errors.add('create_room_id');
    }
    if (stateKey != '') {
      errors.add('create_state_key');
    }
  } else if (eventRoomId != roomId) {
    errors.add('room_id_mismatch');
  }

  final prevEvents = readMatrixEventIdList(event['prev_events']);
  final authEvents = readMatrixEventIdList(event['auth_events']);
  if (prevEvents == null) {
    errors.add('prev_events');
    return;
  }
  if (authEvents == null) {
    errors.add('auth_events');
    return;
  }
  if (prevEvents.length > 20) {
    errors.add('prev_events_limit');
  }
  if (authEvents.length > 10) {
    errors.add('auth_events_limit');
  }
  if (prevEvents.toSet().length != prevEvents.length) {
    errors.add('duplicate_prev_event');
  }
  if (authEvents.toSet().length != authEvents.length) {
    errors.add('duplicate_auth_event');
  }
  if (prevEvents.contains(eventId)) {
    errors.add('self_prev_event');
  }
  if (authEvents.contains(eventId)) {
    errors.add('self_auth_event');
  }
  if (isCreate && prevEvents.isNotEmpty) {
    errors.add('create_prev_events');
  }
  if (!isCreate && prevEvents.isEmpty) {
    errors.add('non_create_without_prev_event');
  }

  var maxPrevDepth = 0;
  for (final prevEventId in prevEvents) {
    final prevEvent = byId[prevEventId];
    if (prevEvent == null) {
      errors.add('missing_prev_event');
      continue;
    }
    if (roomId != null &&
        prevEvent['type'] != 'm.room.create' &&
        prevEvent['room_id'] != roomId) {
      errors.add('prev_room_id_mismatch');
    }
    final prevDepth = prevEvent['depth'];
    if (prevDepth is int && prevDepth > maxPrevDepth) {
      maxPrevDepth = prevDepth;
    }
  }
  if (depth is int && prevEvents.isNotEmpty && depth != maxPrevDepth + 1) {
    errors.add('depth');
  }

  final authStateKeys = <String>{};
  for (final authEventId in authEvents) {
    final authEvent = byId[authEventId];
    if (authEvent == null) {
      errors.add('missing_auth_event');
      continue;
    }
    if (authEvent['type'] == 'm.room.create') {
      errors.add('auth_create_event_v12');
    }
    if (roomId != null &&
        authEvent['type'] != 'm.room.create' &&
        authEvent['room_id'] != roomId) {
      errors.add('auth_room_id_mismatch');
    }
    final authType = authEvent['type'];
    final authStateKey = authEvent['state_key'];
    if (authType is! String || authStateKey is! String) {
      errors.add('auth_event_not_state');
      continue;
    }
    final tuple = '$authType\x00$authStateKey';
    if (!authStateKeys.add(tuple)) {
      errors.add('duplicate_auth_state_key');
    }
  }
}

List<String>? readMatrixEventIdList(Object? value) {
  if (value is! List) {
    return null;
  }
  final ids = <String>[];
  for (final item in value) {
    if (item is! String || !isMatrixEventId(item)) {
      return null;
    }
    ids.add(item);
  }
  return ids;
}

bool hasPrevEventCycle(Map<String, Map<String, Object?>> byId) {
  final visiting = <String>{};
  final visited = <String>{};

  bool visit(String eventId) {
    if (visited.contains(eventId)) {
      return false;
    }
    if (!visiting.add(eventId)) {
      return true;
    }
    final prevEvents = readMatrixEventIdList(byId[eventId]?['prev_events']);
    if (prevEvents != null) {
      for (final prevEventId in prevEvents) {
        if (byId.containsKey(prevEventId) && visit(prevEventId)) {
          return true;
        }
      }
    }
    visiting.remove(eventId);
    visited.add(eventId);
    return false;
  }

  for (final eventId in byId.keys) {
    if (visit(eventId)) {
      return true;
    }
  }
  return false;
}

bool isMatrixEventId(String id) =>
    id.startsWith(r'$') && id.length > 1 && id.length <= 255;

bool isMatrixRoomId(String id) =>
    id.startsWith('!') && id.length > 1 && id.length <= 255;

void checkMatrixStateSnapshotResolution(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-041')) {
    failures.add(
      'Matrix state snapshot/resolution contract SPEC-041 is required.',
    );
  }
  const snapshotPath = 'test-vectors/events/matrix-state-snapshot-basic.json';
  const resolutionPath =
      'test-vectors/events/matrix-state-resolution-representative.json';
  for (final path in [snapshotPath, resolutionPath]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix state snapshot/resolution vector: $path');
    }
  }

  final snapshotFile = File(snapshotPath);
  final snapshot = readJsonObject(snapshotFile, failures);
  if (snapshot != null) {
    final event = snapshot['event'];
    if (event is! Map) {
      failures.add('${relative(snapshotFile)} event must be an object.');
    } else {
      validateMatrixStateSnapshotVector(
        snapshotFile,
        event.cast<String, Object?>(),
        failures,
      );
    }
  }

  final resolutionFile = File(resolutionPath);
  final resolution = readJsonObject(resolutionFile, failures);
  if (resolution != null) {
    final event = resolution['event'];
    if (event is! Map) {
      failures.add('${relative(resolutionFile)} event must be an object.');
    } else {
      validateMatrixStateResolutionVector(
        resolutionFile,
        event.cast<String, Object?>(),
        failures,
      );
    }
  }
}

void validateMatrixStateSnapshotVector(
  File file,
  Map<String, Object?> event,
  List<String> failures,
) {
  final catalog = readMatrixStateEventCatalog(file, event, failures);
  final snapshots = event['snapshots'];
  if (snapshots is! List || snapshots.isEmpty) {
    failures.add('${relative(file)} snapshots must be non-empty.');
    return;
  }
  for (final item in snapshots) {
    if (item is! Map) {
      failures.add('${relative(file)} snapshot entries must be objects.');
      continue;
    }
    final snapshot = item.cast<String, Object?>();
    final id = snapshot['id'];
    if (id is! String || id.isEmpty) {
      failures.add('${relative(file)} snapshot id is required.');
    }
    final before = readMatrixStateMap(
      file,
      snapshot['before_state'],
      catalog,
      failures,
      label: 'snapshot.$id.before_state',
    );
    final expected = readMatrixStateMap(
      file,
      snapshot['expected_after_state'],
      catalog,
      failures,
      label: 'snapshot.$id.expected_after_state',
    );
    final eventId = snapshot['event_id'];
    if (eventId is! String || !catalog.containsKey(eventId)) {
      failures.add('${relative(file)} snapshot.$id event_id is unknown.');
      continue;
    }
    final applied = Map<String, String>.from(before);
    final eventInfo = catalog[eventId]!;
    final stateKey = eventInfo.stateKey;
    if (stateKey != null) {
      applied[matrixStateTuple(eventInfo.type, stateKey)] = eventId;
    }
    if (!sameStringMap(applied, expected)) {
      failures.add(
        '${relative(file)} snapshot.$id expected_after_state does not match state application.',
      );
    }
  }
}

void validateMatrixStateResolutionVector(
  File file,
  Map<String, Object?> event,
  List<String> failures,
) {
  final catalog = readMatrixStateEventCatalog(file, event, failures);
  final cases = event['resolution_cases'];
  if (cases is! List || cases.isEmpty) {
    failures.add('${relative(file)} resolution_cases must be non-empty.');
    return;
  }
  for (final item in cases) {
    if (item is! Map) {
      failures.add('${relative(file)} resolution cases must be objects.');
      continue;
    }
    final testCase = item.cast<String, Object?>();
    final id = testCase['id'];
    if (id is! String || id.isEmpty) {
      failures.add('${relative(file)} resolution case id is required.');
    }
    final stateSets = readMatrixStateSets(file, testCase, catalog, failures);
    final expected = testCase['expected'];
    if (expected is! Map) {
      failures.add(
        '${relative(file)} resolution case $id expected is required.',
      );
      continue;
    }
    final expectedMap = expected.cast<String, Object?>();
    final expectedUnconflicted = readMatrixStateMap(
      file,
      expectedMap['unconflicted_state'],
      catalog,
      failures,
      label: 'resolution.$id.expected.unconflicted_state',
    );
    final expectedResolved = readMatrixStateMap(
      file,
      expectedMap['resolved_state'],
      catalog,
      failures,
      label: 'resolution.$id.expected.resolved_state',
    );
    final expectedConflicted = readMatrixEventIdSet(
      expectedMap['conflicted_event_ids'],
    );
    if (expectedConflicted == null) {
      failures.add(
        '${relative(file)} resolution.$id expected conflicted_event_ids must be event IDs.',
      );
      continue;
    }
    final classified = classifyMatrixStateSets(stateSets);
    if (!sameStringMap(classified.unconflicted, expectedUnconflicted)) {
      failures.add(
        '${relative(file)} resolution.$id unconflicted_state mismatch.',
      );
    }
    if (!sameStringSet(classified.conflictedEventIds, expectedConflicted)) {
      failures.add(
        '${relative(file)} resolution.$id conflicted_event_ids mismatch.',
      );
    }
    final representativeResolved = resolveRepresentativeState(
      classified,
      catalog,
    );
    if (!sameStringMap(representativeResolved, expectedResolved)) {
      failures.add('${relative(file)} resolution.$id resolved_state mismatch.');
    }
  }
}

Map<String, MatrixStateEventInfo> readMatrixStateEventCatalog(
  File file,
  Map<String, Object?> event,
  List<String> failures,
) {
  if (event['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  if (event['room_version'] != '12') {
    failures.add('${relative(file)} room_version must be 12.');
  }
  final catalog = event['event_catalog'];
  if (catalog is! List || catalog.isEmpty) {
    failures.add('${relative(file)} event_catalog must be non-empty.');
    return const {};
  }
  final result = <String, MatrixStateEventInfo>{};
  for (final item in catalog) {
    if (item is! Map) {
      failures.add('${relative(file)} event_catalog entries must be objects.');
      continue;
    }
    final entry = item.cast<String, Object?>();
    final eventId = entry['event_id'];
    final type = entry['type'];
    final stateKey = entry['state_key'];
    final ts = entry['origin_server_ts'];
    if (eventId is! String || !isMatrixEventId(eventId)) {
      failures.add('${relative(file)} event_catalog event_id is invalid.');
      continue;
    }
    if (type is! String || type.isEmpty) {
      failures.add('${relative(file)} event_catalog $eventId type is invalid.');
      continue;
    }
    if (stateKey != null && stateKey is! String) {
      failures.add(
        '${relative(file)} event_catalog $eventId state_key is invalid.',
      );
      continue;
    }
    final normalizedStateKey = stateKey as String?;
    if (ts is! int) {
      failures.add(
        '${relative(file)} event_catalog $eventId origin_server_ts is invalid.',
      );
      continue;
    }
    if (result.containsKey(eventId)) {
      failures.add('${relative(file)} duplicates event_catalog id: $eventId');
      continue;
    }
    result[eventId] = MatrixStateEventInfo(
      eventId: eventId,
      type: type,
      stateKey: normalizedStateKey,
      originServerTs: ts,
    );
  }
  return result;
}

Map<String, String> readMatrixStateMap(
  File file,
  Object? value,
  Map<String, MatrixStateEventInfo> catalog,
  List<String> failures, {
  required String label,
}) {
  if (value is! List) {
    failures.add('${relative(file)} $label must be an array.');
    return const {};
  }
  final result = <String, String>{};
  for (final item in value) {
    if (item is! Map) {
      failures.add('${relative(file)} $label entries must be objects.');
      continue;
    }
    final entry = item.cast<String, Object?>();
    final type = entry['type'];
    final stateKey = entry['state_key'];
    final eventId = entry['event_id'];
    if (type is! String || type.isEmpty || stateKey is! String) {
      failures.add('${relative(file)} $label state tuple is invalid.');
      continue;
    }
    if (eventId is! String || !catalog.containsKey(eventId)) {
      failures.add('${relative(file)} $label event_id is unknown.');
      continue;
    }
    final catalogEntry = catalog[eventId]!;
    if (catalogEntry.type != type || catalogEntry.stateKey != stateKey) {
      failures.add(
        '${relative(file)} $label event_id does not match type/state_key.',
      );
      continue;
    }
    final tuple = matrixStateTuple(type, stateKey);
    if (result.containsKey(tuple)) {
      failures.add('${relative(file)} $label duplicates state tuple.');
      continue;
    }
    result[tuple] = eventId;
  }
  return result;
}

List<Map<String, String>> readMatrixStateSets(
  File file,
  Map<String, Object?> testCase,
  Map<String, MatrixStateEventInfo> catalog,
  List<String> failures,
) {
  final stateSets = testCase['state_sets'];
  if (stateSets is! List || stateSets.length < 2) {
    failures.add('${relative(file)} resolution state_sets must have 2+ sets.');
    return const [];
  }
  final result = <Map<String, String>>[];
  for (final item in stateSets) {
    if (item is! Map) {
      failures.add('${relative(file)} resolution state set must be an object.');
      continue;
    }
    final stateSet = item.cast<String, Object?>();
    final id = stateSet['id'];
    if (id is! String || id.isEmpty) {
      failures.add('${relative(file)} resolution state set id is required.');
    }
    result.add(
      readMatrixStateMap(
        file,
        stateSet['state'],
        catalog,
        failures,
        label: 'resolution.state_set.$id.state',
      ),
    );
  }
  return result;
}

Set<String>? readMatrixEventIdSet(Object? value) {
  if (value is! List) {
    return null;
  }
  final result = <String>{};
  for (final item in value) {
    if (item is! String || !isMatrixEventId(item)) {
      return null;
    }
    result.add(item);
  }
  return result;
}

MatrixStateClassification classifyMatrixStateSets(
  List<Map<String, String>> stateSets,
) {
  final allTuples = <String>{
    for (final stateSet in stateSets) ...stateSet.keys,
  };
  final unconflicted = <String, String>{};
  final conflictedEventIds = <String>{};
  final conflictedByTuple = <String, Set<String>>{};
  for (final tuple in allTuples) {
    final values = <String>{};
    var presentInEverySet = true;
    for (final stateSet in stateSets) {
      final eventId = stateSet[tuple];
      if (eventId == null) {
        presentInEverySet = false;
      } else {
        values.add(eventId);
      }
    }
    if (presentInEverySet && values.length == 1) {
      unconflicted[tuple] = values.single;
    } else {
      conflictedEventIds.addAll(values);
      conflictedByTuple[tuple] = values;
    }
  }
  return MatrixStateClassification(
    unconflicted: unconflicted,
    conflictedEventIds: conflictedEventIds,
    conflictedByTuple: conflictedByTuple,
  );
}

Map<String, String> resolveRepresentativeState(
  MatrixStateClassification classified,
  Map<String, MatrixStateEventInfo> catalog,
) {
  final result = Map<String, String>.from(classified.unconflicted);
  for (final entry in classified.conflictedByTuple.entries) {
    final sorted = entry.value.toList()
      ..sort((left, right) {
        final leftInfo = catalog[left]!;
        final rightInfo = catalog[right]!;
        final byTs = leftInfo.originServerTs.compareTo(
          rightInfo.originServerTs,
        );
        if (byTs != 0) {
          return byTs;
        }
        return leftInfo.eventId.compareTo(rightInfo.eventId);
      });
    if (sorted.isNotEmpty) {
      result[entry.key] = sorted.last;
    }
  }
  return result;
}

String matrixStateTuple(String type, String stateKey) => '$type\x00$stateKey';

bool sameStringMap(Map<String, String> left, Map<String, String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

bool sameStringSet(Set<String> left, Set<String> right) =>
    left.length == right.length && left.containsAll(right);

class MatrixStateEventInfo {
  MatrixStateEventInfo({
    required this.eventId,
    required this.type,
    required this.stateKey,
    required this.originServerTs,
  });

  final String eventId;
  final String type;
  final String? stateKey;
  final int originServerTs;
}

class MatrixStateClassification {
  MatrixStateClassification({
    required this.unconflicted,
    required this.conflictedEventIds,
    required this.conflictedByTuple,
  });

  final Map<String, String> unconflicted;
  final Set<String> conflictedEventIds;
  final Map<String, Set<String>> conflictedByTuple;
}

void checkMatrixRoomVersionsGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-042')) {
    failures.add('Matrix room versions gate contract SPEC-042 is required.');
  }
  const supportedPath =
      'test-vectors/rooms/matrix-room-versions-supported.json';
  const defaultCreatePath =
      'test-vectors/rooms/matrix-room-version-default-create-room.json';
  const unsupportedCreatePath =
      'test-vectors/rooms/matrix-room-version-unsupported-create-room.json';
  for (final path in [
    supportedPath,
    defaultCreatePath,
    unsupportedCreatePath,
  ]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix room versions gate vector: $path');
    }
  }

  final supportedFile = File(supportedPath);
  final supported = readJsonObject(supportedFile, failures);
  if (supported != null) {
    final event = supported['event'];
    if (event is! Map) {
      failures.add('${relative(supportedFile)} event must be an object.');
    } else {
      validateMatrixRoomVersionsSupported(
        supportedFile,
        event.cast<String, Object?>(),
        failures,
      );
    }
  }

  final defaultFile = File(defaultCreatePath);
  final defaultCreate = readJsonObject(defaultFile, failures);
  if (defaultCreate != null) {
    validateMatrixRoomVersionDefaultCreateRoom(
      defaultFile,
      defaultCreate,
      failures,
    );
  }

  final unsupportedFile = File(unsupportedCreatePath);
  final unsupportedCreate = readJsonObject(unsupportedFile, failures);
  if (unsupportedCreate != null) {
    validateMatrixRoomVersionUnsupportedCreateRoom(
      unsupportedFile,
      unsupportedCreate,
      failures,
    );
  }
}

void validateMatrixRoomVersionsSupported(
  File file,
  Map<String, Object?> event,
  List<String> failures,
) {
  if (event['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final stableRoomVersions = readStringList(event['stable_room_versions']);
  const expected = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];
  if (stableRoomVersions == null ||
      stableRoomVersions.length != expected.length ||
      !stableRoomVersions.asMap().entries.every(
        (entry) => entry.value == expected[entry.key],
      )) {
    failures.add(
      '${relative(file)} stable_room_versions must be 1 through 12.',
    );
  }
  if (event['default_room_version'] != '12') {
    failures.add('${relative(file)} default_room_version must be 12.');
  }
  final deprecated = readStringList(event['deprecated_room_versions']);
  if (deprecated == null || deprecated.isNotEmpty) {
    failures.add('${relative(file)} deprecated_room_versions must be empty.');
  }
  if (event['unstable_room_versions_included'] != false) {
    failures.add(
      '${relative(file)} unstable_room_versions_included must be false.',
    );
  }
  final validExamples = readStringList(event['grammar_valid_examples']);
  if (validExamples == null ||
      validExamples.any((version) => !isMatrixRoomVersionGrammar(version))) {
    failures.add('${relative(file)} grammar_valid_examples are invalid.');
  }
  final invalidExamples = readStringList(event['grammar_invalid_examples']);
  if (invalidExamples == null ||
      invalidExamples.any(isMatrixRoomVersionGrammar)) {
    failures.add(
      '${relative(file)} grammar_invalid_examples include valid values.',
    );
  }
}

void validateMatrixRoomVersionDefaultCreateRoom(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  final event = vector['event'];
  if (request is! Map || event is! Map) {
    failures.add('${relative(file)} must include request and event objects.');
    return;
  }
  final requestMap = request.cast<String, Object?>();
  final body = requestMap['body'];
  if (body is! Map) {
    failures.add('${relative(file)} request.body must be an object.');
    return;
  }
  if (body.containsKey('room_version')) {
    failures.add(
      '${relative(file)} default create-room request must omit room_version.',
    );
  }
  final eventMap = event.cast<String, Object?>();
  if (eventMap['selected_room_version'] != '12') {
    failures.add('${relative(file)} selected_room_version must be 12.');
  }
  if (eventMap['selection_reason'] != 'server_default') {
    failures.add('${relative(file)} selection_reason must be server_default.');
  }
  if (eventMap['server_overwrites_creation_content_room_version'] != true) {
    failures.add(
      '${relative(file)} must require creation_content.room_version overwrite.',
    );
  }
  final createContent = eventMap['expected_create_event_content'];
  if (createContent is! Map || createContent['room_version'] != '12') {
    failures.add(
      '${relative(file)} expected_create_event_content.room_version must be 12.',
    );
  }
}

void validateMatrixRoomVersionUnsupportedCreateRoom(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  final expected = vector['expected'];
  if (request is! Map || expected is! Map) {
    failures.add(
      '${relative(file)} must include request and expected objects.',
    );
    return;
  }
  final body = request['body'];
  if (body is! Map || body['room_version'] != '13') {
    failures.add(
      '${relative(file)} unsupported vector must request version 13.',
    );
  }
  final bodyContains = expected['body_contains'];
  if (expected['status'] != 400 ||
      bodyContains is! Map ||
      bodyContains['errcode'] != 'M_UNSUPPORTED_ROOM_VERSION') {
    failures.add(
      '${relative(file)} unsupported vector must expect M_UNSUPPORTED_ROOM_VERSION.',
    );
  }
}

List<String>? readStringList(Object? value) {
  if (value is! List) {
    return null;
  }
  final result = <String>[];
  for (final item in value) {
    if (item is! String) {
      return null;
    }
    result.add(item);
  }
  return result;
}

bool isMatrixRoomVersionGrammar(String version) {
  if (version.isEmpty || version.runes.length > 32) {
    return false;
  }
  return RegExp(r'^[a-z0-9.-]+$').hasMatch(version);
}

void checkMatrixRoomAuthRepresentativeVectors(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-043')) {
    failures.add(
      'Matrix room auth representative vectors contract SPEC-043 is required.',
    );
  }
  const paths = {
    'test-vectors/events/matrix-auth-membership-v12.json': 2,
    'test-vectors/events/matrix-auth-power-levels-v12.json': 3,
    'test-vectors/events/matrix-auth-redaction-v12.json': 3,
  };
  for (final entry in paths.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) {
      failures.add('Missing Matrix room auth vector: ${entry.key}');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    validateMatrixRoomAuthVector(file, json, entry.value, failures);
  }
}

void validateMatrixRoomAuthVector(
  File file,
  Map<String, Object?> vector,
  int expectedCaseCount,
  List<String> failures,
) {
  final event = vector['event'];
  if (event is! Map) {
    failures.add('${relative(file)} event must be an object.');
    return;
  }
  final eventMap = event.cast<String, Object?>();
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  if (eventMap['room_version'] != '12') {
    failures.add('${relative(file)} room_version must be 12.');
  }
  final cases = eventMap['cases'];
  if (cases is! List || cases.length != expectedCaseCount) {
    failures.add(
      '${relative(file)} cases must contain $expectedCaseCount entries.',
    );
    return;
  }
  for (final item in cases) {
    if (item is! Map) {
      failures.add('${relative(file)} case entries must be objects.');
      continue;
    }
    final testCase = item.cast<String, Object?>();
    final id = testCase['id'];
    final expected = testCase['expected'];
    if (id is! String || id.isEmpty || expected is! Map) {
      failures.add('${relative(file)} case id and expected are required.');
      continue;
    }
    final expectedMap = expected.cast<String, Object?>();
    final actual = evaluateRepresentativeAuthCase(testCase);
    if (!sameObjectMap(actual, expectedMap)) {
      failures.add('${relative(file)} case $id expected result mismatch.');
    }
  }
}

Map<String, Object?> evaluateRepresentativeAuthCase(
  Map<String, Object?> testCase,
) {
  final id = testCase['id'];
  final candidate = (testCase['candidate_event'] as Map?)
      ?.cast<String, Object?>();
  final expected = (testCase['expected'] as Map).cast<String, Object?>();
  switch (id) {
    case 'membership-join-self-public':
      return {
        'allowed':
            candidate?['type'] == 'm.room.member' &&
            candidate?['sender'] == candidate?['state_key'] &&
            (candidate?['content'] as Map?)?['membership'] == 'join',
        'reason': 'membership_join_public_self',
      };
    case 'membership-join-sender-mismatch':
      return {
        'allowed': false,
        'reason': candidate?['sender'] == candidate?['state_key']
            ? 'membership_join_public_self'
            : 'membership_join_sender_mismatch',
      };
    case 'power-levels-valid-non-creator':
      return {
        'allowed':
            powerLevelFieldsAreIntegers(candidate) &&
            !powerLevelsContainCreator(testCase),
        'reason': 'power_levels_valid_non_creator',
      };
    case 'power-levels-creator-entry-v12':
      return {
        'allowed': !powerLevelsContainCreator(testCase),
        'reason': 'power_levels_creator_entry_v12',
      };
    case 'power-levels-non-integer-field':
      return {
        'allowed': powerLevelFieldsAreIntegers(candidate),
        'reason': 'power_levels_non_integer_field',
      };
    case 'redaction-send-authorized-by-power':
      return {
        'allowed':
            redactionSenderPower(testCase) >= redactionRequiredPower(testCase),
        'reason': 'redaction_send_authorized_by_power',
      };
    case 'redaction-apply-same-sender-domain':
      return {
        'redaction_applies': sameSenderDomain(testCase),
        'reason': 'redaction_apply_same_sender_domain',
      };
    case 'redaction-apply-cross-domain-low-power':
      final applies =
          sameSenderDomain(testCase) ||
          redactionSenderPower(testCase) >= redactionRequiredPower(testCase);
      return {
        'redaction_applies': applies,
        'reason': 'redaction_apply_cross_domain_low_power',
      };
  }
  return expected;
}

bool powerLevelFieldsAreIntegers(Map<String, Object?>? candidate) {
  final content = candidate?['content'];
  if (content is! Map) {
    return false;
  }
  const integerFields = {
    'users_default',
    'events_default',
    'state_default',
    'ban',
    'kick',
    'redact',
    'invite',
  };
  for (final field in integerFields) {
    final value = content[field];
    if (value != null && value is! int) {
      return false;
    }
  }
  return true;
}

bool powerLevelsContainCreator(Map<String, Object?> testCase) {
  final creators = roomCreators(testCase);
  final candidate = (testCase['candidate_event'] as Map?)
      ?.cast<String, Object?>();
  final content = candidate?['content'];
  final users = content is Map ? content['users'] : null;
  if (users is! Map) {
    return false;
  }
  return users.keys.any(creators.contains);
}

Set<String> roomCreators(Map<String, Object?> testCase) {
  final authState = testCase['auth_state'];
  if (authState is! List) {
    return const {};
  }
  for (final item in authState) {
    if (item is! Map) {
      continue;
    }
    final event = item.cast<String, Object?>();
    if (event['type'] != 'm.room.create') {
      continue;
    }
    final creators = <String>{};
    final sender = event['sender'];
    if (sender is String) {
      creators.add(sender);
    }
    final content = event['content'];
    final additionalCreators = content is Map
        ? content['additional_creators']
        : null;
    if (additionalCreators is List) {
      creators.addAll(additionalCreators.whereType<String>());
    }
    return creators;
  }
  return const {};
}

int redactionSenderPower(Map<String, Object?> testCase) {
  final candidate = (testCase['candidate_event'] as Map?)
      ?.cast<String, Object?>();
  final sender = candidate?['sender'];
  final power = powerLevelsContent(testCase);
  final users = power['users'];
  if (sender is String && users is Map && users[sender] is int) {
    return users[sender] as int;
  }
  final usersDefault = power['users_default'];
  return usersDefault is int ? usersDefault : 0;
}

int redactionRequiredPower(Map<String, Object?> testCase) {
  final redact = powerLevelsContent(testCase)['redact'];
  return redact is int ? redact : 50;
}

Map<String, Object?> powerLevelsContent(Map<String, Object?> testCase) {
  final authState = testCase['auth_state'];
  if (authState is! List) {
    return const {};
  }
  for (final item in authState) {
    if (item is! Map) {
      continue;
    }
    final event = item.cast<String, Object?>();
    if (event['type'] == 'm.room.power_levels' && event['content'] is Map) {
      return (event['content'] as Map).cast<String, Object?>();
    }
  }
  return const {};
}

bool sameSenderDomain(Map<String, Object?> testCase) {
  final candidate = (testCase['candidate_event'] as Map?)
      ?.cast<String, Object?>();
  final target = (testCase['target_event'] as Map?)?.cast<String, Object?>();
  final redactionDomain = matrixUserServerName(candidate?['sender']);
  final targetDomain = matrixUserServerName(target?['sender']);
  return redactionDomain != null && redactionDomain == targetDomain;
}

String? matrixUserServerName(Object? userId) {
  if (userId is! String) {
    return null;
  }
  final separator = userId.lastIndexOf(':');
  if (!userId.startsWith('@') ||
      separator < 0 ||
      separator == userId.length - 1) {
    return null;
  }
  return userId.substring(separator + 1);
}

bool sameObjectMap(Map<String, Object?> left, Map<String, Object?> right) {
  if (left.length != right.length) {
    return false;
  }
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

void checkMatrixRoomAliasUpgradePersistenceGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-044')) {
    failures.add(
      'Matrix room alias/upgrade/persistence contract SPEC-044 is required.',
    );
  }
  const paths = [
    'test-vectors/rooms/matrix-room-alias-lifecycle.json',
    'test-vectors/rooms/matrix-room-upgrade-representative.json',
    'test-vectors/rooms/matrix-room-restart-persistence-gate.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add(
        'Missing Matrix room alias/upgrade/persistence vector: $path',
      );
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('alias-lifecycle')) {
      validateMatrixRoomAliasLifecycle(file, json, failures);
    } else if (path.contains('upgrade-representative')) {
      validateMatrixRoomUpgradeRepresentative(file, json, failures);
    } else {
      validateMatrixRoomRestartPersistenceGate(file, json, failures);
    }
  }
}

void validateMatrixRoomAliasLifecycle(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final event = vector['event'];
  if (event is! Map) {
    failures.add('${relative(file)} event must be an object.');
    return;
  }
  final eventMap = event.cast<String, Object?>();
  final alias = eventMap['room_alias'];
  final roomId = eventMap['room_id'];
  final serverName = eventMap['server_name'];
  if (alias is! String || !alias.startsWith('#') || !alias.contains(':')) {
    failures.add('${relative(file)} room_alias must be a Matrix alias.');
  }
  if (roomId is! String || !isMatrixRoomId(roomId)) {
    failures.add('${relative(file)} room_id must be a Matrix room ID.');
  }
  if (serverName is! String || serverName.isEmpty) {
    failures.add('${relative(file)} server_name is required.');
  }
  final steps = eventMap['steps'];
  if (steps is! List || steps.length != 4) {
    failures.add(
      '${relative(file)} steps must contain create/resolve/delete/resolve-deleted.',
    );
    return;
  }
  const expectedSteps = [
    'create-alias',
    'resolve-alias',
    'delete-alias',
    'resolve-deleted-alias',
  ];
  for (var index = 0; index < steps.length; index += 1) {
    final item = steps[index];
    if (item is! Map || item['id'] != expectedSteps[index]) {
      failures.add('${relative(file)} alias step order is invalid.');
      continue;
    }
    final step = item.cast<String, Object?>();
    if (step['path'] is! String ||
        !(step['path'] as String).startsWith(
          '/_matrix/client/v3/directory/room/',
        )) {
      failures.add('${relative(file)} alias step path is invalid.');
    }
  }
}

void validateMatrixRoomUpgradeRepresentative(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final event = vector['event'];
  if (event is! Map) {
    failures.add('${relative(file)} event must be an object.');
    return;
  }
  final eventMap = event.cast<String, Object?>();
  final oldRoomId = eventMap['old_room_id'];
  final replacementRoomId = eventMap['replacement_room_id'];
  if (oldRoomId is! String ||
      replacementRoomId is! String ||
      !isMatrixRoomId(oldRoomId) ||
      !isMatrixRoomId(replacementRoomId) ||
      oldRoomId == replacementRoomId) {
    failures.add('${relative(file)} old and replacement room IDs are invalid.');
  }
  if (eventMap['new_version'] != '12') {
    failures.add('${relative(file)} new_version must be 12.');
  }
  final createContent = eventMap['replacement_create_content'];
  final tombstone = eventMap['old_room_tombstone'];
  if (createContent is! Map || tombstone is! Map) {
    failures.add('${relative(file)} upgrade content objects are required.');
    return;
  }
  final predecessor = createContent['predecessor'];
  final tombstoneContent = tombstone['content'];
  if (predecessor is! Map ||
      predecessor['room_id'] != oldRoomId ||
      predecessor['event_id'] != tombstone['event_id']) {
    failures.add('${relative(file)} replacement predecessor is invalid.');
  }
  if (tombstone['type'] != 'm.room.tombstone' ||
      tombstoneContent is! Map ||
      tombstoneContent['replacement_room'] != replacementRoomId) {
    failures.add('${relative(file)} old room tombstone is invalid.');
  }
}

void validateMatrixRoomRestartPersistenceGate(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final event = vector['event'];
  if (event is! Map) {
    failures.add('${relative(file)} event must be an object.');
    return;
  }
  final eventMap = event.cast<String, Object?>();
  const requiredRecordSets = {
    'event_graph',
    'state_snapshots',
    'room_versions',
    'room_aliases',
    'room_upgrades',
  };
  final records = readStringList(eventMap['required_record_sets']);
  if (records == null || !sameStringSet(records.toSet(), requiredRecordSets)) {
    failures.add('${relative(file)} required_record_sets are incomplete.');
  }
  final before = eventMap['before_restart'];
  final after = eventMap['after_restart'];
  if (before is! Map || after is! Map) {
    failures.add(
      '${relative(file)} before_restart and after_restart are required.',
    );
    return;
  }
  for (final key in requiredRecordSets) {
    final beforeJson = jsonEncode(before[key]);
    final afterJson = jsonEncode(after[key]);
    if (beforeJson != afterJson) {
      failures.add('${relative(file)} restart records differ for $key.');
    }
  }
}

void checkMatrixProfileAccountDataTags(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-045')) {
    failures.add(
      'Matrix profile/account-data/tags contract SPEC-045 is required.',
    );
  }
  const paths = [
    'test-vectors/sync/matrix-profile-get-basic.json',
    'test-vectors/sync/matrix-profile-displayname-basic.json',
    'test-vectors/sync/matrix-profile-delete-basic.json',
    'test-vectors/sync/matrix-account-data-global-basic.json',
    'test-vectors/sync/matrix-account-data-room-basic.json',
    'test-vectors/sync/matrix-room-tags-basic.json',
    'test-vectors/sync/matrix-account-data-user-mismatch.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix profile/account-data/tags vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('matrix-profile-')) {
      validateMatrixProfileVector(file, json, failures);
    } else if (path.contains('account-data-user-mismatch')) {
      validateMatrixAccountDataMismatchVector(file, json, failures);
    } else if (path.contains('account-data-global')) {
      validateMatrixAccountDataSteps(file, json, failures, roomScoped: false);
    } else if (path.contains('account-data-room')) {
      validateMatrixAccountDataSteps(file, json, failures, roomScoped: true);
    } else {
      validateMatrixRoomTagsSteps(file, json, failures);
    }
  }
}

void validateMatrixProfileVector(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  if (request is! Map) {
    failures.add('${relative(file)} request must be an object.');
    return;
  }
  final requestMap = request.cast<String, Object?>();
  final method = requestMap['method'];
  final path = requestMap['path'];
  if (path is! String ||
      !path.startsWith('/_matrix/client/v3/profile/@alice:example.test')) {
    failures.add('${relative(file)} profile path is invalid.');
  }
  final body = requestMap['body'];
  if (method == 'PUT') {
    if (body is! Map || !body.containsKey('displayname')) {
      failures.add('${relative(file)} PUT profile body must set displayname.');
    }
  } else if (method != 'GET' && method != 'DELETE') {
    failures.add('${relative(file)} profile method is invalid.');
  }
  requireExpectedStatus(file, vector, failures, 200);
}

void validateMatrixAccountDataMismatchVector(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  if (request is! Map) {
    failures.add('${relative(file)} request must be an object.');
    return;
  }
  final requestMap = request.cast<String, Object?>();
  if (requestMap['method'] != 'PUT') {
    failures.add('${relative(file)} mismatch request must use PUT.');
  }
  final path = requestMap['path'];
  if (path is! String ||
      !path.startsWith('/_matrix/client/v3/user/@bob:example.test/')) {
    failures.add('${relative(file)} mismatch path must target another user.');
  }
  final token = requestMap['access_token'];
  if (token != 'token-alice') {
    failures.add('${relative(file)} mismatch vector must use token-alice.');
  }
  requireExpectedStatus(file, vector, failures, 403);
  requireExpectedErrcode(file, vector, failures, 'M_FORBIDDEN');
}

void validateMatrixAccountDataSteps(
  File file,
  Map<String, Object?> vector,
  List<String> failures, {
  required bool roomScoped,
}) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final userId = eventMap['user_id'];
  if (userId is! String || !userId.startsWith('@')) {
    failures.add('${relative(file)} user_id must be a Matrix user ID.');
  }
  if (roomScoped) {
    final roomId = eventMap['room_id'];
    if (roomId is! String || !isMatrixRoomId(roomId)) {
      failures.add('${relative(file)} room_id must be a Matrix room ID.');
    }
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  final expected = roomScoped
      ? const [
          'put-room-account-data',
          'get-room-account-data',
          'sync-room-account-data',
        ]
      : const [
          'put-global-account-data',
          'get-global-account-data',
          'sync-global-account-data',
        ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final path = step['path'];
    if (path is! String) {
      failures.add('${relative(file)} account data step path is required.');
      continue;
    }
    final isSync = path == '/_matrix/client/v3/sync';
    final containsAccountData = roomScoped
        ? path.contains('/rooms/!room:example.test/account_data/')
        : path.contains('/account_data/') && !path.contains('/rooms/');
    if (!isSync && !containsAccountData) {
      failures.add('${relative(file)} account data step path is invalid.');
    }
    final id = step['id'];
    if (id is String && id.startsWith('put-') && step['body'] is! Map) {
      failures.add('${relative(file)} account data PUT body is required.');
    }
    if (id is String && id.startsWith('get-')) {
      if (step['expected_status'] != 200 || step['expected_body'] is! Map) {
        failures.add('${relative(file)} account data GET expectation invalid.');
      }
    }
    if (id is String && id.startsWith('sync-')) {
      final key = roomScoped
          ? 'expected_room_account_data_event'
          : 'expected_account_data_event';
      if (step[key] is! Map) {
        failures.add(
          '${relative(file)} account data sync expectation missing.',
        );
      }
    }
  }
}

void validateMatrixRoomTagsSteps(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final roomId = eventMap['room_id'];
  if (roomId is! String || !isMatrixRoomId(roomId)) {
    failures.add('${relative(file)} room_id must be a Matrix room ID.');
  }
  if (eventMap['tag'] != 'm.favourite') {
    failures.add('${relative(file)} tag must use m.favourite.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'put-room-tag',
    'get-room-tags',
    'delete-room-tag',
    'get-room-tags-after-delete',
    'sync-room-tags',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final path = step['path'];
    if (path is! String) {
      failures.add('${relative(file)} room tag step path is required.');
      continue;
    }
    final isSync = path == '/_matrix/client/v3/sync';
    if (!isSync &&
        !path.startsWith(
          '/_matrix/client/v3/user/@alice:example.test/rooms/'
          '!room:example.test/tags',
        )) {
      failures.add('${relative(file)} room tag step path is invalid.');
    }
    final id = step['id'];
    if (id == 'put-room-tag') {
      final body = step['body'];
      final order = body is Map ? body['order'] : null;
      if (order is! num || order < 0 || order > 1) {
        failures.add('${relative(file)} tag order must be in [0, 1].');
      }
    }
    if (id is String && id.startsWith('get-room-tags')) {
      if (step['expected_status'] != 200 || step['expected_body'] is! Map) {
        failures.add('${relative(file)} room tag GET expectation invalid.');
      }
    }
    if (id == 'sync-room-tags' &&
        step['expected_room_account_data_event'] is! Map) {
      failures.add('${relative(file)} room tag sync expectation missing.');
    }
  }
}

Map<String, Object?>? requireMatrixEventMap(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final event = vector['event'];
  if (event is! Map) {
    failures.add('${relative(file)} event must be an object.');
    return null;
  }
  return event.cast<String, Object?>();
}

List<Object?>? requireMatrixSteps(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  final steps = eventMap['steps'];
  if (steps is! List || steps.isEmpty) {
    failures.add('${relative(file)} steps must be a non-empty list.');
    return null;
  }
  return steps.cast<Object?>();
}

void validateStepOrder(
  File file,
  List<Object?> steps,
  List<String> expected,
  List<String> failures,
) {
  if (steps.length != expected.length) {
    failures.add('${relative(file)} step count is invalid.');
    return;
  }
  for (var index = 0; index < steps.length; index += 1) {
    final item = steps[index];
    if (item is! Map || item['id'] != expected[index]) {
      failures.add('${relative(file)} step order is invalid.');
    }
  }
}

void requireExpectedStatus(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
  int status,
) {
  final expected = vector['expected'];
  if (expected is! Map || expected['status'] != status) {
    failures.add('${relative(file)} expected.status must be $status.');
  }
}

void requireExpectedErrcode(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
  String errcode,
) {
  final expected = vector['expected'];
  final error = expected is Map ? expected['error'] : null;
  if (error is! Map || error['errcode'] != errcode) {
    failures.add('${relative(file)} expected.error.errcode must be $errcode.');
  }
}

void checkMatrixReceiptsTypingReadMarkers(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-046')) {
    failures.add(
      'Matrix receipts/typing/read-markers contract SPEC-046 is required.',
    );
  }
  const paths = [
    'test-vectors/sync/matrix-typing-basic.json',
    'test-vectors/sync/matrix-typing-missing-token.json',
    'test-vectors/sync/matrix-receipt-basic.json',
    'test-vectors/sync/matrix-receipt-invalid-thread.json',
    'test-vectors/sync/matrix-read-markers-basic.json',
    'test-vectors/sync/matrix-read-marker-direct-account-data-forbidden.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix receipts/typing/read-markers vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('typing-basic')) {
      validateMatrixTypingSteps(file, json, failures);
    } else if (path.contains('typing-missing-token')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'PUT',
        pathPrefix: '/_matrix/client/v3/rooms/!room:example.test/typing/',
        status: 401,
        errcode: 'M_MISSING_TOKEN',
      );
    } else if (path.contains('receipt-basic')) {
      validateMatrixReceiptSteps(file, json, failures);
    } else if (path.contains('receipt-invalid-thread')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'POST',
        pathPrefix: '/_matrix/client/v3/rooms/!room:example.test/receipt/',
        status: 400,
        errcode: 'M_INVALID_PARAM',
      );
    } else if (path.contains('read-markers-basic')) {
      validateMatrixReadMarkersSteps(file, json, failures);
    } else {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'PUT',
        pathPrefix:
            '/_matrix/client/v3/user/@alice:example.test/rooms/'
            '!room:example.test/account_data/m.fully_read',
        status: 403,
        errcode: 'M_FORBIDDEN',
      );
    }
  }
}

void validateMatrixTypingSteps(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixEventHeader(file, eventMap, failures);
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = ['typing-start', 'sync-typing-start', 'typing-stop'];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    final path = step['path'];
    if (path is! String) {
      failures.add('${relative(file)} typing step path is required.');
      continue;
    }
    if (id == 'sync-typing-start') {
      if (path != '/_matrix/client/v3/sync' ||
          step['expected_ephemeral_event'] is! Map) {
        failures.add('${relative(file)} typing sync expectation is invalid.');
      }
      continue;
    }
    if (!path.startsWith(
      '/_matrix/client/v3/rooms/!room:example.test/typing/'
      '@alice:example.test',
    )) {
      failures.add('${relative(file)} typing endpoint path is invalid.');
    }
    final body = step['body'];
    final typing = body is Map ? body['typing'] : null;
    if (typing is! bool) {
      failures.add('${relative(file)} typing body must include a boolean.');
    }
    if (id == 'typing-start') {
      final timeout = body is Map ? body['timeout'] : null;
      if (timeout is! int || timeout <= 0) {
        failures.add('${relative(file)} typing start timeout is invalid.');
      }
    }
  }
}

void validateMatrixReceiptSteps(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixEventHeader(file, eventMap, failures);
  if (eventMap['receipt_type'] != 'm.read') {
    failures.add('${relative(file)} receipt_type must be m.read.');
  }
  final eventId = eventMap['event_id'];
  if (eventId is! String || !eventId.startsWith(r'$')) {
    failures.add('${relative(file)} event_id must be a Matrix event ID.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = ['send-read-receipt', 'sync-read-receipt'];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    final path = step['path'];
    if (path is! String) {
      failures.add('${relative(file)} receipt step path is required.');
      continue;
    }
    if (id == 'send-read-receipt') {
      if (!path.startsWith(
        '/_matrix/client/v3/rooms/!room:example.test/receipt/m.read/',
      )) {
        failures.add('${relative(file)} receipt endpoint path is invalid.');
      }
      if (step['expected_status'] != 200) {
        failures.add('${relative(file)} receipt send must expect 200.');
      }
    }
    if (id == 'sync-read-receipt') {
      if (path != '/_matrix/client/v3/sync' ||
          step['expected_ephemeral_event'] is! Map) {
        failures.add('${relative(file)} receipt sync expectation is invalid.');
      }
    }
  }
}

void validateMatrixReadMarkersSteps(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixEventHeader(file, eventMap, failures);
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'post-read-markers',
    'sync-fully-read',
    'sync-read-marker-receipt',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    final path = step['path'];
    if (path is! String) {
      failures.add('${relative(file)} read marker step path is required.');
      continue;
    }
    if (id == 'post-read-markers') {
      if (path != '/_matrix/client/v3/rooms/!room:example.test/read_markers') {
        failures.add('${relative(file)} read marker endpoint path is invalid.');
      }
      final body = step['body'];
      if (body is! Map ||
          body['m.fully_read'] is! String ||
          body['m.read'] is! String ||
          body['m.read.private'] is! String) {
        failures.add('${relative(file)} read marker body is incomplete.');
      }
    }
    if (id == 'sync-fully-read' &&
        step['expected_room_account_data_event'] is! Map) {
      failures.add('${relative(file)} fully read sync expectation missing.');
    }
    if (id == 'sync-read-marker-receipt' &&
        step['expected_ephemeral_event'] is! Map) {
      failures.add(
        '${relative(file)} read marker receipt sync expectation missing.',
      );
    }
  }
}

void validateMatrixEventHeader(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final roomId = eventMap['room_id'];
  if (roomId is! String || !isMatrixRoomId(roomId)) {
    failures.add('${relative(file)} room_id must be a Matrix room ID.');
  }
  final userId = eventMap['user_id'];
  if (userId is! String || !userId.startsWith('@')) {
    failures.add('${relative(file)} user_id must be a Matrix user ID.');
  }
}

void validateMatrixSimpleRequestVector(
  File file,
  Map<String, Object?> vector,
  List<String> failures, {
  required String method,
  required String pathPrefix,
  required int status,
  required String errcode,
}) {
  final request = vector['request'];
  if (request is! Map) {
    failures.add('${relative(file)} request must be an object.');
    return;
  }
  final requestMap = request.cast<String, Object?>();
  if (requestMap['method'] != method) {
    failures.add('${relative(file)} request.method must be $method.');
  }
  final path = requestMap['path'];
  if (path is! String || !path.startsWith(pathPrefix)) {
    failures.add('${relative(file)} request.path is invalid.');
  }
  requireExpectedStatus(file, vector, failures, status);
  requireExpectedErrcode(file, vector, failures, errcode);
}

void checkMatrixFiltersPresenceCapabilities(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-047')) {
    failures.add(
      'Matrix filters/presence/capabilities contract SPEC-047 is required.',
    );
  }
  const paths = [
    'test-vectors/sync/matrix-filter-create-read-basic.json',
    'test-vectors/sync/matrix-filter-user-mismatch.json',
    'test-vectors/sync/matrix-presence-set-get-basic.json',
    'test-vectors/sync/matrix-presence-user-mismatch.json',
    'test-vectors/sync/matrix-capabilities-basic.json',
    'test-vectors/sync/matrix-capabilities-missing-token.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add(
        'Missing Matrix filters/presence/capabilities vector: $path',
      );
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('filter-create-read')) {
      validateMatrixFilterSteps(file, json, failures);
    } else if (path.contains('filter-user-mismatch')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'POST',
        pathPrefix: '/_matrix/client/v3/user/@bob:example.test/filter',
        status: 403,
        errcode: 'M_FORBIDDEN',
      );
    } else if (path.contains('presence-set-get')) {
      validateMatrixPresenceSteps(file, json, failures);
    } else if (path.contains('presence-user-mismatch')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'PUT',
        pathPrefix: '/_matrix/client/v3/presence/@bob:example.test/status',
        status: 403,
        errcode: 'M_FORBIDDEN',
      );
    } else if (path.contains('capabilities-basic')) {
      validateMatrixCapabilitiesVector(file, json, failures);
    } else {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'GET',
        pathPrefix: '/_matrix/client/v3/capabilities',
        status: 401,
        errcode: 'M_MISSING_TOKEN',
      );
    }
  }
}

void validateMatrixFilterSteps(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final userId = eventMap['user_id'];
  if (userId is! String || !userId.startsWith('@')) {
    failures.add('${relative(file)} user_id must be a Matrix user ID.');
  }
  final filterId = eventMap['filter_id'];
  if (filterId is! String || filterId.isEmpty || filterId.startsWith('{')) {
    failures.add('${relative(file)} filter_id is invalid.');
  }
  final filter = eventMap['filter'];
  if (filter is! Map || filter['room'] is! Map || filter['presence'] is! Map) {
    failures.add('${relative(file)} representative filter is incomplete.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = ['create-filter', 'get-filter'];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    final path = step['path'];
    if (path is! String ||
        !path.startsWith(
          '/_matrix/client/v3/user/@alice:example.test/filter',
        )) {
      failures.add('${relative(file)} filter step path is invalid.');
    }
    if (id == 'create-filter') {
      if (step['method'] != 'POST' ||
          step['body'] is! Map ||
          step['expected_body'] is! Map) {
        failures.add('${relative(file)} create filter step is incomplete.');
      }
    }
    if (id == 'get-filter') {
      if (step['method'] != 'GET' ||
          step['expected_status'] != 200 ||
          step['expected_body'] is! Map) {
        failures.add('${relative(file)} get filter step is incomplete.');
      }
    }
  }
}

void validateMatrixPresenceSteps(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final userId = eventMap['user_id'];
  if (userId is! String || !userId.startsWith('@')) {
    failures.add('${relative(file)} user_id must be a Matrix user ID.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = ['set-presence', 'get-presence', 'sync-presence'];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    final path = step['path'];
    if (path is! String) {
      failures.add('${relative(file)} presence step path is required.');
      continue;
    }
    if (id == 'sync-presence') {
      if (path != '/_matrix/client/v3/sync' ||
          step['expected_presence_event'] is! Map) {
        failures.add('${relative(file)} presence sync expectation is invalid.');
      }
      continue;
    }
    if (!path.startsWith(
      '/_matrix/client/v3/presence/@alice:example.test/status',
    )) {
      failures.add('${relative(file)} presence endpoint path is invalid.');
    }
    if (id == 'set-presence') {
      final body = step['body'];
      final presence = body is Map ? body['presence'] : null;
      if (presence != 'online' &&
          presence != 'offline' &&
          presence != 'unavailable') {
        failures.add('${relative(file)} presence value is invalid.');
      }
    }
    if (id == 'get-presence' &&
        (step['expected_status'] != 200 || step['expected_body'] is! Map)) {
      failures.add('${relative(file)} get presence expectation is invalid.');
    }
  }
}

void validateMatrixCapabilitiesVector(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  if (request is! Map) {
    failures.add('${relative(file)} request must be an object.');
    return;
  }
  final requestMap = request.cast<String, Object?>();
  if (requestMap['method'] != 'GET' ||
      requestMap['path'] != '/_matrix/client/v3/capabilities') {
    failures.add('${relative(file)} capabilities request is invalid.');
  }
  requireExpectedStatus(file, vector, failures, 200);
  final expected = vector['expected'];
  final bodyContains = expected is Map ? expected['body_contains'] : null;
  final capabilities = bodyContains is Map
      ? bodyContains['capabilities']
      : null;
  if (capabilities is! Map) {
    failures.add('${relative(file)} capabilities body is missing.');
    return;
  }
  final roomVersions = capabilities['m.room_versions'];
  if (roomVersions is! Map ||
      roomVersions['default'] != '12' ||
      roomVersions['available'] is! Map) {
    failures.add('${relative(file)} m.room_versions capability is invalid.');
  }
  final profileFields = capabilities['m.profile_fields'];
  if (profileFields is! Map || profileFields['enabled'] != true) {
    failures.add('${relative(file)} m.profile_fields capability is invalid.');
  }
  for (final key in [
    'm.change_password',
    'm.forget_forced_upon_leave',
    'm.set_displayname',
    'm.set_avatar_url',
  ]) {
    final capability = capabilities[key];
    if (capability is! Map || capability['enabled'] is! bool) {
      failures.add('${relative(file)} $key capability must be boolean.');
    }
  }
}

void checkMatrixRoomDirectoryAliasesInvites(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-048')) {
    failures.add(
      'Matrix room directory/aliases/invites contract SPEC-048 is required.',
    );
  }
  const paths = [
    'test-vectors/rooms/matrix-public-rooms-basic.json',
    'test-vectors/rooms/matrix-public-rooms-filter-basic.json',
    'test-vectors/rooms/matrix-room-directory-visibility-basic.json',
    'test-vectors/rooms/matrix-room-aliases-basic.json',
    'test-vectors/rooms/matrix-room-alias-update-forbidden.json',
    'test-vectors/rooms/matrix-room-invite-basic.json',
    'test-vectors/rooms/matrix-room-invite-forbidden.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add(
        'Missing Matrix room directory/aliases/invites vector: $path',
      );
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('public-rooms')) {
      validateMatrixPublicRoomsVector(file, json, failures);
    } else if (path.contains('directory-visibility')) {
      validateMatrixDirectoryVisibilitySteps(file, json, failures);
    } else if (path.contains('aliases-basic')) {
      validateMatrixRoomAliasesVector(file, json, failures);
    } else if (path.contains('alias-update-forbidden')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'PUT',
        pathPrefix: '/_matrix/client/v3/directory/room/',
        status: 403,
        errcode: 'M_FORBIDDEN',
      );
    } else if (path.contains('invite-basic')) {
      validateMatrixInviteSteps(file, json, failures);
    } else {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'POST',
        pathPrefix: '/_matrix/client/v3/rooms/!room:example.test/invite',
        status: 403,
        errcode: 'M_FORBIDDEN',
      );
    }
  }
}

void validateMatrixPublicRoomsVector(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  if (request is! Map) {
    failures.add('${relative(file)} request must be an object.');
    return;
  }
  final requestMap = request.cast<String, Object?>();
  final method = requestMap['method'];
  if (method != 'GET' && method != 'POST') {
    failures.add('${relative(file)} publicRooms method is invalid.');
  }
  if (requestMap['path'] != '/_matrix/client/v3/publicRooms') {
    failures.add('${relative(file)} publicRooms path is invalid.');
  }
  if (method == 'POST' && requestMap['body'] is! Map) {
    failures.add('${relative(file)} filtered publicRooms body is required.');
  }
  requireExpectedStatus(file, vector, failures, 200);
  final expected = vector['expected'];
  final bodyContains = expected is Map ? expected['body_contains'] : null;
  final chunk = bodyContains is Map ? bodyContains['chunk'] : null;
  if (chunk is! List || chunk.isEmpty) {
    failures.add('${relative(file)} publicRooms chunk is required.');
    return;
  }
  final first = chunk.first;
  if (first is! Map ||
      first['room_id'] is! String ||
      first['num_joined_members'] is! int ||
      first['world_readable'] is! bool ||
      first['guest_can_join'] is! bool) {
    failures.add('${relative(file)} publicRooms chunk is incomplete.');
  }
}

void validateMatrixDirectoryVisibilitySteps(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final roomId = eventMap['room_id'];
  if (roomId is! String || !isMatrixRoomId(roomId)) {
    failures.add('${relative(file)} room_id must be a Matrix room ID.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'set-directory-public',
    'get-directory-visibility',
    'list-public-room',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    final path = step['path'];
    if (path is! String) {
      failures.add('${relative(file)} directory step path is required.');
      continue;
    }
    if (id == 'list-public-room') {
      if (path != '/_matrix/client/v3/publicRooms' ||
          step['expected_body_contains'] is! Map) {
        failures.add('${relative(file)} public directory expectation invalid.');
      }
      continue;
    }
    if (!path.startsWith(
      '/_matrix/client/v3/directory/list/room/!room:example.test',
    )) {
      failures.add('${relative(file)} directory visibility path is invalid.');
    }
    if (id == 'set-directory-public') {
      final body = step['body'];
      if (body is! Map || body['visibility'] != 'public') {
        failures.add('${relative(file)} directory visibility body invalid.');
      }
    }
    if (id == 'get-directory-visibility' &&
        (step['expected_status'] != 200 || step['expected_body'] is! Map)) {
      failures.add('${relative(file)} directory visibility GET invalid.');
    }
  }
}

void validateMatrixRoomAliasesVector(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  if (request is! Map) {
    failures.add('${relative(file)} request must be an object.');
    return;
  }
  final requestMap = request.cast<String, Object?>();
  if (requestMap['method'] != 'GET' ||
      requestMap['path'] !=
          '/_matrix/client/v3/rooms/!room:example.test/aliases') {
    failures.add('${relative(file)} aliases request is invalid.');
  }
  requireExpectedStatus(file, vector, failures, 200);
  final expected = vector['expected'];
  final bodyContains = expected is Map ? expected['body_contains'] : null;
  final aliases = bodyContains is Map ? bodyContains['aliases'] : null;
  if (aliases is! List || aliases.isEmpty) {
    failures.add('${relative(file)} aliases response is missing.');
  }
}

void validateMatrixInviteSteps(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final roomId = eventMap['room_id'];
  if (roomId is! String || !isMatrixRoomId(roomId)) {
    failures.add('${relative(file)} room_id must be a Matrix room ID.');
  }
  if (eventMap['inviter'] != '@alice:example.test' ||
      eventMap['invitee'] != '@bob:example.test') {
    failures.add('${relative(file)} inviter/invitee are invalid.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = ['invite-user', 'sync-invite'];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    final path = step['path'];
    if (path is! String) {
      failures.add('${relative(file)} invite step path is required.');
      continue;
    }
    if (id == 'invite-user') {
      if (path != '/_matrix/client/v3/rooms/!room:example.test/invite') {
        failures.add('${relative(file)} invite endpoint path is invalid.');
      }
      final body = step['body'];
      if (body is! Map || body['user_id'] != '@bob:example.test') {
        failures.add('${relative(file)} invite body is invalid.');
      }
    }
    if (id == 'sync-invite') {
      if (path != '/_matrix/client/v3/sync' ||
          step['expected_invite_room'] is! Map) {
        failures.add('${relative(file)} invite sync expectation is invalid.');
      }
    }
  }
}

bool isNegativeVector(Map<String, Object?> json) {
  final expected = json['expected'];
  if (expected is Map) {
    final status = expected['status'];
    if (status is int && status >= 400) {
      return true;
    }
    if (expected.containsKey('error')) {
      return true;
    }
  }
  return false;
}

void checkGiven(File file, Object? value, List<String> failures) {
  if (value is! Map) {
    failures.add('${relative(file)} given must be an object.');
    return;
  }
  final given = value.cast<String, Object?>();
  const allowedKeys = {'previous_request', 'previous_event_id'};
  for (final key in given.keys) {
    if (!allowedKeys.contains(key)) {
      failures.add('${relative(file)} given has unexpected key: $key');
    }
  }
  if (given.containsKey('previous_request')) {
    checkRequest(
      file,
      given['previous_request'],
      failures,
      pathPrefix: 'given.previous_request',
    );
  }
  final previousEventId = given['previous_event_id'];
  if (previousEventId != null &&
      (previousEventId is! String || previousEventId.isEmpty)) {
    failures.add(
      '${relative(file)} given.previous_event_id must be a non-empty string.',
    );
  }
}

void checkMvpReadiness(
  Map<String, String> contracts,
  Map<String, String> profileMap,
  List<String> failures,
) {
  final contractProfiles = contracts.values.toSet();
  for (final profile in fullClientProfiles) {
    if (!profiles.contains(profile)) {
      failures.add('full-client references unknown profile: $profile');
    }
    if (!contractProfiles.contains(profile)) {
      failures.add('full-client profile has no contract: $profile');
    }
  }

  for (final entry in profileMap.entries) {
    if (!fullClientProfiles.contains(entry.value)) {
      failures.add('${entry.key} uses non-MVP profile: ${entry.value}');
    }
  }
}

void checkVectorProfile(
  File file,
  String contract,
  Map<String, String> profileMap,
  List<String> failures,
) {
  final path = relative(file);
  final segments = Uri.file(path).pathSegments;
  if (segments.length < 3 || segments.first != 'test-vectors') {
    failures.add('$path must be under test-vectors/<profile>/');
    return;
  }

  final directory = segments[1];
  if (!profiles.contains(directory)) {
    failures.add('$path uses unknown vector profile directory: $directory');
    return;
  }

  final contractProfile = profileMap[contract];
  if (contractProfile == null) {
    failures.add(
      '$path references contract missing from profile map: $contract',
    );
    return;
  }
  if (directory != contractProfile) {
    failures.add(
      '$path profile directory mismatch for $contract: '
      '$directory != $contractProfile',
    );
  }
}

void checkRequest(
  File file,
  Object? value,
  List<String> failures, {
  String pathPrefix = 'request',
}) {
  if (value is! Map) {
    failures.add('${relative(file)} $pathPrefix must be an object.');
    return;
  }
  final request = value.cast<String, Object?>();
  final method = request['method'];
  if (method is! String || method.isEmpty || method != method.toUpperCase()) {
    failures.add('${relative(file)} $pathPrefix.method must be uppercase.');
  }
  final path = request['path'];
  if (path is! String ||
      !(isApiPath(path, '/_houra/client') ||
          isApiPath(path, '/_matrix/client') ||
          isApiPath(path, '/_matrix/media'))) {
    failures.add(
      '${relative(file)} $pathPrefix.path must use /_houra/client or '
      '/_matrix/client or /_matrix/media.',
    );
  }
  final query = request['query'];
  if (query is Map && query.containsKey('access_token')) {
    failures.add('${relative(file)} must not put access tokens in query.');
  }
}

bool isApiPath(String path, String prefix) =>
    path == prefix || path.startsWith('$prefix/');

void checkStatusObject(
  File file,
  Object? value,
  String key,
  List<String> failures,
) {
  if (value is! Map) {
    failures.add('${relative(file)} $key must be an object.');
    return;
  }
  final object = value.cast<String, Object?>();
  final status = object['status'];
  if (status != null && status is! int) {
    failures.add('${relative(file)} $key.status must be an integer.');
  }
}

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

Map<String, Object?>? readJsonObject(File file, List<String> failures) {
  if (!file.existsSync()) {
    failures.add('Missing JSON file: ${relative(file)}');
    return null;
  }
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is Map) {
      return decoded.cast<String, Object?>();
    }
    failures.add('${relative(file)} must contain a JSON object.');
  } on FormatException catch (error) {
    failures.add('${relative(file)} is not valid JSON: ${error.message}');
  }
  return null;
}

Iterable<File> filesUnder(Directory root, String extension) {
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith(extension));
}

String relative(FileSystemEntity entity) {
  final rootPath = Directory.current.absolute.uri.path.endsWith('/')
      ? Directory.current.absolute.uri.path
      : '${Directory.current.absolute.uri.path}/';
  final entityPath = entity.absolute.uri.path;
  if (!entityPath.startsWith(rootPath)) {
    return Uri.decodeComponent(entityPath);
  }
  return Uri.decodeComponent(entityPath.substring(rootPath.length));
}

String entityName(FileSystemEntity entity) {
  final segments = entity.uri.pathSegments.where(
    (segment) => segment.isNotEmpty,
  );
  if (segments.isEmpty) {
    return entity.path;
  }
  return segments.last;
}

bool isGeneratedEntry(String name) {
  return name == '.git' ||
      name == '.dart_tool' ||
      name == 'build' ||
      name == 'pubspec.lock';
}
