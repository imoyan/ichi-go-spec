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
  'Application Service API',
  'Client-Server API',
  'Client-Server API; Room Versions',
  'Identity Service API',
  'Push Gateway API',
  'Server-Server API',
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
  checkHouraLoginSession(contracts, failures);
  checkMatrixFoundation(contracts, failures);
  checkMatrixAuthSession(contracts, failures);
  checkMatrixRegistration(contracts, failures);
  checkMatrixDevices(contracts, failures);
  checkMatrixOAuthAccountManagement(contracts, failures);
  checkMatrixDeviceKeyQuery(contracts, failures);
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
  checkMatrixModerationReportingAdminControls(contracts, failures);
  checkMatrixCryptoAdapterBoundary(contracts, failures);
  checkMatrixDeviceOneTimeFallbackKeys(contracts, failures);
  checkMatrixToDeviceEncryptedRoomGate(contracts, failures);
  checkMatrixKeyBackupRestoreGate(contracts, failures);
  checkMatrixVerificationCrossSigningGate(contracts, failures);
  checkMatrixFederationDiscoverySigningKeys(contracts, failures);
  checkMatrixFederationTransactionJoinInvite(contracts, failures);
  checkMatrixFederationBackfillAuthState(contracts, failures);
  checkMatrixApplicationServiceRegistrationTransaction(contracts, failures);
  checkMatrixIdentityServiceBoundary(contracts, failures);
  checkMatrixPushGatewayBoundary(contracts, failures);
  checkMatrixFederationInteropSmoke(contracts, failures);
  checkMatrixDomainCoverageReport(contracts, failures);
  checkMatrixComplementCiLane(contracts, failures);
  checkMatrixVersionAdvertisementGate(contracts, failures);
  checkMatrixReleaseNotesEvidenceTemplate(contracts, failures);
  checkMatrixV118ReleaseReadinessGate(contracts, failures);
  checkMatrixV118ReleaseEvidenceExampleBundle(contracts, failures);
  checkMatrixV118ReleaseEvidenceCurrentBlockedBundle(contracts, failures);
  checkMatrixV118ReleaseEvidenceBundleNegativeFixtures(failures);
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
    if (Directory('docs').existsSync()) ...filesUnder(Directory('docs'), '.md'),
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
    'docs',
    'test-vectors',
    'tool',
  };
  const allowedToolFiles = {'check_spec.dart'};
  const allowedToolDirectories = {'fixtures'};

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
    if (entity is File && allowedToolFiles.contains(name)) {
      continue;
    }
    if (entity is Directory && allowedToolDirectories.contains(name)) {
      continue;
    }
    failures.add('Unexpected spec tool entry: ${relative(entity)}');
  }

  final allowedToolFixtureFiles = {
    'tool/fixtures/check_spec/spec-066-inconsistent-release-artifact-path.json',
    'tool/fixtures/check_spec/spec-066-mismatched-release-candidate-ref.json',
  };
  final fixtureRoot = Directory('tool/fixtures');
  if (fixtureRoot.existsSync()) {
    for (final entity in fixtureRoot.listSync(recursive: true)) {
      if (entity is Directory) {
        continue;
      }
      if (entity is! File ||
          !allowedToolFixtureFiles.contains(relative(entity))) {
        failures.add('Unexpected spec tool fixture entry: ${relative(entity)}');
      }
    }
  }

  final checkSpecFixtureRoot = Directory('tool/fixtures/check_spec');
  if (checkSpecFixtureRoot.existsSync()) {
    for (final path in allowedToolFixtureFiles) {
      if (!File(path).existsSync()) {
        failures.add('Missing spec tool fixture entry: $path');
      }
    }
  } else if (fixtureRoot.existsSync()) {
    failures.add(
      'Missing spec tool fixture directory: ${relative(checkSpecFixtureRoot)}',
    );
  }

  if (fixtureRoot.existsSync()) {
    for (final entity in fixtureRoot.listSync()) {
      if (entity is! Directory || entityName(entity) != 'check_spec') {
        failures.add('Unexpected spec tool entry: ${relative(entity)}');
      }
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
    'Implementation metrics recording locations',
    'Minimum implementation metrics schema',
    'matrix_reference_snapshot',
    'Matrix reference',
    'Matrix v1.18 Compliance Matrix',
    'Matrix v1.18 roadmap close-out snapshot',
    'Matrix compliance advertisement gate',
    'Shared Implementation Strategy',
    'External reference snapshot',
    'Implementation Sharing Matrix',
    'Initial Shared-Core Adoption Gates',
    'Matrix versions request/response handling',
    'Matrix / Houra error parsing and emission',
    'Deferred candidates',
    'Security, Privacy, and Abuse-Case Review',
    'Auth/session lifecycle and owner scope',
    'Federation and push outbound destinations',
    'redacted artifacts only',
    'houra-server#59',
    'houra-client#55',
    'houra-labs#56',
    '#200',
    '#201',
    '#202',
    'matrix-v1-18-release-evidence-current-blocked-bundle.json',
    'stale_or_mismatched_refs_block_release',
    'Implementation Adoption Reports',
    'Language: [English](#english) | [日本語](#日本語)',
    '## 日本語',
    'docs/ja/',
    'Shared boundary and risk rule',
    'fail-closed capability',
    'version advertisement',
    'parse / normalize / validate / authorize',
    'next-touch rule',
    'planned adoption gate',
  ]) {
    if (!readme.contains(phrase)) {
      failures.add('README.md must document $phrase.');
    }
  }
  if (!readme.contains('UI Surface Contract')) {
    failures.add('README.md must document UI Surface Contract.');
  }
  checkJapaneseDocs(failures);

  final agents = File('AGENTS.md').readAsStringSync();
  for (final phrase in [
    'Codex-facing repo instructions live in this file',
    'Change Workflow',
    'Contract Update Rules',
    'Verification',
    'MCP',
    'parse/normalize/validate/authorize logic',
    'affected representative vector batch',
    'next-touch rule',
    'planned adoption gate',
  ]) {
    if (!agents.contains(phrase)) {
      failures.add('AGENTS.md must document $phrase.');
    }
  }

  final workflow = File('.github/workflows/spec-check.yml');
  if (!workflow.existsSync()) {
    failures.add('Missing workflow: .github/workflows/spec-check.yml');
  } else if (!workflow.readAsStringSync().contains('git diff --check')) {
    failures.add('Spec Check workflow must run git diff --check.');
  }

  final prTemplate = File('.github/PULL_REQUEST_TEMPLATE.md');
  if (!prTemplate.existsSync()) {
    failures.add('Missing PR template: .github/PULL_REQUEST_TEMPLATE.md');
  } else {
    final source = prTemplate.readAsStringSync();
    for (final phrase in [
      'git diff --check',
      'Adoption evidence',
      'Matrix reference snapshot',
      'Clean-room confirmed',
    ]) {
      if (!source.contains(phrase)) {
        failures.add('PR template must document $phrase.');
      }
    }
  }

  final sourceOfTruth = File('SOURCE_OF_TRUTH.md').readAsStringSync();
  if (!sourceOfTruth.contains('Codex-facing repository instructions')) {
    failures.add('SOURCE_OF_TRUTH.md must point to AGENTS.md.');
  }
  if (!sourceOfTruth.contains('MVP Readiness Boundary')) {
    failures.add('SOURCE_OF_TRUTH.md must document MVP Readiness Boundary.');
  }

  final referencePolicy = File('REFERENCE_POLICY.md').readAsStringSync();
  if (!referencePolicy.contains('Codex-facing repository instructions')) {
    failures.add('REFERENCE_POLICY.md must point to AGENTS.md.');
  }
}

void checkJapaneseDocs(List<String> failures) {
  const requiredDocs = {
    'docs/ja/README.md',
    'docs/ja/adoption-guide.md',
    'docs/ja/release-readiness.md',
    'docs/ja/matrix-v1-18.md',
  };
  for (final path in requiredDocs) {
    if (!File(path).existsSync()) {
      failures.add('Missing Japanese documentation: $path');
    }
  }
  final index = File('docs/ja/README.md');
  if (!index.existsSync()) {
    return;
  }
  final source = index.readAsStringSync();
  for (final phrase in [
    '英語',
    '正本',
    'release',
    'adoption-guide.md',
    'release-readiness.md',
    'matrix-v1-18.md',
  ]) {
    if (!source.contains(phrase)) {
      failures.add('docs/ja/README.md must document $phrase.');
    }
  }
  final adoptionGuide = File('docs/ja/adoption-guide.md');
  final adoptionSource = adoptionGuide.readAsStringSync();
  for (final phrase in [
    'implementation metrics',
    'Codex usage',
    'unavailable',
    'contracts/SPEC-030-matrix-client-versions.md',
  ]) {
    if (!adoptionSource.contains(phrase)) {
      failures.add('docs/ja/adoption-guide.md must document $phrase.');
    }
  }
  final matrixGuide = File('docs/ja/matrix-v1-18.md');
  final matrixSource = matrixGuide.readAsStringSync();
  for (final phrase in [
    'close-out snapshot',
    '#95',
    '#189',
    '#200',
    'release-ready',
  ]) {
    if (!matrixSource.contains(phrase)) {
      failures.add('docs/ja/matrix-v1-18.md must document $phrase.');
    }
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

void checkHouraLoginSession(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-004')) {
    failures.add('Houra login/session contract SPEC-004 is required.');
  }
  final file = File('test-vectors/auth/logout-token-invalid-after-logout.json');
  if (!file.existsSync()) {
    failures.add('Missing Houra logout invalidation vector: ${relative(file)}');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  validateHouraLogoutTokenInvalidAfterLogout(file, json, failures);
}

void validateHouraLogoutTokenInvalidAfterLogout(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final given = vector['given'];
  final previous = given is Map ? given['previous_request'] : null;
  final previousMap = previous is Map ? previous.cast<String, Object?>() : null;
  final request = vector['request'];
  final requestMap = request is Map ? request.cast<String, Object?>() : null;
  final expected = vector['expected'];
  final expectedMap = expected is Map ? expected.cast<String, Object?>() : null;
  if (previousMap == null ||
      previousMap['method'] != 'POST' ||
      previousMap['path'] != '/_houra/client/logout' ||
      previousMap['access_token'] is! String) {
    failures.add('${relative(file)} previous request must log out a token.');
  }
  if (requestMap == null ||
      requestMap['method'] != 'GET' ||
      requestMap['path'] != '/_houra/client/account/whoami' ||
      requestMap['access_token'] != previousMap?['access_token']) {
    failures.add(
      '${relative(file)} must retry whoami with the logged-out token.',
    );
  }
  final body = expectedMap?['body_contains'];
  if (expectedMap == null ||
      expectedMap['status'] != 401 ||
      body is! Map ||
      body['code'] != 'HOURA_UNAUTHORIZED') {
    failures.add(
      '${relative(file)} must expect HOURA_UNAUTHORIZED after logout.',
    );
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
    'test-vectors/auth/matrix-device-delete-owner-scope.json',
    'test-vectors/auth/matrix-devices-missing-token.json',
  ]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix devices/session vector: $path');
    }
  }
  final ownerScopeFile = File(
    'test-vectors/auth/matrix-device-delete-owner-scope.json',
  );
  if (ownerScopeFile.existsSync()) {
    final json = readJsonObject(ownerScopeFile, failures);
    if (json != null) {
      validateMatrixDeviceDeleteOwnerScope(ownerScopeFile, json, failures);
    }
  }
}

void validateMatrixDeviceDeleteOwnerScope(
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
  final source = eventMap['matrix_spec_source'];
  if (source is! String ||
      !source.startsWith('https://spec.matrix.org/v1.18/client-server-api/#')) {
    failures.add('${relative(file)} matrix_spec_source is invalid.');
  }
  if (eventMap['authenticated_user_id'] != '@alice:example.test' ||
      eventMap['protected_user_id'] != '@bob:example.test' ||
      eventMap['protected_device_id'] != 'BOBDEVICE1') {
    failures.add('${relative(file)} owner-scope actors are invalid.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'delete-other-user-device',
    'bulk-delete-other-user-device',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      failures.add('${relative(file)} owner-scope step must be an object.');
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    if (step['access_token'] != 'token-alice-device1') {
      failures.add('${relative(file)} owner-scope step must use Alice token.');
    }
    validateMatrixStepError(file, step, 404, 'M_NOT_FOUND', failures);
    if (step['must_not_delete_protected_device'] != true ||
        step['protected_access_token_must_remain_valid'] != true) {
      failures.add(
        '${relative(file)} owner-scope step must preserve Bob device/token.',
      );
    }
    final body = step['body'];
    final auth = body is Map ? body['auth'] : null;
    final identifier = auth is Map ? auth['identifier'] : null;
    if (identifier is! Map || identifier['user'] != 'alice') {
      failures.add('${relative(file)} UIA auth must belong to Alice.');
    }
    if (id == 'delete-other-user-device') {
      if (step['method'] != 'DELETE' ||
          step['path'] != '/_matrix/client/v3/devices/BOBDEVICE1') {
        failures.add('${relative(file)} single-device owner path invalid.');
      }
    } else if (id == 'bulk-delete-other-user-device') {
      final devices = body is Map ? body['devices'] : null;
      if (step['method'] != 'POST' ||
          step['path'] != '/_matrix/client/v3/delete_devices' ||
          devices is! List ||
          !devices.contains('BOBDEVICE1')) {
        failures.add('${relative(file)} bulk owner-scope request invalid.');
      }
    }
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['owner_scope_enforced'] != true ||
      expectedResult['protected_access_token_remains_valid'] != true) {
    failures.add('${relative(file)} owner-scope expectation invalid.');
  }
}

void checkMatrixOAuthAccountManagement(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-068')) {
    failures.add(
      'Matrix OAuth account-management contract SPEC-068 is required.',
    );
  }
  final required = [
    'test-vectors/auth/matrix-oauth-auth-metadata-account-management-basic.json',
    'test-vectors/auth/matrix-oauth-device-delete-account-management-link.json',
    'test-vectors/auth/matrix-oauth-generic-account-management-fallback.json',
    'test-vectors/auth/matrix-oauth-device-delete-return-refresh-complete.json',
    'test-vectors/auth/matrix-oauth-current-device-deleted-token-invalid.json',
    'test-vectors/auth/matrix-oauth-account-deactivate-account-management-link.json',
    'test-vectors/auth/matrix-oauth-adoption-boundary.json',
  ];
  for (final path in required) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix OAuth account-management vector: $path');
    }
  }

  final metadata = readJsonObject(
    File(
      'test-vectors/auth/matrix-oauth-auth-metadata-account-management-basic.json',
    ),
    failures,
  );
  final body = metadata?['expected'] is Map
      ? (metadata!['expected'] as Map)['body_contains']
      : null;
  if (body is Map) {
    final uri = body['account_management_uri'];
    if (uri is! String || !uri.startsWith('https://')) {
      failures.add('Matrix OAuth account-management URI must be HTTPS.');
    }
    final actions = body['account_management_actions_supported'];
    if (actions is! List ||
        !actions.contains('org.matrix.device_delete') ||
        !actions.contains('org.matrix.account_deactivate')) {
      failures.add(
        'Matrix OAuth account-management actions must include device delete and account deactivate.',
      );
    }
  } else {
    failures.add(
      'Matrix OAuth account-management metadata expectation is required.',
    );
  }

  for (final path in [
    'test-vectors/auth/matrix-oauth-device-delete-account-management-link.json',
    'test-vectors/auth/matrix-oauth-account-deactivate-account-management-link.json',
    'test-vectors/auth/matrix-oauth-generic-account-management-fallback.json',
  ]) {
    final json = readJsonObject(File(path), failures);
    final expected = json?['expected'];
    final redirect = expected is Map ? expected['client_redirect'] : null;
    final uri = redirect is Map ? redirect['uri'] : null;
    if (uri is! String || !uri.startsWith('https://')) {
      failures.add('$path client_redirect.uri must be HTTPS.');
    }
    if (uri is String && uri.contains('access_token')) {
      failures.add('$path client_redirect.uri must not include access_token.');
    }
  }

  final fallback = readJsonObject(
    File(
      'test-vectors/auth/matrix-oauth-generic-account-management-fallback.json',
    ),
    failures,
  );
  final fallbackContext = fallback?['client_context'];
  final fallbackMetadata = fallbackContext is Map
      ? fallbackContext['auth_metadata']
      : null;
  final fallbackExpected = fallback?['expected'];
  final fallbackRedirect = fallbackExpected is Map
      ? fallbackExpected['client_redirect']
      : null;
  final fallbackUri = fallbackRedirect is Map ? fallbackRedirect['uri'] : null;
  final fallbackAccountManagementUri = fallbackMetadata is Map
      ? fallbackMetadata['account_management_uri']
      : null;
  if (fallbackAccountManagementUri is! String ||
      !fallbackAccountManagementUri.startsWith('https://')) {
    failures.add(
      'Matrix OAuth generic account-management fallback metadata URI must be HTTPS.',
    );
  }
  if (fallbackMetadata is Map) {
    final actions = fallbackMetadata['account_management_actions_supported'];
    if (actions != null && (actions is! List || actions.isNotEmpty)) {
      failures.add(
        'Matrix OAuth generic account-management fallback must omit actions or use an empty action list.',
      );
    }
  }
  if (fallbackUri != fallbackAccountManagementUri) {
    failures.add(
      'Matrix OAuth generic account-management fallback must use the bare account_management_uri.',
    );
  }
  if (fallbackUri is String &&
      (fallbackUri.contains('action=') || fallbackUri.contains('device_id='))) {
    failures.add(
      'Matrix OAuth generic account-management fallback must not include action parameters.',
    );
  }

  final adoptionBoundaryFile = File(
    'test-vectors/auth/matrix-oauth-adoption-boundary.json',
  );
  validateMatrixOAuthAdoptionBoundary(
    adoptionBoundaryFile,
    readJsonObject(adoptionBoundaryFile, failures),
    failures,
  );
}

void validateMatrixOAuthAdoptionBoundary(
  File file,
  Map<String, Object?>? vector,
  List<String> failures,
) {
  if (vector == null) {
    return;
  }
  final event = vector['event'];
  if (event is! Map) {
    failures.add('${relative(file)} event must be an object.');
    return;
  }
  final eventMap = event.cast<String, Object?>();
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} Matrix spec version must be v1.18.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }
  final boundaryContracts = eventMap['boundary_contracts'];
  const requiredBoundaryContracts = {
    'SPEC-032',
    'SPEC-033',
    'SPEC-034',
    'SPEC-068',
  };
  if (boundaryContracts is! List ||
      !boundaryContracts.toSet().containsAll(requiredBoundaryContracts)) {
    failures.add(
      '${relative(file)} boundary_contracts must include SPEC-032, SPEC-033, SPEC-034, and SPEC-068.',
    );
  }

  final tracking = eventMap['repo_adoption_tracking'];
  final trackingMap = tracking is Map ? tracking.cast<String, Object?>() : null;
  final serverTracking = trackingMap?['server'];
  final clientTracking = trackingMap?['client'];
  final labsTracking = trackingMap?['labs'];
  if (serverTracking is! Map ||
      serverTracking['issue'] != 'imoyan/houra-server#106') {
    failures.add('${relative(file)} must track server adoption issue #106.');
  }
  if (clientTracking is! Map ||
      clientTracking['issue'] != 'imoyan/houra-client#95') {
    failures.add('${relative(file)} must track client adoption issue #95.');
  }
  if (labsTracking is! Map || labsTracking['issue_required'] != false) {
    failures.add(
      '${relative(file)} must keep labs adoption optional unless parser-only shared-core is needed.',
    );
  }

  final server = eventMap['server_boundary'];
  final serverMap = server is Map ? server.cast<String, Object?>() : null;
  if (serverMap == null ||
      serverMap['full_oauth_claim_allowed'] != false ||
      serverMap['legacy_password_login_preserved'] != true ||
      serverMap['legacy_registration_preserved'] != true ||
      serverMap['legacy_device_uia_preserved_for_non_oauth_sessions'] != true) {
    failures.add('${relative(file)} server adoption boundary is invalid.');
  }
  final unsupported = serverMap?['unsupported_behavior'];
  final unsupportedMap = unsupported is Map
      ? unsupported.cast<String, Object?>()
      : null;
  if (unsupportedMap == null ||
      unsupportedMap['auth_metadata_account_management_uri_present'] != false ||
      unsupportedMap['oauth_login_flow_advertised'] != false ||
      unsupportedMap['versions_advertisement_widened'] != false ||
      unsupportedMap['matrix_error_envelope_required_for_errors'] != true) {
    failures.add(
      '${relative(file)} unsupported server behavior must fail closed.',
    );
  }

  final client = eventMap['client_boundary'];
  final clientMap = client is Map ? client.cast<String, Object?>() : null;
  if (clientMap == null ||
      clientMap['sdk_constructs_account_management_url'] != true ||
      clientMap['host_owns_browser_presentation'] != true ||
      clientMap['host_owns_deep_link_routing'] != true ||
      clientMap['host_owns_cancellation_ui'] != true ||
      clientMap['host_owns_bearer_token_storage'] != true ||
      clientMap['account_management_url_is_not_completion_proof'] != true ||
      clientMap['post_return_reconciliation_required'] != true) {
    failures.add('${relative(file)} client adoption boundary is invalid.');
  }

  final expected = vector['expected'];
  final expectedMap = expected is Map ? expected.cast<String, Object?>() : null;
  if (expectedMap == null ||
      expectedMap['full_oauth_claimed'] != false ||
      expectedMap['legacy_auth_contracts_preserved'] != true ||
      expectedMap['host_browser_policy_owned_by_host'] != true ||
      expectedMap['server_fail_closed_when_unsupported'] != true ||
      expectedMap['versions_advertisement_widened'] != false ||
      expectedMap['implementation_follow_up_split_by_repo'] != true) {
    failures.add('${relative(file)} expected adoption boundary is invalid.');
  }
}

void checkMatrixDeviceKeyQuery(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-069')) {
    failures.add('Matrix device key query contract SPEC-069 is required.');
  }
  const paths = [
    'test-vectors/auth/matrix-keys-query-basic.json',
    'test-vectors/auth/matrix-keys-query-all-devices.json',
    'test-vectors/auth/matrix-keys-query-unknown-device-omitted.json',
    'test-vectors/auth/matrix-keys-query-missing-token.json',
    'test-vectors/auth/matrix-keys-query-missing-device-keys.json',
    'test-vectors/auth/matrix-keys-query-body-not-object.json',
    'test-vectors/auth/matrix-keys-query-device-keys-not-object.json',
    'test-vectors/auth/matrix-keys-query-device-selection-not-array.json',
    'test-vectors/auth/matrix-keys-query-device-id-not-string.json',
    'test-vectors/auth/matrix-keys-query-timeout-not-integer.json',
    'test-vectors/auth/matrix-keys-query-token-not-string.json',
    'test-vectors/auth/matrix-keys-query-adoption-boundary.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix device key query vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (json['contract'] != 'SPEC-069') {
      failures.add('${relative(file)} must reference SPEC-069.');
    }
    if (path.contains('adoption-boundary')) {
      validateMatrixKeysQueryAdoptionBoundary(file, json, failures);
    } else if (path.contains('missing-token')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'POST',
        pathPrefix: '/_matrix/client/v3/keys/query',
        status: 401,
        errcode: 'M_MISSING_TOKEN',
      );
    } else if (path.contains('missing-device-keys')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'POST',
        pathPrefix: '/_matrix/client/v3/keys/query',
        status: 400,
        errcode: 'M_MISSING_PARAM',
      );
    } else if (path.contains('body-not-object')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'POST',
        pathPrefix: '/_matrix/client/v3/keys/query',
        status: 400,
        errcode: 'M_NOT_JSON',
      );
    } else if (path.contains('not-object') ||
        path.contains('not-array') ||
        path.contains('not-string') ||
        path.contains('not-integer')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'POST',
        pathPrefix: '/_matrix/client/v3/keys/query',
        status: 400,
        errcode: 'M_INVALID_PARAM',
      );
    } else {
      validateMatrixKeysQueryVector(file, json, failures);
    }
  }
}

void validateMatrixKeysQueryAdoptionBoundary(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} Matrix spec version must be v1.18.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }
  requireStringListIncludes(file, eventMap, 'boundary_contracts', {
    'SPEC-034',
    'SPEC-050',
    'SPEC-051',
    'SPEC-052',
    'SPEC-053',
    'SPEC-054',
    'SPEC-069',
  }, failures);

  final tracking = eventMap['repo_adoption_tracking'];
  final trackingMap = tracking is Map ? tracking.cast<String, Object?>() : null;
  final serverTracking = trackingMap?['server'];
  final clientTracking = trackingMap?['client'];
  final labsTracking = trackingMap?['labs'];
  if (serverTracking is! Map ||
      serverTracking['issue'] != 'imoyan/houra-server#107') {
    failures.add('${relative(file)} must track server adoption issue #107.');
  }
  if (clientTracking is! Map ||
      clientTracking['issue'] != 'imoyan/houra-client#96') {
    failures.add('${relative(file)} must track client adoption issue #96.');
  }
  if (labsTracking is! Map ||
      labsTracking['issue'] != 'imoyan/houra-labs#65' ||
      labsTracking['crypto_primitives_allowed'] != false) {
    failures.add(
      '${relative(file)} must keep labs adoption parser-only and crypto-free.',
    );
  }

  final queryOnly = eventMap['query_only_boundary'];
  final queryOnlyMap = queryOnly is Map
      ? queryOnly.cast<String, Object?>()
      : null;
  if (queryOnlyMap == null ||
      queryOnlyMap['endpoint'] != '/_matrix/client/v3/keys/query' ||
      queryOnlyMap['full_e2ee_claim_allowed'] != false ||
      queryOnlyMap['crypto_stack_selection_required'] != false ||
      queryOnlyMap['versions_advertisement_widened'] != false ||
      queryOnlyMap['release_notes_e2ee_claim_allowed'] != false) {
    failures.add('${relative(file)} query-only boundary is invalid.');
  }

  final server = eventMap['server_boundary'];
  final serverMap = server is Map ? server.cast<String, Object?>() : null;
  if (serverMap == null ||
      serverMap['public_device_key_response_allowed'] != true ||
      serverMap['unknown_users_or_devices_omitted'] != true ||
      serverMap['private_key_material_returned'] != false ||
      serverMap['key_upload_required'] != false ||
      serverMap['one_time_key_claim_required'] != false ||
      serverMap['encrypted_room_required'] != false ||
      serverMap['verification_required'] != false) {
    failures.add('${relative(file)} server query-only boundary is invalid.');
  }

  final client = eventMap['client_shared_core_boundary'];
  final clientMap = client is Map ? client.cast<String, Object?>() : null;
  if (clientMap == null ||
      clientMap['request_descriptor_allowed'] != true ||
      clientMap['public_response_parser_allowed'] != true ||
      clientMap['timeout_validation_allowed'] != true ||
      clientMap['signature_verification_owned_by_crypto_adapter'] != true ||
      clientMap['token_storage_owned_by_host'] != true ||
      clientMap['transport_retry_owned_by_host'] != true ||
      clientMap['trust_ui_owned_by_host'] != true) {
    failures.add('${relative(file)} client/shared-core boundary is invalid.');
  }

  requireStringListIncludes(file, eventMap, 'out_of_scope', {
    'Olm/Megolm implementation',
    'secure storage',
    'verification UX',
    'encrypted-room behavior',
    'key backup',
    'cross-signing',
    'Matrix E2EE support advertisement',
  }, failures);

  final expected = vector['expected'];
  final expectedMap = expected is Map ? expected.cast<String, Object?>() : null;
  if (expectedMap == null ||
      expectedMap['query_only_gate'] != true ||
      expectedMap['full_e2ee_claimed'] != false ||
      expectedMap['parser_only_shared_core_allowed'] != true ||
      expectedMap['crypto_primitives_in_labs_allowed'] != false ||
      expectedMap['versions_advertisement_widened'] != false ||
      expectedMap['implementation_follow_up_split_by_repo'] != true) {
    failures.add('${relative(file)} expected query-only boundary is invalid.');
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
    'test-vectors/rooms/matrix-room-state-invalid-token.json',
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
    'test-vectors/media/matrix-media-download-filename-safety-negative.json',
    'test-vectors/media/matrix-media-download-missing-token.json',
    'test-vectors/media/matrix-media-download-not-found.json',
  ]) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix media MVP vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('download-with-filename-basic')) {
      validateMatrixMediaFilenameBasic(file, json, failures);
    } else if (path.contains('filename-safety-negative')) {
      validateMatrixMediaFilenameSafetyNegative(file, json, failures);
    }
  }
}

void validateMatrixMediaFilenameBasic(
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
          '/_matrix/client/v1/media/download/example.test/media1/avatar.png' ||
      requestMap['access_token'] != 'token-1') {
    failures.add('${relative(file)} filename download request invalid.');
  }
  final expected = vector['expected'];
  final headers = expected is Map ? expected['headers'] : null;
  final contentDisposition = headers is Map
      ? headers['content-disposition']
      : null;
  if (expected is! Map ||
      expected['status'] != 200 ||
      contentDisposition != 'inline; filename="avatar.png"' ||
      (contentDisposition is String &&
          (contentDisposition.contains('\r') ||
              contentDisposition.contains('\n')))) {
    failures.add(
      '${relative(file)} filename download Content-Disposition invalid.',
    );
  }
}

void validateMatrixMediaFilenameSafetyNegative(
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
  final source = eventMap['matrix_spec_source'];
  if (source is! String ||
      !source.startsWith('https://spec.matrix.org/v1.18/client-server-api/#')) {
    failures.add('${relative(file)} matrix_spec_source is invalid.');
  }
  final rfcSources = readStringList(eventMap['rfc_sources']);
  for (final rfcSource in const [
    'https://www.rfc-editor.org/rfc/rfc6266',
    'https://www.rfc-editor.org/rfc/rfc5987',
    'https://www.rfc-editor.org/rfc/rfc8187',
  ]) {
    if (rfcSources == null || !rfcSources.contains(rfcSource)) {
      failures.add('${relative(file)} rfc_sources must include $rfcSource.');
    }
  }
  final cases = eventMap['invalid_cases'];
  if (cases is! List || cases.length < 5) {
    failures.add('${relative(file)} invalid_cases must cover filename risks.');
    return;
  }
  final seenViolations = <String>{};
  for (final item in cases) {
    if (item is! Map) {
      failures.add('${relative(file)} invalid case must be an object.');
      continue;
    }
    final testCase = item.cast<String, Object?>();
    final id = testCase['id'];
    if (id is! String || id.isEmpty) {
      failures.add('${relative(file)} invalid case id is required.');
      continue;
    }
    final request = testCase['request'];
    checkRequest(
      file,
      request,
      failures,
      pathPrefix: 'event.invalid_cases.$id.request',
    );
    final requestMap = request is Map ? request.cast<String, Object?>() : null;
    final path = requestMap?['path'];
    if (requestMap?['method'] != 'GET' ||
        requestMap?['access_token'] != 'token-1' ||
        path is! String ||
        !path.startsWith(
          '/_matrix/client/v1/media/download/example.test/media1/',
        )) {
      failures.add('${relative(file)} invalid case $id request invalid.');
    }
    validateMatrixStepError(file, testCase, 400, 'M_INVALID_PARAM', failures);
    final violation = testCase['expected_violation'];
    if (violation is! String || violation.isEmpty) {
      failures.add('${relative(file)} invalid case $id violation missing.');
    } else {
      seenViolations.add(violation);
    }
  }
  for (final violation in const {
    'crlf_or_control_character',
    'path_separator_or_traversal',
    'unsupported_quoted_string_escape',
  }) {
    if (!seenViolations.contains(violation)) {
      failures.add('${relative(file)} missing filename violation: $violation.');
    }
  }
  final expected = vector['expected'];
  if (expected is! Map ||
      expected['filename_rejected_before_content_disposition'] != true ||
      expected['content_disposition_header_not_emitted'] != true) {
    failures.add('${relative(file)} filename safety expectation invalid.');
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
  if (eventSet['matrix_spec_version'] != 'v1.18') {
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

bool isMatrixRoomId(String id) {
  if (!id.startsWith('!') || id.length <= 1 || id.length > 255) {
    return false;
  }
  final separator = id.indexOf(':', 1);
  return separator > 1 &&
      separator < id.length - 1 &&
      isMatrixServerNameForVector(id.substring(separator + 1));
}

bool isIso8601TimestampWithTimezone(String value) =>
    DateTime.tryParse(value) != null &&
    RegExp(r'(Z|[+-]\d{2}:\d{2})$').hasMatch(value);

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
  final roomId = event['room_id'];
  if (roomId is! String || !isMatrixRoomId(roomId)) {
    failures.add('${relative(file)} room_id must be a Matrix room ID.');
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
    if (result.contains(item)) {
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
  if (requestMap['method'] != 'POST' ||
      requestMap['path'] != '/_matrix/client/v3/createRoom') {
    failures.add(
      '${relative(file)} default create-room request target invalid.',
    );
  }
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
  final creationContent = body['creation_content'];
  if (creationContent is! Map || creationContent['room_version'] != '1') {
    failures.add(
      '${relative(file)} default create-room vector must include overwritten creation_content.room_version.',
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
  if (request['method'] != 'POST' ||
      request['path'] != '/_matrix/client/v3/createRoom') {
    failures.add(
      '${relative(file)} unsupported create-room request target invalid.',
    );
  }
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
  if (vector['contract'] != 'SPEC-043') {
    failures.add('${relative(file)} must reference SPEC-043.');
  }
  final expectedMeta = vector['expected'];
  if (expectedMeta is Map && expectedMeta['case_count'] != expectedCaseCount) {
    failures.add('${relative(file)} expected.case_count is invalid.');
  }
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
    final actual = evaluateRepresentativeAuthCase(file, testCase, failures);
    if (actual == null) {
      continue;
    }
    if (!sameObjectMap(actual, expectedMap)) {
      failures.add('${relative(file)} case $id expected result mismatch.');
    }
  }
}

Map<String, Object?>? evaluateRepresentativeAuthCase(
  File file,
  Map<String, Object?> testCase,
  List<String> failures,
) {
  final id = testCase['id'];
  final candidate = (testCase['candidate_event'] as Map?)
      ?.cast<String, Object?>();
  switch (id) {
    case 'membership-join-self-public':
      return {
        'allowed':
            candidate?['type'] == 'm.room.member' &&
            candidate?['sender'] == candidate?['state_key'] &&
            (candidate?['content'] as Map?)?['membership'] == 'join' &&
            roomJoinRule(testCase) == 'public' &&
            !isBannedFromRoom(testCase, candidate?['state_key']),
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
  failures.add('${relative(file)} unsupported room auth case id: $id.');
  return null;
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
  for (final field in ['users', 'events']) {
    final value = content[field];
    if (value is Map && value.values.any((entry) => entry is! int)) {
      return false;
    }
  }
  return true;
}

String? roomJoinRule(Map<String, Object?> testCase) {
  final authState = testCase['auth_state'];
  if (authState is! List) {
    return null;
  }
  for (final item in authState) {
    if (item is! Map) {
      continue;
    }
    final event = item.cast<String, Object?>();
    if (event['type'] == 'm.room.join_rules') {
      final content = event['content'];
      final joinRule = content is Map ? content['join_rule'] : null;
      return joinRule is String ? joinRule : null;
    }
  }
  return null;
}

bool isBannedFromRoom(Map<String, Object?> testCase, Object? userId) {
  if (userId is! String) {
    return true;
  }
  final authState = testCase['auth_state'];
  if (authState is! List) {
    return false;
  }
  for (final item in authState) {
    if (item is! Map) {
      continue;
    }
    final event = item.cast<String, Object?>();
    final content = event['content'];
    if (event['type'] == 'm.room.member' &&
        event['state_key'] == userId &&
        content is Map &&
        content['membership'] == 'ban') {
      return true;
    }
  }
  return false;
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

bool sameJsonValue(Object? left, Object? right) {
  if (left is Map && right is Map) {
    if (left.length != right.length) {
      return false;
    }
    for (final entry in left.entries) {
      if (!right.containsKey(entry.key) ||
          !sameJsonValue(entry.value, right[entry.key])) {
        return false;
      }
    }
    return true;
  }
  if (left is List && right is List) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index += 1) {
      if (!sameJsonValue(left[index], right[index])) {
        return false;
      }
    }
    return true;
  }
  return left == right;
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
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
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
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
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
  final request = eventMap['request'];
  if (request is! Map ||
      request['path'] != '/_matrix/client/v3/rooms/$oldRoomId/upgrade') {
    failures.add('${relative(file)} request path must target the old room ID.');
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
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
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
    if (!sameJsonValue(before[key], after[key])) {
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
    final keyName = path is String ? path.split('/').last : null;
    if (body is! Map ||
        body.length != 1 ||
        keyName is! String ||
        !body.containsKey(keyName)) {
      failures.add(
        '${relative(file)} PUT profile body must match the profile key path.',
      );
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
  final type = eventMap['type'];
  if (type is! String || type.isEmpty) {
    failures.add('${relative(file)} account data type is required.');
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
    final expectedPath = roomScoped
        ? '/_matrix/client/v3/user/$userId/rooms/${eventMap['room_id']}/account_data/$type'
        : '/_matrix/client/v3/user/$userId/account_data/$type';
    if (!isSync && path != expectedPath) {
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
  final userId = eventMap['user_id'];
  if (userId is! String || !userId.startsWith('@')) {
    failures.add('${relative(file)} user_id must be a Matrix user ID.');
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
    final tag = eventMap['tag'];
    final tagsPath = '/_matrix/client/v3/user/$userId/rooms/$roomId/tags';
    if (!isSync && path != tagsPath && path != '$tagsPath/$tag') {
      failures.add('${relative(file)} room tag step path is invalid.');
    }
    final id = step['id'];
    if (id == 'put-room-tag') {
      final body = step['body'];
      final order = body is Map ? body['order'] : null;
      if (order != null && (order is! num || order < 0 || order > 1)) {
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

void validateMatrixStepError(
  File file,
  Map<String, Object?> step,
  int status,
  String errcode,
  List<String> failures,
) {
  final error = step['expected_error'];
  if (step['expected_status'] != status ||
      error is! Map ||
      error['errcode'] != errcode) {
    failures.add('${relative(file)} step must expect $status with $errcode.');
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
    if ((id == 'typing-start' || id == 'typing-stop') &&
        step['expected_status'] != 200) {
      failures.add('${relative(file)} typing update must expect 200.');
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
      if (step['expected_status'] != 200) {
        failures.add('${relative(file)} read marker post must expect 200.');
      }
    }
    if (id == 'sync-fully-read' &&
        (path != '/_matrix/client/v3/sync' ||
            step['expected_room_account_data_event'] is! Map)) {
      failures.add('${relative(file)} fully read sync expectation missing.');
    }
    if (id == 'sync-read-marker-receipt' &&
        (path != '/_matrix/client/v3/sync' ||
            step['expected_ephemeral_event'] is! Map)) {
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

void checkMatrixModerationReportingAdminControls(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-049')) {
    failures.add(
      'Matrix moderation/reporting/admin controls contract SPEC-049 is required.',
    );
  }
  const paths = [
    'test-vectors/rooms/matrix-room-moderation-kick-ban-unban.json',
    'test-vectors/rooms/matrix-room-moderation-permission-denied.json',
    'test-vectors/rooms/matrix-room-redaction-basic.json',
    'test-vectors/rooms/matrix-room-redaction-forbidden.json',
    'test-vectors/rooms/matrix-room-reporting-basic.json',
    'test-vectors/rooms/matrix-admin-account-moderation-basic.json',
    'test-vectors/rooms/matrix-admin-account-moderation-forbidden.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add(
        'Missing Matrix moderation/reporting/admin controls vector: $path',
      );
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('kick-ban-unban')) {
      validateMatrixModerationSteps(file, json, failures);
    } else if (path.contains('moderation-permission-denied')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'POST',
        pathPrefix: '/_matrix/client/v3/rooms/!room:example.test/kick',
        status: 403,
        errcode: 'M_FORBIDDEN',
      );
    } else if (path.contains('redaction-basic')) {
      validateMatrixRedactionVector(file, json, failures);
    } else if (path.contains('redaction-forbidden')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'PUT',
        pathPrefix: '/_matrix/client/v3/rooms/!room:example.test/redact/',
        status: 403,
        errcode: 'M_FORBIDDEN',
      );
    } else if (path.contains('reporting-basic')) {
      validateMatrixReportingSteps(file, json, failures);
    } else if (path.contains('account-moderation-basic')) {
      validateMatrixAdminModerationSteps(file, json, failures);
    } else {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'PUT',
        pathPrefix: '/_matrix/client/v1/admin/lock/@bob:example.test',
        status: 403,
        errcode: 'M_FORBIDDEN',
      );
    }
  }
}

void validateMatrixModerationSteps(
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
  if (eventMap['moderator'] != '@alice:example.test') {
    failures.add('${relative(file)} moderator must be @alice:example.test.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = ['kick-user', 'ban-user', 'unban-user'];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    final path = step['path'];
    if (path is! String ||
        !path.startsWith('/_matrix/client/v3/rooms/!room:example.test/')) {
      failures.add('${relative(file)} moderation step path is invalid.');
    }
    final expectedPathSuffix = switch (id) {
      'kick-user' => '/kick',
      'ban-user' => '/ban',
      'unban-user' => '/unban',
      _ => '',
    };
    if (expectedPathSuffix.isNotEmpty &&
        path is String &&
        !path.endsWith(expectedPathSuffix)) {
      failures.add('${relative(file)} moderation endpoint suffix is invalid.');
    }
    final body = step['body'];
    if (body is! Map || body['user_id'] is! String) {
      failures.add('${relative(file)} moderation body must include user_id.');
    }
    if (step['expected_status'] != 200 ||
        step['expected_membership_event'] is! Map) {
      failures.add('${relative(file)} moderation expectation is incomplete.');
    }
  }
}

void validateMatrixRedactionVector(
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
    failures.add('${relative(file)} redaction request must use PUT.');
  }
  final path = requestMap['path'];
  if (path is! String ||
      !path.startsWith('/_matrix/client/v3/rooms/!room:example.test/redact/')) {
    failures.add('${relative(file)} redaction path is invalid.');
  }
  final body = requestMap['body'];
  if (body is! Map) {
    failures.add('${relative(file)} redaction body is required.');
  }
  requireExpectedStatus(file, vector, failures, 200);
  final expected = vector['expected'];
  final bodyContains = expected is Map ? expected['body_contains'] : null;
  if (bodyContains is! Map || bodyContains['event_id'] is! String) {
    failures.add('${relative(file)} redaction event_id expectation missing.');
  }
}

void validateMatrixReportingSteps(
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
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = ['report-room', 'report-event', 'report-user'];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    final path = step['path'];
    if (path is! String || !path.startsWith('/_matrix/client/v3/')) {
      failures.add('${relative(file)} reporting step path is invalid.');
    }
    if (id == 'report-room' &&
        path != '/_matrix/client/v3/rooms/!room:example.test/report') {
      failures.add('${relative(file)} room report path is invalid.');
    }
    if (id == 'report-event' &&
        path !=
            '/_matrix/client/v3/rooms/!room:example.test/report/\$event1:example.test') {
      failures.add('${relative(file)} event report path is invalid.');
    }
    if (id == 'report-user' &&
        path != '/_matrix/client/v3/users/@spam:example.test/report') {
      failures.add('${relative(file)} user report path is invalid.');
    }
    final body = step['body'];
    if (body is! Map) {
      failures.add('${relative(file)} report body must be an object.');
    }
    if (id == 'report-room' && (body is! Map || body['reason'] is! String)) {
      failures.add('${relative(file)} room report body must include reason.');
    }
    if (id != 'report-room' &&
        body is Map &&
        body.containsKey('reason') &&
        body['reason'] is! String) {
      failures.add(
        '${relative(file)} report reason must be a string when present.',
      );
    }
    if (id == 'report-event' && body is Map && body.containsKey('score')) {
      failures.add('${relative(file)} event report must not include score.');
    }
    if (step['expected_status'] != 200) {
      failures.add('${relative(file)} report step must expect 200.');
    }
  }
}

void validateMatrixAdminModerationSteps(
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
  if (eventMap['admin_user_id'] != '@admin:example.test' ||
      eventMap['target_user_id'] != '@bob:example.test') {
    failures.add('${relative(file)} admin/target users are invalid.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'capabilities-account-moderation',
    'lock-user',
    'get-lock',
    'suspend-user',
    'get-suspend',
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
      failures.add('${relative(file)} admin step path is required.');
      continue;
    }
    if (id == 'capabilities-account-moderation') {
      final expectedBody = step['expected_body_contains'];
      final capabilities = expectedBody is Map
          ? expectedBody['capabilities']
          : null;
      final moderation = capabilities is Map
          ? capabilities['m.account_moderation']
          : null;
      if (step['method'] != 'GET' ||
          path != '/_matrix/client/v3/capabilities' ||
          moderation is! Map ||
          moderation['lock'] != true ||
          moderation['suspend'] != true) {
        failures.add(
          '${relative(file)} account moderation capability invalid.',
        );
      }
      continue;
    }
    final isLock = path.startsWith('/_matrix/client/v1/admin/lock/');
    final isSuspend = path.startsWith('/_matrix/client/v1/admin/suspend/');
    if (!isLock && !isSuspend) {
      failures.add('${relative(file)} admin moderation path is invalid.');
    }
    if (id == 'lock-user') {
      final body = step['body'];
      if (body is! Map || body['locked'] != true) {
        failures.add('${relative(file)} lock body is invalid.');
      }
    }
    if (id == 'suspend-user') {
      final body = step['body'];
      if (body is! Map || body['suspended'] != true) {
        failures.add('${relative(file)} suspend body is invalid.');
      }
    }
    if ((id == 'get-lock' || id == 'get-suspend') &&
        (step['expected_status'] != 200 || step['expected_body'] is! Map)) {
      failures.add('${relative(file)} admin GET expectation is invalid.');
    }
  }
}

void checkMatrixCryptoAdapterBoundary(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-050')) {
    failures.add(
      'Matrix crypto adapter boundary contract SPEC-050 is required.',
    );
  }
  const paths = [
    'test-vectors/core/matrix-crypto-adapter-boundary.json',
    'test-vectors/core/matrix-crypto-adoption-decision-checklist.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix crypto adapter boundary vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('adapter-boundary')) {
      validateMatrixCryptoAdapterBoundary(file, json, failures);
    } else {
      validateMatrixCryptoAdoptionChecklist(file, json, failures);
    }
  }
}

void validateMatrixCryptoAdapterBoundary(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixCryptoReference(file, eventMap, failures);
  if (eventMap['requires_maintained_matrix_crypto_stack'] != true) {
    failures.add(
      '${relative(file)} must require a maintained Matrix crypto stack.',
    );
  }
  requireStringListIncludes(file, eventMap, 'forbidden_local_crypto', {
    'olm',
    'megolm',
    'sas',
    'cross_signing_crypto',
    'secret_storage_crypto',
    'key_backup_crypto',
  }, failures);
  requireStringListIncludes(file, eventMap, 'required_algorithm_coverage', {
    'm.olm.v1.curve25519-aes-sha2',
    'm.megolm.v1.aes-sha2',
  }, failures);
  requireStringListIncludes(file, eventMap, 'host_owned', {
    'access_tokens',
    'refresh_tokens',
    'secure_storage',
    'private_key_storage_policy',
    'recovery_key_storage_policy',
  }, failures);
  requireStringListIncludes(file, eventMap, 'crypto_adapter_owned', {
    'olm_sessions',
    'megolm_group_sessions',
    'device_key_generation',
    'one_time_key_generation',
    'fallback_key_generation',
    'encrypted_room_event_crypto',
    'key_backup_crypto',
    'verification_crypto',
    'cross_signing_crypto',
  }, failures);
  requireStringListIncludes(file, eventMap, 'server_must_treat_as_opaque', {
    'encrypted_room_content',
    'to_device_payloads',
    'private_cross_signing_keys',
    'recovery_keys',
    'key_backup_session_data',
  }, failures);
  final expected = vector['expected'];
  if (expected is! Map ||
      expected['local_olm_megolm_allowed'] != false ||
      expected['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} crypto boundary expectation is invalid.');
  }
}

void validateMatrixCryptoAdoptionChecklist(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixCryptoReference(file, eventMap, failures);
  final decisions = eventMap['adoption_decisions'];
  if (decisions is! List || decisions.length != 3) {
    failures.add('${relative(file)} adoption_decisions must list 3 repos.');
    return;
  }
  final byRepo = <String, Map<String, Object?>>{};
  for (final item in decisions) {
    if (item is! Map) {
      failures.add('${relative(file)} adoption_decisions items must be maps.');
      continue;
    }
    final decision = item.cast<String, Object?>();
    final repo = decision['repo'];
    if (repo is String) {
      byRepo[repo] = decision;
    }
  }
  for (final repo in ['houra-client', 'houra-server', 'houra-labs']) {
    if (!byRepo.containsKey(repo)) {
      failures.add('${relative(file)} adoption decision missing: $repo');
    }
  }
  final client = byRepo['houra-client'];
  if (client != null) {
    if (client['create_issue_after_spec_merge'] != true) {
      failures.add('${relative(file)} houra-client issue must be required.');
    }
    requireStringListIncludes(file, client, 'required_scope', {
      'select_maintained_matrix_crypto_stack',
      'adapter_facade',
      'host_owned_token_storage_boundary',
      'host_owned_secure_key_storage_boundary',
    }, failures);
    requireStringListIncludes(file, client, 'forbidden_scope', {
      'local_olm_implementation',
      'local_megolm_implementation',
      'sdk_owned_token_persistence',
    }, failures);
  }
  final server = byRepo['houra-server'];
  if (server != null) {
    if (server['create_issue_after_spec_merge'] !=
        'when_server_key_or_to_device_contract_merges') {
      failures.add('${relative(file)} houra-server issue condition invalid.');
    }
    requireStringListIncludes(file, server, 'required_scope', {
      'opaque_device_key_storage',
      'one_time_key_claim_semantics',
      'fallback_key_storage',
      'opaque_to_device_routing',
      'opaque_key_backup_storage',
    }, failures);
    requireStringListIncludes(file, server, 'forbidden_scope', {
      'decrypt_room_content',
      'decrypt_to_device_payloads',
      'decrypt_key_backup_session_data',
    }, failures);
  }
  final labs = byRepo['houra-labs'];
  if (labs != null) {
    if (labs['create_issue_after_spec_merge'] !=
        'parser_only_helper_if_intentionally_adopted') {
      failures.add('${relative(file)} houra-labs issue condition invalid.');
    }
    requireStringListIncludes(file, labs, 'required_scope', {
      'parity_vectors',
      'performance_gate',
    }, failures);
    requireStringListIncludes(file, labs, 'forbidden_scope', {
      'crypto_primitives',
      'olm',
      'megolm',
      'transport',
      'storage',
      'ui',
      'retry',
      'secure_storage',
    }, failures);
  }
  final expected = vector['expected'];
  if (expected is! Map ||
      expected['adoption_repo_count'] != 3 ||
      expected['client_issue_required_after_merge'] != true ||
      expected['labs_crypto_issue_allowed'] != false) {
    failures.add('${relative(file)} adoption checklist expectation invalid.');
  }
}

void validateMatrixCryptoReference(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final source = eventMap['matrix_spec_source'];
  if (source is! String ||
      !source.startsWith('https://spec.matrix.org/v1.18/client-server-api/#')) {
    failures.add('${relative(file)} matrix_spec_source is invalid.');
  }
}

void requireStringListIncludes(
  File file,
  Map<String, Object?> object,
  String key,
  Set<String> required,
  List<String> failures,
) {
  final value = object[key];
  if (value is! List || value.any((item) => item is! String)) {
    failures.add('${relative(file)} $key must be a string array.');
    return;
  }
  final actual = value.cast<String>().toSet();
  for (final item in required) {
    if (!actual.contains(item)) {
      failures.add('${relative(file)} $key missing required item: $item');
    }
  }
}

void checkMatrixDeviceOneTimeFallbackKeys(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-051')) {
    failures.add(
      'Matrix device/one-time/fallback keys contract SPEC-051 is required.',
    );
  }
  const paths = [
    'test-vectors/auth/matrix-keys-upload-device-one-time-fallback-basic.json',
    'test-vectors/auth/matrix-keys-upload-malformed-device-keys.json',
    'test-vectors/auth/matrix-keys-query-basic.json',
    'test-vectors/auth/matrix-keys-query-missing-token.json',
    'test-vectors/auth/matrix-keys-claim-one-time-fallback-basic.json',
    'test-vectors/auth/matrix-keys-claim-invalid-algorithm.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix device/one-time/fallback key vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('upload-device-one-time-fallback')) {
      validateMatrixKeysUploadVector(file, json, failures);
    } else if (path.contains('upload-malformed')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'POST',
        pathPrefix: '/_matrix/client/v3/keys/upload',
        status: 400,
        errcode: 'M_INVALID_PARAM',
      );
    } else if (path.contains('query-basic')) {
      validateMatrixKeysQueryVector(file, json, failures);
    } else if (path.contains('query-missing-token')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'POST',
        pathPrefix: '/_matrix/client/v3/keys/query',
        status: 401,
        errcode: 'M_MISSING_TOKEN',
      );
    } else if (path.contains('claim-one-time-fallback')) {
      validateMatrixKeysClaimSteps(file, json, failures);
    } else {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'POST',
        pathPrefix: '/_matrix/client/v3/keys/claim',
        status: 400,
        errcode: 'M_INVALID_PARAM',
      );
    }
  }
}

void validateMatrixKeysUploadVector(
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
  if (requestMap['method'] != 'POST' ||
      requestMap['path'] != '/_matrix/client/v3/keys/upload') {
    failures.add('${relative(file)} keys upload request is invalid.');
  }
  final body = requestMap['body'];
  if (body is! Map) {
    failures.add('${relative(file)} keys upload body must be an object.');
    return;
  }
  final bodyMap = body.cast<String, Object?>();
  final deviceKeys = bodyMap['device_keys'];
  if (deviceKeys is! Map) {
    failures.add('${relative(file)} device_keys must be an object.');
  } else {
    validateMatrixDeviceKeyObject(
      file,
      deviceKeys.cast<String, Object?>(),
      '@alice:example.test',
      'DEVICE1',
      failures,
    );
  }
  validateMatrixSignedCurve25519Keys(
    file,
    bodyMap['one_time_keys'],
    failures,
    fallback: false,
  );
  validateMatrixSignedCurve25519Keys(
    file,
    bodyMap['fallback_keys'],
    failures,
    fallback: true,
  );
  requireExpectedStatus(file, vector, failures, 200);
  final expected = vector['expected'];
  final bodyContains = expected is Map ? expected['body_contains'] : null;
  final counts = bodyContains is Map
      ? bodyContains['one_time_key_counts']
      : null;
  if (counts is! Map || counts['signed_curve25519'] is! int) {
    failures.add('${relative(file)} one_time_key_counts expectation missing.');
  }
  if (expected is! Map || expected['private_key_material_returned'] != false) {
    failures.add('${relative(file)} must assert no private key material.');
  }
}

void validateMatrixKeysQueryVector(
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
  if (requestMap['method'] != 'POST' ||
      requestMap['path'] != '/_matrix/client/v3/keys/query') {
    failures.add('${relative(file)} keys query request is invalid.');
  }
  final body = requestMap['body'];
  final requested = body is Map ? body['device_keys'] : null;
  if (requested is! Map || requested.isEmpty) {
    failures.add('${relative(file)} keys query body is invalid.');
  } else {
    for (final entry in requested.entries) {
      final userId = entry.key;
      final selectedDevices = entry.value;
      if (userId is! String || selectedDevices is! List) {
        failures.add('${relative(file)} keys query body is invalid.');
        continue;
      }
      for (final deviceId in selectedDevices) {
        if (deviceId is! String || deviceId.isEmpty) {
          failures.add(
            '${relative(file)} keys query device selection invalid.',
          );
        }
      }
    }
  }
  requireExpectedStatus(file, vector, failures, 200);
  final expected = vector['expected'];
  final bodyContains = expected is Map ? expected['body_contains'] : null;
  if (bodyContains is! Map) {
    failures.add('${relative(file)} keys query response body missing.');
    return;
  }
  if (bodyContains.containsKey('omitted_device_keys')) {
    failures.add(
      '${relative(file)} must omit unknown devices without reporting omitted_device_keys.',
    );
  }
  if (bodyContains['failures'] is! Map) {
    failures.add('${relative(file)} keys query failures map missing.');
  }
  final deviceKeys = bodyContains['device_keys'];
  if (deviceKeys is! Map) {
    failures.add('${relative(file)} keys query response device missing.');
    return;
  }
  if (deviceKeys.isEmpty) {
    return;
  }
  for (final userEntry in deviceKeys.entries) {
    final userId = userEntry.key;
    final devices = userEntry.value;
    if (userId is! String || devices is! Map || devices.isEmpty) {
      failures.add('${relative(file)} keys query response device missing.');
      continue;
    }
    for (final deviceEntry in devices.entries) {
      final deviceId = deviceEntry.key;
      final device = deviceEntry.value;
      if (deviceId is! String || device is! Map) {
        failures.add('${relative(file)} keys query response device invalid.');
        continue;
      }
      validateMatrixDeviceKeyObject(
        file,
        device.cast<String, Object?>(),
        userId,
        deviceId,
        failures,
      );
    }
  }
  if (expected is! Map || expected['private_key_material_returned'] != false) {
    failures.add('${relative(file)} must assert no private key material.');
  }
}

void validateMatrixKeysClaimSteps(
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
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'claim-one-time-key',
    'claim-fallback-key-after-one-time-exhausted',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    if (step['method'] != 'POST' ||
        step['path'] != '/_matrix/client/v3/keys/claim' ||
        step['expected_status'] != 200) {
      failures.add('${relative(file)} keys claim step request invalid.');
    }
    final body = step['body'];
    final requestKeys = body is Map ? body['one_time_keys'] : null;
    final aliceRequest = requestKeys is Map
        ? requestKeys['@alice:example.test']
        : null;
    final algorithm = aliceRequest is Map ? aliceRequest['DEVICE1'] : null;
    if (algorithm != 'signed_curve25519') {
      failures.add('${relative(file)} keys claim algorithm is invalid.');
    }
    final expectedBody = step['expected_body_contains'];
    final responseKeys = expectedBody is Map
        ? expectedBody['one_time_keys']
        : null;
    final aliceResponse = responseKeys is Map
        ? responseKeys['@alice:example.test']
        : null;
    final deviceResponse = aliceResponse is Map
        ? aliceResponse['DEVICE1']
        : null;
    if (deviceResponse is! Map || deviceResponse.isEmpty) {
      failures.add('${relative(file)} keys claim response is missing a key.');
      continue;
    }
    final first = deviceResponse.values.first;
    if (first is! Map ||
        first['key'] is! String ||
        first['signatures'] is! Map) {
      failures.add('${relative(file)} claimed key object is invalid.');
    }
    final id = step['id'];
    if (id == 'claim-fallback-key-after-one-time-exhausted' &&
        first is Map &&
        first['fallback'] != true) {
      failures.add('${relative(file)} fallback claim must mark fallback true.');
    }
    final serverEffect = step['server_effect'];
    if (serverEffect is! Map || serverEffect.isEmpty) {
      failures.add('${relative(file)} keys claim server_effect is required.');
    }
  }
}

void validateMatrixDeviceKeyObject(
  File file,
  Map<String, Object?> device,
  String userId,
  String deviceId,
  List<String> failures,
) {
  if (device['user_id'] != userId || device['device_id'] != deviceId) {
    failures.add('${relative(file)} device key identity is invalid.');
  }
  requireStringListIncludes(file, device, 'algorithms', {
    'm.olm.v1.curve25519-aes-sha2',
    'm.megolm.v1.aes-sha2',
  }, failures);
  final keys = device['keys'];
  if (keys is! Map ||
      keys['curve25519:$deviceId'] is! String ||
      keys['ed25519:$deviceId'] is! String) {
    failures.add('${relative(file)} device key public keys are invalid.');
  }
  final signatures = device['signatures'];
  final userSignatures = signatures is Map ? signatures[userId] : null;
  if (userSignatures is! Map ||
      userSignatures['ed25519:$deviceId'] is! String) {
    failures.add('${relative(file)} device key signature is invalid.');
  }
}

void validateMatrixSignedCurve25519Keys(
  File file,
  Object? value,
  List<String> failures, {
  required bool fallback,
}) {
  if (value is! Map || value.isEmpty) {
    failures.add('${relative(file)} signed_curve25519 key map is required.');
    return;
  }
  for (final entry in value.entries) {
    if (entry.key is! String ||
        !(entry.key as String).startsWith('signed_curve25519:')) {
      failures.add('${relative(file)} signed_curve25519 key id is invalid.');
    }
    final key = entry.value;
    if (key is! Map || key['key'] is! String || key['signatures'] is! Map) {
      failures.add('${relative(file)} signed_curve25519 key object invalid.');
      continue;
    }
    if (fallback && key['fallback'] != true) {
      failures.add('${relative(file)} fallback key must set fallback true.');
    }
  }
}

void checkMatrixToDeviceEncryptedRoomGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-052')) {
    failures.add(
      'Matrix to-device/encrypted room gate contract SPEC-052 is required.',
    );
  }
  const paths = [
    'test-vectors/messaging/matrix-to-device-send-basic.json',
    'test-vectors/messaging/matrix-to-device-sync-receive-basic.json',
    'test-vectors/messaging/matrix-to-device-missing-token.json',
    'test-vectors/messaging/matrix-encrypted-room-send-receive-basic.json',
    'test-vectors/messaging/matrix-encrypted-room-malformed-payload.json',
    'test-vectors/messaging/matrix-e2ee-multi-device-send-receive-gate.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix to-device/encrypted room vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('to-device-send-basic')) {
      validateMatrixToDeviceSendVector(file, json, failures);
    } else if (path.contains('to-device-sync-receive')) {
      validateMatrixToDeviceSyncSteps(file, json, failures);
    } else if (path.contains('to-device-missing-token')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'PUT',
        pathPrefix: '/_matrix/client/v3/sendToDevice/m.room.encrypted/',
        status: 401,
        errcode: 'M_MISSING_TOKEN',
      );
    } else if (path.contains('send-receive-basic')) {
      validateMatrixEncryptedRoomSteps(file, json, failures);
    } else if (path.contains('malformed-payload')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'PUT',
        pathPrefix:
            '/_matrix/client/v3/rooms/!encrypted:example.test/send/'
            'm.room.encrypted/',
        status: 400,
        errcode: 'M_INVALID_PARAM',
      );
    } else {
      validateMatrixE2eeMultiDeviceGate(file, json, failures);
    }
  }
}

void validateMatrixToDeviceSendVector(
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
  if (requestMap['method'] != 'PUT' ||
      requestMap['path'] is! String ||
      !(requestMap['path'] as String).startsWith(
        '/_matrix/client/v3/sendToDevice/m.room.encrypted/',
      )) {
    failures.add('${relative(file)} to-device send request is invalid.');
  }
  final body = requestMap['body'];
  validateMatrixToDeviceMessages(file, body, failures);
  requireExpectedStatus(file, vector, failures, 200);
  final expected = vector['expected'];
  final serverEffect = expected is Map ? expected['server_effect'] : null;
  if (serverEffect is! Map || serverEffect['queued_to_device_count'] is! int) {
    failures.add('${relative(file)} queued to-device effect missing.');
  }
}

void validateMatrixToDeviceSyncSteps(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixE2eeReference(file, eventMap, failures);
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = ['send-to-device', 'sync-recipient-device'];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    if (id == 'send-to-device') {
      if (step['method'] != 'PUT' ||
          step['path'] is! String ||
          !(step['path'] as String).startsWith(
            '/_matrix/client/v3/sendToDevice/m.room.encrypted/',
          ) ||
          step['expected_status'] != 200) {
        failures.add('${relative(file)} send-to-device step is invalid.');
      }
      validateMatrixToDeviceMessages(file, step['body'], failures);
    }
    if (id == 'sync-recipient-device') {
      if (step['method'] != 'GET' ||
          step['path'] != '/_matrix/client/v3/sync' ||
          step['expected_status'] != 200) {
        failures.add('${relative(file)} to-device sync step is invalid.');
      }
      final expectedBody = step['expected_body_contains'];
      final toDevice = expectedBody is Map ? expectedBody['to_device'] : null;
      final events = toDevice is Map ? toDevice['events'] : null;
      if (events is! List || events.isEmpty) {
        failures.add('${relative(file)} to_device.events expectation missing.');
      } else {
        final first = events.first;
        if (first is! Map ||
            first['type'] != 'm.room.encrypted' ||
            first['sender'] != '@alice:example.test') {
          failures.add('${relative(file)} to-device event envelope invalid.');
        } else {
          validateMatrixOlmEncryptedContent(file, first['content'], failures);
        }
      }
    }
  }
}

void validateMatrixEncryptedRoomSteps(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixE2eeReference(file, eventMap, failures);
  final roomId = eventMap['room_id'];
  if (roomId is! String || !isMatrixRoomId(roomId)) {
    failures.add('${relative(file)} room_id must be a Matrix room ID.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'set-room-encryption',
    'send-encrypted-event',
    'sync-encrypted-event',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    if (id == 'set-room-encryption') {
      if (step['method'] != 'PUT' ||
          step['path'] !=
              '/_matrix/client/v3/rooms/!encrypted:example.test/state/'
                  'm.room.encryption/' ||
          step['expected_status'] != 200) {
        failures.add('${relative(file)} room encryption state step invalid.');
      }
      final body = step['body'];
      if (body is! Map || body['algorithm'] != 'm.megolm.v1.aes-sha2') {
        failures.add('${relative(file)} room encryption algorithm invalid.');
      }
    }
    if (id == 'send-encrypted-event') {
      if (step['method'] != 'PUT' ||
          step['path'] !=
              '/_matrix/client/v3/rooms/!encrypted:example.test/send/'
                  'm.room.encrypted/txn-encrypted-1' ||
          step['expected_status'] != 200 ||
          step['server_must_not_decrypt'] != true) {
        failures.add('${relative(file)} encrypted send step invalid.');
      }
      validateMatrixMegolmEncryptedContent(file, step['body'], failures);
    }
    if (id == 'sync-encrypted-event') {
      if (step['method'] != 'GET' ||
          step['path'] != '/_matrix/client/v3/sync' ||
          step['expected_status'] != 200) {
        failures.add('${relative(file)} encrypted sync step invalid.');
      }
      final event = step['expected_timeline_event'];
      if (event is! Map || event['type'] != 'm.room.encrypted') {
        failures.add('${relative(file)} encrypted timeline event missing.');
      } else {
        validateMatrixMegolmEncryptedContent(file, event['content'], failures);
      }
    }
  }
}

void validateMatrixE2eeMultiDeviceGate(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixE2eeReference(file, eventMap, failures);
  requireStringListIncludes(file, eventMap, 'required_contracts', {
    'SPEC-050',
    'SPEC-051',
    'SPEC-052',
  }, failures);
  if (eventMap['crypto_stack_required'] != true ||
      eventMap['local_olm_megolm_allowed'] != false) {
    failures.add('${relative(file)} crypto stack boundary is invalid.');
  }
  final devices = eventMap['devices'];
  final bobDevices = devices is Map ? devices['@bob:example.test'] : null;
  if (bobDevices is! List || bobDevices.length < 2) {
    failures.add('${relative(file)} multi-device gate must include 2 devices.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'publish-recipient-device-keys',
    'claim-recipient-one-time-keys',
    'distribute-room-session-to-bob-devices',
    'send-encrypted-room-event',
    'sync-bob-devices',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map || item['required'] != true) {
      failures.add('${relative(file)} all multi-device steps are required.');
      continue;
    }
    if (item['contract'] is! String) {
      failures.add('${relative(file)} multi-device step contract missing.');
    }
  }
  requireStringListIncludes(file, eventMap, 'required_evidence', {
    'houra_spec_ref',
    'houra_server_ref',
    'houra_client_ref',
    'crypto_stack_name',
    'crypto_stack_version',
    'device_ids',
    'commands',
    'per_step_pass_fail',
  }, failures);
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['recipient_device_count'] != 2 ||
      expectedResult['encrypted_room_send_receive'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} multi-device expectation invalid.');
  }
}

void validateMatrixToDeviceMessages(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map || value['messages'] is! Map) {
    failures.add(
      '${relative(file)} to-device body.messages must be an object.',
    );
    return;
  }
  final messages = value['messages'] as Map;
  if (messages.isEmpty) {
    failures.add('${relative(file)} to-device messages must not be empty.');
  }
  for (final userEntry in messages.entries) {
    if (userEntry.key is! String ||
        !(userEntry.key as String).startsWith('@') ||
        userEntry.value is! Map) {
      failures.add('${relative(file)} to-device user map invalid.');
      continue;
    }
    final devices = userEntry.value as Map;
    if (devices.isEmpty) {
      failures.add('${relative(file)} to-device device map empty.');
    }
    for (final deviceEntry in devices.entries) {
      if (deviceEntry.key is! String || (deviceEntry.key as String).isEmpty) {
        failures.add('${relative(file)} to-device device id invalid.');
      }
      validateMatrixOlmEncryptedContent(file, deviceEntry.value, failures);
    }
  }
}

void validateMatrixOlmEncryptedContent(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map ||
      value['algorithm'] != 'm.olm.v1.curve25519-aes-sha2' ||
      value['sender_key'] is! String ||
      value['ciphertext'] is! Map) {
    failures.add('${relative(file)} Olm encrypted content is invalid.');
  }
}

void validateMatrixMegolmEncryptedContent(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map ||
      value['algorithm'] != 'm.megolm.v1.aes-sha2' ||
      value['sender_key'] is! String ||
      value['ciphertext'] is! String ||
      value['session_id'] is! String ||
      value['device_id'] is! String) {
    failures.add('${relative(file)} Megolm encrypted content is invalid.');
  }
}

void validateMatrixE2eeReference(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final source = eventMap['matrix_spec_source'];
  if (source is! String ||
      !source.startsWith('https://spec.matrix.org/v1.18/client-server-api/#')) {
    failures.add('${relative(file)} matrix_spec_source is invalid.');
  }
}

void checkMatrixKeyBackupRestoreGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-053')) {
    failures.add('Matrix key backup/restore contract SPEC-053 is required.');
  }
  const paths = [
    'test-vectors/messaging/matrix-key-backup-version-lifecycle.json',
    'test-vectors/messaging/matrix-key-backup-session-upload-restore-basic.json',
    'test-vectors/messaging/matrix-key-backup-wrong-version.json',
    'test-vectors/messaging/matrix-key-backup-restore-missing-session.json',
    'test-vectors/messaging/matrix-key-backup-logout-relogin-recovery-gate.json',
    'test-vectors/messaging/matrix-key-backup-owner-scope.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix key backup/restore vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('version-lifecycle')) {
      validateMatrixKeyBackupVersionLifecycle(file, json, failures);
    } else if (path.contains('session-upload-restore')) {
      validateMatrixKeyBackupSessionRestore(file, json, failures);
    } else if (path.contains('wrong-version')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'PUT',
        pathPrefix:
            '/_matrix/client/v3/room_keys/keys/!encrypted:example.test/'
            'megolm-session-1',
        status: 403,
        errcode: 'M_WRONG_ROOM_KEYS_VERSION',
      );
    } else if (path.contains('restore-missing-session')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'GET',
        pathPrefix:
            '/_matrix/client/v3/room_keys/keys/!encrypted:example.test/'
            'missing-session',
        status: 404,
        errcode: 'M_NOT_FOUND',
      );
    } else if (path.contains('owner-scope')) {
      validateMatrixKeyBackupOwnerScope(file, json, failures);
    } else {
      validateMatrixKeyBackupLogoutReloginGate(file, json, failures);
    }
  }
}

void validateMatrixKeyBackupVersionLifecycle(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixE2eeReference(file, eventMap, failures);
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'create-backup-version',
    'get-current-backup-version',
    'update-backup-auth-data',
    'get-specific-backup-version',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    final path = step['path'];
    if (path is! String || !path.startsWith('/_matrix/client/v3/room_keys/')) {
      failures.add('${relative(file)} key backup version path invalid.');
    }
    if (step['expected_status'] != 200) {
      failures.add(
        '${relative(file)} key backup version step must expect 200.',
      );
    }
    if (id == 'create-backup-version' || id == 'update-backup-auth-data') {
      validateMatrixKeyBackupVersionBody(file, step['body'], failures);
    }
    if (id == 'create-backup-version') {
      final expectedBody = step['expected_body_contains'];
      if (expectedBody is! Map || expectedBody['version'] != '1') {
        failures.add('${relative(file)} created backup version missing.');
      }
    }
    if (id == 'get-current-backup-version' ||
        id == 'get-specific-backup-version') {
      final expectedBody = step['expected_body_contains'];
      if (expectedBody is! Map ||
          expectedBody['algorithm'] !=
              'm.megolm_backup.v1.curve25519-aes-sha2') {
        failures.add('${relative(file)} backup version response invalid.');
      }
    }
  }
}

void validateMatrixKeyBackupSessionRestore(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixE2eeReference(file, eventMap, failures);
  final roomId = eventMap['room_id'];
  if (roomId is! String || !isMatrixRoomId(roomId)) {
    failures.add('${relative(file)} room_id must be a Matrix room ID.');
  }
  if (eventMap['session_id'] != 'megolm-session-1') {
    failures.add('${relative(file)} session_id is invalid.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = ['upload-room-key-session', 'restore-room-key-session'];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    if (step['path'] !=
        '/_matrix/client/v3/room_keys/keys/!encrypted:example.test/'
            'megolm-session-1') {
      failures.add('${relative(file)} room key backup path invalid.');
    }
    final query = step['query'];
    if (query is! Map || query['version'] != '1') {
      failures.add('${relative(file)} room key backup version query invalid.');
    }
    if (step['id'] == 'upload-room-key-session') {
      if (step['method'] != 'PUT' ||
          step['expected_status'] != 200 ||
          step['server_must_not_decrypt'] != true) {
        failures.add('${relative(file)} room key upload step invalid.');
      }
      validateMatrixKeyBackupData(file, step['body'], failures);
    }
    if (step['id'] == 'restore-room-key-session') {
      if (step['method'] != 'GET' || step['expected_status'] != 200) {
        failures.add('${relative(file)} room key restore step invalid.');
      }
      validateMatrixKeyBackupData(
        file,
        step['expected_body_contains'],
        failures,
      );
    }
  }
}

void validateMatrixKeyBackupLogoutReloginGate(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixE2eeReference(file, eventMap, failures);
  requireStringListIncludes(file, eventMap, 'required_contracts', {
    'SPEC-050',
    'SPEC-052',
    'SPEC-053',
  }, failures);
  if (eventMap['crypto_stack_required'] != true ||
      eventMap['local_olm_megolm_allowed'] != false) {
    failures.add('${relative(file)} key backup crypto boundary invalid.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'create-or-discover-trusted-backup',
    'upload-room-session',
    'logout-and-clear-local-session',
    'relogin-new-device-session',
    'restore-room-session-from-backup',
    'decrypt-previous-encrypted-event',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map || item['required'] != true) {
      failures.add('${relative(file)} all key backup recovery steps required.');
      continue;
    }
    if (item['contract'] is! String) {
      failures.add('${relative(file)} key backup step contract missing.');
    }
  }
  requireStringListIncludes(file, eventMap, 'required_evidence', {
    'houra_spec_ref',
    'houra_server_ref',
    'houra_client_ref',
    'crypto_stack_name',
    'crypto_stack_version',
    'backup_version',
    'commands',
    'per_step_pass_fail',
  }, failures);
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['logout_relogin_restore'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} key backup recovery expectation invalid.');
  }
}

void validateMatrixKeyBackupVersionBody(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map ||
      value['algorithm'] != 'm.megolm_backup.v1.curve25519-aes-sha2' ||
      value['auth_data'] is! Map) {
    failures.add('${relative(file)} key backup version body invalid.');
    return;
  }
  final authData = value['auth_data'] as Map;
  if (authData['public_key'] is! String || authData['signatures'] is! Map) {
    failures.add('${relative(file)} key backup auth_data invalid.');
  }
}

void validateMatrixKeyBackupOwnerScope(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixE2eeReference(file, eventMap, failures);
  if (eventMap['backup_owner_user_id'] != '@alice:example.test' ||
      eventMap['request_user_id'] != '@bob:example.test' ||
      eventMap['backup_version'] != '1' ||
      eventMap['room_id'] != '!encrypted:example.test' ||
      eventMap['session_id'] != 'megolm-session-1') {
    failures.add('${relative(file)} key backup owner-scope actors invalid.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'read-other-user-backup-version',
    'overwrite-other-user-backup-version',
    'restore-other-user-room-key-session',
    'overwrite-other-user-room-key-session',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      failures.add(
        '${relative(file)} key backup owner step must be an object.',
      );
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    if (step['access_token'] != 'token-bob-device1') {
      failures.add('${relative(file)} owner-scope step must use Bob token.');
    }
    validateMatrixStepError(file, step, 404, 'M_NOT_FOUND', failures);
    if (id == 'read-other-user-backup-version') {
      if (step['method'] != 'GET' ||
          step['path'] != '/_matrix/client/v3/room_keys/version/1' ||
          step['must_not_disclose_protected_backup'] != true) {
        failures.add('${relative(file)} read owner-scope step invalid.');
      }
    } else if (id == 'overwrite-other-user-backup-version') {
      if (step['method'] != 'PUT' ||
          step['path'] != '/_matrix/client/v3/room_keys/version/1' ||
          step['must_not_mutate_protected_backup'] != true) {
        failures.add('${relative(file)} update owner-scope step invalid.');
      }
      validateMatrixKeyBackupVersionBody(file, step['body'], failures);
    } else {
      if (step['path'] !=
          '/_matrix/client/v3/room_keys/keys/!encrypted:example.test/'
              'megolm-session-1') {
        failures.add('${relative(file)} room key owner-scope path invalid.');
      }
      final query = step['query'];
      if (query is! Map || query['version'] != '1') {
        failures.add('${relative(file)} room key owner-scope query invalid.');
      }
      if (id == 'restore-other-user-room-key-session') {
        if (step['method'] != 'GET' ||
            step['must_not_disclose_protected_backup'] != true) {
          failures.add('${relative(file)} restore owner-scope step invalid.');
        }
      } else if (id == 'overwrite-other-user-room-key-session') {
        if (step['method'] != 'PUT' ||
            step['must_not_mutate_protected_backup'] != true ||
            step['server_must_not_decrypt'] != true) {
          failures.add('${relative(file)} upload owner-scope step invalid.');
        }
        validateMatrixKeyBackupData(file, step['body'], failures);
      }
    }
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['owner_scope_enforced'] != true ||
      expectedResult['protected_backup_unchanged'] != true) {
    failures.add('${relative(file)} owner-scope expectation invalid.');
  }
}

void validateMatrixKeyBackupData(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map ||
      value['first_message_index'] is! int ||
      value['forwarded_count'] is! int ||
      value['is_verified'] is! bool ||
      value['session_data'] is! Map) {
    failures.add('${relative(file)} key backup data invalid.');
    return;
  }
  final sessionData = value['session_data'] as Map;
  if (sessionData['ephemeral'] is! String ||
      sessionData['ciphertext'] is! String ||
      sessionData['mac'] is! String) {
    failures.add('${relative(file)} key backup session_data invalid.');
  }
}

void checkMatrixVerificationCrossSigningGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-054')) {
    failures.add(
      'Matrix verification/cross-signing contract SPEC-054 is required.',
    );
  }
  const paths = [
    'test-vectors/messaging/matrix-verification-sas-to-device-happy-path.json',
    'test-vectors/messaging/matrix-verification-sas-mismatch-cancel.json',
    'test-vectors/messaging/matrix-cross-signing-key-lifecycle.json',
    'test-vectors/messaging/matrix-cross-signing-missing-token.json',
    'test-vectors/messaging/matrix-cross-signing-invalid-signature.json',
    'test-vectors/messaging/matrix-wrong-device-failure-gate.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix verification/cross-signing vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('sas-to-device')) {
      validateMatrixVerificationSasHappyPath(file, json, failures);
    } else if (path.contains('sas-mismatch')) {
      validateMatrixVerificationSasMismatch(file, json, failures);
    } else if (path.contains('key-lifecycle')) {
      validateMatrixCrossSigningLifecycle(file, json, failures);
    } else if (path.contains('missing-token')) {
      validateMatrixCrossSigningMissingToken(file, json, failures);
    } else if (path.contains('invalid-signature')) {
      validateMatrixSimpleRequestVector(
        file,
        json,
        failures,
        method: 'POST',
        pathPrefix: '/_matrix/client/v3/keys/device_signing/upload',
        status: 400,
        errcode: 'M_INVALID_SIGNATURE',
      );
      final request = json['request'];
      if (request is! Map || request['access_token'] is! String) {
        failures.add(
          '${relative(file)} invalid signature must be authenticated.',
        );
      }
    } else {
      validateMatrixWrongDeviceFailureGate(file, json, failures);
    }
  }
}

void validateMatrixVerificationSasHappyPath(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixE2eeReference(file, eventMap, failures);
  requireStringListIncludes(file, eventMap, 'required_contracts', {
    'SPEC-050',
    'SPEC-051',
    'SPEC-052',
    'SPEC-054',
  }, failures);
  if (eventMap['transport'] != 'to_device' ||
      eventMap['transaction_id'] != 'verif-txn-1') {
    failures.add('${relative(file)} SAS verification metadata invalid.');
  }
  validateMatrixVerificationParticipant(file, eventMap['initiator'], failures);
  validateMatrixVerificationParticipant(file, eventMap['recipient'], failures);
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'send-verification-request',
    'send-verification-ready',
    'send-verification-start',
    'send-verification-accept',
    'exchange-verification-keys',
    'exchange-verification-mac',
    'mark-device-verified',
  ];
  validateStepOrder(file, steps, expected, failures);
  const expectedTypes = {
    'send-verification-request': 'm.key.verification.request',
    'send-verification-ready': 'm.key.verification.ready',
    'send-verification-start': 'm.key.verification.start',
    'send-verification-accept': 'm.key.verification.accept',
    'exchange-verification-keys': 'm.key.verification.key',
    'exchange-verification-mac': 'm.key.verification.mac',
  };
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    if (id is String && expectedTypes.containsKey(id)) {
      if (step['type'] != expectedTypes[id] || step['to_device'] != true) {
        failures.add('${relative(file)} SAS verification step type invalid.');
      }
      final content = step['content'];
      if (content is! Map || content['transaction_id'] != 'verif-txn-1') {
        failures.add(
          '${relative(file)} SAS verification transaction_id invalid.',
        );
      }
      if ((id == 'send-verification-start' ||
              id == 'send-verification-accept') &&
          content is Map &&
          content['method'] != 'm.sas.v1') {
        failures.add('${relative(file)} SAS verification method invalid.');
      }
    }
    if (id == 'mark-device-verified') {
      final result = step['result'];
      if (step['adapter_owned'] != true ||
          result is! Map ||
          result['verified'] != true) {
        failures.add('${relative(file)} verified device result invalid.');
      }
    }
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['verified'] != true ||
      expectedResult['local_sas_allowed'] != false ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} SAS verification expectation invalid.');
  }
}

void validateMatrixVerificationSasMismatch(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixE2eeReference(file, eventMap, failures);
  if (eventMap['transport'] != 'to_device') {
    failures.add('${relative(file)} SAS mismatch transport must be to_device.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'detect-sas-mismatch',
    'send-verification-cancel',
    'leave-device-unverified',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    if (id == 'detect-sas-mismatch' &&
        (step['adapter_owned'] != true || step['required'] != true)) {
      failures.add('${relative(file)} SAS mismatch detection flags invalid.');
    }
    if (id == 'send-verification-cancel') {
      final content = step['content'];
      if (step['type'] != 'm.key.verification.cancel' ||
          step['to_device'] != true ||
          content is! Map ||
          content['code'] != 'm.mismatched_sas' ||
          content['transaction_id'] != 'verif-txn-mismatch') {
        failures.add('${relative(file)} SAS mismatch cancel invalid.');
      }
    }
    if (id == 'leave-device-unverified') {
      final result = step['result'];
      if (result is! Map || result['verified'] != false) {
        failures.add('${relative(file)} SAS mismatch trust result invalid.');
      }
    }
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['cancel_code'] != 'm.mismatched_sas' ||
      expectedResult['verified'] != false ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} SAS mismatch expectation invalid.');
  }
}

void validateMatrixCrossSigningLifecycle(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixE2eeReference(file, eventMap, failures);
  requireStringListIncludes(file, eventMap, 'required_contracts', {
    'SPEC-050',
    'SPEC-051',
    'SPEC-054',
  }, failures);
  if (eventMap['user_id'] != '@alice:example.test' ||
      eventMap['server_must_not_store_private_keys'] != true) {
    failures.add('${relative(file)} cross-signing metadata invalid.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'upload-cross-signing-keys',
    'query-cross-signing-keys',
    'upload-device-signature',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    if (step['expected_status'] != 200 || step['method'] != 'POST') {
      failures.add('${relative(file)} cross-signing step status invalid.');
    }
    if (step['access_token'] != 'token-alice-device1') {
      failures.add(
        '${relative(file)} cross-signing protected step missing access token.',
      );
    }
    final id = step['id'];
    if (id == 'upload-cross-signing-keys') {
      if (step['path'] != '/_matrix/client/v3/keys/device_signing/upload') {
        failures.add('${relative(file)} device_signing path invalid.');
      }
      final body = step['body'];
      if (body is! Map) {
        failures.add('${relative(file)} cross-signing upload body invalid.');
      } else {
        validateMatrixCrossSigningKey(
          file,
          body['master_key'],
          'master',
          failures,
        );
        validateMatrixCrossSigningKey(
          file,
          body['self_signing_key'],
          'self_signing',
          failures,
        );
        validateMatrixCrossSigningKey(
          file,
          body['user_signing_key'],
          'user_signing',
          failures,
        );
      }
    } else if (id == 'query-cross-signing-keys') {
      if (step['path'] != '/_matrix/client/v3/keys/query') {
        failures.add('${relative(file)} keys/query path invalid.');
      }
      final response = step['expected_body_contains'];
      if (response is! Map ||
          response['master_keys'] is! Map ||
          response['self_signing_keys'] is! Map ||
          response['user_signing_keys'] is! Map) {
        failures.add('${relative(file)} cross-signing query response invalid.');
      }
    } else if (id == 'upload-device-signature') {
      if (step['path'] != '/_matrix/client/v3/keys/signatures/upload') {
        failures.add('${relative(file)} signatures upload path invalid.');
      }
      final response = step['expected_body_contains'];
      if (response is! Map || response['failures'] is! Map) {
        failures.add(
          '${relative(file)} signatures upload expectation invalid.',
        );
      }
    }
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['cross_signing_public_keys_available'] != true ||
      expectedResult['signature_failures_empty'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} cross-signing expectation invalid.');
  }
}

void validateMatrixCrossSigningMissingToken(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixE2eeReference(file, eventMap, failures);
  requireStringListIncludes(file, eventMap, 'required_contracts', {
    'SPEC-050',
    'SPEC-051',
    'SPEC-054',
  }, failures);
  if (eventMap['auth_precedes_signature_validation'] != true) {
    failures.add('${relative(file)} auth precedence flag missing.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = {
    'missing-token-device-signing-upload':
        '/_matrix/client/v3/keys/device_signing/upload',
    'missing-token-keys-query': '/_matrix/client/v3/keys/query',
    'missing-token-signatures-upload':
        '/_matrix/client/v3/keys/signatures/upload',
  };
  validateStepOrder(file, steps, expected.keys.toList(), failures);
  for (final item in steps) {
    if (item is! Map) {
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    if (id is! String || !expected.containsKey(id)) {
      failures.add('${relative(file)} unexpected missing-token step.');
      continue;
    }
    if (step['method'] != 'POST' ||
        step['path'] != expected[id] ||
        step.containsKey('access_token') ||
        step['expected_status'] != 401) {
      failures.add('${relative(file)} missing-token request invalid.');
    }
    final error = step['expected_error'];
    if (error is! Map ||
        error['errcode'] != 'M_MISSING_TOKEN' ||
        error['error'] is! String) {
      failures.add('${relative(file)} missing-token error invalid.');
    }
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['protected_key_operations_require_token'] != true ||
      expectedResult['semantic_errors_suppressed_until_authenticated'] !=
          true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} missing-token expectation invalid.');
  }
}

void validateMatrixWrongDeviceFailureGate(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixE2eeReference(file, eventMap, failures);
  requireStringListIncludes(file, eventMap, 'required_contracts', {
    'SPEC-050',
    'SPEC-051',
    'SPEC-052',
    'SPEC-054',
  }, failures);
  if (eventMap['crypto_stack_required'] != true ||
      eventMap['local_cross_signing_crypto_allowed'] != false) {
    failures.add('${relative(file)} wrong-device crypto boundary invalid.');
  }
  validateMatrixIdentitySnapshot(file, eventMap['trusted_identity'], failures);
  validateMatrixIdentitySnapshot(file, eventMap['observed_identity'], failures);
  final trusted = eventMap['trusted_identity'];
  final observed = eventMap['observed_identity'];
  if (trusted is Map && observed is Map) {
    if (trusted['master_key'] == observed['master_key'] &&
        trusted['device_key'] == observed['device_key']) {
      failures.add('${relative(file)} wrong-device mismatch not represented.');
    }
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'load-established-trust-chain',
    'observe-device-or-master-key-mismatch',
    'refuse-to-mark-device-verified',
    'refuse-outbound-session-share',
    'record-verification-failure',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map || item['required'] != true) {
      failures.add('${relative(file)} all wrong-device steps required.');
      continue;
    }
    if (item['contract'] is! String) {
      failures.add('${relative(file)} wrong-device step contract missing.');
    }
    if (item['id'] == 'record-verification-failure' &&
        item['cancel_code'] != 'm.key_mismatch') {
      failures.add('${relative(file)} wrong-device cancel code invalid.');
    }
  }
  requireStringListIncludes(file, eventMap, 'required_evidence', {
    'houra_spec_ref',
    'houra_server_ref',
    'houra_client_ref',
    'crypto_stack_name',
    'crypto_stack_version',
    'trusted_fingerprint',
    'observed_fingerprint',
    'commands',
    'per_step_pass_fail',
  }, failures);
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['device_verified'] != false ||
      expectedResult['outbound_session_shared'] != false ||
      expectedResult['requires_user_reverification'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} wrong-device expectation invalid.');
  }
}

void validateMatrixVerificationParticipant(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map ||
      value['user_id'] is! String ||
      !(value['user_id'] as String).startsWith('@') ||
      value['device_id'] is! String ||
      (value['device_id'] as String).isEmpty) {
    failures.add('${relative(file)} verification participant invalid.');
  }
}

void validateMatrixCrossSigningKey(
  File file,
  Object? value,
  String expectedUsage,
  List<String> failures,
) {
  if (value is! Map ||
      value['user_id'] != '@alice:example.test' ||
      value['usage'] is! List ||
      value['keys'] is! Map) {
    failures.add('${relative(file)} cross-signing key invalid.');
    return;
  }
  final usage = (value['usage'] as List).cast<Object?>();
  if (usage.length != 1 || usage.first != expectedUsage) {
    failures.add('${relative(file)} cross-signing key usage invalid.');
  }
  final keys = (value['keys'] as Map).cast<String, Object?>();
  if (keys.length != 1 ||
      keys.keys.any((key) => !key.startsWith('ed25519:')) ||
      keys.values.any((key) => key is! String || key.isEmpty)) {
    failures.add('${relative(file)} cross-signing public key invalid.');
  }
  if (expectedUsage != 'master') {
    final signatures = value['signatures'];
    if (signatures is! Map || signatures['@alice:example.test'] is! Map) {
      failures.add('${relative(file)} cross-signing signature invalid.');
    }
  }
}

void validateMatrixIdentitySnapshot(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map ||
      value['user_id'] is! String ||
      !(value['user_id'] as String).startsWith('@') ||
      value['device_id'] is! String ||
      (value['device_id'] as String).isEmpty ||
      value['master_key'] is! String ||
      value['device_key'] is! String) {
    failures.add('${relative(file)} identity snapshot invalid.');
  }
}

void checkMatrixFederationDiscoverySigningKeys(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-055')) {
    failures.add(
      'Matrix federation discovery/signing keys contract SPEC-055 is required.',
    );
  }
  const paths = [
    'test-vectors/core/matrix-federation-well-known-server-basic.json',
    'test-vectors/core/matrix-federation-signing-key-basic.json',
    'test-vectors/core/matrix-federation-key-query-basic.json',
    'test-vectors/core/matrix-federation-destination-resolution-failure.json',
    'test-vectors/core/matrix-federation-outbound-destination-controls.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add(
        'Missing Matrix federation discovery/signing key vector: $path',
      );
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('well-known')) {
      validateMatrixFederationWellKnown(file, json, failures);
    } else if (path.contains('signing-key-basic')) {
      validateMatrixFederationSigningKey(file, json, failures);
    } else if (path.contains('key-query')) {
      validateMatrixFederationKeyQuery(file, json, failures);
    } else if (path.contains('outbound-destination-controls')) {
      validateMatrixFederationOutboundDestinationControls(file, json, failures);
    } else {
      validateMatrixFederationDestinationFailure(file, json, failures);
    }
  }
}

void validateMatrixFederationWellKnown(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  final response = vector['response'];
  if (request is! Map ||
      request['method'] != 'GET' ||
      request['path'] != '/.well-known/matrix/server' ||
      request['host'] != 'example.test') {
    failures.add('${relative(file)} well-known request invalid.');
  }
  if (response is! Map || response['status'] != 200) {
    failures.add('${relative(file)} well-known response status invalid.');
    return;
  }
  final body = response['body'];
  final delegated = body is Map ? body['m.server'] : null;
  if (delegated is! String || !isMatrixServerNameForVector(delegated)) {
    failures.add('${relative(file)} well-known m.server invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['status'] != 200 ||
      expectedResult['delegated_server_name'] != delegated ||
      expectedResult['cacheable'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} well-known expectation invalid.');
  }
}

void validateMatrixFederationSigningKey(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  if (request is! Map ||
      request['method'] != 'GET' ||
      request['path'] != '/_matrix/key/v2/server') {
    failures.add('${relative(file)} signing key request invalid.');
  }
  final response = vector['response'];
  final body = response is Map ? response['body'] : null;
  if (response is! Map || response['status'] != 200 || body is! Map) {
    failures.add('${relative(file)} signing key response invalid.');
    return;
  }
  validateMatrixServerKeyObject(file, body, failures);
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['status'] != 200 ||
      expectedResult['contains_private_key'] != false ||
      expectedResult['effective_validity_days_max'] != 7 ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} signing key expectation invalid.');
  }
}

void validateMatrixFederationKeyQuery(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  if (request is! Map ||
      request['method'] != 'POST' ||
      request['path'] != '/_matrix/key/v2/query') {
    failures.add('${relative(file)} key query request invalid.');
    return;
  }
  final body = request['body'];
  final serverKeys = body is Map ? body['server_keys'] : null;
  if (serverKeys is! Map || serverKeys['example.test'] is! Map) {
    failures.add('${relative(file)} key query body invalid.');
  }
  final response = vector['response'];
  final responseBody = response is Map ? response['body'] : null;
  final keys = responseBody is Map ? responseBody['server_keys'] : null;
  if (response is! Map ||
      response['status'] != 200 ||
      keys is! List ||
      keys.length != 1 ||
      keys.first is! Map) {
    failures.add('${relative(file)} key query response invalid.');
    return;
  }
  final keyObject = (keys.first as Map).cast<String, Object?>();
  validateMatrixServerKeyObject(file, keyObject, failures);
  final signatures = keyObject['signatures'];
  if (signatures is! Map || signatures['notary.example.test'] is! Map) {
    failures.add('${relative(file)} key query notary signature missing.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['status'] != 200 ||
      expectedResult['notary_signature_required'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} key query expectation invalid.');
  }
}

void validateMatrixFederationDestinationFailure(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixFederationReference(file, eventMap, failures);
  if (eventMap['server_name'] != 'broken.example.test') {
    failures.add('${relative(file)} destination failure server_name invalid.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'well-known-invalid',
    'matrix-fed-srv-missing',
    'deprecated-matrix-srv-missing',
    'address-resolution-failed',
    'record-failure-backoff',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map || item['required'] != true) {
      failures.add('${relative(file)} all destination failure steps required.');
      continue;
    }
    if (item['stage'] is! String || item['result'] is! Map) {
      failures.add('${relative(file)} destination failure step invalid.');
    }
  }
  final last = steps.last;
  if (last is Map) {
    final result = last['result'];
    if (result is! Map ||
        result['destination_resolved'] != false ||
        result['federation_request_sent'] != false ||
        result['backoff_recorded'] != true) {
      failures.add(
        '${relative(file)} destination failure final result invalid.',
      );
    }
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['destination_resolved'] != false ||
      expectedResult['federation_request_sent'] != false ||
      expectedResult['backoff_recorded'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} destination failure expectation invalid.');
  }
}

void validateMatrixFederationOutboundDestinationControls(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixFederationReference(file, eventMap, failures);
  validateIanaAddressRegistrySources(file, eventMap, failures);
  final allowed = eventMap['allowed_public_case'];
  if (allowed is! Map ||
      allowed['server_name'] != 'public.example.test' ||
      allowed['delegated_server_name'] != 'delegated.example.test:8448' ||
      allowed['resolved_addresses'] is! List ||
      allowed['destination_allowed'] != true ||
      allowed['federation_request_sent'] != true) {
    failures.add('${relative(file)} allowed federation egress case invalid.');
  }
  final cases = eventMap['unsafe_cases'];
  if (cases is! List || cases.length < 5) {
    failures.add('${relative(file)} unsafe federation cases are incomplete.');
    return;
  }
  final seenClassifications = <String>{};
  for (final item in cases) {
    if (item is! Map) {
      failures.add('${relative(file)} unsafe federation case must be object.');
      continue;
    }
    final testCase = item.cast<String, Object?>();
    final id = testCase['id'];
    final classification = testCase['expected_classification'];
    if (id is! String || id.isEmpty || testCase['stage'] is! String) {
      failures.add(
        '${relative(file)} unsafe federation case id/stage invalid.',
      );
    }
    if (classification is! String || classification.isEmpty) {
      failures.add(
        '${relative(file)} unsafe federation classification missing.',
      );
    } else {
      seenClassifications.add(classification);
    }
    if (testCase['expected_blocked'] != true ||
        testCase['federation_request_sent'] != false) {
      failures.add('${relative(file)} unsafe federation case must be blocked.');
    }
    if (id == 'redirect-to-private-well-known' &&
        testCase['redirect_location'] is! String) {
      failures.add('${relative(file)} redirect unsafe case missing location.');
    }
    if (id == 'dns-rebinding-before-connect' &&
        (testCase['initial_resolved_addresses'] is! List ||
            testCase['connect_resolved_addresses'] is! List)) {
      failures.add('${relative(file)} DNS rebinding case invalid.');
    }
  }
  for (final classification in const {
    'loopback',
    'link_local',
    'private_use',
    'redirect_to_unsafe_destination',
    'dns_rebinding_to_private_use',
  }) {
    if (!seenClassifications.contains(classification)) {
      failures.add(
        '${relative(file)} missing unsafe federation class: $classification.',
      );
    }
  }
  final controls = eventMap['controls'];
  if (controls is! Map ||
      controls['redirect_revalidation_required'] != true ||
      controls['dns_revalidation_before_connect'] != true ||
      controls['unsafe_addresses_blocked_before_signed_request'] != true ||
      controls['max_redirects'] is! int ||
      controls['connect_timeout_ms_max'] is! int ||
      controls['read_timeout_ms_max'] is! int ||
      controls['response_body_bytes_max'] is! int) {
    failures.add('${relative(file)} federation outbound controls invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['legitimate_public_egress_allowed'] != true ||
      expectedResult['unsafe_internal_destination_blocked'] != true ||
      expectedResult['federation_request_sent_to_unsafe_destination'] !=
          false ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} federation outbound expectation invalid.');
  }
}

void validateMatrixFederationReference(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final source = eventMap['matrix_spec_source'];
  if (source is! String ||
      !source.startsWith('https://spec.matrix.org/v1.18/server-server-api/#')) {
    failures.add('${relative(file)} matrix_spec_source is invalid.');
  }
}

void validateIanaAddressRegistrySources(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  final ianaSources = readStringList(eventMap['iana_sources']);
  for (final source in const [
    'https://www.iana.org/assignments/iana-ipv4-special-registry',
    'https://www.iana.org/assignments/iana-ipv6-special-registry',
  ]) {
    if (ianaSources == null || !ianaSources.contains(source)) {
      failures.add('${relative(file)} iana_sources must include $source.');
    }
  }
}

void validateMatrixServerKeyObject(
  File file,
  Map<dynamic, dynamic> value,
  List<String> failures,
) {
  final serverName = value['server_name'];
  if (serverName is! String || !isMatrixServerNameForVector(serverName)) {
    failures.add('${relative(file)} server key server_name invalid.');
  }
  if (value.containsKey('private_key') || value.containsKey('signing_key')) {
    failures.add('${relative(file)} server key leaks private key material.');
  }
  if (value['valid_until_ts'] is! int) {
    failures.add('${relative(file)} server key valid_until_ts invalid.');
  }
  validateMatrixVerifyKeys(file, value['verify_keys'], failures);
  final oldKeys = value['old_verify_keys'];
  if (oldKeys is! Map) {
    failures.add('${relative(file)} old_verify_keys must be an object.');
  } else {
    for (final entry in oldKeys.entries) {
      if (entry.key is! String ||
          !isMatrixServerKeyId(entry.key as String) ||
          entry.value is! Map ||
          (entry.value as Map)['expired_ts'] is! int ||
          (entry.value as Map)['key'] is! String) {
        failures.add('${relative(file)} old_verify_keys entry invalid.');
      }
    }
  }
  final signatures = value['signatures'];
  if (signatures is! Map || signatures[serverName] is! Map) {
    failures.add('${relative(file)} server key signatures invalid.');
  }
}

void validateMatrixVerifyKeys(File file, Object? value, List<String> failures) {
  if (value is! Map || value.isEmpty) {
    failures.add('${relative(file)} verify_keys must be a non-empty object.');
    return;
  }
  for (final entry in value.entries) {
    if (entry.key is! String ||
        !isMatrixServerKeyId(entry.key as String) ||
        entry.value is! Map ||
        (entry.value as Map)['key'] is! String) {
      failures.add('${relative(file)} verify_keys entry invalid.');
    }
  }
}

bool isMatrixServerNameForVector(String value) {
  if (value.isEmpty || value.length > 255) {
    return false;
  }
  if (value.startsWith('[') && !value.contains(']')) {
    return false;
  }
  final portIndex = value.lastIndexOf(':');
  final host = value.startsWith('[')
      ? value.substring(0, value.indexOf(']') + 1)
      : portIndex > 0 && value.indexOf(':') == portIndex
      ? value.substring(0, portIndex)
      : value;
  final port = value.startsWith('[')
      ? value.substring(value.indexOf(']') + 1)
      : portIndex > 0 && value.indexOf(':') == portIndex
      ? value.substring(portIndex)
      : '';
  if (port.isNotEmpty && !RegExp(r'^:[0-9]{1,5}$').hasMatch(port)) {
    return false;
  }
  if (RegExp(r'^[A-Za-z0-9.-]+$').hasMatch(host)) {
    return true;
  }
  if (RegExp(r'^[0-9]{1,3}(?:\.[0-9]{1,3}){3}$').hasMatch(host)) {
    return true;
  }
  return RegExp(r'^\[[0-9A-Fa-f:.]+\]$').hasMatch(host);
}

bool isMatrixServerKeyId(String value) =>
    RegExp(r'^ed25519:[A-Za-z0-9_]+$').hasMatch(value);

void checkMatrixFederationTransactionJoinInvite(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-056')) {
    failures.add(
      'Matrix federation transaction/join/invite contract SPEC-056 is required.',
    );
  }
  const paths = [
    'test-vectors/events/matrix-federation-send-transaction-basic.json',
    'test-vectors/events/matrix-federation-send-transaction-pdu-failure.json',
    'test-vectors/events/matrix-federation-make-send-join-basic.json',
    'test-vectors/events/matrix-federation-invite-v2-basic.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix federation transaction vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('send-transaction-basic')) {
      validateMatrixFederationTransaction(
        file,
        json,
        failures,
        expectPduError: false,
      );
    } else if (path.contains('pdu-failure')) {
      validateMatrixFederationTransaction(
        file,
        json,
        failures,
        expectPduError: true,
      );
    } else if (path.contains('make-send-join')) {
      validateMatrixFederationJoin(file, json, failures);
    } else {
      validateMatrixFederationInvite(file, json, failures);
    }
  }
}

void validateMatrixFederationTransaction(
  File file,
  Map<String, Object?> vector,
  List<String> failures, {
  required bool expectPduError,
}) {
  final request = vector['request'];
  if (request is! Map ||
      request['method'] != 'PUT' ||
      request['path'] is! String ||
      !(request['path'] as String).startsWith('/_matrix/federation/v1/send/')) {
    failures.add('${relative(file)} federation transaction request invalid.');
    return;
  }
  validateMatrixFederationAuthorization(
    file,
    request['authorization'],
    failures,
  );
  final body = request['body'];
  if (body is! Map ||
      body['origin'] != 'remote.example.test' ||
      body['origin_server_ts'] is! int ||
      body['pdus'] is! List) {
    failures.add('${relative(file)} federation transaction body invalid.');
    return;
  }
  final pdus = (body['pdus'] as List).cast<Object?>();
  final edus = body['edus'];
  if (pdus.length > 50) {
    failures.add('${relative(file)} federation transaction PDU count invalid.');
  }
  if (edus is List && edus.length > 100) {
    failures.add('${relative(file)} federation transaction EDU count invalid.');
  }
  for (final pdu in pdus) {
    validateMatrixFederationPdu(file, pdu, failures);
  }
  final response = vector['response'];
  final responseBody = response is Map ? response['body'] : null;
  final resultPdus = responseBody is Map ? responseBody['pdus'] : null;
  if (response is! Map || response['status'] != 200 || resultPdus is! Map) {
    failures.add('${relative(file)} federation transaction response invalid.');
    return;
  }
  final hasPduError = resultPdus.values.any(
    (value) => value is Map && value['error'] is String,
  );
  if (hasPduError != expectPduError) {
    failures.add('${relative(file)} federation PDU error expectation invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['status'] != 200 ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} federation transaction expectation invalid.',
    );
    return;
  }
  final expectedMap = expectedResult.cast<String, Object?>();
  if (!expectPduError &&
      (expectedMap['pdu_count_max'] != 50 ||
          expectedMap['edu_count_max'] != 100 ||
          expectedMap['accepted_event_id'] is! String)) {
    failures.add('${relative(file)} federation transaction limits invalid.');
  }
  if (expectPduError &&
      (expectedMap['transaction_failed'] != false ||
          expectedMap['pdu_error_recorded'] != true)) {
    failures.add(
      '${relative(file)} federation transaction failure expectation invalid.',
    );
  }
}

void validateMatrixFederationJoin(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixFederationReference(file, eventMap, failures);
  if (eventMap['room_id'] != '!room:example.test' ||
      eventMap['user_id'] != '@alice:remote.example.test' ||
      eventMap['room_version'] != '12') {
    failures.add('${relative(file)} federation join metadata invalid.');
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'make-join-request',
    'make-join-response',
    'sign-join-event',
    'send-join-request',
    'send-join-response',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map) {
      failures.add('${relative(file)} federation join step invalid.');
      continue;
    }
    final step = item.cast<String, Object?>();
    final id = step['id'];
    if (id == 'make-join-request') {
      if (step['method'] != 'GET' ||
          step['path'] !=
              '/_matrix/federation/v1/make_join/!room:example.test/'
                  '@alice:remote.example.test' ||
          step['expected_status'] != 200) {
        failures.add('${relative(file)} make_join request invalid.');
      }
      validateMatrixFederationAuthorization(
        file,
        step['authorization'],
        failures,
      );
    } else if (id == 'make-join-response') {
      final body = step['body'];
      final event = body is Map ? body['event'] : null;
      if (step['expected_status'] != 200 ||
          body is! Map ||
          body['room_version'] != '12') {
        failures.add('${relative(file)} make_join response invalid.');
      }
      validateMatrixFederationMembershipEvent(
        file,
        event,
        'join',
        failures,
        requireEventId: false,
      );
    } else if (id == 'sign-join-event') {
      final result = step['result'];
      if (step['required'] != true ||
          result is! Map ||
          result['signed_by_joining_server'] != true ||
          result['event_id'] is! String ||
          !isMatrixEventId(result['event_id'] as String)) {
        failures.add('${relative(file)} sign join step invalid.');
      }
    } else if (id == 'send-join-request') {
      if (step['method'] != 'PUT' ||
          step['path'] !=
              '/_matrix/federation/v2/send_join/!room:example.test/'
                  r'$join:remote.example.test' ||
          step['expected_status'] != 200) {
        failures.add('${relative(file)} send_join request invalid.');
      }
      validateMatrixFederationAuthorization(
        file,
        step['authorization'],
        failures,
      );
      validateMatrixFederationMembershipEvent(
        file,
        step['body'],
        'join',
        failures,
        requireEventId: true,
      );
    } else if (id == 'send-join-response') {
      final body = step['body'];
      if (step['expected_status'] != 200 ||
          body is! Map ||
          body['state'] is! List ||
          body['auth_chain'] is! List) {
        failures.add('${relative(file)} send_join response invalid.');
      } else {
        validateMatrixFederationMembershipEvent(
          file,
          body['event'],
          'join',
          failures,
          requireEventId: true,
        );
      }
    }
  }
  requireStringListIncludes(file, eventMap, 'required_evidence', {
    'houra_spec_ref',
    'houra_server_ref',
    'resident_server',
    'joining_server',
    'room_version',
    'commands',
    'per_step_pass_fail',
  }, failures);
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['join_accepted'] != true ||
      expectedResult['state_returned'] != true ||
      expectedResult['auth_chain_returned'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} federation join expectation invalid.');
  }
}

void validateMatrixFederationInvite(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  if (request is! Map ||
      request['method'] != 'PUT' ||
      request['path'] !=
          '/_matrix/federation/v2/invite/!room:example.test/'
              r'$invite:example.test') {
    failures.add('${relative(file)} federation invite request invalid.');
    return;
  }
  validateMatrixFederationAuthorization(
    file,
    request['authorization'],
    failures,
  );
  final body = request['body'];
  final event = body is Map ? body['event'] : null;
  if (body is! Map || body['room_version'] != '12') {
    failures.add('${relative(file)} federation invite body invalid.');
  }
  validateMatrixFederationMembershipEvent(
    file,
    event,
    'invite',
    failures,
    requireEventId: true,
  );
  final response = vector['response'];
  final responseBody = response is Map ? response['body'] : null;
  if (response is! Map || response['status'] != 200 || responseBody is! Map) {
    failures.add('${relative(file)} federation invite response invalid.');
    return;
  }
  validateMatrixFederationMembershipEvent(
    file,
    responseBody['event'],
    'invite',
    failures,
    requireEventId: true,
  );
  final responseEvent = responseBody['event'];
  final signatures = responseEvent is Map ? responseEvent['signatures'] : null;
  if (signatures is! Map ||
      signatures['example.test'] is! Map ||
      signatures['remote.example.test'] is! Map) {
    failures.add('${relative(file)} federation invite signatures invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['status'] != 200 ||
      expectedResult['invite_signed_by_origin'] != true ||
      expectedResult['invite_signed_by_destination'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} federation invite expectation invalid.');
  }
}

void validateMatrixFederationAuthorization(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map ||
      value['scheme'] != 'X-Matrix' ||
      value['origin'] is! String ||
      !isMatrixServerNameForVector(value['origin'] as String) ||
      value['destination'] is! String ||
      !isMatrixServerNameForVector(value['destination'] as String) ||
      value['key'] is! String ||
      !isMatrixServerKeyId(value['key'] as String) ||
      value['signed_json'] != true) {
    failures.add('${relative(file)} federation authorization invalid.');
  }
}

void validateMatrixFederationPdu(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map ||
      value['event_id'] is! String ||
      !isMatrixEventId(value['event_id'] as String) ||
      value['type'] is! String ||
      value['room_id'] is! String ||
      !isMatrixRoomId(value['room_id'] as String) ||
      value['sender'] is! String ||
      !(value['sender'] as String).startsWith('@') ||
      value['origin_server_ts'] is! int ||
      value['prev_events'] is! List ||
      value['auth_events'] is! List ||
      value['content'] is! Map ||
      value['hashes'] is! Map ||
      value['signatures'] is! Map) {
    failures.add('${relative(file)} federation PDU invalid.');
  }
}

void validateMatrixFederationMembershipEvent(
  File file,
  Object? value,
  String membership,
  List<String> failures, {
  required bool requireEventId,
}) {
  if (value is! Map ||
      value['type'] != 'm.room.member' ||
      value['room_id'] != '!room:example.test' ||
      value['sender'] is! String ||
      !(value['sender'] as String).startsWith('@') ||
      value['state_key'] is! String ||
      !(value['state_key'] as String).startsWith('@') ||
      value['content'] is! Map ||
      (value['content'] as Map)['membership'] != membership) {
    failures.add('${relative(file)} federation membership event invalid.');
    return;
  }
  if (requireEventId &&
      (value['event_id'] is! String ||
          !isMatrixEventId(value['event_id'] as String))) {
    failures.add('${relative(file)} federation membership event_id invalid.');
  }
}

void checkMatrixFederationBackfillAuthState(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-057')) {
    failures.add(
      'Matrix federation backfill/event-auth/state contract SPEC-057 is required.',
    );
  }
  const paths = [
    'test-vectors/events/matrix-federation-backfill-basic.json',
    'test-vectors/events/matrix-federation-event-auth-basic.json',
    'test-vectors/events/matrix-federation-state-ids-basic.json',
    'test-vectors/events/matrix-federation-state-resolution-interop-gate.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add(
        'Missing Matrix federation backfill/event-auth/state vector: $path',
      );
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('backfill-basic')) {
      validateMatrixFederationBackfill(file, json, failures);
    } else if (path.contains('event-auth')) {
      validateMatrixFederationEventAuth(file, json, failures);
    } else if (path.contains('state-ids')) {
      validateMatrixFederationStateIds(file, json, failures);
    } else {
      validateMatrixFederationStateInteropGate(file, json, failures);
    }
  }
}

void validateMatrixFederationBackfill(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  if (request is! Map ||
      request['method'] != 'GET' ||
      request['path'] != '/_matrix/federation/v1/backfill/!room:example.test') {
    failures.add('${relative(file)} federation backfill request invalid.');
    return;
  }
  validateMatrixFederationAuthorization(
    file,
    request['authorization'],
    failures,
  );
  final query = request['query'];
  if (query is! Map ||
      query['v'] is! List ||
      (query['v'] as List).isEmpty ||
      (query['v'] as List).any(
        (value) => value is! String || !isMatrixEventId(value),
      ) ||
      query['limit'] is! int ||
      (query['limit'] as int) < 1) {
    failures.add('${relative(file)} federation backfill query invalid.');
  }
  final response = vector['response'];
  final body = response is Map ? response['body'] : null;
  final pdus = body is Map ? body['pdus'] : null;
  if (response is! Map ||
      response['status'] != 200 ||
      body is! Map ||
      body['origin'] != 'example.test' ||
      body['origin_server_ts'] is! int ||
      pdus is! List ||
      pdus.isEmpty) {
    failures.add('${relative(file)} federation backfill response invalid.');
    return;
  }
  for (final pdu in pdus) {
    validateMatrixFederationPdu(file, pdu, failures);
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['status'] != 200 ||
      expectedResult['backfilled_from'] != r'$event3:example.test' ||
      expectedResult['pdu_count'] != pdus.length ||
      expectedResult['historical_prev_auth_count_relaxed'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} federation backfill expectation invalid.');
  }
}

void validateMatrixFederationEventAuth(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  if (request is! Map ||
      request['method'] != 'GET' ||
      request['path'] !=
          '/_matrix/federation/v1/event_auth/!room:example.test/'
              r'$event3:example.test') {
    failures.add('${relative(file)} federation event_auth request invalid.');
    return;
  }
  validateMatrixFederationAuthorization(
    file,
    request['authorization'],
    failures,
  );
  final response = vector['response'];
  final body = response is Map ? response['body'] : null;
  final authChain = body is Map ? body['auth_chain'] : null;
  if (response is! Map ||
      response['status'] != 200 ||
      authChain is! List ||
      authChain.isEmpty) {
    failures.add('${relative(file)} federation event_auth response invalid.');
    return;
  }
  for (final pdu in authChain) {
    validateMatrixFederationPdu(file, pdu, failures);
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['status'] != 200 ||
      expectedResult['auth_chain_count'] != authChain.length ||
      expectedResult['room_version'] != '12' ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} federation event_auth expectation invalid.',
    );
  }
}

void validateMatrixFederationStateIds(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  if (request is! Map ||
      request['method'] != 'GET' ||
      request['path'] !=
          '/_matrix/federation/v1/state_ids/!room:example.test') {
    failures.add('${relative(file)} federation state_ids request invalid.');
    return;
  }
  validateMatrixFederationAuthorization(
    file,
    request['authorization'],
    failures,
  );
  final query = request['query'];
  if (query is! Map || query['event_id'] != r'$event3:example.test') {
    failures.add('${relative(file)} federation state_ids query invalid.');
  }
  final response = vector['response'];
  final body = response is Map ? response['body'] : null;
  final pduIds = body is Map ? body['pdu_ids'] : null;
  final authChainIds = body is Map ? body['auth_chain_ids'] : null;
  if (response is! Map ||
      response['status'] != 200 ||
      pduIds is! List ||
      authChainIds is! List ||
      pduIds.isEmpty ||
      authChainIds.isEmpty ||
      pduIds.any((value) => value is! String || !isMatrixEventId(value)) ||
      authChainIds.any(
        (value) => value is! String || !isMatrixEventId(value),
      )) {
    failures.add('${relative(file)} federation state_ids response invalid.');
    return;
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['status'] != 200 ||
      expectedResult['pdu_ids_count'] != pduIds.length ||
      expectedResult['auth_chain_ids_count'] != authChainIds.length ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} federation state_ids expectation invalid.');
  }
}

void validateMatrixFederationStateInteropGate(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixFederationReference(file, eventMap, failures);
  requireStringListIncludes(file, eventMap, 'required_contracts', {
    'SPEC-040',
    'SPEC-041',
    'SPEC-043',
    'SPEC-055',
    'SPEC-056',
    'SPEC-057',
  }, failures);
  if (eventMap['local_server'] != 'local.example.test' ||
      eventMap['remote_server'] != 'remote.example.test' ||
      eventMap['room_id'] != '!room:example.test' ||
      eventMap['room_version'] != '12' ||
      eventMap['target_event_id'] != r'$event3:example.test') {
    failures.add(
      '${relative(file)} federation state interop metadata invalid.',
    );
  }
  final steps = requireMatrixSteps(file, eventMap, failures);
  if (steps == null) {
    return;
  }
  const expected = [
    'receive-event-with-missing-prev-or-auth',
    'backfill-missing-history',
    'fetch-event-auth-chain',
    'fetch-state-ids-at-event',
    'run-representative-state-resolution',
    'run-representative-auth-check',
    'record-event-decision',
  ];
  validateStepOrder(file, steps, expected, failures);
  for (final item in steps) {
    if (item is! Map || item['required'] != true) {
      failures.add(
        '${relative(file)} all federation state interop steps required.',
      );
      continue;
    }
    if (item['contract'] is! String) {
      failures.add(
        '${relative(file)} federation state interop contract missing.',
      );
    }
    final endpoint = item['endpoint'];
    if (endpoint is String && !endpoint.startsWith('/_matrix/federation/v1/')) {
      failures.add(
        '${relative(file)} federation state interop endpoint invalid.',
      );
    }
    if (item['id'] == 'record-event-decision') {
      final allowed = item['allowed_results'];
      if (allowed is! List ||
          !{'accepted', 'soft_failed', 'rejected'}.every(allowed.contains)) {
        failures.add('${relative(file)} event decision results invalid.');
      }
    }
  }
  requireStringListIncludes(file, eventMap, 'required_evidence', {
    'houra_spec_ref',
    'houra_server_ref',
    'local_server',
    'remote_server',
    'room_version',
    'commands',
    'per_step_pass_fail',
    'event_decision',
  }, failures);
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['interop_gate_defined'] != true ||
      expectedResult['full_state_resolution_completeness_claimed'] != false ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} federation state interop expectation invalid.',
    );
  }
}

void checkMatrixApplicationServiceRegistrationTransaction(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-058')) {
    failures.add('Matrix application service contract SPEC-058 is required.');
  }
  const paths = [
    'test-vectors/core/matrix-appservice-registration-basic.json',
    'test-vectors/core/matrix-appservice-namespace-ownership.json',
    'test-vectors/core/matrix-appservice-transaction-basic.json',
    'test-vectors/core/matrix-appservice-query-user-room-basic.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix appservice vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('registration')) {
      validateMatrixAppserviceRegistration(file, json, failures);
    } else if (path.contains('namespace')) {
      validateMatrixAppserviceNamespace(file, json, failures);
    } else if (path.contains('transaction')) {
      validateMatrixAppserviceTransaction(file, json, failures);
    } else {
      validateMatrixAppserviceQueries(file, json, failures);
    }
  }
}

void validateMatrixAppserviceRegistration(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixAppserviceReference(file, eventMap, failures);
  final registration = eventMap['registration'];
  if (registration is! Map) {
    failures.add('${relative(file)} appservice registration missing.');
    return;
  }
  validateMatrixAppserviceRegistrationObject(file, registration, failures);
  if (eventMap['secrets_redacted'] != true) {
    failures.add('${relative(file)} appservice secrets must be redacted.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['valid_registration'] != true ||
      expectedResult['sender_user_id'] != '@_irc_bot:example.test' ||
      expectedResult['tokens_unique'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} appservice registration expectation invalid.',
    );
  }
}

void validateMatrixAppserviceNamespace(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixAppserviceReference(file, eventMap, failures);
  validateMatrixAppserviceNamespaces(file, eventMap['namespaces'], failures);
  final checks = eventMap['checks'];
  if (checks is! List || checks.length != 3) {
    failures.add('${relative(file)} appservice namespace checks invalid.');
  } else {
    for (final item in checks) {
      if (item is! Map ||
          item['id'] is! String ||
          item['kind'] is! String ||
          item['entity'] is! String) {
        failures.add('${relative(file)} appservice namespace check invalid.');
      }
    }
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['exclusive_namespaces_enforced'] != true ||
      expectedResult['nonexclusive_room_namespace_allowed'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} appservice namespace expectation invalid.');
  }
}

void validateMatrixAppserviceTransaction(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  if (request is! Map ||
      request['method'] != 'PUT' ||
      request['path'] != '/_matrix/app/v1/transactions/txn-1') {
    failures.add('${relative(file)} appservice transaction request invalid.');
    return;
  }
  validateMatrixAppserviceAuthorization(
    file,
    request['authorization'],
    failures,
  );
  final body = request['body'];
  final events = body is Map ? body['events'] : null;
  if (body is! Map || events is! List || events.isEmpty) {
    failures.add('${relative(file)} appservice transaction body invalid.');
  }
  final response = vector['response'];
  if (response is! Map ||
      response['status'] != 200 ||
      response['body'] is! Map) {
    failures.add('${relative(file)} appservice transaction response invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['status'] != 200 ||
      expectedResult['idempotent_by_txn_id'] != true ||
      expectedResult['uses_hs_token'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} appservice transaction expectation invalid.',
    );
  }
}

void validateMatrixAppserviceQueries(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixAppserviceReference(file, eventMap, failures);
  final queries = eventMap['queries'];
  if (queries is! List ||
      queries.length != 2 ||
      eventMap['namespace_only'] != true) {
    failures.add('${relative(file)} appservice queries invalid.');
  } else {
    final paths = <String>{};
    for (final item in queries) {
      if (item is! Map ||
          item['method'] != 'GET' ||
          item['path'] is! String ||
          item['expected_status'] != 200) {
        failures.add('${relative(file)} appservice query item invalid.');
        continue;
      }
      validateMatrixAppserviceAuthorization(
        file,
        item['authorization'],
        failures,
      );
      paths.add(item['path'] as String);
    }
    if (!paths.contains(
          '/_matrix/app/v1/users/@_irc_bridge_alice:example.test',
        ) ||
        !paths.contains(
          '/_matrix/app/v1/rooms/#_irc_bridge_lobby:example.test',
        )) {
      failures.add('${relative(file)} appservice query paths invalid.');
    }
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['user_query_defined'] != true ||
      expectedResult['room_alias_query_defined'] != true ||
      expectedResult['queries_limited_to_namespaces'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} appservice query expectation invalid.');
  }
}

void validateMatrixAppserviceReference(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final source = eventMap['matrix_spec_source'];
  if (source is! String ||
      !source.startsWith(
        'https://spec.matrix.org/v1.18/application-service-api/#',
      )) {
    failures.add('${relative(file)} matrix_spec_source is invalid.');
  }
}

void validateMatrixAppserviceRegistrationObject(
  File file,
  Map<dynamic, dynamic> registration,
  List<String> failures,
) {
  for (final key in ['id', 'url', 'as_token', 'hs_token', 'sender_localpart']) {
    if (registration[key] is! String || (registration[key] as String).isEmpty) {
      failures.add('${relative(file)} appservice registration $key invalid.');
    }
  }
  if (registration['as_token'] == registration['hs_token']) {
    failures.add('${relative(file)} appservice tokens must be unique.');
  }
  final senderLocalpart = registration['sender_localpart'];
  if (senderLocalpart is! String || !senderLocalpart.startsWith('_')) {
    failures.add('${relative(file)} sender_localpart should use underscore.');
  }
  validateMatrixAppserviceNamespaces(
    file,
    registration['namespaces'],
    failures,
  );
}

void validateMatrixAppserviceNamespaces(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map) {
    failures.add('${relative(file)} appservice namespaces invalid.');
    return;
  }
  for (final key in ['users', 'aliases', 'rooms']) {
    final entries = value[key];
    if (entries is! List) {
      failures.add('${relative(file)} appservice namespace $key invalid.');
      continue;
    }
    for (final entry in entries) {
      if (entry is! Map ||
          entry['exclusive'] is! bool ||
          entry['regex'] is! String ||
          (entry['regex'] as String).isEmpty) {
        failures.add('${relative(file)} appservice namespace entry invalid.');
      }
    }
  }
}

void validateMatrixAppserviceAuthorization(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map ||
      value['scheme'] != 'Bearer' ||
      value['token'] != 'hs-token-redacted') {
    failures.add('${relative(file)} appservice authorization invalid.');
  }
}

void checkMatrixIdentityServiceBoundary(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-059')) {
    failures.add('Matrix identity service contract SPEC-059 is required.');
  }
  const paths = [
    'test-vectors/core/matrix-identity-service-boundary-basic.json',
    'test-vectors/core/matrix-identity-lookup-hash-details-basic.json',
    'test-vectors/core/matrix-identity-validation-bind-basic.json',
    'test-vectors/core/matrix-identity-unbind-auth-failures.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix identity service vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('service-boundary')) {
      validateMatrixIdentityServiceBoundary(file, json, failures);
    } else if (path.contains('lookup')) {
      validateMatrixIdentityLookup(file, json, failures);
    } else if (path.contains('validation-bind')) {
      validateMatrixIdentityValidationBind(file, json, failures);
    } else {
      validateMatrixIdentityUnbindFailures(file, json, failures);
    }
  }
}

void validateMatrixIdentityServiceBoundary(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixIdentityReference(file, eventMap, failures);
  final boundary = eventMap['service_boundary'];
  if (boundary is! Map ||
      boundary['component'] != 'identity-service' ||
      boundary['deployment'] != 'separate-service' ||
      boundary['not_hidden_homeserver_module'] != true) {
    failures.add('${relative(file)} identity service boundary invalid.');
  }
  final endpoints = eventMap['endpoints'];
  if (endpoints is! List ||
      !endpoints.contains('GET /_matrix/identity/versions') ||
      !endpoints.contains('GET /_matrix/identity/v2/account') ||
      !endpoints.contains('POST /_matrix/identity/v2/account/register')) {
    failures.add('${relative(file)} identity boundary endpoints invalid.');
  }
  final authentication = eventMap['authentication'];
  if (authentication is! Map ||
      authentication['query_access_token_supported_for_compatibility'] !=
          true ||
      authentication['query_access_token_deprecated'] != true ||
      authentication['client_must_emit_query_access_token'] != false ||
      authentication['token_scope'] != 'identity-service-only') {
    failures.add('${relative(file)} identity authentication boundary invalid.');
  }
  validateMatrixIdentitySecrets(file, eventMap, failures);
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['separate_service_boundary'] != true ||
      expectedResult['identity_tokens_not_client_server_tokens'] != true ||
      expectedResult['terms_gate_defined'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} identity boundary expectation invalid.');
  }
}

void validateMatrixIdentityLookup(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixIdentityReference(file, eventMap, failures);
  validateMatrixIdentityRequest(
    file,
    eventMap['hash_details_request'],
    failures,
    method: 'GET',
    path: '/_matrix/identity/v2/hash_details',
    pathPrefix: 'event.hash_details_request',
  );
  final hashResponse = eventMap['hash_details_response'];
  final hashBody = hashResponse is Map ? hashResponse['body'] : null;
  final algorithms = hashBody is Map ? hashBody['algorithms'] : null;
  if (hashResponse is! Map ||
      hashResponse['status'] != 200 ||
      algorithms is! List ||
      !algorithms.contains('sha256') ||
      hashBody['lookup_pepper'] != 'pepper-redacted') {
    failures.add('${relative(file)} identity hash_details response invalid.');
  }
  validateMatrixIdentityRequest(
    file,
    eventMap['lookup_request'],
    failures,
    method: 'POST',
    path: '/_matrix/identity/v2/lookup',
    pathPrefix: 'event.lookup_request',
  );
  final lookupRequest = eventMap['lookup_request'];
  final lookupBody = lookupRequest is Map ? lookupRequest['body'] : null;
  if (lookupBody is! Map ||
      lookupBody['algorithm'] != 'sha256' ||
      lookupBody['pepper'] != 'pepper-redacted' ||
      lookupBody['addresses'] is! List ||
      (lookupBody['addresses'] as List).isEmpty) {
    failures.add('${relative(file)} identity lookup request body invalid.');
  }
  final lookupResponse = eventMap['lookup_response'];
  final responseBody = lookupResponse is Map ? lookupResponse['body'] : null;
  final mappings = responseBody is Map ? responseBody['mappings'] : null;
  if (lookupResponse is! Map ||
      lookupResponse['status'] != 200 ||
      mappings is! Map ||
      mappings['sha256-address-redacted'] != '@alice:example.test') {
    failures.add('${relative(file)} identity lookup response invalid.');
  }
  final privacy = eventMap['privacy'];
  if (privacy is! Map ||
      privacy['reverse_lookup_supported'] != false ||
      privacy['bulk_graph_export_supported'] != false ||
      privacy['unmatched_addresses_omitted'] != true) {
    failures.add('${relative(file)} identity lookup privacy invalid.');
  }
  validateMatrixIdentitySecrets(file, eventMap, failures);
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['hash_details_defined'] != true ||
      expectedResult['lookup_defined'] != true ||
      expectedResult['sha256_supported'] != true ||
      expectedResult['privacy_preserving_lookup'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} identity lookup expectation invalid.');
  }
}

void validateMatrixIdentityValidationBind(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixIdentityReference(file, eventMap, failures);
  final steps = eventMap['validation_steps'];
  if (steps is! List || steps.length != 3) {
    failures.add('${relative(file)} identity validation steps invalid.');
  } else {
    final expectedPaths = {
      '/_matrix/identity/v2/validate/email/requestToken',
      '/_matrix/identity/v2/validate/email/submitToken',
      '/_matrix/identity/v2/3pid/getValidated3pid',
    };
    final actualPaths = <String>{};
    for (final step in steps) {
      if (step is! Map || step['id'] is! String) {
        failures.add('${relative(file)} identity validation step invalid.');
        continue;
      }
      final request = step['request'];
      if (request is Map && request['path'] is String) {
        actualPaths.add(request['path'] as String);
      }
      validateMatrixIdentityRequest(
        file,
        request,
        failures,
        pathPrefix: 'event.validation_steps.${step['id']}.request',
      );
      final response = step['response'];
      if (response is! Map || response['status'] != 200) {
        failures.add('${relative(file)} identity validation response invalid.');
      }
    }
    if (!actualPaths.containsAll(expectedPaths)) {
      failures.add('${relative(file)} identity validation paths invalid.');
    }
  }
  validateMatrixIdentityRequest(
    file,
    eventMap['bind_request'],
    failures,
    method: 'POST',
    path: '/_matrix/identity/v2/3pid/bind',
    pathPrefix: 'event.bind_request',
  );
  validateMatrixIdentityAssociation(file, eventMap['bind_response'], failures);
  if (eventMap['validation_does_not_publish_lookup'] != true) {
    failures.add(
      '${relative(file)} identity validation publish boundary invalid.',
    );
  }
  validateMatrixIdentitySecrets(file, eventMap, failures);
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['validation_session_defined'] != true ||
      expectedResult['bind_defined'] != true ||
      expectedResult['signed_association_returned'] != true ||
      expectedResult['lookup_published_only_after_bind'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} identity validation expectation invalid.');
  }
}

void validateMatrixIdentityUnbindFailures(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixIdentityReference(file, eventMap, failures);
  validateMatrixIdentityRequest(
    file,
    eventMap['unbind_request'],
    failures,
    method: 'POST',
    path: '/_matrix/identity/v2/3pid/unbind',
    pathPrefix: 'event.unbind_request',
  );
  final unbindResponse = eventMap['unbind_response'];
  if (unbindResponse is! Map ||
      unbindResponse['status'] != 200 ||
      unbindResponse['body'] is! Map) {
    failures.add('${relative(file)} identity unbind response invalid.');
  }
  final failureCases = eventMap['failure_cases'];
  if (failureCases is! List || failureCases.length < 4) {
    failures.add('${relative(file)} identity failure cases invalid.');
  } else {
    final errcodes = <String>{};
    for (final item in failureCases) {
      if (item is! Map ||
          item['id'] is! String ||
          item['status'] is! int ||
          item['errcode'] is! String) {
        failures.add('${relative(file)} identity failure case invalid.');
        continue;
      }
      errcodes.add(item['errcode'] as String);
    }
    for (final code in [
      'M_UNAUTHORIZED',
      'M_TERMS_NOT_SIGNED',
      'M_FORBIDDEN',
      'M_INVALID_PEPPER',
    ]) {
      if (!errcodes.contains(code)) {
        failures.add('${relative(file)} identity failure code missing: $code');
      }
    }
  }
  final privacy = eventMap['privacy'];
  if (privacy is! Map ||
      privacy['lookup_after_unbind_returns_mapping'] != false ||
      privacy['matrix_error_passthrough_required'] != true ||
      privacy['secrets_redacted'] != true) {
    failures.add('${relative(file)} identity unbind privacy invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['unbind_defined'] != true ||
      expectedResult['future_lookup_removed'] != true ||
      expectedResult['auth_failures_defined'] != true ||
      expectedResult['privacy_failure_gate_defined'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} identity unbind expectation invalid.');
  }
}

void validateMatrixIdentityReference(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final source = eventMap['matrix_spec_source'];
  if (source is! String ||
      !source.startsWith(
        'https://spec.matrix.org/v1.18/identity-service-api/#',
      )) {
    failures.add('${relative(file)} matrix_spec_source is invalid.');
  }
}

void validateMatrixIdentityRequest(
  File file,
  Object? value,
  List<String> failures, {
  String? method,
  String? path,
  String pathPrefix = 'request',
}) {
  checkRequest(file, value, failures, pathPrefix: pathPrefix);
  if (value is! Map) {
    return;
  }
  if (method != null && value['method'] != method) {
    failures.add('${relative(file)} $pathPrefix.method must be $method.');
  }
  if (path != null && value['path'] != path) {
    failures.add('${relative(file)} $pathPrefix.path must be $path.');
  }
  validateMatrixIdentityAuthorization(file, value['authorization'], failures);
}

void validateMatrixIdentityAuthorization(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map ||
      value['scheme'] != 'Bearer' ||
      value['token'] != 'identity-token-redacted') {
    failures.add('${relative(file)} identity authorization invalid.');
  }
}

void validateMatrixIdentityAssociation(
  File file,
  Object? value,
  List<String> failures,
) {
  final body = value is Map ? value['body'] : null;
  final signatures = body is Map ? body['signatures'] : null;
  if (value is! Map ||
      value['status'] != 200 ||
      body is! Map ||
      body['address'] != 'alice@example.test' ||
      body['medium'] != 'email' ||
      body['mxid'] != '@alice:example.test' ||
      body['not_after'] is! int ||
      body['not_before'] is! int ||
      body['ts'] is! int ||
      signatures is! Map ||
      signatures['identity.example.test'] is! Map) {
    failures.add('${relative(file)} identity association response invalid.');
  }
}

void validateMatrixIdentitySecrets(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  if (eventMap['secrets_redacted'] != true) {
    failures.add('${relative(file)} identity secrets must be redacted.');
  }
}

void checkMatrixPushGatewayBoundary(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-060')) {
    failures.add('Matrix push gateway contract SPEC-060 is required.');
  }
  const paths = [
    'test-vectors/core/matrix-push-gateway-boundary-basic.json',
    'test-vectors/core/matrix-push-gateway-destination-controls.json',
    'test-vectors/core/matrix-push-gateway-notify-basic.json',
    'test-vectors/core/matrix-push-gateway-event-id-only.json',
    'test-vectors/core/matrix-push-rules-pusher-delivery-failures.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix push gateway vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('destination-controls')) {
      validateMatrixPushGatewayDestinationControls(file, json, failures);
    } else if (path.contains('boundary')) {
      validateMatrixPushGatewayServiceBoundary(file, json, failures);
    } else if (path.contains('event-id-only')) {
      validateMatrixPushGatewayNotify(file, json, failures, eventIdOnly: true);
    } else if (path.contains('notify')) {
      validateMatrixPushGatewayNotify(file, json, failures);
    } else {
      validateMatrixPushRulesPusherDelivery(file, json, failures);
    }
  }
}

void validateMatrixPushGatewayDestinationControls(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixPushReference(file, eventMap, failures);
  validateIanaAddressRegistrySources(file, eventMap, failures);
  final allowed = eventMap['allowed_public_case'];
  if (allowed is! Map ||
      allowed['pusher_url'] !=
          'https://push.example.test/_matrix/push/v1/notify' ||
      allowed['resolved_addresses'] is! List ||
      allowed['destination_allowed'] != true ||
      allowed['notification_sent'] != true) {
    failures.add('${relative(file)} allowed push gateway case invalid.');
  }
  final cases = eventMap['unsafe_cases'];
  if (cases is! List || cases.length < 6) {
    failures.add('${relative(file)} unsafe push gateway cases incomplete.');
    return;
  }
  final seenClassifications = <String>{};
  for (final item in cases) {
    if (item is! Map) {
      failures.add('${relative(file)} unsafe push case must be object.');
      continue;
    }
    final testCase = item.cast<String, Object?>();
    final id = testCase['id'];
    final pusherUrl = testCase['pusher_url'];
    final classification = testCase['expected_classification'];
    if (id is! String || id.isEmpty || pusherUrl is! String) {
      failures.add('${relative(file)} unsafe push case id/url invalid.');
    }
    if (classification is! String || classification.isEmpty) {
      failures.add('${relative(file)} unsafe push classification missing.');
    } else {
      seenClassifications.add(classification);
    }
    if (testCase['expected_blocked'] != true ||
        testCase['notification_sent'] != false) {
      failures.add('${relative(file)} unsafe push case must be blocked.');
    }
    if (id == 'redirect-to-private' &&
        testCase['redirect_location'] is! String) {
      failures.add('${relative(file)} push redirect case missing location.');
    }
    if (id == 'dns-rebinding-before-connect' &&
        (testCase['initial_resolved_addresses'] is! List ||
            testCase['connect_resolved_addresses'] is! List)) {
      failures.add('${relative(file)} push DNS rebinding case invalid.');
    }
  }
  for (final classification in const {
    'non_https_scheme',
    'loopback',
    'link_local',
    'private_use',
    'redirect_to_unsafe_destination',
    'dns_rebinding_to_private_use',
  }) {
    if (!seenClassifications.contains(classification)) {
      failures.add(
        '${relative(file)} missing unsafe push class: $classification.',
      );
    }
  }
  final controls = eventMap['controls'];
  if (controls is! Map ||
      controls['https_required'] != true ||
      controls['exact_notify_path_required'] != true ||
      controls['userinfo_forbidden'] != true ||
      controls['fragment_forbidden'] != true ||
      controls['redirect_revalidation_required'] != true ||
      controls['dns_revalidation_before_connect'] != true ||
      controls['max_redirects'] is! int ||
      controls['connect_timeout_ms_max'] is! int ||
      controls['read_timeout_ms_max'] is! int ||
      controls['response_body_bytes_max'] is! int ||
      controls['pushkeys_redacted_in_diagnostics'] != true) {
    failures.add(
      '${relative(file)} push gateway destination controls invalid.',
    );
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['legitimate_public_push_gateway_allowed'] != true ||
      expectedResult['unsafe_gateway_url_rejected'] != true ||
      expectedResult['notification_sent_to_unsafe_destination'] != false ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} push destination expectation invalid.');
  }
}

void validateMatrixPushGatewayServiceBoundary(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixPushReference(file, eventMap, failures);
  final boundary = eventMap['service_boundary'];
  if (boundary is! Map ||
      boundary['component'] != 'push-gateway' ||
      boundary['deployment'] != 'separate-service' ||
      boundary['not_hidden_homeserver_module'] != true ||
      boundary['vendor_provider_owned_by_gateway'] != true) {
    failures.add('${relative(file)} push gateway boundary invalid.');
  }
  final endpoint = eventMap['endpoint'];
  if (endpoint is! Map ||
      endpoint['method'] != 'POST' ||
      endpoint['path'] != '/_matrix/push/v1/notify' ||
      endpoint['requires_authentication'] != false) {
    failures.add('${relative(file)} push gateway endpoint invalid.');
  }
  final unsupported = eventMap['unsupported'];
  if (unsupported is! List || unsupported.length != 2) {
    failures.add('${relative(file)} push gateway unsupported cases invalid.');
  } else {
    final statuses = <int>{};
    for (final item in unsupported) {
      if (item is! Map ||
          item['status'] is! int ||
          item['errcode'] != 'M_UNRECOGNIZED') {
        failures.add(
          '${relative(file)} push gateway unsupported item invalid.',
        );
        continue;
      }
      statuses.add(item['status'] as int);
    }
    if (!statuses.contains(404) || !statuses.contains(405)) {
      failures.add(
        '${relative(file)} push gateway unsupported statuses invalid.',
      );
    }
  }
  final privacy = eventMap['privacy'];
  if (privacy is! Map ||
      privacy['prefer_event_id_only'] != true ||
      privacy['pushkeys_redacted'] != true ||
      privacy['vendor_credentials_out_of_scope'] != true) {
    failures.add('${relative(file)} push gateway privacy boundary invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['separate_service_boundary'] != true ||
      expectedResult['notify_endpoint_defined'] != true ||
      expectedResult['unsupported_endpoint_errors_defined'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} push gateway boundary expectation invalid.',
    );
  }
}

void validateMatrixPushGatewayNotify(
  File file,
  Map<String, Object?> vector,
  List<String> failures, {
  bool eventIdOnly = false,
}) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixPushReference(file, eventMap, failures);
  checkRequest(
    file,
    eventMap['request'],
    failures,
    pathPrefix: 'event.request',
  );
  final request = eventMap['request'];
  if (request is! Map ||
      request['method'] != 'POST' ||
      request['path'] != '/_matrix/push/v1/notify') {
    failures.add('${relative(file)} push notify request invalid.');
    return;
  }
  final body = request['body'];
  final notification = body is Map ? body['notification'] : null;
  if (notification is! Map) {
    failures.add('${relative(file)} push notification body invalid.');
    return;
  }
  validateMatrixPushNotification(file, notification, failures, eventIdOnly);
  final response = eventMap['response'];
  final responseBody = response is Map ? response['body'] : null;
  if (response is! Map ||
      response['status'] != 200 ||
      responseBody is! Map ||
      responseBody['rejected'] is! List) {
    failures.add('${relative(file)} push notify response invalid.');
  }
  if (eventIdOnly) {
    final privacy = eventMap['privacy'];
    if (privacy is! Map ||
        privacy['content_omitted'] != true ||
        privacy['sender_omitted'] != true ||
        privacy['sync_required_for_content'] != true) {
      failures.add('${relative(file)} push event_id_only privacy invalid.');
    }
    final expectedResult = vector['expected'];
    if (expectedResult is! Map ||
        expectedResult['event_id_only_payload_valid'] != true ||
        expectedResult['content_minimized'] != true ||
        expectedResult['device_format_forwarded_without_url'] != true ||
        expectedResult['versions_advertisement_widened'] != false) {
      failures.add('${relative(file)} push event_id_only expectation invalid.');
    }
  } else {
    final delivery = eventMap['delivery'];
    if (delivery is! Map ||
        delivery['duplicate_suppression_key'] != '\$event1:example.test' ||
        delivery['counts_idempotent'] != true ||
        delivery['pushkeys_redacted'] != true) {
      failures.add('${relative(file)} push delivery metadata invalid.');
    }
    final expectedResult = vector['expected'];
    if (expectedResult is! Map ||
        expectedResult['status'] != 200 ||
        expectedResult['notify_payload_valid'] != true ||
        expectedResult['duplicate_suppression_by_event_id'] != true ||
        expectedResult['rejected_pushkeys_handled'] != true ||
        expectedResult['versions_advertisement_widened'] != false) {
      failures.add('${relative(file)} push notify expectation invalid.');
    }
  }
}

void validateMatrixPushRulesPusherDelivery(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixPushReference(file, eventMap, failures);
  validateMatrixPushClientRequest(
    file,
    eventMap['pusher_set_request'],
    failures,
    method: 'POST',
    path: '/_matrix/client/v3/pushers/set',
    pathPrefix: 'event.pusher_set_request',
  );
  final pusherSet = eventMap['pusher_set_request'];
  final pusherBody = pusherSet is Map ? pusherSet['body'] : null;
  final pusherData = pusherBody is Map ? pusherBody['data'] : null;
  if (pusherBody is! Map ||
      pusherBody['kind'] != 'http' ||
      pusherBody['app_id'] != 'dev.houra.ios' ||
      pusherBody['pushkey'] != 'pushkey-redacted' ||
      pusherData is! Map ||
      pusherData['format'] != 'event_id_only' ||
      pusherData['url'] != 'https://push.example.test/_matrix/push/v1/notify') {
    failures.add('${relative(file)} pusher set body invalid.');
  }
  validateMatrixPushClientRequest(
    file,
    eventMap['push_rule_request'],
    failures,
    method: 'PUT',
    path: '/_matrix/client/v3/pushrules/global/content/cake-rule',
    pathPrefix: 'event.push_rule_request',
  );
  final pushRule = eventMap['push_rule_request'];
  final ruleBody = pushRule is Map ? pushRule['body'] : null;
  if (ruleBody is! Map ||
      ruleBody['actions'] is! List ||
      ruleBody['pattern'] != 'cake') {
    failures.add('${relative(file)} push rule body invalid.');
  }
  final accountData = eventMap['sync_account_data'];
  final accountContent = accountData is Map ? accountData['content'] : null;
  if (accountData is! Map ||
      accountData['type'] != 'm.push_rules' ||
      accountContent is! Map ||
      accountContent['global'] is! Map) {
    failures.add('${relative(file)} push rule sync account data invalid.');
  }
  final deliveryFailure = eventMap['delivery_failure'];
  final rejected = deliveryFailure is Map ? deliveryFailure['rejected'] : null;
  if (deliveryFailure is! Map ||
      deliveryFailure['gateway_status'] is! int ||
      (deliveryFailure['gateway_status'] as int) < 500 ||
      rejected is! List ||
      !rejected.contains('pushkey-redacted') ||
      deliveryFailure['homeserver_action'] != 'remove-pusher' ||
      deliveryFailure['http_error_retry'] != 'exponential-backoff') {
    failures.add('${relative(file)} push delivery failure invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['pusher_set_defined'] != true ||
      expectedResult['push_rule_defined'] != true ||
      expectedResult['push_rule_sync_account_data_defined'] != true ||
      expectedResult['rejected_pushkey_removes_pusher'] != true ||
      expectedResult['http_error_retried_with_backoff'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} push delivery expectation invalid.');
  }
}

void validateMatrixPushNotification(
  File file,
  Map<dynamic, dynamic> notification,
  List<String> failures,
  bool eventIdOnly,
) {
  final counts = notification['counts'];
  final devices = notification['devices'];
  if (counts is! Map || devices is! List || devices.isEmpty) {
    failures.add('${relative(file)} push notification counts/devices invalid.');
    return;
  }
  for (final device in devices) {
    if (device is! Map ||
        device['app_id'] != 'dev.houra.ios' ||
        device['pushkey'] != 'pushkey-redacted') {
      failures.add('${relative(file)} push notification device invalid.');
      continue;
    }
    final data = device['data'];
    if (eventIdOnly &&
        (data is! Map ||
            data['format'] != 'event_id_only' ||
            data.containsKey('url'))) {
      failures.add('${relative(file)} event_id_only device data invalid.');
    }
  }
  if (eventIdOnly) {
    if (notification['event_id'] != '\$event2:example.test' ||
        notification['room_id'] != '!room:example.test' ||
        notification.containsKey('content') ||
        notification.containsKey('sender')) {
      failures.add('${relative(file)} event_id_only notification invalid.');
    }
  } else if (notification['event_id'] != '\$event1:example.test' ||
      notification['room_id'] != '!room:example.test' ||
      notification['type'] != 'm.room.message' ||
      notification['sender'] != '@alice:example.test' ||
      notification['content'] is! Map) {
    failures.add('${relative(file)} push event notification invalid.');
  }
}

void validateMatrixPushClientRequest(
  File file,
  Object? value,
  List<String> failures, {
  required String method,
  required String path,
  required String pathPrefix,
}) {
  checkRequest(file, value, failures, pathPrefix: pathPrefix);
  if (value is! Map) {
    return;
  }
  if (value['method'] != method) {
    failures.add('${relative(file)} $pathPrefix.method must be $method.');
  }
  if (value['path'] != path) {
    failures.add('${relative(file)} $pathPrefix.path must be $path.');
  }
  final authorization = value['authorization'];
  if (authorization is! Map ||
      authorization['scheme'] != 'Bearer' ||
      authorization['token'] != 'client-token-redacted') {
    failures.add('${relative(file)} push client authorization invalid.');
  }
}

void validateMatrixPushReference(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final source = eventMap['matrix_spec_source'];
  if (source is! String ||
      !(source.startsWith('https://spec.matrix.org/v1.18/push-gateway-api/#') ||
          source.startsWith(
            'https://spec.matrix.org/v1.18/client-server-api/#',
          ))) {
    failures.add('${relative(file)} matrix_spec_source is invalid.');
  }
}

void checkMatrixFederationInteropSmoke(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-061')) {
    failures.add(
      'Matrix federation interop smoke contract SPEC-061 is required.',
    );
  }
  const paths = [
    'test-vectors/events/matrix-federation-two-homeserver-smoke.json',
    'test-vectors/events/matrix-federation-reference-homeserver-smoke.json',
    'test-vectors/events/matrix-federation-compose-ci-lane.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix federation interop vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('two-homeserver')) {
      validateMatrixFederationTwoHomeserverSmoke(file, json, failures);
    } else if (path.contains('reference-homeserver')) {
      validateMatrixFederationReferenceSmoke(file, json, failures);
    } else {
      validateMatrixFederationComposeCiLane(file, json, failures);
    }
  }
}

void validateMatrixFederationTwoHomeserverSmoke(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixFederationInteropReference(file, eventMap, failures);
  final requiredContracts = eventMap['requires_contracts'];
  if (requiredContracts is! List ||
      !requiredContracts.contains('SPEC-055') ||
      !requiredContracts.contains('SPEC-056') ||
      !requiredContracts.contains('SPEC-057') ||
      !requiredContracts.contains('SPEC-061')) {
    failures.add('${relative(file)} federation interop requirements invalid.');
  }
  final topology = eventMap['topology'];
  final servers = topology is Map ? topology['servers'] : null;
  if (topology is! Map ||
      topology['kind'] != 'two-houra-homeservers' ||
      topology['isolated_storage'] != true ||
      topology['distinct_signing_keys'] != true ||
      servers is! List ||
      servers.length != 2) {
    failures.add('${relative(file)} two-homeserver topology invalid.');
  }
  validateMatrixFederationInteropSteps(
    file,
    eventMap['steps'],
    failures,
    requiredStepIds: const {
      'well-known',
      'server-keys',
      'make-join',
      'send-join',
      'send-transaction',
      'backfill',
      'event-auth',
      'state-ids',
      'sync-observe',
    },
  );
  validateMatrixFederationInteropEvidence(file, eventMap['evidence'], failures);
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['two_houra_smoke_defined'] != true ||
      expectedResult['all_steps_pass'] != true ||
      expectedResult['room_version'] != '12' ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} two-homeserver expectation invalid.');
  }
}

void validateMatrixFederationReferenceSmoke(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixFederationInteropReference(
    file,
    eventMap,
    failures,
    requireComplement: true,
  );
  final topology = eventMap['topology'];
  if (topology is! Map ||
      topology['kind'] != 'houra-plus-reference-homeserver' ||
      topology['reference_kind'] != 'complement-compatible' ||
      topology['stable_spec_only'] != true ||
      topology['unstable_msc_enabled'] != false) {
    failures.add('${relative(file)} reference homeserver topology invalid.');
  }
  final checklist = eventMap['checklist'];
  if (checklist is! List || checklist.length < 6) {
    failures.add('${relative(file)} reference homeserver checklist invalid.');
  } else {
    final ids = <String>{};
    for (final item in checklist) {
      if (item is! Map || item['id'] is! String || item['required'] != true) {
        failures.add('${relative(file)} reference checklist item invalid.');
        continue;
      }
      ids.add(item['id'] as String);
    }
    for (final required in [
      'reference-image-recorded',
      'houra-image-or-commit-recorded',
      'make-send-join-both-directions',
      'transaction-both-directions',
      'backfill-event-auth-state-ids',
      'failure-artifacts-linked',
    ]) {
      if (!ids.contains(required)) {
        failures.add(
          '${relative(file)} reference checklist missing $required.',
        );
      }
    }
  }
  validateMatrixFederationInteropEvidence(file, eventMap['evidence'], failures);
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['reference_homeserver_smoke_defined'] != true ||
      expectedResult['stable_spec_only'] != true ||
      expectedResult['complement_compatible'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} reference smoke expectation invalid.');
  }
}

void validateMatrixFederationComposeCiLane(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixFederationInteropReference(
    file,
    eventMap,
    failures,
    requireComplement: true,
  );
  final lane = eventMap['lane'];
  if (lane is! Map ||
      lane['kind'] != 'docker-compose-or-complement-ci' ||
      lane['requires_docker'] != true ||
      lane['client_port'] != 8008 ||
      lane['federation_port'] != 8448 ||
      lane['tls_or_complement_pki'] != true ||
      lane['isolated_storage_per_homeserver'] != true ||
      lane['healthcheck_required'] != true) {
    failures.add('${relative(file)} federation compose lane invalid.');
  }
  final commands = eventMap['commands'];
  if (commands is! List || commands.length != 3) {
    failures.add('${relative(file)} federation compose commands invalid.');
  } else {
    final commandIds = <String>{};
    for (final item in commands) {
      if (item is! Map || item['id'] is! String || item['command'] is! String) {
        failures.add('${relative(file)} federation command item invalid.');
        continue;
      }
      commandIds.add(item['id'] as String);
    }
    if (!commandIds.containsAll({
      'build-houra-image',
      'two-houra',
      'reference',
    })) {
      failures.add('${relative(file)} federation command ids invalid.');
    }
  }
  final evidenceFields = eventMap['evidence_fields'];
  if (evidenceFields is! List ||
      !evidenceFields.contains('matrix_spec_version') ||
      !evidenceFields.contains('step_results') ||
      !evidenceFields.contains('secrets_redacted')) {
    failures.add('${relative(file)} federation evidence fields invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['ci_lane_defined'] != true ||
      expectedResult['docker_or_complement_supported'] != true ||
      expectedResult['healthcheck_required'] != true ||
      expectedResult['secrets_redacted'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} federation CI expectation invalid.');
  }
}

void validateMatrixFederationInteropSteps(
  File file,
  Object? value,
  List<String> failures, {
  required Set<String> requiredStepIds,
}) {
  if (value is! List || value.isEmpty) {
    failures.add('${relative(file)} federation steps invalid.');
    return;
  }
  final ids = <String>{};
  for (final item in value) {
    if (item is! Map ||
        item['id'] is! String ||
        item['contract'] is! String ||
        item['path'] is! String ||
        item['result'] != 'pass') {
      failures.add('${relative(file)} federation step invalid.');
      continue;
    }
    ids.add(item['id'] as String);
    final path = item['path'] as String;
    if (!(isApiPath(path, '/_matrix/federation') ||
        isApiPath(path, '/_matrix/client') ||
        isApiPath(path, '/_matrix/key') ||
        isApiPath(path, '/.well-known/matrix'))) {
      failures.add('${relative(file)} federation step path invalid: $path');
    }
  }
  if (!ids.containsAll(requiredStepIds)) {
    failures.add('${relative(file)} federation required steps missing.');
  }
}

void validateMatrixFederationInteropEvidence(
  File file,
  Object? value,
  List<String> failures,
) {
  if (value is! Map ||
      value['command'] is! String ||
      value['artifact'] is! String ||
      value['secrets_redacted'] != true) {
    failures.add('${relative(file)} federation evidence invalid.');
  }
}

void validateMatrixFederationInteropReference(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures, {
  bool requireComplement = false,
}) {
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final source = eventMap['matrix_spec_source'];
  if (source is! String ||
      !source.startsWith('https://spec.matrix.org/v1.18/server-server-api/#')) {
    failures.add('${relative(file)} matrix_spec_source is invalid.');
  }
  if (requireComplement &&
      eventMap['complement_source'] !=
          'https://github.com/matrix-org/complement') {
    failures.add('${relative(file)} complement source is invalid.');
  }
}

void checkMatrixDomainCoverageReport(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-062')) {
    failures.add(
      'Matrix domain coverage report contract SPEC-062 is required.',
    );
  }
  const path = 'test-vectors/core/matrix-domain-coverage-report-basic.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix domain coverage report vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  validateMatrixDomainCoverageReport(file, json, contracts, failures);
}

void validateMatrixDomainCoverageReport(
  File file,
  Map<String, Object?> vector,
  Map<String, String> contracts,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] != 'https://spec.matrix.org/v1.18/' ||
      eventMap['unstable_mscs_included'] != false) {
    failures.add('${relative(file)} matrix coverage report header invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !isIso8601TimestampWithTimezone(checkedAt)) {
    failures.add(
      '${relative(file)} checked_at must be an ISO-8601 timestamp with timezone.',
    );
  }
  const requiredDomains = {
    'Appendices/common rules',
    'Client-Server API',
    'Server-Server API',
    'Application Service API',
    'Identity Service API',
    'Push Gateway API',
    'Room Versions',
    'Olm & Megolm',
  };
  final domains = eventMap['domains'];
  if (domains is! List || domains.length != requiredDomains.length) {
    failures.add('${relative(file)} matrix coverage domain list invalid.');
  } else {
    final seen = <String>{};
    for (final domain in domains) {
      validateMatrixDomainCoverageRecord(file, domain, contracts, failures);
      if (domain is Map && domain['domain'] is String) {
        seen.add(domain['domain'] as String);
      }
    }
    if (!seen.containsAll(requiredDomains) ||
        seen.length != requiredDomains.length) {
      failures.add('${relative(file)} matrix coverage domains incomplete.');
    }
  }
  final excluded = eventMap['excluded_unstable_mscs'];
  if (excluded is! Map ||
      excluded['included'] != false ||
      excluded['reason'] != 'Matrix v1.18 stable domains only' ||
      excluded['opt_in_policy'] != 'separate issue and contract required') {
    failures.add('${relative(file)} unstable MSC exclusion record invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['stable_domain_count'] != 8 ||
      expectedResult['unstable_mscs_excluded'] != true ||
      expectedResult['pass_fail_fields_defined'] != true ||
      expectedResult['advertisement_blocked_until_implementation_pass'] !=
          true) {
    failures.add('${relative(file)} matrix coverage expectation invalid.');
  }
}

void validateMatrixDomainCoverageRecord(
  File file,
  Object? value,
  Map<String, String> contracts,
  List<String> failures,
) {
  if (value is! Map) {
    failures.add('${relative(file)} matrix coverage domain record invalid.');
    return;
  }
  for (final key in [
    'domain',
    'source',
    'contract_refs',
    'implementation_repos',
    'adoption_issue_refs',
    'contract_gate',
    'implementation_gate',
    'advertisement_allowed',
  ]) {
    if (!value.containsKey(key)) {
      failures.add('${relative(file)} matrix coverage domain missing $key.');
    }
  }
  final domain = value['domain'];
  final source = value['source'];
  if (domain is! String ||
      source is! String ||
      !source.startsWith('https://spec.matrix.org/v1.18/')) {
    failures.add('${relative(file)} matrix coverage domain/source invalid.');
  }
  final contractRefs = value['contract_refs'];
  if (contractRefs is! List || contractRefs.isEmpty) {
    failures.add('${relative(file)} matrix coverage contract refs invalid.');
  } else {
    for (final ref in contractRefs) {
      if (ref is! String || !contracts.containsKey(ref)) {
        failures.add('${relative(file)} matrix coverage contract ref invalid.');
      }
    }
  }
  final repos = value['implementation_repos'];
  if (repos is! List || repos.isEmpty) {
    failures.add(
      '${relative(file)} matrix coverage implementation repos invalid.',
    );
  } else {
    for (final repo in repos) {
      if (repo is! String ||
          !{'houra-server', 'houra-client', 'houra-labs'}.contains(repo)) {
        failures.add('${relative(file)} matrix coverage repo invalid.');
      }
    }
  }
  final adoptionRefs = value['adoption_issue_refs'];
  if (adoptionRefs is! List || adoptionRefs.any((item) => item is! String)) {
    failures.add('${relative(file)} matrix coverage adoption refs invalid.');
  }
  final contractGate = value['contract_gate'];
  final implementationGate = value['implementation_gate'];
  validateMatrixCoverageGate(
    file,
    contractGate,
    failures,
    allowedStatuses: const {'pass', 'fail', 'not-run'},
    requireCommand: true,
  );
  validateMatrixCoverageGate(
    file,
    implementationGate,
    failures,
    allowedStatuses: const {'pass', 'fail', 'not-run', 'not-applicable'},
    requireCommand: false,
  );
  final advertisementAllowed = value['advertisement_allowed'];
  if (advertisementAllowed is! bool) {
    failures.add('${relative(file)} advertisement_allowed must be boolean.');
  }
  if (advertisementAllowed == true &&
      !(contractGate is Map &&
          contractGate['status'] == 'pass' &&
          implementationGate is Map &&
          implementationGate['status'] == 'pass')) {
    failures.add(
      '${relative(file)} advertisement requires passing contract and implementation gates.',
    );
  }
}

void validateMatrixCoverageGate(
  File file,
  Object? value,
  List<String> failures, {
  required Set<String> allowedStatuses,
  required bool requireCommand,
}) {
  if (value is! Map || value['status'] is! String) {
    failures.add('${relative(file)} matrix coverage gate invalid.');
    return;
  }
  if (!allowedStatuses.contains(value['status'])) {
    failures.add('${relative(file)} matrix coverage gate status invalid.');
  }
  if (requireCommand &&
      (value['command'] is! String || (value['command'] as String).isEmpty)) {
    failures.add('${relative(file)} matrix coverage gate command invalid.');
  }
  if (!value.containsKey('artifact')) {
    failures.add('${relative(file)} matrix coverage gate artifact missing.');
  } else {
    final status = value['status'];
    final artifact = value['artifact'];
    if ((status == 'pass' || status == 'fail') &&
        (artifact is! String || artifact.isEmpty)) {
      failures.add('${relative(file)} matrix coverage gate artifact invalid.');
    }
    if ((status == 'not-run' || status == 'not-applicable') &&
        artifact != null &&
        artifact is! String) {
      failures.add(
        '${relative(file)} matrix coverage gate artifact must be null or string.',
      );
    }
  }
}

void checkMatrixComplementCiLane(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-063')) {
    failures.add('Matrix Complement CI lane contract SPEC-063 is required.');
  }
  const paths = [
    'test-vectors/core/matrix-complement-ci-lane-setup.json',
    'test-vectors/core/matrix-complement-ci-pass-fail-report.json',
    'test-vectors/core/matrix-complement-ci-release-gate.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix Complement CI vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('lane-setup')) {
      validateMatrixComplementLaneSetup(file, json, failures);
    } else if (path.contains('pass-fail-report')) {
      validateMatrixComplementPassFailReport(file, json, failures);
    } else {
      validateMatrixComplementReleaseGate(file, json, failures);
    }
  }
}

void validateMatrixComplementLaneSetup(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixComplementReference(file, eventMap, failures);
  final lane = eventMap['lane'];
  if (lane is! Map ||
      lane['kind'] != 'complement-compatible-homeserver' ||
      lane['owner_repo'] != 'houra-server' ||
      lane['image_build_command'] is! String ||
      lane['startup_command'] is! String ||
      lane['client_api_base_url'] is! String ||
      lane['federation_base_url'] is! String ||
      lane['healthcheck_command'] is! String ||
      lane['timeout_seconds'] is! int ||
      (lane['timeout_seconds'] as int) <= 0 ||
      lane['retry_policy'] is! Map ||
      lane['isolated_storage_per_test'] != true ||
      lane['tls_or_complement_pki'] != true ||
      lane['artifact_dir'] != 'artifacts/complement' ||
      lane['stable_spec_only'] != true ||
      lane['unstable_mscs_included'] != false) {
    failures.add('${relative(file)} Complement lane setup invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['lane_setup_defined'] != true ||
      expectedResult['server_owned'] != true ||
      expectedResult['stable_spec_only'] != true ||
      expectedResult['secrets_redacted'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} Complement lane setup expectation invalid.',
    );
  }
}

void validateMatrixComplementPassFailReport(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixComplementReference(file, eventMap, failures);
  final report = eventMap['report'];
  final totals = report is Map ? report['totals'] : null;
  final failuresList = report is Map ? report['failures'] : null;
  final artifacts = report is Map ? report['artifacts'] : null;
  if (report is! Map ||
      report['houra_ref'] is! String ||
      report['complement_ref'] is! String ||
      report['stable_spec_only'] != true ||
      report['unstable_mscs_included'] != false ||
      report['domains'] is! List ||
      totals is! Map ||
      totals['pass'] is! int ||
      totals['fail'] is! int ||
      totals['skip'] is! int ||
      totals['expected_fail'] is! int ||
      failuresList is! List ||
      artifacts is! Map ||
      artifacts['summary'] is! String ||
      artifacts['logs'] is! String ||
      report['release_gate_status'] != 'blocked') {
    failures.add('${relative(file)} Complement pass/fail report invalid.');
  }
  if (failuresList is List) {
    for (final item in failuresList) {
      if (item is! Map ||
          item['test'] is! String ||
          item['domain'] is! String ||
          item['failure_class'] is! String ||
          item['artifact'] is! String) {
        failures.add('${relative(file)} Complement failure entry invalid.');
      }
    }
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['pass_fail_report_defined'] != true ||
      expectedResult['failure_artifacts_linked'] != true ||
      expectedResult['unstable_mscs_excluded'] != true ||
      expectedResult['release_gate_blocked_on_failures'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} Complement report expectation invalid.');
  }
}

void validateMatrixComplementReleaseGate(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixComplementReference(file, eventMap, failures);
  final gate = eventMap['gate'];
  if (gate is! Map ||
      gate['requires_domain_coverage_contract'] != 'SPEC-062' ||
      gate['requires_same_houra_ref'] != true ||
      gate['requires_artifacts'] != true ||
      gate['requires_stable_spec_only'] != true ||
      gate['requires_failure_issue_links'] != true ||
      gate['requires_secret_redaction'] != true ||
      gate['blocks_advertisement_on_missing_or_failed_run'] != true) {
    failures.add('${relative(file)} Complement release gate invalid.');
  }
  final adoption = eventMap['adoption'];
  if (adoption is! Map ||
      adoption['server_issue_required_after_merge'] != true ||
      adoption['client_issue_required_after_merge'] != false ||
      adoption['labs_issue_required_after_merge'] != false) {
    failures.add('${relative(file)} Complement adoption boundary invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['release_gate_candidate_defined'] != true ||
      expectedResult['depends_on_spec_062'] != true ||
      expectedResult['blocks_advertisement_on_missing_or_failed_run'] != true ||
      expectedResult['server_adoption_only'] != true) {
    failures.add('${relative(file)} Complement gate expectation invalid.');
  }
}

void validateMatrixComplementReference(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] != 'https://spec.matrix.org/v1.18/' ||
      eventMap['complement_source'] !=
          'https://github.com/matrix-org/complement') {
    failures.add('${relative(file)} Complement reference invalid.');
  }
}

void checkMatrixVersionAdvertisementGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-064')) {
    failures.add('Matrix version advertisement gate SPEC-064 is required.');
  }
  const paths = [
    'test-vectors/core/matrix-version-advertisement-blocked-missing-evidence.json',
    'test-vectors/core/matrix-version-advertisement-allowed-with-evidence.json',
    'test-vectors/core/matrix-version-advertisement-ci-adoption.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix version advertisement vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('blocked')) {
      validateMatrixVersionAdvertisementBlocked(file, json, failures);
    } else if (path.contains('allowed')) {
      validateMatrixVersionAdvertisementAllowed(file, json, failures);
    } else {
      validateMatrixVersionAdvertisementAdoption(file, json, failures);
    }
  }
}

void validateMatrixVersionAdvertisementBlocked(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixVersionAdvertisementReference(file, eventMap, failures);
  final candidate = eventMap['candidate'];
  final evidence = candidate is Map ? candidate['domain_evidence'] : null;
  if (candidate is! Map ||
      candidate['coverage_report_contract'] != 'SPEC-062' ||
      candidate['complement_lane_contract'] != 'SPEC-063' ||
      evidence is! List ||
      evidence.length != 2) {
    failures.add('${relative(file)} advertisement blocked candidate invalid.');
  }
  final gate = eventMap['gate_result'];
  final reasons = gate is Map ? gate['blocking_reasons'] : null;
  if (gate is! Map ||
      gate['status'] != 'blocked' ||
      reasons is! List ||
      reasons.isEmpty ||
      gate['versions_response_must_change'] != true ||
      gate['release_tag_allowed'] != false) {
    failures.add('${relative(file)} advertisement blocked gate invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['missing_evidence_blocks_advertisement'] != true ||
      expectedResult['release_tag_blocked'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} advertisement blocked expectation invalid.',
    );
  }
}

void validateMatrixVersionAdvertisementAllowed(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixVersionAdvertisementReference(file, eventMap, failures);
  final candidate = eventMap['candidate'];
  final advertised = candidate is Map ? candidate['advertised_domains'] : null;
  final excluded = candidate is Map ? candidate['excluded_domains'] : null;
  final evidence = candidate is Map ? candidate['domain_evidence'] : null;
  if (candidate is! Map ||
      candidate['coverage_report_contract'] != 'SPEC-062' ||
      candidate['complement_lane_contract'] != 'SPEC-063' ||
      advertised is! List ||
      !advertised.contains('Client-Server API') ||
      excluded is! List ||
      excluded.isEmpty ||
      candidate['unstable_mscs_included'] != false ||
      evidence is! List ||
      evidence.length != 1) {
    failures.add('${relative(file)} advertisement allowed candidate invalid.');
  }
  final gate = eventMap['gate_result'];
  if (gate is! Map ||
      gate['status'] != 'pass' ||
      gate['release_tag_allowed'] != true ||
      gate['release_notes_required'] != true) {
    failures.add('${relative(file)} advertisement allowed gate invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['included_domains_have_pass_evidence'] != true ||
      expectedResult['unsupported_domains_are_excluded'] != true ||
      expectedResult['unstable_mscs_excluded'] != true ||
      expectedResult['versions_advertisement_allowed'] != true) {
    failures.add(
      '${relative(file)} advertisement allowed expectation invalid.',
    );
  }
}

void validateMatrixVersionAdvertisementAdoption(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixVersionAdvertisementReference(file, eventMap, failures);
  final adoption = eventMap['adoption'];
  if (adoption is! Map ||
      adoption['server_issue_required_after_merge'] != true ||
      adoption['client_issue_required_after_merge'] != true ||
      adoption['labs_issue_required_after_merge'] != false ||
      adoption['server_responsibility'] is! List ||
      adoption['client_responsibility'] is! List) {
    failures.add('${relative(file)} advertisement adoption invalid.');
  }
  final ciStatus = eventMap['ci_status'];
  if (ciStatus is! Map ||
      ciStatus['required_check'] != 'matrix-advertisement-gate' ||
      ciStatus['fails_closed'] != true ||
      ciStatus['requires_spec_062'] != true ||
      ciStatus['requires_spec_063_for_homeserver_domains'] != true) {
    failures.add('${relative(file)} advertisement CI status invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['server_client_adoption_defined'] != true ||
      expectedResult['ci_fails_closed'] != true ||
      expectedResult['depends_on_coverage_report'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} advertisement adoption expectation invalid.',
    );
  }
}

void validateMatrixVersionAdvertisementReference(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  if (eventMap['matrix_spec_version'] != 'v1.18') {
    failures.add('${relative(file)} matrix_spec_version must be v1.18.');
  }
  final source = eventMap['matrix_spec_source'];
  if (source is! String ||
      !source.startsWith(
        'https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientversions',
      )) {
    failures.add('${relative(file)} matrix_spec_source is invalid.');
  }
}

void checkMatrixReleaseNotesEvidenceTemplate(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-065')) {
    failures.add('Matrix release notes template SPEC-065 is required.');
  }
  const path = 'test-vectors/core/matrix-release-notes-evidence-template.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix release notes template vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  validateMatrixReleaseNotesEvidenceTemplate(file, json, failures);
}

void validateMatrixReleaseNotesEvidenceTemplate(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] != 'https://spec.matrix.org/v1.18/' ||
      eventMap['matrix_release_source'] !=
          'https://matrix.org/blog/2026/03/26/matrix-v1.18-release/') {
    failures.add('${relative(file)} release notes reference invalid.');
  }
  final template = eventMap['template'];
  final sections = template is Map ? template['required_sections'] : null;
  final fields = template is Map ? template['evidence_link_fields'] : null;
  const requiredSections = {
    'Matrix spec version',
    'Supported Matrix domains',
    'Excluded Matrix domains',
    'Supported room versions',
    'Excluded unstable MSCs',
    'Implementation evidence',
    'Known gaps',
    'Advertisement decision',
  };
  const requiredFields = {
    'repo',
    'ref',
    'domain',
    'gate',
    'status',
    'artifact',
    'issue',
  };
  if (template is! Map ||
      sections is! List ||
      !sections.toSet().containsAll(requiredSections) ||
      fields is! List ||
      !fields.toSet().containsAll(requiredFields) ||
      template['supported_domain_status'] != 'pass' ||
      template['excluded_domain_requires_reason'] != true ||
      template['unstable_msc_default'] != 'excluded') {
    failures.add('${relative(file)} release notes template invalid.');
  }
  final example = eventMap['example'];
  final evidence = example is Map ? example['implementation_evidence'] : null;
  if (example is! Map ||
      example['matrix_spec_version'] != 'v1.18' ||
      example['supported_domains'] is! List ||
      example['excluded_domains'] is! List ||
      example['supported_room_versions'] is! List ||
      example['excluded_unstable_mscs'] != true ||
      evidence is! List ||
      evidence.isEmpty ||
      example['advertisement_decision'] != 'allowed-for-listed-domains-only') {
    failures.add('${relative(file)} release notes example invalid.');
  }
  if (evidence is List) {
    for (final item in evidence) {
      if (item is! Map ||
          !requiredFields.every(
            (field) =>
                item[field] is String && (item[field] as String).isNotEmpty,
          )) {
        failures.add('${relative(file)} release notes evidence link invalid.');
      }
    }
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['template_sections_defined'] != true ||
      expectedResult['evidence_link_format_defined'] != true ||
      expectedResult['unsupported_domains_require_reason'] != true ||
      expectedResult['unstable_mscs_excluded_by_default'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} release notes expectation invalid.');
  }
}

void checkMatrixV118ReleaseReadinessGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-066')) {
    failures.add('Matrix v1.18 release readiness SPEC-066 is required.');
  }
  const paths = [
    'test-vectors/core/matrix-v1-18-release-readiness-checklist.json',
    'test-vectors/core/matrix-v1-18-release-tag-ordering.json',
    'test-vectors/core/matrix-v1-18-release-rollback-non-advertisement.json',
  ];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Missing Matrix release readiness vector: $path');
      continue;
    }
    final json = readJsonObject(file, failures);
    if (json == null) {
      continue;
    }
    if (path.contains('readiness-checklist')) {
      validateMatrixReleaseReadinessChecklist(file, json, failures);
    } else if (path.contains('tag-ordering')) {
      validateMatrixReleaseTagOrdering(file, json, failures);
    } else {
      validateMatrixReleaseRollback(file, json, failures);
    }
  }
}

void validateMatrixReleaseReadinessChecklist(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixReleaseReadinessReference(file, eventMap, failures);
  final readiness = eventMap['readiness'];
  if (readiness is! Map ||
      readiness['requires_spec_062'] != true ||
      readiness['requires_spec_063_for_homeserver_claims'] != true ||
      readiness['requires_spec_064'] != true ||
      readiness['requires_spec_065'] != true ||
      readiness['all_supported_domain_gates_pass'] != true ||
      readiness['excluded_domains_have_gap_issue_or_reason'] != true ||
      readiness['room_versions_listed'] != true ||
      readiness['default_room_version_listed'] != true ||
      readiness['unstable_mscs_excluded_or_opted_in'] != true ||
      readiness['artifacts_secret_redacted'] != true) {
    failures.add('${relative(file)} release readiness checklist invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['readiness_checklist_defined'] != true ||
      expectedResult['all_release_gates_required'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} release readiness expectation invalid.');
  }
}

void validateMatrixReleaseTagOrdering(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixReleaseReadinessReference(file, eventMap, failures);
  final ordering = eventMap['ordering'];
  const expectedOrder = [
    'freeze-candidate-refs',
    'run-domain-coverage',
    'run-implementation-evidence',
    'run-complement-lane',
    'run-advertisement-gate',
    'generate-release-notes',
    'tag-implementation-repos',
    'tag-houra-spec',
    'publish-release-notes',
  ];
  if (ordering is! List || ordering.join('|') != expectedOrder.join('|')) {
    failures.add('${relative(file)} release tag ordering invalid.');
  }
  final tagRequirements = eventMap['tag_requirements'];
  if (tagRequirements is! Map ||
      tagRequirements['same_checked_refs'] != true ||
      tagRequirements['evidence_bundle_ref_required'] != true ||
      tagRequirements['publish_after_tags'] != true) {
    failures.add('${relative(file)} release tag requirements invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['tag_ordering_defined'] != true ||
      expectedResult['spec_tag_after_implementation_tags'] != true ||
      expectedResult['publish_after_tags'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} release tag expectation invalid.');
  }
}

void validateMatrixReleaseRollback(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final eventMap = requireMatrixEventMap(file, vector, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixReleaseReadinessReference(file, eventMap, failures);
  final failureAfterTag = eventMap['failure_after_tag'];
  final blockingReasons = eventMap['blocking_reasons'];
  if (failureAfterTag is! Map ||
      failureAfterTag['publish_matrix_claims'] != false ||
      failureAfterTag['create_follow_up_issue'] != true ||
      failureAfterTag['non_advertisement_notes_allowed'] != true ||
      failureAfterTag['retag_requires_new_candidate'] != true ||
      failureAfterTag['delete_or_rewrite_published_tags'] != false ||
      blockingReasons is! List ||
      blockingReasons.length < 5) {
    failures.add('${relative(file)} release rollback gate invalid.');
  }
  final expectedResult = vector['expected'];
  if (expectedResult is! Map ||
      expectedResult['rollback_criteria_defined'] != true ||
      expectedResult['non_advertisement_decision_defined'] != true ||
      expectedResult['retag_requires_new_candidate'] != true ||
      expectedResult['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} release rollback expectation invalid.');
  }
}

void validateMatrixReleaseReadinessReference(
  File file,
  Map<String, Object?> eventMap,
  List<String> failures,
) {
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] != 'https://spec.matrix.org/v1.18/' ||
      eventMap['matrix_release_source'] !=
          'https://matrix.org/blog/2026/03/26/matrix-v1.18-release/') {
    failures.add('${relative(file)} release readiness reference invalid.');
  }
}

void checkMatrixV118ReleaseEvidenceExampleBundle(
  Map<String, String> contracts,
  List<String> failures,
) {
  const path =
      'test-vectors/core/matrix-v1-18-release-evidence-example-bundle.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix release evidence example bundle: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-066') {
    failures.add('${relative(file)} must use SPEC-066 as its readiness gate.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixReleaseReadinessReference(file, eventMap, failures);

  const requiredContracts = {
    'SPEC-062',
    'SPEC-063',
    'SPEC-064',
    'SPEC-065',
    'SPEC-066',
  };
  for (final id in requiredContracts) {
    if (!contracts.containsKey(id)) {
      failures.add('${relative(file)} references missing contract: $id');
    }
  }
  final bundleContracts = eventMap['bundle_contracts'];
  if (bundleContracts is! List ||
      !bundleContracts.toSet().containsAll(requiredContracts)) {
    failures.add('${relative(file)} bundle contract list incomplete.');
  }

  final refs = eventMap['candidate_refs'];
  final releaseCandidate = refs is Map ? refs['release_candidate'] : null;
  if (refs is! Map ||
      releaseCandidate is! String ||
      releaseCandidate.isEmpty ||
      refs['houra_spec_ref'] is! String ||
      refs['houra_server_ref'] is! String ||
      refs['houra_client_ref'] is! String) {
    failures.add('${relative(file)} candidate refs invalid.');
  }
  final expectedArtifactPrefix = releaseCandidate is String
      ? releaseArtifactPrefixForCandidate(releaseCandidate)
      : null;

  final coverage = eventMap['coverage_report'];
  final complement = eventMap['complement_report'];
  final advertisement = eventMap['advertisement_decision'];
  final notes = eventMap['release_notes_evidence'];
  final readiness = eventMap['readiness_checklist'];
  validateBundlePart(file, coverage, 'SPEC-062', failures);
  validateBundlePart(file, complement, 'SPEC-063', failures);
  validateBundlePart(file, advertisement, 'SPEC-064', failures);
  validateBundlePart(file, notes, 'SPEC-065', failures);
  validateBundlePart(file, readiness, 'SPEC-066', failures);
  validateReleaseBundleArtifactPaths(
    file,
    {
      'SPEC-062': coverage,
      'SPEC-063': complement,
      'SPEC-064': advertisement,
      'SPEC-065': notes,
      'SPEC-066': readiness,
    },
    expectedArtifactPrefix,
    failures,
  );

  final domainResults = coverage is Map ? coverage['domain_results'] : null;
  if (domainResults is! List || domainResults.length != 8) {
    failures.add('${relative(file)} coverage domain results invalid.');
  } else {
    final advertisedDomains = advertisement is Map
        ? advertisement['advertised_domains']
        : null;
    final excludedDomains = advertisement is Map
        ? advertisement['excluded_domains']
        : null;
    if (advertisedDomains is! List ||
        !advertisedDomains.contains('Client-Server API') ||
        !advertisedDomains.contains('Appendices/common rules') ||
        excludedDomains is! List ||
        !excludedDomains.contains('Server-Server API')) {
      failures.add('${relative(file)} advertisement domain lists invalid.');
    }
    for (final result in domainResults) {
      if (result is! Map ||
          result['domain'] is! String ||
          result['contract_gate'] is! String ||
          result['implementation_gate'] is! String ||
          result['artifact'] is! String ||
          result['advertisement_allowed'] is! bool) {
        failures.add('${relative(file)} coverage domain result invalid.');
        continue;
      }
      final domain = result['domain'];
      final allowed = result['advertisement_allowed'];
      if (allowed == true &&
          (advertisedDomains is! List || !advertisedDomains.contains(domain))) {
        failures.add(
          '${relative(file)} advertised coverage domain is not listed.',
        );
      }
    }
  }

  final totals = complement is Map ? complement['totals'] : null;
  if (complement is! Map ||
      complement['stable_spec_only'] != true ||
      complement['unstable_mscs_included'] != false ||
      totals is! Map ||
      totals['fail'] is! int ||
      complement['failure_issue_refs'] is! List) {
    failures.add('${relative(file)} Complement bundle report invalid.');
  }

  final evidence = notes is Map ? notes['implementation_evidence'] : null;
  if (notes is! Map ||
      evidence is! List ||
      evidence.isEmpty ||
      notes['advertisement_decision'] !=
          (advertisement is Map ? advertisement['decision'] : null)) {
    failures.add('${relative(file)} release notes bundle evidence invalid.');
  }

  final versionsResponse = advertisement is Map
      ? advertisement['versions_response']
      : null;
  final versions = versionsResponse is Map
      ? versionsResponse['versions']
      : null;
  if (versions is! List || !versions.contains('v1.18')) {
    failures.add('${relative(file)} allowed bundle must advertise v1.18.');
  }

  if (readiness is! Map ||
      readiness['same_checked_refs'] != true ||
      readiness['coverage_report_present'] != true ||
      readiness['complement_report_present'] != true ||
      readiness['advertisement_decision_present'] != true ||
      readiness['release_notes_evidence_present'] != true ||
      readiness['supported_domain_gates_pass'] != true ||
      readiness['excluded_domains_have_gap_issue_or_reason'] != true ||
      readiness['artifacts_secret_redacted'] != true ||
      readiness['ready_to_publish'] != true) {
    failures.add('${relative(file)} readiness bundle checklist invalid.');
  }

  final expectedResult = json['expected'];
  if (expectedResult is! Map ||
      expectedResult['bundle_links_spec_062_to_066'] != true ||
      expectedResult['same_release_candidate_ref'] != true ||
      expectedResult['coverage_report_drives_advertisement'] != true ||
      expectedResult['complement_failures_excluded_from_advertisement'] !=
          true ||
      expectedResult['release_notes_link_gate_artifacts'] != true ||
      expectedResult['readiness_requires_all_bundle_parts'] != true ||
      expectedResult['versions_advertisement_allowed'] != true) {
    failures.add('${relative(file)} bundle expectation invalid.');
  }
}

void checkMatrixV118ReleaseEvidenceCurrentBlockedBundle(
  Map<String, String> contracts,
  List<String> failures,
) {
  const path =
      'test-vectors/core/matrix-v1-18-release-evidence-current-blocked-bundle.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix current release evidence bundle: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-066') {
    failures.add('${relative(file)} must use SPEC-066 as its readiness gate.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  validateMatrixReleaseReadinessReference(file, eventMap, failures);
  for (final id in const {
    'SPEC-062',
    'SPEC-063',
    'SPEC-064',
    'SPEC-065',
    'SPEC-066',
  }) {
    if (!contracts.containsKey(id)) {
      failures.add('${relative(file)} references missing contract: $id');
    }
  }

  final refs = eventMap['candidate_refs'];
  if (refs is! Map ||
      refs['release_candidate'] !=
          'houra-matrix-v1.18-current-blocked-2026-05-14' ||
      refs['houra_spec_ref'] != 'ce587f202de77dade3eebb07b63a0a6b4908743b' ||
      refs['houra_server_ref'] != '3fa134955c9e0804adc9e4b54e6d90fb24631f77' ||
      refs['houra_client_ref'] != '0f330a14ad86d69ad4f147c7a5b6d1852c9c78f2') {
    failures.add('${relative(file)} current candidate refs invalid.');
  }

  final evidenceSources = eventMap['evidence_sources'];
  final server = evidenceSources is Map ? evidenceSources['server'] : null;
  final client = evidenceSources is Map ? evidenceSources['client'] : null;
  if (server is! Map ||
      server['repo'] != 'houra-server' ||
      server['issue'] != 'imoyan/houra-server#108' ||
      server['pull_request'] != 'imoyan/houra-server#145' ||
      server['merge_commit'] !=
          (refs is Map ? refs['houra_server_ref'] : null) ||
      server['head_under_test'] !=
          (refs is Map ? refs['houra_server_ref'] : null) ||
      server['spec_ref_under_test'] !=
          (refs is Map ? refs['houra_spec_ref'] : null) ||
      server['support_claim_decision'] != 'not-advertised') {
    failures.add('${relative(file)} server evidence source invalid.');
  }
  if (client is! Map ||
      client['repo'] != 'houra-client' ||
      client['issue'] != 'imoyan/houra-client#97' ||
      client['pull_request'] != 'imoyan/houra-client#116' ||
      client['merge_commit'] !=
          (refs is Map ? refs['houra_client_ref'] : null) ||
      client['head_under_test'] !=
          (refs is Map ? refs['houra_client_ref'] : null) ||
      client['spec_ref_under_test'] !=
          (refs is Map ? refs['houra_spec_ref'] : null) ||
      client['support_claim_decision'] != 'not-advertised') {
    failures.add('${relative(file)} client evidence source invalid.');
  }

  final domainResults = eventMap['domain_results'];
  const expectedScopeDecisionRefsByDomain = {
    'Appendices/common rules': 'imoyan/houra-server#142',
    'Client-Server API': 'imoyan/houra-server#135',
    'Server-Server API': 'imoyan/houra-server#136',
    'Application Service API': 'imoyan/houra-server#137',
    'Identity Service API': 'imoyan/houra-server#138',
    'Push Gateway API': 'imoyan/houra-server#139',
    'Room Versions': 'imoyan/houra-server#140',
    'Olm & Megolm': 'imoyan/houra-server#141',
  };
  if (domainResults is! List || domainResults.length != 8) {
    failures.add('${relative(file)} current bundle domain results invalid.');
  } else {
    for (final result in domainResults) {
      if (result is! Map ||
          result['domain'] is! String ||
          result['contract_gate'] != 'pass' ||
          result['advertisement_allowed'] != false ||
          result['blocker_issue_refs'] is! List) {
        failures.add('${relative(file)} current domain result invalid.');
        continue;
      }
      final domain = result['domain'];
      final expectedScopeRef = expectedScopeDecisionRefsByDomain[domain];
      final scopeDecisionRefs = result['scope_decision_refs'];
      if (expectedScopeRef == null ||
          scopeDecisionRefs is! List ||
          !scopeDecisionRefs.contains(expectedScopeRef)) {
        failures.add(
          '${relative(file)} current domain scope decision invalid.',
        );
      }
    }
  }

  final advertisement = eventMap['advertisement_decision'];
  final versionsResponse = advertisement is Map
      ? advertisement['versions_response']
      : null;
  final versions = versionsResponse is Map
      ? versionsResponse['versions']
      : null;
  final advertisedDomains = advertisement is Map
      ? advertisement['advertised_domains']
      : null;
  final excludedDomains = advertisement is Map
      ? advertisement['excluded_domains']
      : null;
  if (advertisement is! Map ||
      advertisement['contract'] != 'SPEC-064' ||
      versions is! List ||
      versions.isNotEmpty ||
      advertisedDomains is! List ||
      advertisedDomains.isNotEmpty ||
      excludedDomains is! List ||
      excludedDomains.length != 8 ||
      advertisement['decision'] != 'blocked-no-matrix-support-claim') {
    failures.add('${relative(file)} current advertisement decision invalid.');
  }

  final releaseScopeDecisions = eventMap['release_scope_decisions'];
  if (releaseScopeDecisions is! List || releaseScopeDecisions.length != 8) {
    failures.add('${relative(file)} release scope decisions invalid.');
  } else {
    final seenIssueRefs = <String>{};
    for (final decision in releaseScopeDecisions) {
      if (decision is! Map ||
          decision['domain'] is! String ||
          decision['decision'] !=
              'out-of-scope-for-current-release-candidate' ||
          decision['issue'] is! String ||
          decision['reason'] is! String ||
          decision['advertisement_allowed'] != false) {
        failures.add('${relative(file)} release scope decision invalid.');
        continue;
      }
      final domain = decision['domain'];
      final issue = decision['issue'];
      if (expectedScopeDecisionRefsByDomain[domain] != issue) {
        failures.add('${relative(file)} release scope issue ref invalid.');
      }
      seenIssueRefs.add(issue as String);
    }
    if (!seenIssueRefs.containsAll(expectedScopeDecisionRefsByDomain.values)) {
      failures.add('${relative(file)} release scope issue refs incomplete.');
    }
  }

  final readiness = eventMap['readiness_checklist'];
  if (readiness is! Map ||
      readiness['contract'] != 'SPEC-066' ||
      readiness['same_checked_refs'] != true ||
      readiness['supported_domain_gates_pass'] != true ||
      readiness['ready_to_publish'] != false ||
      readiness['artifacts_secret_redacted'] != true ||
      readiness['explicit_out_of_scope_decisions_present'] != true ||
      readiness['scope_decision_issue_refs'] is! List ||
      readiness['release_candidate_ref_mismatch_blocks_publish'] != false) {
    failures.add('${relative(file)} current readiness checklist invalid.');
  } else {
    final scopeRefs = readiness['scope_decision_issue_refs'] as List;
    if (!scopeRefs.toSet().containsAll(
      expectedScopeDecisionRefsByDomain.values,
    )) {
      failures.add('${relative(file)} readiness scope issue refs incomplete.');
    }
  }

  final blockers = eventMap['blockers'];
  if (blockers is! List ||
      blockers.length != 1 ||
      !blockers.any(
        (item) => item is Map && item['id'] == 'no-matrix-advertisement',
      ) ||
      blockers.any(
        (item) =>
            item is Map &&
            item['id'] == 'complement-full-breadth-blocked' &&
            item['issue'] == 'imoyan/houra-server#133',
      )) {
    failures.add('${relative(file)} current bundle blockers invalid.');
  }

  final serialized = jsonEncode(json);
  for (final forbidden in const ['/Users', '/tmp', 'access_token', 'token-']) {
    if (serialized.contains(forbidden)) {
      failures.add(
        '${relative(file)} leaks forbidden evidence text: $forbidden',
      );
    }
  }

  final expectedResult = json['expected'];
  if (expectedResult is! Map ||
      expectedResult['real_implementation_refs_recorded'] != true ||
      expectedResult['example_bundle_separate'] != true ||
      expectedResult['same_release_candidate_ref'] != true ||
      expectedResult['stale_or_mismatched_refs_block_release'] != false ||
      expectedResult['versions_advertisement_allowed'] != false ||
      expectedResult['ready_to_publish'] != false) {
    failures.add('${relative(file)} current bundle expectation invalid.');
  }
}

void checkMatrixV118ReleaseEvidenceBundleNegativeFixtures(
  List<String> failures,
) {
  const fixtures = {
    'tool/fixtures/check_spec/spec-066-mismatched-release-candidate-ref.json':
        _ReleaseBundleFixtureCase(
          mutation: _ReleaseBundleFixtureMutation.mismatchedReleaseCandidateRef,
          mutationDescription:
              'set event.candidate_refs.release_candidate to houra-matrix-v1.18-rc.2',
        ),
    'tool/fixtures/check_spec/spec-066-inconsistent-release-artifact-path.json':
        _ReleaseBundleFixtureCase(
          mutation:
              _ReleaseBundleFixtureMutation.inconsistentReleaseArtifactPath,
          mutationDescription:
              'set one SPEC-065 implementation_evidence artifact to artifacts/release/matrix-v1.18-rc.2',
        ),
  };
  const basePath =
      'test-vectors/core/matrix-v1-18-release-evidence-example-bundle.json';
  final baseFile = File(basePath);
  final base = readJsonObject(baseFile, failures);
  if (base == null) {
    return;
  }
  for (final entry in fixtures.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) {
      failures.add(
        'Missing Matrix release bundle negative fixture: ${entry.key}',
      );
      continue;
    }
    final fixture = readJsonObject(file, failures);
    if (fixture == null) {
      continue;
    }
    final expectedName = file.uri.pathSegments.last.replaceAll('.json', '');
    if (fixture['name'] != expectedName) {
      failures.add('${relative(file)} name must match file name.');
      continue;
    }
    if (fixture['base'] != basePath) {
      failures.add('${relative(file)} base must reference canonical bundle.');
      continue;
    }
    if (fixture['mutation'] != entry.value.mutationDescription) {
      failures.add('${relative(file)} mutation description invalid.');
      continue;
    }
    final expectedFailure = fixture['expected_failure_contains'];
    if (expectedFailure is! String || expectedFailure.isEmpty) {
      failures.add('${relative(file)} expected_failure_contains invalid.');
      continue;
    }
    final candidate = (jsonDecode(jsonEncode(base)) as Map)
        .cast<String, Object?>();
    mutateReleaseEvidenceBundleFixture(candidate, entry.value.mutation);
    final fixtureFailures = <String>[];
    final eventMap = requireMatrixEventMap(file, candidate, fixtureFailures);
    if (eventMap != null) {
      final refs = eventMap['candidate_refs'];
      final releaseCandidate = refs is Map ? refs['release_candidate'] : null;
      final expectedArtifactPrefix = releaseCandidate is String
          ? releaseArtifactPrefixForCandidate(releaseCandidate)
          : null;
      validateReleaseBundleArtifactPaths(
        file,
        {
          'SPEC-062': eventMap['coverage_report'],
          'SPEC-063': eventMap['complement_report'],
          'SPEC-064': eventMap['advertisement_decision'],
          'SPEC-065': eventMap['release_notes_evidence'],
          'SPEC-066': eventMap['readiness_checklist'],
        },
        expectedArtifactPrefix,
        fixtureFailures,
      );
    }
    if (!fixtureFailures.any((failure) => failure.contains(expectedFailure))) {
      failures.add(
        '${relative(file)} did not fail with expected release bundle error.',
      );
    }
  }
}

void validateBundlePart(
  File file,
  Object? value,
  String contract,
  List<String> failures,
) {
  if (value is! Map ||
      value['contract'] != contract ||
      value['artifact'] is! String ||
      (value['artifact'] as String).isEmpty) {
    failures.add('${relative(file)} bundle part invalid for $contract.');
  }
}

void validateReleaseBundleArtifactPaths(
  File file,
  Map<String, Object?> bundleParts,
  String? expectedArtifactPrefix,
  List<String> failures,
) {
  final releaseDirs = <String>{};
  var candidateMismatch = false;
  var invalidPath = false;
  for (final part in bundleParts.entries) {
    collectArtifactPaths(part.value, (artifact) {
      final releaseDir = releaseArtifactDirectory(artifact);
      if (releaseDir == null) {
        invalidPath = true;
        return;
      }
      releaseDirs.add(releaseDir);
      if (expectedArtifactPrefix != null &&
          !artifact.startsWith(expectedArtifactPrefix)) {
        candidateMismatch = true;
      }
    });
  }
  if (invalidPath) {
    failures.add(
      '${relative(file)} bundle artifact paths must use artifacts/release/.',
    );
  }
  if (candidateMismatch) {
    failures.add(
      '${relative(file)} release candidate ref does not match artifact path.',
    );
  }
  if (releaseDirs.length > 1) {
    failures.add('${relative(file)} artifact release paths inconsistent.');
  }
}

void collectArtifactPaths(Object? value, void Function(String artifact) visit) {
  if (value is Map) {
    for (final entry in value.entries) {
      if (entry.key == 'artifact' && entry.value is String) {
        visit(entry.value as String);
      } else {
        collectArtifactPaths(entry.value, visit);
      }
    }
  } else if (value is List) {
    for (final item in value) {
      collectArtifactPaths(item, visit);
    }
  }
}

String? releaseArtifactDirectory(String artifact) {
  const prefix = 'artifacts/release/';
  if (!artifact.startsWith(prefix)) {
    return null;
  }
  final rest = artifact.substring(prefix.length);
  final slash = rest.indexOf('/');
  if (slash <= 0) {
    return null;
  }
  return rest.substring(0, slash);
}

String releaseArtifactPrefixForCandidate(String releaseCandidate) {
  final releaseDir = releaseCandidate.startsWith('houra-')
      ? releaseCandidate.substring('houra-'.length)
      : releaseCandidate;
  return 'artifacts/release/$releaseDir/';
}

enum _ReleaseBundleFixtureMutation {
  mismatchedReleaseCandidateRef,
  inconsistentReleaseArtifactPath,
}

class _ReleaseBundleFixtureCase {
  const _ReleaseBundleFixtureCase({
    required this.mutation,
    required this.mutationDescription,
  });

  final _ReleaseBundleFixtureMutation mutation;
  final String mutationDescription;
}

void mutateReleaseEvidenceBundleFixture(
  Map<String, Object?> bundle,
  _ReleaseBundleFixtureMutation mutation,
) {
  final event = bundle['event'];
  if (event is! Map) {
    return;
  }
  switch (mutation) {
    case _ReleaseBundleFixtureMutation.mismatchedReleaseCandidateRef:
      final refs = event['candidate_refs'];
      if (refs is Map) {
        refs['release_candidate'] = 'houra-matrix-v1.18-rc.2';
      }
      return;
    case _ReleaseBundleFixtureMutation.inconsistentReleaseArtifactPath:
      final notes = event['release_notes_evidence'];
      final evidence = notes is Map ? notes['implementation_evidence'] : null;
      final first = evidence is List && evidence.isNotEmpty
          ? evidence.first
          : null;
      if (first is Map) {
        first['artifact'] =
            'artifacts/release/matrix-v1.18-rc.2/advertisement-decision.json';
      }
      return;
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
          isApiPath(path, '/_matrix/media') ||
          isApiPath(path, '/_matrix/key') ||
          isApiPath(path, '/_matrix/federation') ||
          isApiPath(path, '/_matrix/app') ||
          isApiPath(path, '/_matrix/identity') ||
          isApiPath(path, '/_matrix/push') ||
          isApiPath(path, '/.well-known/matrix'))) {
    failures.add(
      '${relative(file)} $pathPrefix.path must use /_houra/client or '
      '/_matrix/client or /_matrix/media or /_matrix/key or '
      '/_matrix/federation or /_matrix/app or /_matrix/identity or '
      '/_matrix/push or /.well-known/matrix.',
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
