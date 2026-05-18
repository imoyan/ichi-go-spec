import 'dart:convert';
import 'dart:io';

part 'check_spec/ui.dart';
part 'check_spec/docs.dart';
part 'check_spec/boundary.dart';

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

const contractTypes = {
  'boundary',
  'endpoint',
  'gap-inventory',
  'gate',
  'schema',
};

const matrixDomains = {
  'Appendices/common rules',
  'Application Service API',
  'Client-Server API',
  'Identity Service API',
  'none',
  'Olm & Megolm',
  'Push Gateway API',
  'Room Versions',
  'Server-Server API',
};

const adoptionStates = {
  'adopted',
  'blocked',
  'evidence-only',
  'planned',
  'tracked',
};

const claimImpacts = {'both', 'Matrix', 'neither', 'Product MVP'};

const reservedContractIds = {
  'SPEC-005',
  'SPEC-012',
  'SPEC-013',
  'SPEC-014',
  'SPEC-015',
  'SPEC-016',
  'SPEC-017',
  'SPEC-018',
  'SPEC-019',
  'SPEC-021',
  'SPEC-022',
  'SPEC-023',
  'SPEC-024',
  'SPEC-025',
  'SPEC-026',
  'SPEC-027',
  'SPEC-028',
  'SPEC-029',
  'SPEC-067',
  'SPEC-087',
  'SPEC-088',
  'SPEC-089',
  'SPEC-119',
};

final contractTypeById = <String, String>{};
final contractMatrixDomainById = <String, String>{};
final contractPrimaryReferenceById = <String, String>{};
final contractRepositoryAnchorById = <String, String>{};

const negativeVectorProfiles = {
  'auth',
  'rooms',
  'events',
  'messaging',
  'sync',
  'media',
};

void main() {
  final failures = <String>[];
  checkBoundary(failures);
  checkNamespaceConsistency(failures);
  checkPre10CompatibilityPolicy(failures);
  checkSpecHealthChecklist(failures);
  final contracts = readContracts(failures);

  checkDocs(contracts, failures);
  final profileMap = checkProfileMap(contracts, failures);
  if (profileMap.isNotEmpty) {
    checkVectors(contracts, profileMap, failures);
    checkTestVectorDomainIndex(contracts, profileMap, failures);
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
  checkMatrixRoomVersionsFullAlgorithmGapInventory(contracts, failures);
  checkMatrixRoomVersionsCapabilitiesAdvertisementBoundary(contracts, failures);
  checkMatrixProfileAccountDataTags(contracts, failures);
  checkMatrixReceiptsTypingReadMarkers(contracts, failures);
  checkMatrixFiltersPresenceCapabilities(contracts, failures);
  checkMatrixRoomDirectoryAliasesInvites(contracts, failures);
  checkMatrixModerationReportingAdminControls(contracts, failures);
  checkMatrixClientServerFullBreadthGapInventory(contracts, failures);
  checkMatrixClientWellKnownDiscoverySupportPolicy(contracts, failures);
  checkMatrixClientServerEventRetrievalMembershipHistory(contracts, failures);
  checkMatrixClientServerRelationsThreadsReactions(contracts, failures);
  checkMatrixCryptoAdapterBoundary(contracts, failures);
  checkMatrixDeviceOneTimeFallbackKeys(contracts, failures);
  checkMatrixToDeviceEncryptedRoomGate(contracts, failures);
  checkMatrixKeyBackupRestoreGate(contracts, failures);
  checkMatrixVerificationCrossSigningGate(contracts, failures);
  checkMatrixOlmMegolmFullE2eeGapInventory(contracts, failures);
  checkMatrixOlmMegolmFullE2eeGapInventoryNegativeFixtures(failures);
  checkMatrixMaintainedCryptoStorageOwnershipBoundary(contracts, failures);
  checkMatrixFederationDiscoverySigningKeys(contracts, failures);
  checkMatrixFederationTransactionJoinInvite(contracts, failures);
  checkMatrixFederationBackfillAuthState(contracts, failures);
  checkMatrixApplicationServiceRegistrationTransaction(contracts, failures);
  checkMatrixApplicationServiceFullBreadthGapInventory(contracts, failures);
  checkMatrixIdentityServiceBoundary(contracts, failures);
  checkMatrixIdentityServiceFullBreadthGapInventory(contracts, failures);
  checkMatrixPushGatewayBoundary(contracts, failures);
  checkMatrixPushGatewayFullBreadthGapInventory(contracts, failures);
  checkMatrixFederationInteropSmoke(contracts, failures);
  checkMatrixServerServerFullBreadthGapInventory(contracts, failures);
  checkMatrixDomainCoverageReport(contracts, failures);
  checkMatrixComplementCiLane(contracts, failures);
  checkMatrixVersionAdvertisementGate(contracts, failures);
  checkMatrixReleaseNotesEvidenceTemplate(contracts, failures);
  checkMatrixV118ReleaseReadinessGate(contracts, failures);
  checkMatrixV118ReleaseEvidenceExampleBundle(contracts, failures);
  checkMatrixV118ReleaseEvidenceCurrentBlockedBundle(contracts, failures);
  checkMatrixV118ReleaseEvidenceBundleNegativeFixtures(failures);
  checkMatrix2SnapshotV118DiffChecklist(contracts, failures);
  checkMatrix2VersionsAdvertisementEvidenceGate(contracts, failures);
  checkMatrix2OAuthOidcReadinessGate(contracts, failures);
  checkMatrix2SlidingSyncReadinessGate(contracts, failures);
  checkMatrix2E2eeKeyBackupVerificationReadinessGate(contracts, failures);
  checkMatrix2RoomVersionsAuthStateReadinessGate(contracts, failures);
  checkMatrix2ExtensibleProfilesEventsReadinessGate(contracts, failures);
  checkProductMvpReleaseCandidatePlan(contracts, failures);
  checkOssPublicationReadinessPlan(contracts, failures);
  checkConformanceToolingResultSchema(contracts, profileMap, failures);
  checkSharedCoreAdoptionEvidenceSchema(contracts, profileMap, failures);
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
    'SECURITY.md',
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
    if (Directory('test-vectors').existsSync())
      ...filesUnder(Directory('test-vectors'), '.md'),
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

Map<String, String> readContracts(List<String> failures) {
  contractTypeById.clear();
  contractMatrixDomainById.clear();
  contractPrimaryReferenceById.clear();
  contractRepositoryAnchorById.clear();
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
    final headingMatch = RegExp(
      r'^# (.+)$',
      multiLine: true,
    ).firstMatch(source);
    if (headingMatch == null) {
      failures.add('${relative(file)} must start with a primary heading.');
    }
    if (!source.contains('Status: draft')) {
      failures.add('${relative(file)} must declare draft status.');
    }
    if (!source.contains('Canonical: yes')) {
      failures.add('${relative(file)} must declare canonical status.');
    }

    final typeMatch = RegExp(
      r'^Contract type: ([a-z-]+)$',
      multiLine: true,
    ).firstMatch(source);
    if (typeMatch == null) {
      failures.add('${relative(file)} must declare a contract type.');
    } else {
      final type = typeMatch.group(1)!;
      if (!contractTypes.contains(type)) {
        failures.add('${relative(file)} uses unknown contract type: $type');
      } else {
        contractTypeById[id] = type;
      }
    }

    final matrixDomainMatch = RegExp(
      r'^Matrix domain: ([A-Za-z0-9 &/().-]+)$',
      multiLine: true,
    ).firstMatch(source);
    if (matrixDomainMatch == null) {
      failures.add('${relative(file)} must declare a Matrix domain.');
    } else {
      final matrixDomain = matrixDomainMatch.group(1)!;
      if (!matrixDomains.contains(matrixDomain)) {
        failures.add(
          '${relative(file)} uses unknown Matrix domain: $matrixDomain',
        );
      } else {
        contractMatrixDomainById[id] = matrixDomain;
      }
    }

    final primaryReferenceMatch = RegExp(
      r'^Primary reference: (.+)$',
      multiLine: true,
    ).firstMatch(source);
    if (primaryReferenceMatch == null) {
      failures.add('${relative(file)} must declare a primary reference.');
    } else {
      final primaryReference = primaryReferenceMatch.group(1)!;
      if (primaryReference.contains(id)) {
        failures.add('${relative(file)} primary reference must not use $id.');
      } else {
        contractPrimaryReferenceById[id] = primaryReference;
      }
    }

    if (headingMatch != null && primaryReferenceMatch != null) {
      final heading = headingMatch.group(1)!;
      final primaryReference = primaryReferenceMatch.group(1)!;
      if (heading != primaryReference) {
        failures.add('${relative(file)} H1 must match Primary reference.');
      }
    }

    final repositoryAnchorMatch = RegExp(
      r'^Repository anchor: (.+)$',
      multiLine: true,
    ).firstMatch(source);
    if (repositoryAnchorMatch == null) {
      failures.add('${relative(file)} must declare a repository anchor.');
    } else {
      final repositoryAnchor = repositoryAnchorMatch.group(1)!;
      if (!repositoryAnchor.startsWith(id)) {
        failures.add(
          '${relative(file)} repository anchor must start with $id.',
        );
      } else {
        contractRepositoryAnchorById[id] = repositoryAnchor;
      }
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
  int? previousMatrixBreadthContractNumber;
  final source = file.readAsStringSync();
  if (!source.contains('| Primary reference | Repository anchor |')) {
    failures.add(
      'CONTRACT_MODULE_MAP.md must lead with Primary reference and Repository anchor.',
    );
  }
  for (final line in file.readAsLinesSync()) {
    if (!line.startsWith('| ') || !line.contains('SPEC-')) {
      continue;
    }
    final parts = line.split('|').map((part) => part.trim()).toList();
    if (parts.length < 9) {
      failures.add('Malformed contract map row: $line');
      continue;
    }
    final primaryReference = parts[1];
    final id = RegExp(r'\bSPEC-\d{3}\b').firstMatch(parts[2])?.group(0);
    if (id == null || !contracts.containsKey(id)) {
      failures.add('Contract map references missing contract: ${parts[2]}');
      continue;
    }
    if (primaryReference.isEmpty || primaryReference.contains(id)) {
      failures.add('Contract map primary reference is invalid for $id.');
    }
    final contractPrimaryReference = contractPrimaryReferenceById[id];
    if (contractPrimaryReference != null &&
        primaryReference != contractPrimaryReference) {
      failures.add(
        'Contract map primary reference mismatch for $id: '
        '$primaryReference != $contractPrimaryReference',
      );
    }
    final contractRepositoryAnchor = contractRepositoryAnchorById[id];
    if (contractRepositoryAnchor != null &&
        parts[2] != contractRepositoryAnchor) {
      failures.add(
        'Contract map repository anchor mismatch for $id: '
        '${parts[2]} != $contractRepositoryAnchor',
      );
    }
    final matrixDomain = contractMatrixDomainById[id];
    if (matrixDomain == null) {
      failures.add('Contract map missing contract Matrix domain for $id.');
      continue;
    }
    if (matrixDomain == 'none') {
      if (!primaryReference.startsWith('Houra ')) {
        failures.add(
          'Contract map primary reference for $id must use an Houra label.',
        );
      }
    } else if (!primaryReference.startsWith('Matrix v1.18 / $matrixDomain /')) {
      failures.add(
        'Contract map primary reference for $id must start with Matrix v1.18 / $matrixDomain /.',
      );
    }
    final numericId = int.parse(id.substring('SPEC-'.length));
    if (numericId >= 73) {
      final previous = previousMatrixBreadthContractNumber;
      if (previous != null && numericId < previous) {
        failures.add(
          'CONTRACT_MODULE_MAP.md lists $id after SPEC-${previous.toString().padLeft(3, '0')}.',
        );
      }
      previousMatrixBreadthContractNumber = numericId;
    }
    if (parts[3] != contracts[id]) {
      failures.add(
        'Contract map profile mismatch for $id: ${parts[3]} != '
        '${contracts[id]}',
      );
    }
    final contractType = contractTypeById[id];
    if (contractType != null && parts[4] != contractType) {
      failures.add(
        'Contract map type mismatch for $id: ${parts[4]} != $contractType',
      );
    }
    if (parts[5] != matrixDomain) {
      failures.add(
        'Contract map Matrix domain mismatch for $id: '
        '${parts[5]} != $matrixDomain',
      );
    }
    if (!matrixDomains.contains(parts[5])) {
      failures.add(
        'Contract map Matrix domain is unknown for $id: ${parts[5]}',
      );
    }
    if (parts[6].isEmpty) {
      failures.add('Contract map current Matrix alignment is empty for $id.');
    }
    if (parts[7].isEmpty) {
      failures.add('Contract map next compliance action is empty for $id.');
    }
    if (parts[3] != contracts[id]) {
      continue;
    }
    profileMap[id] = parts[3];
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
    'test-vectors/auth/matrix-logout-all-basic.json',
    'test-vectors/auth/matrix-logout-all-token-invalid-after-logout.json',
  ]) {
    if (!File(path).existsSync()) {
      failures.add('Missing Matrix auth session vector: $path');
    }
  }
  final logoutAllBasic = File('test-vectors/auth/matrix-logout-all-basic.json');
  if (logoutAllBasic.existsSync()) {
    final json = readJsonObject(logoutAllBasic, failures);
    if (json != null) {
      validateMatrixLogoutAllBasic(logoutAllBasic, json, failures);
    }
  }
  final logoutAllInvalid = File(
    'test-vectors/auth/matrix-logout-all-token-invalid-after-logout.json',
  );
  if (logoutAllInvalid.existsSync()) {
    final json = readJsonObject(logoutAllInvalid, failures);
    if (json != null) {
      validateMatrixLogoutAllTokenInvalid(logoutAllInvalid, json, failures);
    }
  }
}

void validateMatrixLogoutAllBasic(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final request = vector['request'];
  final requestMap = request is Map ? request : null;
  if (requestMap == null ||
      requestMap['method'] != 'POST' ||
      requestMap['path'] != '/_matrix/client/v3/logout/all' ||
      requestMap['access_token'] is! String ||
      requestMap.containsKey('body')) {
    failures.add(
      '${relative(file)} must call Matrix logout/all without a body.',
    );
  }
  final expected = vector['expected'];
  final expectedMap = expected is Map ? expected : null;
  final body = expectedMap?['body_contains'];
  if (expectedMap == null ||
      expectedMap['status'] != 200 ||
      body is! Map ||
      body.isNotEmpty ||
      expectedMap['all_same_user_tokens_invalidated'] != true ||
      expectedMap['all_same_user_devices_deleted'] != true ||
      expectedMap['does_not_require_uia'] != true ||
      expectedMap['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} must define fail-closed logout/all success semantics.',
    );
  }
}

void validateMatrixLogoutAllTokenInvalid(
  File file,
  Map<String, Object?> vector,
  List<String> failures,
) {
  final given = vector['given'];
  final givenMap = given is Map ? given : null;
  final previous = givenMap?['previous_request'];
  final previousMap = previous is Map ? previous : null;
  if (previousMap == null ||
      previousMap['method'] != 'POST' ||
      previousMap['path'] != '/_matrix/client/v3/logout/all' ||
      previousMap['access_token'] != 'token-alice-device1' ||
      previousMap.containsKey('body')) {
    failures.add(
      '${relative(file)} previous request must call logout/all without UIA.',
    );
  }
  final request = vector['request'];
  final requestMap = request is Map ? request : null;
  if (requestMap == null ||
      requestMap['method'] != 'GET' ||
      requestMap['path'] != '/_matrix/client/v3/account/whoami' ||
      requestMap['access_token'] != 'token-alice-device2') {
    failures.add(
      '${relative(file)} must retry whoami with another same-user token.',
    );
  }
  final expected = vector['expected'];
  final expectedMap = expected is Map ? expected : null;
  final body = expectedMap?['body_contains'];
  if (expectedMap == null ||
      expectedMap['status'] != 401 ||
      body is! Map ||
      body['errcode'] != 'M_UNKNOWN_TOKEN' ||
      body.containsKey('code') ||
      expectedMap['all_same_user_tokens_invalidated'] != true ||
      expectedMap['all_same_user_devices_deleted'] != true ||
      expectedMap['other_user_access_token_remains_valid'] != true ||
      expectedMap['does_not_require_uia'] != true ||
      expectedMap['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} must expect Matrix token invalidation without widening advertisement.',
    );
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
    return;
  }
  final file = File(path);
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-039') {
    failures.add('${relative(file)} must reference SPEC-039.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  requireStringListIncludes(file, eventMap, 'required_contracts', {
    'SPEC-030',
    'SPEC-031',
    'SPEC-032',
    'SPEC-033',
    'SPEC-034',
    'SPEC-035',
    'SPEC-036',
    'SPEC-037',
    'SPEC-038',
  }, failures);
  requireStringListIncludes(file, eventMap, 'required_evidence_fields', {
    'houra_spec_ref',
    'houra_server_ref',
    'houra_client_ref',
    'commands',
    'scenario_step_results',
    'versions_advertisement',
    'known_exclusions',
    'clean_room_confirmed',
  }, failures);
  final evidenceClasses = eventMap['evidence_classes'];
  if (evidenceClasses is! List || evidenceClasses.length < 2) {
    failures.add('${relative(file)} evidence classes are incomplete.');
  } else {
    final seen = <String>{};
    for (final item in evidenceClasses) {
      if (item is! Map ||
          item['id'] is! String ||
          item['purpose'] is! String ||
          item['required_inputs'] is! List ||
          item['required_checks'] is! List ||
          item['not_evidence_for'] is! List) {
        failures.add('${relative(file)} evidence class shape invalid.');
        continue;
      }
      seen.add(item['id'] as String);
    }
    if (!seen.contains('product-mvp-happy-path') ||
        !seen.contains('docker-compose-deploy-smoke')) {
      failures.add('${relative(file)} evidence class ids incomplete.');
    }
  }
  final separationRules = eventMap['evidence_separation_rules'];
  if (separationRules is! Map ||
      separationRules['must_label_evidence_class'] != true ||
      separationRules['mixed_check_rows_must_split_or_label_parts'] != true ||
      separationRules['deploy_smoke_success_is_not_product_mvp_happy_path'] !=
          true ||
      separationRules['product_mvp_happy_path_success_is_not_deploy_smoke'] !=
          true ||
      separationRules['matrix_full_compliance_not_claimed'] != true) {
    failures.add('${relative(file)} evidence separation rules invalid.');
  }
  final redactionPolicy = eventMap['redaction_policy'];
  if (redactionPolicy is! Map ||
      redactionPolicy['forbidden_release_evidence_fields'] is! List ||
      redactionPolicy['allow_redacted_env_shape'] != true) {
    failures.add('${relative(file)} redaction policy invalid.');
  } else {
    final forbidden =
        redactionPolicy['forbidden_release_evidence_fields'] as List;
    for (final required in [
      'raw bearer token',
      'refresh token',
      'database URL',
      'private local path',
      'image registry credential',
      'machine-specific environment value',
    ]) {
      if (!forbidden.contains(required)) {
        failures.add('${relative(file)} redaction policy missing $required.');
      }
    }
  }
  final adoptionIssuePolicy = eventMap['adoption_issue_policy'];
  if (adoptionIssuePolicy is! Map ||
      adoptionIssuePolicy['houra-server'] is! String ||
      adoptionIssuePolicy['houra-client'] is! String ||
      adoptionIssuePolicy['houra-server-deploy-smoke'] is! String) {
    failures.add('${relative(file)} adoption issue policy invalid.');
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

bool isDatedJstSnapshot(String value) =>
    DateTime.tryParse(value) != null && RegExp(r'\+09:00$').hasMatch(value);

bool isNonEmptyStringList(Object? value) =>
    value is List &&
    value.isNotEmpty &&
    value.every((item) => item is String && item.isNotEmpty);

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

void checkMatrixRoomVersionsFullAlgorithmGapInventory(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-078')) {
    failures.add(
      'Matrix Room Versions full algorithm gap inventory SPEC-078 is required.',
    );
  }
  const path =
      'test-vectors/rooms/matrix-room-versions-full-algorithm-gap-inventory.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix Room Versions full algorithm vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-078') {
    failures.add('${relative(file)} must reference SPEC-078.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] !=
          'https://spec.matrix.org/v1.18/rooms/' ||
      eventMap['room_version_12_source'] !=
          'https://spec.matrix.org/v1.18/rooms/v12/' ||
      eventMap['parent_issue'] != 'imoyan/houra-server#140') {
    failures.add('${relative(file)} Matrix reference or parent issue invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }

  final releaseScopeDecision = eventMap['release_scope_decision'];
  if (releaseScopeDecision is! Map ||
      releaseScopeDecision['domain'] != 'Room Versions' ||
      releaseScopeDecision['decision'] !=
          'out-of-scope-for-current-release-candidate' ||
      releaseScopeDecision['issue'] != 'imoyan/houra-server#140' ||
      releaseScopeDecision['advertisement_allowed'] != false) {
    failures.add('${relative(file)} release scope decision invalid.');
  }

  requireStringListIncludes(file, eventMap, 'covered_subset_contracts', {
    'SPEC-040',
    'SPEC-041',
    'SPEC-042',
    'SPEC-043',
    'SPEC-044',
    'SPEC-062',
    'SPEC-064',
    'SPEC-065',
    'SPEC-066',
  }, failures);

  const expectedLaneIds = {
    'stable-version-set-grammar-default-capabilities-breadth',
    'per-version-event-format-id-hash-signature-limit-breadth',
    'authorization-rules-breadth',
    'state-resolution-algorithm-breadth',
    'event-acceptance-rejection-soft-fail-visibility-breadth',
    'room-upgrade-migration-breadth',
    'federation-cross-domain-room-version-breadth',
    'shared-parser-helper-test-harness-breadth',
    'release-evidence-non-advertisement-breadth',
  };
  final lanes = eventMap['required_gap_lanes'];
  if (lanes is! List || lanes.length < expectedLaneIds.length) {
    failures.add('${relative(file)} Room Versions gap lanes are incomplete.');
  } else {
    final seenLaneIds = <String>{};
    for (final lane in lanes) {
      if (lane is! Map ||
          lane['id'] is! String ||
          lane['status'] !=
              'requires-follow-up-contract-or-implementation-issue' ||
          lane['endpoint_examples'] is! List ||
          lane['owner_repos'] is! List ||
          lane['advertisement_allowed'] != false) {
        failures.add('${relative(file)} Room Versions gap lane shape invalid.');
        continue;
      }
      final laneId = lane['id'] as String;
      final endpointExamples = lane['endpoint_examples'] as List;
      final ownerRepos = lane['owner_repos'] as List;
      if (!expectedLaneIds.contains(laneId) ||
          endpointExamples.isEmpty ||
          ownerRepos.isEmpty ||
          !ownerRepos.any((repo) => repo == 'houra-server')) {
        failures.add(
          '${relative(file)} Room Versions gap lane content invalid.',
        );
      }
      seenLaneIds.add(laneId);
    }
    if (!seenLaneIds.containsAll(expectedLaneIds)) {
      failures.add('${relative(file)} Room Versions gap lane ids incomplete.');
    }
  }

  final rules = eventMap['release_evidence_rules'];
  if (rules is! Map ||
      rules['representative_subset_is_not_full_breadth'] != true ||
      rules['room_versions_full_algorithm_claim_requires_lane_evidence'] !=
          true ||
      rules['explicit_exclusion_required_when_lane_not_included'] != true ||
      rules['failure_issue_ref_must_remain_open_until_resolved'] != true ||
      rules['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} Room Versions release evidence rules invalid.',
    );
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['room_versions_full_algorithm_decomposed'] != true ||
      expected['release_scope_issue_ref'] != 'imoyan/houra-server#140' ||
      expected['support_claim_not_widened'] != true ||
      expected['versions_advertisement_widened'] != false ||
      expected['follow_up_required'] != true) {
    failures.add(
      '${relative(file)} expected Room Versions gap inventory invalid.',
    );
  }
}

void checkMatrixRoomVersionsCapabilitiesAdvertisementBoundary(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-080')) {
    failures.add(
      'Matrix Room Versions capabilities advertisement SPEC-080 is required.',
    );
  }
  const path =
      'test-vectors/rooms/matrix-room-versions-capabilities-advertisement-boundary.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add(
      'Missing Matrix Room Versions capabilities advertisement vector: $path',
    );
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-080') {
    failures.add('${relative(file)} must reference SPEC-080.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_capabilities_source'] !=
          'https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3capabilities' ||
      eventMap['matrix_room_versions_source'] !=
          'https://spec.matrix.org/v1.18/rooms/' ||
      eventMap['room_version_12_source'] !=
          'https://spec.matrix.org/v1.18/rooms/v12/' ||
      eventMap['parent_contract'] != 'SPEC-078' ||
      eventMap['boundary'] != 'm.room_versions-capabilities-advertisement') {
    failures.add('${relative(file)} Matrix reference or boundary invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }

  requireStringListIncludes(file, eventMap, 'representative_subset_contracts', {
    'SPEC-042',
    'SPEC-043',
  }, failures);
  final stableRegistry = readStringList(
    eventMap['stable_room_versions_registry'],
  );
  const expectedStable = [
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
  if (stableRegistry == null ||
      stableRegistry.length != expectedStable.length ||
      !stableRegistry.asMap().entries.every(
        (entry) => entry.value == expectedStable[entry.key],
      )) {
    failures.add('${relative(file)} stable room-version registry invalid.');
  }

  final advertised = eventMap['advertised_capability'];
  if (advertised is! Map) {
    failures.add('${relative(file)} advertised capability missing.');
  } else {
    validateRoomVersionsCapabilitySubset(
      file,
      advertised.cast<String, Object?>(),
      failures,
    );
  }

  final nonAdvertised = readStringList(
    eventMap['non_advertised_stable_versions'],
  );
  const expectedNonAdvertised = {
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
  };
  if (nonAdvertised == null ||
      !sameStringSet(nonAdvertised.toSet(), expectedNonAdvertised)) {
    failures.add('${relative(file)} non-advertised versions invalid.');
  }

  final rules = eventMap['release_evidence_rules'];
  if (rules is! Map ||
      rules['available_is_evidence_list_not_registry'] != true ||
      rules['default_must_be_available'] != true ||
      rules['representative_subset_is_not_full_claim'] != true ||
      rules['missing_evidence_removes_available_entry'] != true ||
      rules['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} room-version advertisement rules invalid.');
  }

  final expected = json['expected'];
  final availableVersions = readStringList(
    expected is Map ? expected['available_room_versions'] : null,
  );
  if (expected is! Map ||
      expected['default_room_version'] != '12' ||
      availableVersions == null ||
      !sameStringSet(availableVersions.toSet(), {'12'}) ||
      expected['full_stable_registry_advertised'] != false ||
      expected['support_claim_not_widened'] != true ||
      expected['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} expected room-version advertisement invalid.',
    );
  }
}

void validateRoomVersionsCapabilitySubset(
  File file,
  Map<String, Object?> roomVersions,
  List<String> failures,
) {
  final available = roomVersions['available'];
  if (roomVersions['default'] != '12' || available is! Map) {
    failures.add('${relative(file)} m.room_versions capability is invalid.');
    return;
  }
  if (!available.containsKey('12') || available['12'] != 'stable') {
    failures.add(
      '${relative(file)} m.room_versions.available must include 12: stable.',
    );
  }
  final advertised = available.keys.whereType<String>().toSet();
  if (!sameStringSet(advertised, {'12'})) {
    failures.add(
      '${relative(file)} m.room_versions.available must stay evidence-scoped.',
    );
  }
  if (!advertised.contains(roomVersions['default'])) {
    failures.add(
      '${relative(file)} m.room_versions.default must be listed in available.',
    );
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
  if (roomVersions is! Map) {
    failures.add('${relative(file)} m.room_versions capability is invalid.');
  } else {
    validateRoomVersionsCapabilitySubset(
      file,
      roomVersions.cast<String, Object?>(),
      failures,
    );
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

void checkMatrixClientServerFullBreadthGapInventory(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-073')) {
    failures.add(
      'Matrix Client-Server full-breadth gap inventory SPEC-073 is required.',
    );
  }
  const path =
      'test-vectors/core/matrix-client-server-full-breadth-gap-inventory.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix Client-Server full-breadth gap vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-073') {
    failures.add('${relative(file)} must reference SPEC-073.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] !=
          'https://spec.matrix.org/v1.18/client-server-api/' ||
      eventMap['parent_issue'] != 'imoyan/houra-server#135') {
    failures.add('${relative(file)} Matrix reference or parent issue invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }

  final releaseScopeDecision = eventMap['release_scope_decision'];
  if (releaseScopeDecision is! Map ||
      releaseScopeDecision['domain'] != 'Client-Server API' ||
      releaseScopeDecision['decision'] !=
          'out-of-scope-for-current-release-candidate' ||
      releaseScopeDecision['issue'] != 'imoyan/houra-server#135' ||
      releaseScopeDecision['advertisement_allowed'] != false) {
    failures.add('${relative(file)} release scope decision invalid.');
  }

  requireStringListIncludes(file, eventMap, 'covered_subset_contracts', {
    'SPEC-030',
    'SPEC-031',
    'SPEC-032',
    'SPEC-033',
    'SPEC-034',
    'SPEC-035',
    'SPEC-036',
    'SPEC-037',
    'SPEC-038',
    'SPEC-039',
    'SPEC-045',
    'SPEC-046',
    'SPEC-047',
    'SPEC-048',
    'SPEC-049',
    'SPEC-068',
    'SPEC-069',
  }, failures);

  const expectedLaneIds = {
    'discovery-support-policy-well-known',
    'auth-refresh-fallback-account-lifecycle',
    'event-retrieval-membership-history-deprecated-compatibility',
    'room-lifecycle-state-relations-user-visible-breadth',
    'sync-breadth-extensions',
    'media-repository-breadth',
    'e2ee-keys-backup-verification-cross-signing-breadth',
  };
  final lanes = eventMap['required_gap_lanes'];
  if (lanes is! List || lanes.length < expectedLaneIds.length) {
    failures.add('${relative(file)} gap lanes are incomplete.');
  } else {
    final seenLaneIds = <String>{};
    for (final lane in lanes) {
      if (lane is! Map ||
          lane['id'] is! String ||
          lane['status'] !=
              'requires-follow-up-contract-or-implementation-issue' ||
          lane['endpoint_examples'] is! List ||
          lane['owner_repos'] is! List ||
          lane['advertisement_allowed'] != false) {
        failures.add('${relative(file)} gap lane shape invalid.');
        continue;
      }
      final laneId = lane['id'] as String;
      final endpointExamples = lane['endpoint_examples'] as List;
      final ownerRepos = lane['owner_repos'] as List;
      if (!expectedLaneIds.contains(laneId) ||
          endpointExamples.isEmpty ||
          ownerRepos.isEmpty ||
          !ownerRepos.contains('houra-server')) {
        failures.add('${relative(file)} gap lane content invalid.');
      }
      seenLaneIds.add(laneId);
    }
    if (!seenLaneIds.containsAll(expectedLaneIds)) {
      failures.add('${relative(file)} gap lane ids incomplete.');
    }
  }

  const expectedPromotionPlan = {
    1: {
      'id': 'sync-query-semantics',
      'issue': 'imoyan/houra-server#178',
      'lane': 'sync-breadth-extensions',
    },
    2: {
      'id': 'sync-delivery-semantics',
      'issue': 'imoyan/houra-server#181',
      'lane': 'sync-breadth-extensions',
    },
    3: {
      'id': 'sync-section-completeness',
      'issue': 'imoyan/houra-server#180',
      'lane': 'sync-breadth-extensions',
    },
    4: {
      'id': 'membership-listing-breadth',
      'issue': 'imoyan/houra-server#183',
      'lane': 'event-retrieval-membership-history-deprecated-compatibility',
    },
    5: {
      'id': 'room-state-event-breadth',
      'issue': 'imoyan/houra-server#184',
      'lane': 'room-lifecycle-state-relations-user-visible-breadth',
    },
  };
  final promotionPlan = eventMap['release_exclusion_promotion_plan'];
  if (promotionPlan is! List ||
      promotionPlan.length != expectedPromotionPlan.length) {
    failures.add('${relative(file)} release exclusion promotion plan invalid.');
  } else {
    final seenOrders = <int>{};
    for (final item in promotionPlan) {
      if (item is! Map ||
          item['order'] is! int ||
          item['id'] is! String ||
          item['source_issues'] is! List ||
          item['target_lane'] is! String ||
          item['contract_or_vector_scope'] is! List ||
          item['server_adoption_issue_condition'] is! String ||
          item['product_mvp_boundary'] is! String ||
          item['advertisement_allowed'] != false) {
        failures.add('${relative(file)} promotion plan item shape invalid.');
        continue;
      }
      final order = item['order'] as int;
      final expected = expectedPromotionPlan[order];
      final sourceIssues = item['source_issues'] as List;
      final scope = item['contract_or_vector_scope'] as List;
      if (expected == null ||
          item['id'] != expected['id'] ||
          item['target_lane'] != expected['lane'] ||
          !sourceIssues.contains(expected['issue']) ||
          scope.isEmpty) {
        failures.add('${relative(file)} promotion plan item content invalid.');
      }
      seenOrders.add(order);
    }
    if (!seenOrders.containsAll(expectedPromotionPlan.keys)) {
      failures.add('${relative(file)} promotion plan ordering incomplete.');
    }
  }

  final rules = eventMap['release_evidence_rules'];
  if (rules is! Map ||
      rules['representative_subset_is_not_full_breadth'] != true ||
      rules['full_breadth_claim_requires_lane_evidence'] != true ||
      rules['explicit_exclusion_required_when_lane_not_included'] != true ||
      rules['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} release evidence rules invalid.');
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['client_server_full_breadth_decomposed'] != true ||
      expected['release_scope_issue_ref'] != 'imoyan/houra-server#135' ||
      expected['support_claim_not_widened'] != true ||
      expected['versions_advertisement_widened'] != false ||
      expected['follow_up_required'] != true) {
    failures.add('${relative(file)} expected gap inventory invalid.');
  }
}

void checkMatrixClientWellKnownDiscoverySupportPolicy(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-082')) {
    failures.add(
      'Matrix client well-known discovery/support/policy SPEC-082 is required.',
    );
  }
  const path =
      'test-vectors/core/matrix-client-well-known-discovery-support-policy.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix client well-known vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-082') {
    failures.add('${relative(file)} must reference SPEC-082.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_client_well_known_source'] !=
          'https://spec.matrix.org/v1.18/client-server-api/#getwell-knownmatrixclient' ||
      eventMap['matrix_support_well_known_source'] !=
          'https://spec.matrix.org/v1.18/client-server-api/#getwell-knownmatrixsupport' ||
      eventMap['matrix_policy_server_well_known_source'] !=
          'https://spec.matrix.org/v1.18/client-server-api/#getwell-knownmatrixpolicy_server' ||
      eventMap['parent_contract'] != 'SPEC-073' ||
      eventMap['spec_issue'] != 'imoyan/houra-spec#260' ||
      eventMap['parent_issue'] != 'imoyan/houra-server#135' ||
      eventMap['implementation_issue'] != 'imoyan/houra-server#229') {
    failures.add('${relative(file)} Matrix reference or issue refs invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }

  final routes = eventMap['routes'];
  const expectedPaths = {
    '/.well-known/matrix/client',
    '/.well-known/matrix/support',
    '/.well-known/matrix/policy_server',
  };
  if (routes is! List || routes.length != expectedPaths.length) {
    failures.add('${relative(file)} well-known routes invalid.');
  } else {
    final seenPaths = <String>{};
    for (final route in routes) {
      if (route is! Map ||
          route['method'] != 'GET' ||
          route['path'] is! String ||
          route['response'] is! Map) {
        failures.add('${relative(file)} well-known route shape invalid.');
        continue;
      }
      final path = route['path'] as String;
      if (!expectedPaths.contains(path)) {
        failures.add('${relative(file)} well-known route path invalid.');
      }
      seenPaths.add(path);
      if (path == '/.well-known/matrix/client' &&
          (route['requires_safe_public_https_base_url'] != true ||
              route['identity_server_advertised'] != false)) {
        failures.add('${relative(file)} client well-known rules invalid.');
      }
      if (path == '/.well-known/matrix/support' &&
          route['requires_explicit_public_support_metadata'] != true) {
        failures.add('${relative(file)} support well-known rules invalid.');
      }
      if (path == '/.well-known/matrix/policy_server' &&
          (route['requires_explicit_public_policy_server_base_url'] != true ||
              route['policy_server_api_advertised'] != false)) {
        failures.add('${relative(file)} policy well-known rules invalid.');
      }
    }
    if (!seenPaths.containsAll(expectedPaths)) {
      failures.add('${relative(file)} well-known route set incomplete.');
    }
  }

  requireStringListIncludes(file, eventMap, 'fail_closed_cases', {
    'missing_public_homeserver_base_url',
    'unsafe_public_base_url',
    'missing_support_metadata',
    'missing_policy_server_base_url',
    'unsupported_method',
    'malformed_local_configuration',
  }, failures);

  final rules = eventMap['release_evidence_rules'];
  if (rules is! Map ||
      rules['well_known_is_metadata_not_full_support'] != true ||
      rules['identity_service_not_inferred'] != true ||
      rules['policy_server_api_not_inferred'] != true ||
      rules['versions_advertisement_widened'] != false ||
      rules['client_server_support_claim_widened'] != false) {
    failures.add('${relative(file)} release evidence rules invalid.');
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['implemented_routes'] is! List ||
      expected['unsupported_or_unconfigured_routes_fail_closed'] != true ||
      expected['unsafe_urls_rejected'] != true ||
      expected['support_claim_not_widened'] != true ||
      expected['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} expected well-known boundary invalid.');
  }
}

void checkMatrixClientServerEventRetrievalMembershipHistory(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-085')) {
    failures.add(
      'Matrix Client-Server event retrieval/membership SPEC-085 is required.',
    );
  }
  const path =
      'test-vectors/core/matrix-client-server-event-retrieval-membership-history.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix Client-Server event retrieval vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-085') {
    failures.add('${relative(file)} must reference SPEC-085.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] !=
          'https://spec.matrix.org/v1.18/client-server-api/' ||
      eventMap['parent_contract'] != 'SPEC-073' ||
      eventMap['spec_issue'] != 'imoyan/houra-spec#262' ||
      eventMap['implementation_issue'] != 'imoyan/houra-labs#119' ||
      eventMap['parent_issue'] != 'imoyan/houra-server#135' ||
      eventMap['boundary'] !=
          'event-retrieval-membership-history-deprecated-compatibility') {
    failures.add('${relative(file)} Matrix reference or issue refs invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }

  const expectedPaths = {
    '/_matrix/client/v3/events',
    '/_matrix/client/v3/events/{eventId}',
    '/_matrix/client/v3/initialSync',
    '/_matrix/client/v3/rooms/{roomId}/initialSync',
    '/_matrix/client/v3/rooms/{roomId}/event/{eventId}',
    '/_matrix/client/v3/rooms/{roomId}/joined_members',
    '/_matrix/client/v3/rooms/{roomId}/members',
    '/_matrix/client/v1/rooms/{roomId}/timestamp_to_event',
  };
  const expectedParserIds = {
    'client_event',
    'joined_members',
    'membership_chunk',
    'timestamp_to_event',
  };
  final descriptors = eventMap['request_descriptors'];
  final seenPaths = <String>{};
  final seenParsers = <String>{};
  var deprecatedCount = 0;
  if (descriptors is! List || descriptors.length != expectedPaths.length) {
    failures.add('${relative(file)} request descriptors invalid.');
  } else {
    for (final descriptor in descriptors) {
      if (descriptor is! Map ||
          descriptor['id'] is! String ||
          descriptor['method'] != 'GET' ||
          descriptor['path'] is! String ||
          descriptor['requires_auth'] != true) {
        failures.add('${relative(file)} request descriptor shape invalid.');
        continue;
      }
      final descriptorPath = descriptor['path'] as String;
      if (!expectedPaths.contains(descriptorPath)) {
        failures.add('${relative(file)} request descriptor path invalid.');
      }
      seenPaths.add(descriptorPath);
      final parser = descriptor['response_parser'];
      if (parser is String) {
        if (!expectedParserIds.contains(parser)) {
          failures.add('${relative(file)} response parser id invalid.');
        }
        seenParsers.add(parser);
      }
      if (descriptor['adopted_runtime_behavior'] == false) {
        deprecatedCount += 1;
        if (descriptor['unsupported_reason'] !=
            'deprecated_compatibility_endpoint') {
          failures.add(
            '${relative(file)} deprecated descriptor reason invalid.',
          );
        }
      }
    }
    if (!seenPaths.containsAll(expectedPaths) ||
        !seenParsers.containsAll(expectedParserIds) ||
        deprecatedCount != 4) {
      failures.add('${relative(file)} descriptor set incomplete.');
    }
  }

  final responses = eventMap['sample_responses'];
  if (responses is! Map) {
    failures.add('${relative(file)} sample responses invalid.');
  } else {
    final clientEvent = responses['client_event'];
    if (!_isMatrixClientEvent(clientEvent)) {
      failures.add('${relative(file)} client event sample invalid.');
    }
    final joinedMembers = responses['joined_members'];
    final joined = joinedMembers is Map ? joinedMembers['joined'] : null;
    if (joined is! Map || joined.isEmpty) {
      failures.add('${relative(file)} joined members sample invalid.');
    }
    final membershipChunk = responses['membership_chunk'];
    final chunk = membershipChunk is Map ? membershipChunk['chunk'] : null;
    if (chunk is! List ||
        chunk.length != 2 ||
        !chunk.every(_isMatrixMembershipEvent)) {
      failures.add('${relative(file)} membership chunk sample invalid.');
    }
    final timestampToEvent = responses['timestamp_to_event'];
    if (timestampToEvent is! Map ||
        timestampToEvent['event_id'] is! String ||
        timestampToEvent['origin_server_ts'] is! int) {
      failures.add('${relative(file)} timestamp_to_event sample invalid.');
    }
  }

  requireStringListIncludes(file, eventMap, 'fail_closed_cases', {
    'malformed_client_event',
    'malformed_joined_members',
    'malformed_membership_chunk',
    'invalid_membership_filter',
    'unsupported_deprecated_runtime_endpoint',
    'history_visibility_not_inferred',
    'authorization_not_inferred',
  }, failures);

  final rules = eventMap['release_evidence_rules'];
  if (rules is! Map ||
      rules['parser_only'] != true ||
      rules['runtime_route_behavior_claimed'] != false ||
      rules['deprecated_endpoints_adopted'] != false ||
      rules['versions_advertisement_widened'] != false ||
      rules['client_server_support_claim_widened'] != false) {
    failures.add('${relative(file)} release evidence rules invalid.');
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['descriptor_count'] != 8 ||
      expected['deprecated_descriptor_count'] != 4 ||
      expected['parser_count'] != 4 ||
      expected['client_event_required_fields_present'] != true ||
      expected['joined_members_map_parsed'] != true ||
      expected['membership_chunk_events_parsed'] != 2 ||
      expected['timestamp_to_event_fields_present'] != true ||
      expected['runtime_route_behavior_claimed'] != false ||
      expected['deprecated_endpoints_adopted'] != false ||
      expected['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} expected event retrieval boundary invalid.',
    );
  }
}

void checkMatrixClientServerRelationsThreadsReactions(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-090')) {
    failures.add(
      'Matrix Client-Server relations/threads/reactions SPEC-090 is required.',
    );
  }
  const path =
      'test-vectors/core/matrix-client-server-relations-threads-reactions.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix Client-Server relations vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-090') {
    failures.add('${relative(file)} must reference SPEC-090.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] !=
          'https://spec.matrix.org/v1.18/client-server-api/' ||
      eventMap['parent_contract'] != 'SPEC-073' ||
      eventMap['spec_issue'] != 'imoyan/houra-spec#99' ||
      eventMap['implementation_issue'] != 'imoyan/houra-labs#120' ||
      eventMap['parent_issue'] != 'imoyan/houra-server#135' ||
      eventMap['boundary'] !=
          'room-lifecycle-state-relations-user-visible-breadth') {
    failures.add('${relative(file)} Matrix reference or issue refs invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }

  const expectedPaths = {
    '/_matrix/client/v1/rooms/{roomId}/relations/{eventId}',
    '/_matrix/client/v1/rooms/{roomId}/relations/{eventId}/{relType}',
    '/_matrix/client/v1/rooms/{roomId}/relations/{eventId}/{relType}/{eventType}',
    '/_matrix/client/v1/rooms/{roomId}/threads',
  };
  const expectedParserIds = {'relation_chunk', 'thread_roots'};
  final descriptors = eventMap['request_descriptors'];
  final seenPaths = <String>{};
  final seenParsers = <String>{};
  if (descriptors is! List || descriptors.length != expectedPaths.length) {
    failures.add('${relative(file)} request descriptors invalid.');
  } else {
    for (final descriptor in descriptors) {
      if (descriptor is! Map ||
          descriptor['id'] is! String ||
          descriptor['method'] != 'GET' ||
          descriptor['path'] is! String ||
          descriptor['requires_auth'] != true ||
          descriptor['adopted_runtime_behavior'] != true) {
        failures.add('${relative(file)} request descriptor shape invalid.');
        continue;
      }
      final descriptorPath = descriptor['path'] as String;
      if (!expectedPaths.contains(descriptorPath)) {
        failures.add('${relative(file)} request descriptor path invalid.');
      }
      seenPaths.add(descriptorPath);
      final parser = descriptor['response_parser'];
      if (parser is! String || !expectedParserIds.contains(parser)) {
        failures.add('${relative(file)} response parser id invalid.');
      } else {
        seenParsers.add(parser);
      }
    }
    if (!seenPaths.containsAll(expectedPaths) ||
        !seenParsers.containsAll(expectedParserIds)) {
      failures.add('${relative(file)} descriptor set incomplete.');
    }
  }

  final responses = eventMap['sample_responses'];
  if (responses is! Map) {
    failures.add('${relative(file)} sample responses invalid.');
  } else {
    final relationChunk = responses['relation_chunk'];
    final chunk = relationChunk is Map ? relationChunk['chunk'] : null;
    if (chunk is! List ||
        chunk.length != 1 ||
        !_isMatrixReactionEvent(chunk.first)) {
      failures.add('${relative(file)} relation chunk sample invalid.');
    }
    final threadRoots = responses['thread_roots'];
    final threads = threadRoots is Map ? threadRoots['chunk'] : null;
    if (threads is! List ||
        threads.length != 1 ||
        !_hasMatrixThreadSummary(threads.first)) {
      failures.add('${relative(file)} thread roots sample invalid.');
    }
    if (!_isMatrixEditEvent(responses['edit_event'])) {
      failures.add('${relative(file)} edit event sample invalid.');
    }
    if (!_isMatrixReplyEvent(responses['reply_event'])) {
      failures.add('${relative(file)} reply event sample invalid.');
    }
    final membershipFailure = responses['membership_variant_failure'];
    if (membershipFailure is! Map ||
        membershipFailure['errcode'] != 'M_FORBIDDEN' ||
        membershipFailure['error'] is! String) {
      failures.add('${relative(file)} membership failure sample invalid.');
    }
  }

  requireStringListIncludes(file, eventMap, 'fail_closed_cases', {
    'malformed_relation_chunk',
    'malformed_reaction_content',
    'malformed_thread_summary',
    'malformed_edit_relation',
    'malformed_reply_relation',
    'knock_runtime_behavior_not_claimed',
    'restricted_join_runtime_behavior_not_claimed',
    'aggregation_correctness_not_inferred',
    'versions_advertisement_not_widened',
  }, failures);

  final rules = eventMap['release_evidence_rules'];
  if (rules is! Map ||
      rules['parser_only'] != true ||
      rules['runtime_route_behavior_claimed'] != false ||
      rules['aggregation_correctness_claimed'] != false ||
      rules['thread_ordering_claimed'] != false ||
      rules['membership_variant_runtime_claimed'] != false ||
      rules['versions_advertisement_widened'] != false ||
      rules['client_server_support_claim_widened'] != false) {
    failures.add('${relative(file)} release evidence rules invalid.');
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['descriptor_count'] != 4 ||
      expected['parser_count'] != 5 ||
      expected['relation_chunk_events_parsed'] != 1 ||
      expected['thread_roots_parsed'] != 1 ||
      expected['reaction_relation_type'] != 'm.annotation' ||
      expected['edit_relation_type'] != 'm.replace' ||
      expected['reply_relation_present'] != true ||
      expected['membership_variant_failure_errcode'] != 'M_FORBIDDEN' ||
      expected['runtime_route_behavior_claimed'] != false ||
      expected['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} expected relations boundary invalid.');
  }
}

bool _isMatrixClientEvent(Object? value) {
  if (value is! Map) {
    return false;
  }
  return value['content'] is Map &&
      value['event_id'] is String &&
      value['origin_server_ts'] is int &&
      value['room_id'] is String &&
      value['sender'] is String &&
      value['type'] is String;
}

bool _isMatrixMembershipEvent(Object? value) {
  if (!_isMatrixClientEvent(value) || value is! Map) {
    return false;
  }
  final content = value['content'];
  return value['type'] == 'm.room.member' &&
      value['state_key'] is String &&
      content is Map &&
      content['membership'] is String;
}

bool _isMatrixReactionEvent(Object? value) {
  if (!_isMatrixClientEvent(value) ||
      value is! Map ||
      value['type'] != 'm.reaction') {
    return false;
  }
  final content = value['content'];
  final relatesTo = content is Map ? content['m.relates_to'] : null;
  return relatesTo is Map &&
      relatesTo['event_id'] is String &&
      relatesTo['rel_type'] == 'm.annotation' &&
      relatesTo['key'] is String;
}

bool _hasMatrixThreadSummary(Object? value) {
  if (!_isMatrixClientEvent(value) || value is! Map) {
    return false;
  }
  final unsigned = value['unsigned'];
  final relations = unsigned is Map ? unsigned['m.relations'] : null;
  final thread = relations is Map ? relations['m.thread'] : null;
  return thread is Map &&
      thread['count'] is int &&
      (thread['count'] as int) >= 0 &&
      thread['current_user_participated'] is bool &&
      _isMatrixClientEvent(thread['latest_event']);
}

bool _isMatrixEditEvent(Object? value) {
  if (!_isMatrixClientEvent(value) || value is! Map) {
    return false;
  }
  final content = value['content'];
  final relatesTo = content is Map ? content['m.relates_to'] : null;
  return content is Map &&
      content['m.new_content'] is Map &&
      relatesTo is Map &&
      relatesTo['event_id'] is String &&
      relatesTo['rel_type'] == 'm.replace';
}

bool _isMatrixReplyEvent(Object? value) {
  if (!_isMatrixClientEvent(value) || value is! Map) {
    return false;
  }
  final content = value['content'];
  final relatesTo = content is Map ? content['m.relates_to'] : null;
  final reply = relatesTo is Map ? relatesTo['m.in_reply_to'] : null;
  return reply is Map && reply['event_id'] is String;
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

void checkMatrixOlmMegolmFullE2eeGapInventory(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-079')) {
    failures.add(
      'Matrix Olm & Megolm full E2EE gap inventory SPEC-079 is required.',
    );
  }
  const path =
      'test-vectors/messaging/matrix-olm-megolm-full-e2ee-gap-inventory.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix Olm & Megolm full E2EE vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  validateMatrixOlmMegolmFullE2eeGapInventoryVector(file, json, failures);
}

void validateMatrixOlmMegolmFullE2eeGapInventoryVector(
  File file,
  Map<String, Object?> json,
  List<String> failures,
) {
  if (json['contract'] != 'SPEC-079') {
    failures.add('${relative(file)} must reference SPEC-079.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] !=
          'https://spec.matrix.org/v1.18/olm-megolm/' ||
      eventMap['olm_source'] !=
          'https://spec.matrix.org/v1.18/olm-megolm/olm/' ||
      eventMap['megolm_source'] !=
          'https://spec.matrix.org/v1.18/olm-megolm/megolm/' ||
      eventMap['client_server_e2ee_source'] !=
          'https://spec.matrix.org/v1.18/client-server-api/#end-to-end-encryption' ||
      eventMap['parent_issue'] != 'imoyan/houra-server#141') {
    failures.add('${relative(file)} Matrix reference or parent issue invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !isDatedJstSnapshot(checkedAt)) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }

  final releaseScopeDecision = eventMap['release_scope_decision'];
  if (releaseScopeDecision is! Map ||
      releaseScopeDecision['domain'] != 'Olm & Megolm' ||
      releaseScopeDecision['decision'] !=
          'out-of-scope-for-current-release-candidate' ||
      releaseScopeDecision['issue'] != 'imoyan/houra-server#141' ||
      releaseScopeDecision['advertisement_allowed'] != false) {
    failures.add('${relative(file)} release scope decision invalid.');
  }

  requireStringListIncludes(file, eventMap, 'covered_subset_contracts', {
    'SPEC-050',
    'SPEC-051',
    'SPEC-052',
    'SPEC-053',
    'SPEC-054',
    'SPEC-069',
    'SPEC-072',
    'SPEC-062',
    'SPEC-064',
    'SPEC-065',
    'SPEC-066',
  }, failures);

  const expectedLaneIds = {
    'maintained-crypto-stack-local-state-ownership-breadth',
    'device-keys-one-time-fallback-device-list-breadth',
    'olm-session-to-device-withheld-key-breadth',
    'megolm-room-session-encrypted-room-event-breadth',
    'server-side-key-backup-recovery-secret-storage-breadth',
    'verification-cross-signing-trust-wrong-device-breadth',
    'encrypted-media-attachment-breadth',
    'federation-room-version-push-interaction-breadth',
    'shared-parser-artifacts-security-release-evidence-breadth',
  };
  final lanes = eventMap['required_gap_lanes'];
  if (lanes is! List || lanes.length < expectedLaneIds.length) {
    failures.add('${relative(file)} Olm & Megolm gap lanes are incomplete.');
  } else {
    final seenLaneIds = <String>{};
    for (final lane in lanes) {
      final endpointExamplesValue = lane is Map
          ? lane['endpoint_examples']
          : null;
      final ownerReposValue = lane is Map ? lane['owner_repos'] : null;
      if (lane is! Map ||
          lane['id'] is! String ||
          lane['status'] !=
              'requires-follow-up-contract-or-implementation-issue' ||
          !isNonEmptyStringList(endpointExamplesValue) ||
          !isNonEmptyStringList(ownerReposValue) ||
          lane['advertisement_allowed'] != false) {
        failures.add('${relative(file)} Olm & Megolm gap lane shape invalid.');
        continue;
      }
      final laneId = lane['id'] as String;
      final ownerRepos = ownerReposValue as List;
      final expectedOwner =
          laneId == 'maintained-crypto-stack-local-state-ownership-breadth'
          ? 'houra-client'
          : 'houra-server';
      if (!expectedLaneIds.contains(laneId) ||
          !ownerRepos.any((repo) => repo == expectedOwner)) {
        failures.add(
          '${relative(file)} Olm & Megolm gap lane content invalid.',
        );
      }
      if (!seenLaneIds.add(laneId)) {
        failures.add('${relative(file)} Olm & Megolm gap lane ids duplicate.');
      }
    }
    if (!seenLaneIds.containsAll(expectedLaneIds)) {
      failures.add('${relative(file)} Olm & Megolm gap lane ids incomplete.');
    }
  }

  final rules = eventMap['release_evidence_rules'];
  if (rules is! Map ||
      rules['representative_subset_is_not_full_breadth'] != true ||
      rules['olm_megolm_full_e2ee_claim_requires_lane_evidence'] != true ||
      rules['explicit_exclusion_required_when_lane_not_included'] != true ||
      rules['failure_issue_ref_must_remain_open_until_resolved'] != true ||
      rules['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} Olm & Megolm release evidence rules invalid.',
    );
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['olm_megolm_full_e2ee_decomposed'] != true ||
      expected['release_scope_issue_ref'] != 'imoyan/houra-server#141' ||
      expected['support_claim_not_widened'] != true ||
      expected['versions_advertisement_widened'] != false ||
      expected['follow_up_required'] != true) {
    failures.add(
      '${relative(file)} expected Olm & Megolm gap inventory invalid.',
    );
  }
}

void checkMatrixOlmMegolmFullE2eeGapInventoryNegativeFixtures(
  List<String> failures,
) {
  const basePath =
      'test-vectors/messaging/matrix-olm-megolm-full-e2ee-gap-inventory.json';
  final baseFile = File(basePath);
  final base = readJsonObject(baseFile, failures);
  if (base == null) {
    return;
  }
  const cases = {
    'malformed checked_at': _OlmMegolmGapInventoryFixtureCase(
      mutation: _OlmMegolmGapInventoryMutation.malformedCheckedAt,
      expectedFailureContains: 'checked_at must be a dated JST snapshot',
    ),
    'non-string endpoint_examples': _OlmMegolmGapInventoryFixtureCase(
      mutation: _OlmMegolmGapInventoryMutation.nonStringEndpointExample,
      expectedFailureContains: 'Olm & Megolm gap lane shape invalid',
    ),
    'non-string owner_repos': _OlmMegolmGapInventoryFixtureCase(
      mutation: _OlmMegolmGapInventoryMutation.nonStringOwnerRepo,
      expectedFailureContains: 'Olm & Megolm gap lane shape invalid',
    ),
    'duplicate lane id': _OlmMegolmGapInventoryFixtureCase(
      mutation: _OlmMegolmGapInventoryMutation.duplicateLaneId,
      expectedFailureContains: 'Olm & Megolm gap lane ids duplicate',
    ),
  };
  for (final entry in cases.entries) {
    final candidate = (jsonDecode(jsonEncode(base)) as Map)
        .cast<String, Object?>();
    mutateOlmMegolmGapInventoryFixture(candidate, entry.value.mutation);
    final fixtureFailures = <String>[];
    validateMatrixOlmMegolmFullE2eeGapInventoryVector(
      baseFile,
      candidate,
      fixtureFailures,
    );
    if (!fixtureFailures.any(
      (failure) => failure.contains(entry.value.expectedFailureContains),
    )) {
      failures.add(
        '$basePath negative fixture ${entry.key} did not fail as expected.',
      );
    }
  }
}

enum _OlmMegolmGapInventoryMutation {
  malformedCheckedAt,
  nonStringEndpointExample,
  nonStringOwnerRepo,
  duplicateLaneId,
}

class _OlmMegolmGapInventoryFixtureCase {
  const _OlmMegolmGapInventoryFixtureCase({
    required this.mutation,
    required this.expectedFailureContains,
  });

  final _OlmMegolmGapInventoryMutation mutation;
  final String expectedFailureContains;
}

void mutateOlmMegolmGapInventoryFixture(
  Map<String, Object?> vector,
  _OlmMegolmGapInventoryMutation mutation,
) {
  final event = vector['event'];
  if (event is! Map) {
    return;
  }
  switch (mutation) {
    case _OlmMegolmGapInventoryMutation.malformedCheckedAt:
      event['checked_at'] = 'not-a-date+09:00';
      return;
    case _OlmMegolmGapInventoryMutation.nonStringEndpointExample:
      final lanes = event['required_gap_lanes'];
      final firstLane = lanes is List && lanes.isNotEmpty ? lanes.first : null;
      if (firstLane is Map) {
        firstLane['endpoint_examples'] = [123];
      }
      return;
    case _OlmMegolmGapInventoryMutation.nonStringOwnerRepo:
      final lanes = event['required_gap_lanes'];
      final firstLane = lanes is List && lanes.isNotEmpty ? lanes.first : null;
      if (firstLane is Map) {
        firstLane['owner_repos'] = [123];
      }
      return;
    case _OlmMegolmGapInventoryMutation.duplicateLaneId:
      final lanes = event['required_gap_lanes'];
      if (lanes is List && lanes.isNotEmpty) {
        lanes.add(jsonDecode(jsonEncode(lanes.first)));
      }
      return;
  }
}

void checkMatrixMaintainedCryptoStorageOwnershipBoundary(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-081')) {
    failures.add(
      'Matrix maintained crypto storage ownership boundary SPEC-081 is required.',
    );
  }
  const path =
      'test-vectors/messaging/matrix-maintained-crypto-storage-ownership-boundary.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix maintained crypto storage vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-081') {
    failures.add('${relative(file)} must reference SPEC-081.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] !=
          'https://spec.matrix.org/v1.18/olm-megolm/' ||
      eventMap['client_server_e2ee_source'] !=
          'https://spec.matrix.org/v1.18/client-server-api/#end-to-end-encryption' ||
      eventMap['key_backup_source'] !=
          'https://spec.matrix.org/v1.18/client-server-api/#server-side-key-backups' ||
      eventMap['parent_contract'] != 'SPEC-079' ||
      eventMap['parent_issue'] != 'imoyan/houra-server#141' ||
      eventMap['parent_lane'] !=
          'maintained-crypto-stack-local-state-ownership-breadth' ||
      eventMap['child_order'] != 1) {
    failures.add('${relative(file)} Matrix reference or parent link invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }

  final gate = eventMap['maintained_crypto_stack_gate'];
  if (gate is! Map ||
      gate['selection_required_before_e2ee_claim'] != true ||
      gate['local_crypto_implementation_allowed'] != false) {
    failures.add('${relative(file)} maintained crypto stack gate invalid.');
  } else {
    requireStringListIncludes(
      file,
      gate.cast<String, Object?>(),
      'required_evidence',
      {
        'package_name',
        'package_version',
        'runtime_platform_support',
        'license_compatibility',
        'active_maintenance',
        'security_update_policy',
        'olm_megolm_algorithm_coverage',
        'interop_or_vector_evidence',
        'rollback_or_disablement_path',
      },
      failures,
    );
  }

  requireStringListIncludes(file, eventMap, 'host_owned_secure_storage', {
    'access_tokens',
    'refresh_tokens',
    'private_identity_keys',
    'recovery_keys',
    'recovery_passphrases',
    'backup_secrets',
    'secret_storage_key_material',
    'platform_keychain_selection',
    'logout_local_data_deletion',
    'recovery_prompt_ux',
    'local_path_redaction',
  }, failures);
  requireStringListIncludes(file, eventMap, 'crypto_adapter_owned', {
    'olm_session_crypto',
    'megolm_group_session_crypto',
    'sas_calculation',
    'cross_signing_crypto',
    'key_backup_crypto',
    'secret_storage_crypto',
    'encrypted_media_crypto',
    'key_import_export_validation',
  }, failures);
  requireStringListIncludes(file, eventMap, 'server_must_not_own', {
    'plaintext_room_content',
    'room_keys',
    'megolm_session_keys',
    'private_identity_keys',
    'private_cross_signing_keys',
    'recovery_keys',
    'recovery_passphrases',
    'backup_secrets',
    'secret_storage_key_material',
    'platform_secure_storage_handles',
    'local_secret_filesystem_paths',
  }, failures);

  final artifactRules = eventMap['release_artifact_rules'];
  if (artifactRules is! Map ||
      artifactRules['redacted_artifacts_only'] != true ||
      artifactRules['may_record_crypto_stack_name_version'] != true ||
      artifactRules['may_record_platform_support'] != true ||
      artifactRules['must_not_record_secret_material'] != true ||
      artifactRules['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} release artifact rules invalid.');
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['first_child_of_spec_079'] != true ||
      expected['host_owns_secure_storage_and_recovery_secrets'] != true ||
      expected['maintained_crypto_stack_required'] != true ||
      expected['local_crypto_implementation_allowed'] != false ||
      expected['server_secret_ownership_allowed'] != false ||
      expected['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} expected maintained crypto storage boundary invalid.',
    );
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

void checkMatrixApplicationServiceFullBreadthGapInventory(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-075')) {
    failures.add(
      'Matrix Application Service full-breadth gap inventory SPEC-075 is required.',
    );
  }
  const path =
      'test-vectors/core/matrix-application-service-full-breadth-gap-inventory.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add(
      'Missing Matrix Application Service full-breadth gap vector: $path',
    );
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-075') {
    failures.add('${relative(file)} must reference SPEC-075.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] !=
          'https://spec.matrix.org/v1.18/application-service-api/' ||
      eventMap['parent_issue'] != 'imoyan/houra-server#137') {
    failures.add('${relative(file)} Matrix reference or parent issue invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }

  final releaseScopeDecision = eventMap['release_scope_decision'];
  if (releaseScopeDecision is! Map ||
      releaseScopeDecision['domain'] != 'Application Service API' ||
      releaseScopeDecision['decision'] !=
          'out-of-scope-for-current-release-candidate' ||
      releaseScopeDecision['issue'] != 'imoyan/houra-server#137' ||
      releaseScopeDecision['advertisement_allowed'] != false) {
    failures.add('${relative(file)} release scope decision invalid.');
  }

  requireStringListIncludes(file, eventMap, 'covered_subset_contracts', {
    'SPEC-058',
    'SPEC-062',
    'SPEC-064',
    'SPEC-065',
    'SPEC-066',
  }, failures);

  const expectedLaneIds = {
    'registration-namespace-token-lifecycle-breadth',
    'transaction-event-delivery-legacy-unknown-route-breadth',
    'query-user-room-alias-namespace-ownership-breadth',
    'third-party-network-directory-breadth',
    'ping-health-liveness-breadth',
    'client-server-extension-masquerade-timestamp-admin-breadth',
    'client-server-extension-sync-directory-device-cross-signing-breadth',
    'bridge-external-url-security-observability-release-evidence-breadth',
  };
  final lanes = eventMap['required_gap_lanes'];
  if (lanes is! List || lanes.length < expectedLaneIds.length) {
    failures.add(
      '${relative(file)} Application Service gap lanes are incomplete.',
    );
  } else {
    final seenLaneIds = <String>{};
    for (final lane in lanes) {
      if (lane is! Map ||
          lane['id'] is! String ||
          lane['status'] !=
              'requires-follow-up-contract-or-implementation-issue' ||
          lane['endpoint_examples'] is! List ||
          lane['owner_repos'] is! List ||
          lane['advertisement_allowed'] != false) {
        failures.add(
          '${relative(file)} Application Service gap lane shape invalid.',
        );
        continue;
      }
      final laneId = lane['id'] as String;
      final endpointExamples = lane['endpoint_examples'] as List;
      final ownerRepos = lane['owner_repos'] as List;
      if (!expectedLaneIds.contains(laneId) ||
          endpointExamples.isEmpty ||
          ownerRepos.isEmpty ||
          !ownerRepos.contains('houra-server')) {
        failures.add(
          '${relative(file)} Application Service gap lane content invalid.',
        );
      }
      seenLaneIds.add(laneId);
    }
    if (!seenLaneIds.containsAll(expectedLaneIds)) {
      failures.add(
        '${relative(file)} Application Service gap lane ids incomplete.',
      );
    }
  }

  final rules = eventMap['release_evidence_rules'];
  if (rules is! Map ||
      rules['representative_subset_is_not_full_breadth'] != true ||
      rules['application_service_full_breadth_claim_requires_lane_evidence'] !=
          true ||
      rules['explicit_exclusion_required_when_lane_not_included'] != true ||
      rules['failure_issue_ref_must_remain_open_until_resolved'] != true ||
      rules['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} Application Service release evidence rules invalid.',
    );
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['application_service_full_breadth_decomposed'] != true ||
      expected['release_scope_issue_ref'] != 'imoyan/houra-server#137' ||
      expected['support_claim_not_widened'] != true ||
      expected['versions_advertisement_widened'] != false ||
      expected['follow_up_required'] != true) {
    failures.add(
      '${relative(file)} expected Application Service gap inventory invalid.',
    );
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

void checkMatrixIdentityServiceFullBreadthGapInventory(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-076')) {
    failures.add(
      'Matrix Identity Service full-breadth gap inventory SPEC-076 is required.',
    );
  }
  const path =
      'test-vectors/core/matrix-identity-service-full-breadth-gap-inventory.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add(
      'Missing Matrix Identity Service full-breadth gap vector: $path',
    );
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-076') {
    failures.add('${relative(file)} must reference SPEC-076.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] !=
          'https://spec.matrix.org/v1.18/identity-service-api/' ||
      eventMap['parent_issue'] != 'imoyan/houra-server#138') {
    failures.add('${relative(file)} Matrix reference or parent issue invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }

  final releaseScopeDecision = eventMap['release_scope_decision'];
  if (releaseScopeDecision is! Map ||
      releaseScopeDecision['domain'] != 'Identity Service API' ||
      releaseScopeDecision['decision'] !=
          'out-of-scope-for-current-release-candidate' ||
      releaseScopeDecision['issue'] != 'imoyan/houra-server#138' ||
      releaseScopeDecision['advertisement_allowed'] != false) {
    failures.add('${relative(file)} release scope decision invalid.');
  }

  requireStringListIncludes(file, eventMap, 'covered_subset_contracts', {
    'SPEC-059',
    'SPEC-062',
    'SPEC-064',
    'SPEC-065',
    'SPEC-066',
  }, failures);

  const expectedLaneIds = {
    'service-discovery-authentication-account-terms-breadth',
    'public-key-ephemeral-key-signed-association-breadth',
    'lookup-hash-details-pepper-privacy-breadth',
    'validation-session-provider-delivery-breadth',
    'bind-validated-3pid-unbind-association-lifecycle-breadth',
    'invitation-storage-breadth',
    'ephemeral-invitation-signing-breadth',
    'consent-ui-provider-operations-client-handoff-breadth',
    'release-evidence-non-advertisement-breadth',
  };
  final lanes = eventMap['required_gap_lanes'];
  if (lanes is! List || lanes.length < expectedLaneIds.length) {
    failures.add(
      '${relative(file)} Identity Service gap lanes are incomplete.',
    );
  } else {
    final seenLaneIds = <String>{};
    for (final lane in lanes) {
      if (lane is! Map ||
          lane['id'] is! String ||
          lane['status'] !=
              'requires-follow-up-contract-or-implementation-issue' ||
          lane['endpoint_examples'] is! List ||
          lane['owner_repos'] is! List ||
          lane['advertisement_allowed'] != false) {
        failures.add(
          '${relative(file)} Identity Service gap lane shape invalid.',
        );
        continue;
      }
      final laneId = lane['id'] as String;
      final endpointExamples = lane['endpoint_examples'] as List;
      final ownerRepos = lane['owner_repos'] as List;
      if (!expectedLaneIds.contains(laneId) ||
          endpointExamples.isEmpty ||
          ownerRepos.isEmpty ||
          !ownerRepos.contains('houra-server')) {
        failures.add(
          '${relative(file)} Identity Service gap lane content invalid.',
        );
      }
      seenLaneIds.add(laneId);
    }
    if (!seenLaneIds.containsAll(expectedLaneIds)) {
      failures.add(
        '${relative(file)} Identity Service gap lane ids incomplete.',
      );
    }
  }

  final rules = eventMap['release_evidence_rules'];
  if (rules is! Map ||
      rules['representative_subset_is_not_full_breadth'] != true ||
      rules['identity_service_full_breadth_claim_requires_lane_evidence'] !=
          true ||
      rules['explicit_exclusion_required_when_lane_not_included'] != true ||
      rules['failure_issue_ref_must_remain_open_until_resolved'] != true ||
      rules['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} Identity Service release evidence rules invalid.',
    );
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['identity_service_full_breadth_decomposed'] != true ||
      expected['release_scope_issue_ref'] != 'imoyan/houra-server#138' ||
      expected['support_claim_not_widened'] != true ||
      expected['versions_advertisement_widened'] != false ||
      expected['follow_up_required'] != true) {
    failures.add(
      '${relative(file)} expected Identity Service gap inventory invalid.',
    );
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

void checkMatrixPushGatewayFullBreadthGapInventory(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-077')) {
    failures.add(
      'Matrix Push Gateway full-breadth gap inventory SPEC-077 is required.',
    );
  }
  const path =
      'test-vectors/core/matrix-push-gateway-full-breadth-gap-inventory.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix Push Gateway full-breadth gap vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-077') {
    failures.add('${relative(file)} must reference SPEC-077.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] !=
          'https://spec.matrix.org/v1.18/push-gateway-api/' ||
      eventMap['client_server_push_source'] !=
          'https://spec.matrix.org/v1.18/client-server-api/#push-notifications' ||
      eventMap['parent_issue'] != 'imoyan/houra-server#139') {
    failures.add('${relative(file)} Matrix reference or parent issue invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }

  final releaseScopeDecision = eventMap['release_scope_decision'];
  if (releaseScopeDecision is! Map ||
      releaseScopeDecision['domain'] != 'Push Gateway API' ||
      releaseScopeDecision['decision'] !=
          'out-of-scope-for-current-release-candidate' ||
      releaseScopeDecision['issue'] != 'imoyan/houra-server#139' ||
      releaseScopeDecision['advertisement_allowed'] != false) {
    failures.add('${relative(file)} release scope decision invalid.');
  }

  requireStringListIncludes(file, eventMap, 'covered_subset_contracts', {
    'SPEC-060',
    'SPEC-062',
    'SPEC-064',
    'SPEC-065',
    'SPEC-066',
  }, failures);

  const expectedLaneIds = {
    'notify-payload-gateway-endpoint-breadth',
    'pusher-configuration-outbound-destination-safety-breadth',
    'push-rule-evaluation-sync-visibility-breadth',
    'delivery-retry-rejected-pushkey-lifecycle-breadth',
    'privacy-payload-minimization-breadth',
    'vendor-provider-credential-gateway-operation-breadth',
    'client-permission-rendering-background-scheduling-breadth',
    'security-observability-redaction-breadth',
    'release-evidence-non-advertisement-breadth',
  };
  final lanes = eventMap['required_gap_lanes'];
  if (lanes is! List || lanes.length < expectedLaneIds.length) {
    failures.add('${relative(file)} Push Gateway gap lanes are incomplete.');
  } else {
    final seenLaneIds = <String>{};
    for (final lane in lanes) {
      if (lane is! Map ||
          lane['id'] is! String ||
          lane['status'] !=
              'requires-follow-up-contract-or-implementation-issue' ||
          lane['endpoint_examples'] is! List ||
          lane['owner_repos'] is! List ||
          lane['advertisement_allowed'] != false) {
        failures.add('${relative(file)} Push Gateway gap lane shape invalid.');
        continue;
      }
      final laneId = lane['id'] as String;
      final endpointExamples = lane['endpoint_examples'] as List;
      final ownerRepos = lane['owner_repos'] as List;
      final expectedOwner =
          laneId == 'client-permission-rendering-background-scheduling-breadth'
          ? 'houra-client'
          : 'houra-server';
      if (!expectedLaneIds.contains(laneId) ||
          endpointExamples.isEmpty ||
          ownerRepos.isEmpty ||
          !ownerRepos.any((repo) => repo == expectedOwner)) {
        failures.add(
          '${relative(file)} Push Gateway gap lane content invalid.',
        );
      }
      seenLaneIds.add(laneId);
    }
    if (!seenLaneIds.containsAll(expectedLaneIds)) {
      failures.add('${relative(file)} Push Gateway gap lane ids incomplete.');
    }
  }

  final rules = eventMap['release_evidence_rules'];
  if (rules is! Map ||
      rules['representative_subset_is_not_full_breadth'] != true ||
      rules['push_gateway_full_breadth_claim_requires_lane_evidence'] != true ||
      rules['explicit_exclusion_required_when_lane_not_included'] != true ||
      rules['failure_issue_ref_must_remain_open_until_resolved'] != true ||
      rules['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} Push Gateway release evidence rules invalid.',
    );
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['push_gateway_full_breadth_decomposed'] != true ||
      expected['release_scope_issue_ref'] != 'imoyan/houra-server#139' ||
      expected['support_claim_not_widened'] != true ||
      expected['versions_advertisement_widened'] != false ||
      expected['follow_up_required'] != true) {
    failures.add(
      '${relative(file)} expected Push Gateway gap inventory invalid.',
    );
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

void checkMatrixServerServerFullBreadthGapInventory(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-074')) {
    failures.add(
      'Matrix Server-Server full-breadth gap inventory SPEC-074 is required.',
    );
  }
  const path =
      'test-vectors/core/matrix-server-server-full-breadth-gap-inventory.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix Server-Server full-breadth gap vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-074') {
    failures.add('${relative(file)} must reference SPEC-074.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['matrix_spec_version'] != 'v1.18' ||
      eventMap['matrix_spec_source'] !=
          'https://spec.matrix.org/v1.18/server-server-api/' ||
      eventMap['parent_issue'] != 'imoyan/houra-server#136') {
    failures.add('${relative(file)} Matrix reference or parent issue invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String || !checkedAt.contains('+09:00')) {
    failures.add('${relative(file)} checked_at must be a dated JST snapshot.');
  }

  final releaseScopeDecision = eventMap['release_scope_decision'];
  if (releaseScopeDecision is! Map ||
      releaseScopeDecision['domain'] != 'Server-Server API' ||
      releaseScopeDecision['decision'] !=
          'out-of-scope-for-current-release-candidate' ||
      releaseScopeDecision['issue'] != 'imoyan/houra-server#136' ||
      releaseScopeDecision['advertisement_allowed'] != false) {
    failures.add('${relative(file)} release scope decision invalid.');
  }

  requireStringListIncludes(file, eventMap, 'covered_subset_contracts', {
    'SPEC-055',
    'SPEC-056',
    'SPEC-057',
    'SPEC-061',
    'SPEC-063',
  }, failures);

  const expectedLaneIds = {
    'federation-discovery-version-key-lifecycle-request-auth-breadth',
    'transaction-pdu-edu-event-validation-breadth',
    'event-retrieval-missing-events-backfill-state-response-breadth',
    'join-knock-leave-invite-third-party-invite-breadth',
    'directory-spaces-query-openid-profile-breadth',
    'federation-e2ee-device-send-to-device-media-breadth',
    'server-acl-policy-server-event-signing-breadth',
    'complement-full-breadth-reference-interop-breadth',
  };
  final lanes = eventMap['required_gap_lanes'];
  if (lanes is! List || lanes.length < expectedLaneIds.length) {
    failures.add('${relative(file)} Server-Server gap lanes are incomplete.');
  } else {
    final seenLaneIds = <String>{};
    for (final lane in lanes) {
      if (lane is! Map ||
          lane['id'] is! String ||
          lane['status'] !=
              'requires-follow-up-contract-or-implementation-issue' ||
          lane['endpoint_examples'] is! List ||
          lane['owner_repos'] is! List ||
          lane['advertisement_allowed'] != false) {
        failures.add('${relative(file)} Server-Server gap lane shape invalid.');
        continue;
      }
      final laneId = lane['id'] as String;
      final endpointExamples = lane['endpoint_examples'] as List;
      final ownerRepos = lane['owner_repos'] as List;
      if (!expectedLaneIds.contains(laneId) ||
          endpointExamples.isEmpty ||
          ownerRepos.isEmpty ||
          !ownerRepos.contains('houra-server')) {
        failures.add(
          '${relative(file)} Server-Server gap lane content invalid.',
        );
      }
      seenLaneIds.add(laneId);
    }
    if (!seenLaneIds.containsAll(expectedLaneIds)) {
      failures.add('${relative(file)} Server-Server gap lane ids incomplete.');
    }
  }

  final rules = eventMap['release_evidence_rules'];
  if (rules is! Map ||
      rules['representative_subset_is_not_full_breadth'] != true ||
      rules['complement_full_breadth_claim_requires_lane_evidence'] != true ||
      rules['explicit_exclusion_required_when_lane_not_included'] != true ||
      rules['failure_issue_ref_must_remain_open_until_resolved'] != true ||
      rules['versions_advertisement_widened'] != false) {
    failures.add(
      '${relative(file)} Server-Server release evidence rules invalid.',
    );
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['server_server_full_breadth_decomposed'] != true ||
      expected['release_scope_issue_ref'] != 'imoyan/houra-server#136' ||
      expected['support_claim_not_widened'] != true ||
      expected['versions_advertisement_widened'] != false ||
      expected['follow_up_required'] != true) {
    failures.add(
      '${relative(file)} expected Server-Server gap inventory invalid.',
    );
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
    'known_gap_refs',
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
  validateMatrixCoverageKnownGaps(file, value, failures);
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

void validateMatrixCoverageKnownGaps(
  File file,
  Map value,
  List<String> failures,
) {
  final gaps = value['known_gap_refs'];
  if (gaps is! List) {
    failures.add('${relative(file)} matrix coverage known gaps invalid.');
    return;
  }
  for (final gap in gaps) {
    if (gap is! Map) {
      failures.add('${relative(file)} matrix coverage known gap invalid.');
      continue;
    }
    final scope = gap['scope'];
    final reason = gap['reason'];
    if (scope is! String || scope.isEmpty) {
      failures.add('${relative(file)} matrix coverage known gap incomplete.');
    }
    final issue = gap['issue'];
    final hasReason = reason is String && reason.isNotEmpty;
    final hasIssue = issue is String && issue.isNotEmpty;
    if (!hasReason && !hasIssue) {
      failures.add('${relative(file)} matrix coverage known gap incomplete.');
    }
    if (issue != null && (issue is! String || issue.isEmpty)) {
      failures.add(
        '${relative(file)} matrix coverage known gap issue invalid.',
      );
    }
  }
  if (value['domain'] == 'Server-Server API' &&
      !gaps.any((gap) => gap is Map && gap['scope'] == 'policy-servers')) {
    failures.add(
      '${relative(file)} Server-Server API must list policy-servers gap.',
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
  final advertised = candidate is Map
      ? readStringList(candidate['advertised_domains'])
      : null;
  if (candidate is! Map ||
      candidate['coverage_report_contract'] != 'SPEC-062' ||
      candidate['complement_lane_contract'] != 'SPEC-063' ||
      advertised == null ||
      advertised.isEmpty ||
      evidence is! List ||
      evidence.length != advertised.length) {
    failures.add('${relative(file)} advertisement blocked candidate invalid.');
  } else {
    final evidenceByDomain = readMatrixAdvertisementEvidence(
      file,
      evidence,
      failures,
      requirePassing: false,
    );
    for (final domain in advertised) {
      if (!evidenceByDomain.containsKey(domain)) {
        failures.add(
          '${relative(file)} advertised domain lacks evidence: $domain.',
        );
      }
    }
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
  final advertised = candidate is Map
      ? readStringList(candidate['advertised_domains'])
      : null;
  final excluded = candidate is Map
      ? readStringList(candidate['excluded_domains'])
      : null;
  final evidence = candidate is Map ? candidate['domain_evidence'] : null;
  if (candidate is! Map ||
      candidate['coverage_report_contract'] != 'SPEC-062' ||
      candidate['complement_lane_contract'] != 'SPEC-063' ||
      advertised == null ||
      advertised.isEmpty ||
      !advertised.contains('Client-Server API') ||
      excluded == null ||
      excluded.isEmpty ||
      advertised.toSet().intersection(excluded.toSet()).isNotEmpty ||
      candidate['unstable_mscs_included'] != false ||
      evidence is! List ||
      evidence.length != advertised.length) {
    failures.add('${relative(file)} advertisement allowed candidate invalid.');
  } else {
    final evidenceByDomain = readMatrixAdvertisementEvidence(
      file,
      evidence,
      failures,
      requirePassing: true,
    );
    if (evidenceByDomain.length != advertised.length ||
        !advertised.every(evidenceByDomain.containsKey)) {
      failures.add(
        '${relative(file)} advertised domains must match passing evidence.',
      );
    }
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

Map<String, Map<String, Object?>> readMatrixAdvertisementEvidence(
  File file,
  List evidence,
  List<String> failures, {
  required bool requirePassing,
}) {
  final result = <String, Map<String, Object?>>{};
  for (final item in evidence) {
    if (item is! Map) {
      failures.add('${relative(file)} advertisement evidence invalid.');
      continue;
    }
    final evidenceMap = item.cast<String, Object?>();
    final domain = evidenceMap['domain'];
    if (domain is! String || domain.isEmpty) {
      failures.add('${relative(file)} advertisement evidence domain invalid.');
      continue;
    }
    if (result.containsKey(domain)) {
      failures.add(
        '${relative(file)} duplicate advertisement evidence domain.',
      );
      continue;
    }
    final contractGate = evidenceMap['contract_gate'];
    final implementationGate = evidenceMap['implementation_gate'];
    if (contractGate is! String || implementationGate is! String) {
      failures.add('${relative(file)} advertisement evidence gate invalid.');
    }
    if (requirePassing &&
        (contractGate != 'pass' || implementationGate != 'pass')) {
      failures.add(
        '${relative(file)} advertised domain evidence must pass: $domain.',
      );
    }
    if ((requirePassing ||
            (contractGate == 'pass' && implementationGate == 'pass')) &&
        (evidenceMap['artifact'] is! String ||
            (evidenceMap['artifact'] as String).isEmpty)) {
      failures.add(
        '${relative(file)} advertisement evidence artifact invalid.',
      );
    }
    result[domain] = evidenceMap;
  }
  return result;
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
          'houra-matrix-v1.18-current-blocked-2026-05-18' ||
      refs['houra_spec_ref'] != '39c3e98d8070dd86ef3440fe4a2f92fc9c2d0a89' ||
      refs['houra_server_ref'] != 'b3b3eb2d98b1eb924084f6f07a653a1c01b92b03' ||
      refs['houra_client_ref'] != 'b7c31882dbc17c35a25215990e8b0ab86f38f777') {
    failures.add('${relative(file)} current candidate refs invalid.');
  }

  final evidenceSources = eventMap['evidence_sources'];
  final server = evidenceSources is Map ? evidenceSources['server'] : null;
  final client = evidenceSources is Map ? evidenceSources['client'] : null;
  if (server is! Map ||
      server['repo'] != 'houra-server' ||
      server['issue'] != 'imoyan/houra-server#321' ||
      server['pull_request'] != 'imoyan/houra-server#327' ||
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
      client['issue'] != 'imoyan/houra-client#205' ||
      client['pull_request'] != 'imoyan/houra-client#206' ||
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

void checkMatrix2SnapshotV118DiffChecklist(
  Map<String, String> contracts,
  List<String> failures,
) {
  const path = 'test-vectors/core/matrix-2-snapshot-v1-18-diff-checklist.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix 2.0 snapshot diff checklist: $path');
    return;
  }
  if (!contracts.containsKey('SPEC-133')) {
    failures.add('$path references missing contract: SPEC-133');
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-133') {
    failures.add('${relative(file)} must use SPEC-133.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['issue'] != 'imoyan/houra-spec#380' ||
      eventMap['parent_issue'] != 'imoyan/houra-spec#377' ||
      eventMap['matrix_2_release_status'] != 'pending-stable-spec-release' ||
      eventMap['timezone'] != 'Asia/Tokyo') {
    failures.add('${relative(file)} Matrix 2.0 issue/status metadata invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String ||
      !RegExp(
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+09:00$',
      ).hasMatch(checkedAt)) {
    failures.add(
      '${relative(file)} checked_at must be a dated +09:00 snapshot.',
    );
  }

  final baseline = eventMap['current_baseline'];
  if (baseline is! Map ||
      baseline['matrix_spec_version'] != 'v1.18' ||
      baseline['spec_source'] != 'https://spec.matrix.org/v1.18/' ||
      baseline['release_note'] !=
          'https://matrix.org/blog/2026/03/26/matrix-v1.18-release/') {
    failures.add('${relative(file)} v1.18 baseline snapshot invalid.');
  }

  final matrix2Source = eventMap['matrix_2_source_snapshot'];
  final sourceCandidates = matrix2Source is Map
      ? matrix2Source['source_candidates']
      : null;
  if (matrix2Source is! Map ||
      matrix2Source['stable_spec_source'] !=
          'pending-official-stable-matrix-2-spec' ||
      matrix2Source['stable_release_note'] !=
          'pending-official-stable-matrix-2-release-note' ||
      matrix2Source['current_stable_spec_entrypoint'] !=
          'https://spec.matrix.org/latest/' ||
      matrix2Source['source_status'] !=
          'planning-only-until-stable-spec-release' ||
      sourceCandidates is! List ||
      sourceCandidates.length != 2 ||
      !sourceCandidates.contains(
        'https://matrix.org/blog/2024/10/29/matrix-2.0-is-here/',
      ) ||
      !sourceCandidates.contains(
        'https://matrix.org/blog/2023/12/25/the-matrix-holiday-update-2023/',
      )) {
    failures.add('${relative(file)} Matrix 2.0 source snapshot invalid.');
  }

  final lanes = eventMap['diff_lanes'];
  const expectedLaneIssues = {
    'versions-advertisement': 'imoyan/houra-spec#381',
    'oauth-oidc': 'imoyan/houra-spec#382',
    'sliding-sync': 'imoyan/houra-spec#383',
    'e2ee-key-backup-verification': 'imoyan/houra-spec#384',
    'room-versions-auth-state-resolution': 'imoyan/houra-spec#385',
    'extensible-profiles-events': 'imoyan/houra-spec#386',
  };
  if (lanes is! List || lanes.length != expectedLaneIssues.length) {
    failures.add('${relative(file)} diff lanes invalid.');
  } else {
    final seenLaneIds = <String>{};
    for (final lane in lanes) {
      if (lane is! Map ||
          lane['id'] is! String ||
          lane['issue'] is! String ||
          lane['matrix_domain'] is! String ||
          lane['classification_required'] != true ||
          lane['stable_requirement_required_before_claim'] != true ||
          lane['msc_only_allowed_to_widen_claim'] != false ||
          lane['advertisement_allowed'] != false) {
        failures.add('${relative(file)} diff lane entry invalid.');
        continue;
      }
      final id = lane['id'] as String;
      seenLaneIds.add(id);
      if (expectedLaneIssues[id] != lane['issue']) {
        failures.add('${relative(file)} diff lane issue ref invalid for $id.');
      }
      if (!matrixDomains.contains(lane['matrix_domain'])) {
        failures.add('${relative(file)} diff lane domain invalid for $id.');
      }
    }
    if (!seenLaneIds.containsAll(expectedLaneIssues.keys)) {
      failures.add('${relative(file)} diff lane ids incomplete.');
    }
  }

  final classificationRules = eventMap['classification_rules'];
  final stableFields = classificationRules is Map
      ? classificationRules['stable_requirement_fields']
      : null;
  final mscOnlyFields = classificationRules is Map
      ? classificationRules['msc_only_fields']
      : null;
  final allowedClassifications = classificationRules is Map
      ? classificationRules['allowed_classifications']
      : null;
  if (classificationRules is! Map ||
      stableFields is! List ||
      stableFields.length != 8 ||
      mscOnlyFields is! List ||
      mscOnlyFields.length != 6 ||
      allowedClassifications is! List ||
      !allowedClassifications.contains('stable-requirement') ||
      !allowedClassifications.contains('msc-only') ||
      !allowedClassifications.contains('implementation-note') ||
      !allowedClassifications.contains('out-of-scope') ||
      classificationRules['separate_v1_18_and_matrix_2_evidence'] != true) {
    failures.add('${relative(file)} classification rules invalid.');
  }

  final claimBoundary = eventMap['claim_boundary'];
  if (claimBoundary is! Map ||
      claimBoundary['matrix_2_support_claimed'] != false ||
      claimBoundary['versions_advertisement_widened'] != false ||
      claimBoundary['matrix_v1_18_claim_widened'] != false ||
      claimBoundary['product_mvp_readiness_widened'] != false ||
      claimBoundary['release_notes_widened'] != false ||
      claimBoundary['publishable_matrix_support_claim_widened'] != false) {
    failures.add('${relative(file)} claim boundary invalid.');
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['diff_lane_count'] != expectedLaneIssues.length ||
      expected['stable_source_pending'] != true ||
      expected['stable_requirement_fields_count'] != 8 ||
      expected['msc_only_fields_count'] != 6 ||
      expected['versions_advertisement_widened'] != false ||
      expected['matrix_2_support_claimed'] != false ||
      expected['publishable_matrix_support_claim_widened'] != false) {
    failures.add('${relative(file)} expected summary invalid.');
  } else {
    final issueRefs = expected['issue_refs'];
    if (issueRefs is! List ||
        !issueRefs.toSet().containsAll(expectedLaneIssues.values)) {
      failures.add('${relative(file)} expected issue refs incomplete.');
    }
  }

  final serialized = jsonEncode(json);
  for (final forbidden in const [
    '/Users',
    '/tmp',
    'access_token',
    'refresh_token',
    'token-',
  ]) {
    if (serialized.contains(forbidden)) {
      failures.add(
        '${relative(file)} Matrix 2.0 snapshot contains forbidden evidence token: $forbidden',
      );
    }
  }
}

void checkMatrix2VersionsAdvertisementEvidenceGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  const path =
      'test-vectors/core/matrix-2-versions-advertisement-evidence-gate.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix 2.0 versions advertisement gate: $path');
    return;
  }
  if (!contracts.containsKey('SPEC-134')) {
    failures.add('$path references missing contract: SPEC-134');
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-134') {
    failures.add('${relative(file)} must use SPEC-134.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['issue'] != 'imoyan/houra-spec#381' ||
      eventMap['parent_issue'] != 'imoyan/houra-spec#377' ||
      eventMap['snapshot_issue'] != 'imoyan/houra-spec#380' ||
      eventMap['lane'] != 'versions-advertisement' ||
      eventMap['matrix_domain'] != 'Client-Server API' ||
      eventMap['timezone'] != 'Asia/Tokyo' ||
      eventMap['matrix_2_release_status'] != 'pending-stable-spec-release') {
    failures.add(
      '${relative(file)} Matrix 2.0 advertisement metadata invalid.',
    );
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String ||
      !RegExp(
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+09:00$',
      ).hasMatch(checkedAt)) {
    failures.add(
      '${relative(file)} checked_at must be a dated +09:00 snapshot.',
    );
  }
  if (eventMap['current_stable_spec_entrypoint'] !=
          'https://spec.matrix.org/latest/' ||
      eventMap['current_stable_spec_version'] != 'v1.18' ||
      eventMap['source_snapshot_contract'] != 'SPEC-133' ||
      eventMap['existing_advertisement_gate_contract'] != 'SPEC-064' ||
      eventMap['release_readiness_contract'] != 'SPEC-066') {
    failures.add('${relative(file)} Matrix 2.0 reference contracts invalid.');
  }

  final candidate = eventMap['candidate'];
  final refs = candidate is Map
      ? readStringList(candidate['same_candidate_refs_required'])
      : null;
  final domainEvidence = candidate is Map ? candidate['domain_evidence'] : null;
  final requirements = candidate is Map
      ? readStringList(candidate['evidence_requirements'])
      : null;
  if (candidate is! Map ||
      candidate['requested_matrix_version'] != 'v2.0' ||
      candidate['versions_response_path'] != '/_matrix/client/versions' ||
      candidate['stable_source_snapshot_status'] != 'pending' ||
      refs == null ||
      refs.length != 6 ||
      !refs.contains('publishable-support-claim') ||
      requirements == null ||
      requirements.length != 8 ||
      domainEvidence is! List ||
      domainEvidence.length != 5) {
    failures.add('${relative(file)} advertisement candidate invalid.');
  } else {
    const expectedLanes = {
      'oauth-oidc': ('imoyan/houra-spec#382', 'Client-Server API'),
      'sliding-sync': ('imoyan/houra-spec#383', 'Client-Server API'),
      'e2ee-key-backup-verification': ('imoyan/houra-spec#384', 'Olm & Megolm'),
      'room-versions-auth-state-resolution': (
        'imoyan/houra-spec#385',
        'Room Versions',
      ),
      'extensible-profiles-events': (
        'imoyan/houra-spec#386',
        'Client-Server API',
      ),
    };
    final seenLaneIds = <String>{};
    for (final lane in domainEvidence) {
      if (lane is! Map ||
          lane['lane_id'] is! String ||
          lane['lane_issue'] is! String ||
          lane['matrix_domain'] is! String ||
          lane['status'] != 'pending-stable-source' ||
          lane['required_before_advertisement'] != true) {
        failures.add('${relative(file)} domain lane evidence invalid.');
        continue;
      }
      final id = lane['lane_id'] as String;
      seenLaneIds.add(id);
      final expected = expectedLanes[id];
      if (expected == null ||
          lane['lane_issue'] != expected.$1 ||
          lane['matrix_domain'] != expected.$2 ||
          !matrixDomains.contains(lane['matrix_domain'])) {
        failures.add('${relative(file)} domain lane mismatch for $id.');
      }
    }
    if (!seenLaneIds.containsAll(expectedLanes.keys)) {
      failures.add('${relative(file)} domain lane ids incomplete.');
    }
  }

  final gate = eventMap['gate_result'];
  final reasons = gate is Map ? gate['blocking_reasons'] : null;
  if (gate is! Map ||
      gate['status'] != 'blocked' ||
      reasons is! List ||
      reasons.length < 4 ||
      gate['versions_advertisement_allowed'] != false ||
      gate['versions_response_must_include_v2_0'] != false ||
      gate['release_notes_claim_allowed'] != false ||
      gate['release_tag_allowed'] != false ||
      gate['publishable_matrix_support_claim_allowed'] != false) {
    failures.add('${relative(file)} advertisement gate result invalid.');
  }

  final rules = eventMap['separation_rules'];
  if (rules is! Map ||
      rules['stable_source_required'] != true ||
      rules['same_candidate_evidence_required'] != true ||
      rules['secret_redaction_required'] != true ||
      rules['msc_only_allowed_to_widen_claim'] != false ||
      rules['unstable_feature_flags_are_not_stable_versions'] != true ||
      rules['matrix_v1_18_evidence_does_not_imply_matrix_2'] != true) {
    failures.add('${relative(file)} separation rules invalid.');
  }
  final forbiddenClasses = eventMap['forbidden_evidence_classes'];
  if (forbiddenClasses is! List || forbiddenClasses.length != 8) {
    failures.add('${relative(file)} forbidden evidence classes invalid.');
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['matrix_2_advertisement_blocked'] != true ||
      expected['versions_advertisement_allowed'] != false ||
      expected['versions_response_must_include_v2_0'] != false ||
      expected['release_notes_claim_allowed'] != false ||
      expected['release_tag_allowed'] != false ||
      expected['publishable_matrix_support_claim_allowed'] != false ||
      expected['domain_lane_count'] != 5 ||
      expected['same_candidate_ref_count'] != 6 ||
      expected['stable_source_pending'] != true) {
    failures.add('${relative(file)} expected advertisement result invalid.');
  } else {
    final issueRefs = expected['issue_refs'];
    if (issueRefs is! List ||
        !issueRefs.toSet().containsAll({
          'imoyan/houra-spec#382',
          'imoyan/houra-spec#383',
          'imoyan/houra-spec#384',
          'imoyan/houra-spec#385',
          'imoyan/houra-spec#386',
        })) {
      failures.add('${relative(file)} expected issue refs incomplete.');
    }
  }

  final serialized = jsonEncode(json);
  for (final forbidden in const [
    '/Users',
    '/tmp',
    'access_token',
    'refresh_token',
    'authorization_code',
    'callback_query',
    'idp_session',
    'private_key',
    'token-',
  ]) {
    if (serialized.contains(forbidden)) {
      failures.add(
        '${relative(file)} Matrix 2.0 advertisement evidence contains forbidden token: $forbidden',
      );
    }
  }
}

void checkMatrix2OAuthOidcReadinessGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  const path = 'test-vectors/auth/matrix-2-oauth-oidc-readiness-gate.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix 2.0 OAuth/OIDC readiness gate: $path');
    return;
  }
  if (!contracts.containsKey('SPEC-135')) {
    failures.add('$path references missing contract: SPEC-135');
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-135') {
    failures.add('${relative(file)} must use SPEC-135.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['issue'] != 'imoyan/houra-spec#382' ||
      eventMap['parent_issue'] != 'imoyan/houra-spec#377' ||
      eventMap['snapshot_issue'] != 'imoyan/houra-spec#380' ||
      eventMap['advertisement_issue'] != 'imoyan/houra-spec#381' ||
      eventMap['lane'] != 'oauth-oidc' ||
      eventMap['matrix_domain'] != 'Client-Server API' ||
      eventMap['timezone'] != 'Asia/Tokyo' ||
      eventMap['matrix_2_release_status'] != 'pending-stable-spec-release') {
    failures.add('${relative(file)} Matrix 2.0 OAuth/OIDC metadata invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String ||
      !RegExp(
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+09:00$',
      ).hasMatch(checkedAt)) {
    failures.add(
      '${relative(file)} checked_at must be a dated +09:00 snapshot.',
    );
  }
  if (eventMap['current_stable_spec_entrypoint'] !=
          'https://spec.matrix.org/latest/' ||
      eventMap['current_stable_spec_version'] != 'v1.18' ||
      eventMap['source_snapshot_contract'] != 'SPEC-133' ||
      eventMap['versions_advertisement_gate_contract'] != 'SPEC-134' ||
      eventMap['v1_18_oauth_boundary_contract'] != 'SPEC-068') {
    failures.add('${relative(file)} OAuth/OIDC reference contracts invalid.');
  }

  final relatedContracts = readStringList(eventMap['related_contracts']);
  if (relatedContracts == null ||
      !relatedContracts.toSet().containsAll({
        'SPEC-032',
        'SPEC-033',
        'SPEC-034',
        'SPEC-068',
        'SPEC-122',
        'SPEC-134',
      })) {
    failures.add('${relative(file)} related contracts incomplete.');
  }

  final rules = eventMap['classification_rules'];
  final classifications = rules is Map
      ? readStringList(rules['allowed_classifications'])
      : null;
  final stableFields = rules is Map
      ? readStringList(rules['stable_requirement_fields'])
      : null;
  final nonStableFields = rules is Map
      ? readStringList(rules['non_stable_fields'])
      : null;
  if (rules is! Map ||
      classifications == null ||
      classifications.length != 5 ||
      !classifications.contains('stable-requirement') ||
      !classifications.contains('msc-only') ||
      !classifications.contains('provider-specific') ||
      !classifications.contains('implementation-note') ||
      !classifications.contains('out-of-scope') ||
      stableFields == null ||
      stableFields.length != 8 ||
      nonStableFields == null ||
      nonStableFields.length != 5 ||
      rules['provider_specific_behavior_is_not_protocol_claim'] != true ||
      rules['spec_068_account_management_is_not_full_matrix_2_oauth'] != true) {
    failures.add('${relative(file)} classification rules invalid.');
  }

  final redaction = eventMap['redaction_rules'];
  if (redaction is! Map ||
      redaction['bearer_credentials_retained'] != false ||
      redaction['refresh_credentials_retained'] != false ||
      redaction['grant_codes_retained'] != false ||
      redaction['callback_parameters_retained'] != false ||
      redaction['identity_provider_session_ids_retained'] != false ||
      redaction['privateKeyMaterialRetained'] != false ||
      redaction['browser_session_state_retained'] != false ||
      redaction['metadata_shape_allowed'] != true ||
      redaction['redirect_origin_and_path_allowed_after_query_redaction'] !=
          true) {
    failures.add('${relative(file)} redaction rules invalid.');
  }

  final gate = eventMap['gate_result'];
  final reasons = gate is Map ? gate['blocking_reasons'] : null;
  if (gate is! Map ||
      gate['status'] != 'blocked' ||
      reasons is! List ||
      reasons.length < 4 ||
      gate['matrix_2_oauth_claim_allowed'] != false ||
      gate['oauth_login_flow_advertised'] != false ||
      gate['versions_advertisement_widened'] != false ||
      gate['release_notes_claim_allowed'] != false ||
      gate['publishable_matrix_support_claim_widened'] != false ||
      gate['provider_interop_claim_allowed'] != false ||
      gate['dynamic_client_registration_claim_allowed'] != false ||
      gate['device_authorization_grant_claim_allowed'] != false) {
    failures.add('${relative(file)} OAuth/OIDC gate result invalid.');
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['matrix_2_oauth_gate_blocked'] != true ||
      expected['classification_count'] != 5 ||
      expected['stable_requirement_fields_count'] != 8 ||
      expected['non_stable_fields_count'] != 5 ||
      expected['secret_bearing_evidence_allowed'] != false ||
      expected['spec_068_preserved_as_v1_18_boundary'] != true ||
      expected['matrix_2_oauth_claim_allowed'] != false ||
      expected['versions_advertisement_widened'] != false ||
      expected['publishable_matrix_support_claim_widened'] != false ||
      expected['provider_interop_claim_allowed'] != false) {
    failures.add('${relative(file)} expected OAuth/OIDC result invalid.');
  }

  final serialized = jsonEncode(json);
  for (final forbidden in const [
    '/Users',
    '/tmp',
    'access_token',
    'refresh_token',
    'authorization_code',
    'callback_query',
    'idp_session',
    'private_key',
    'token-',
  ]) {
    if (serialized.contains(forbidden)) {
      failures.add(
        '${relative(file)} Matrix 2.0 OAuth/OIDC evidence contains forbidden token: $forbidden',
      );
    }
  }
}

void checkMatrix2SlidingSyncReadinessGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  const path = 'test-vectors/sync/matrix-2-sliding-sync-readiness-gate.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix 2.0 Sliding Sync readiness gate: $path');
    return;
  }
  if (!contracts.containsKey('SPEC-136')) {
    failures.add('$path references missing contract: SPEC-136');
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-136') {
    failures.add('${relative(file)} must use SPEC-136.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['issue'] != 'imoyan/houra-spec#383' ||
      eventMap['parent_issue'] != 'imoyan/houra-spec#377' ||
      eventMap['snapshot_issue'] != 'imoyan/houra-spec#380' ||
      eventMap['advertisement_issue'] != 'imoyan/houra-spec#381' ||
      eventMap['lane'] != 'sliding-sync' ||
      eventMap['matrix_domain'] != 'Client-Server API' ||
      eventMap['timezone'] != 'Asia/Tokyo' ||
      eventMap['matrix_2_release_status'] != 'pending-stable-spec-release') {
    failures.add('${relative(file)} Matrix 2.0 Sliding Sync metadata invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String ||
      !RegExp(
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+09:00$',
      ).hasMatch(checkedAt)) {
    failures.add(
      '${relative(file)} checked_at must be a dated +09:00 snapshot.',
    );
  }
  if (eventMap['current_stable_spec_entrypoint'] !=
          'https://spec.matrix.org/latest/' ||
      eventMap['current_stable_spec_version'] != 'v1.18' ||
      eventMap['source_snapshot_contract'] != 'SPEC-133' ||
      eventMap['versions_advertisement_gate_contract'] != 'SPEC-134' ||
      eventMap['v1_18_sync_contract'] != 'SPEC-037' ||
      eventMap['v1_18_sync_extension_boundary'] != 'SPEC-093') {
    failures.add('${relative(file)} Sliding Sync reference contracts invalid.');
  }

  final rules = eventMap['classification_rules'];
  final classifications = rules is Map
      ? readStringList(rules['allowed_classifications'])
      : null;
  final stableFields = rules is Map
      ? readStringList(rules['stable_requirement_fields'])
      : null;
  if (rules is! Map ||
      classifications == null ||
      classifications.length != 5 ||
      !classifications.contains('stable-requirement') ||
      !classifications.contains('optional-extension') ||
      !classifications.contains('proxy-behavior') ||
      !classifications.contains('implementation-note') ||
      !classifications.contains('out-of-scope') ||
      stableFields == null ||
      stableFields.length != 8 ||
      rules['client_only_evidence_implies_server_support'] != false ||
      rules['server_only_evidence_implies_client_support'] != false ||
      rules['proxy_behavior_is_not_protocol_claim'] != true ||
      rules['spec_093_parser_boundary_is_not_sliding_sync_support'] != true) {
    failures.add(
      '${relative(file)} Sliding Sync classification rules invalid.',
    );
  }

  final unsupported = eventMap['unsupported_behavior'];
  if (unsupported is! Map ||
      unsupported['unsupported_endpoint_fails_closed'] != true ||
      unsupported['unsupported_platform_fails_closed'] != true ||
      unsupported['unadvertised_proxy_fallback_allowed'] != false ||
      unsupported['performance_claim_allowed_without_benchmark'] != false ||
      unsupported['optional_extension_claim_allowed_without_evidence'] !=
          false) {
    failures.add(
      '${relative(file)} Sliding Sync unsupported behavior invalid.',
    );
  }

  final gate = eventMap['gate_result'];
  final reasons = gate is Map ? gate['blocking_reasons'] : null;
  if (gate is! Map ||
      gate['status'] != 'blocked' ||
      reasons is! List ||
      reasons.length < 4 ||
      gate['matrix_2_sliding_sync_claim_allowed'] != false ||
      gate['sync_performance_claim_allowed'] != false ||
      gate['versions_advertisement_widened'] != false ||
      gate['release_notes_claim_allowed'] != false ||
      gate['publishable_matrix_support_claim_widened'] != false) {
    failures.add('${relative(file)} Sliding Sync gate result invalid.');
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['matrix_2_sliding_sync_gate_blocked'] != true ||
      expected['classification_count'] != 5 ||
      expected['stable_requirement_fields_count'] != 8 ||
      expected['unsupported_endpoint_fails_closed'] != true ||
      expected['proxy_behavior_not_claimed'] != true ||
      expected['spec_093_preserved_as_parser_boundary'] != true ||
      expected['matrix_2_sliding_sync_claim_allowed'] != false ||
      expected['versions_advertisement_widened'] != false ||
      expected['publishable_matrix_support_claim_widened'] != false) {
    failures.add('${relative(file)} expected Sliding Sync result invalid.');
  }

  final serialized = jsonEncode(json);
  for (final forbidden in const [
    '/Users',
    '/tmp',
    'access_token',
    'refresh_token',
    'authorization_code',
    'callback_query',
    'idp_session',
    'private_key',
    'token-',
  ]) {
    if (serialized.contains(forbidden)) {
      failures.add(
        '${relative(file)} Matrix 2.0 Sliding Sync evidence contains forbidden token: $forbidden',
      );
    }
  }
}

void checkMatrix2E2eeKeyBackupVerificationReadinessGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  const path =
      'test-vectors/messaging/matrix-2-e2ee-key-backup-verification-readiness-gate.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix 2.0 E2EE readiness gate: $path');
    return;
  }
  if (!contracts.containsKey('SPEC-137')) {
    failures.add('$path references missing contract: SPEC-137');
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-137') {
    failures.add('${relative(file)} must use SPEC-137.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['issue'] != 'imoyan/houra-spec#384' ||
      eventMap['parent_issue'] != 'imoyan/houra-spec#377' ||
      eventMap['snapshot_issue'] != 'imoyan/houra-spec#380' ||
      eventMap['advertisement_issue'] != 'imoyan/houra-spec#381' ||
      eventMap['lane'] != 'e2ee-key-backup-verification' ||
      eventMap['matrix_domain'] != 'Olm & Megolm' ||
      eventMap['timezone'] != 'Asia/Tokyo' ||
      eventMap['matrix_2_release_status'] != 'pending-stable-spec-release') {
    failures.add('${relative(file)} Matrix 2.0 E2EE metadata invalid.');
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String ||
      !RegExp(
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+09:00$',
      ).hasMatch(checkedAt)) {
    failures.add(
      '${relative(file)} checked_at must be a dated +09:00 snapshot.',
    );
  }
  if (eventMap['current_stable_spec_entrypoint'] !=
          'https://spec.matrix.org/latest/' ||
      eventMap['current_stable_spec_version'] != 'v1.18' ||
      eventMap['source_snapshot_contract'] != 'SPEC-133' ||
      eventMap['versions_advertisement_gate_contract'] != 'SPEC-134' ||
      eventMap['v1_18_gap_inventory_contract'] != 'SPEC-079' ||
      eventMap['maintained_crypto_boundary_contract'] != 'SPEC-081') {
    failures.add('${relative(file)} E2EE reference contracts invalid.');
  }

  final relatedContracts = readStringList(eventMap['related_contracts']);
  if (relatedContracts == null ||
      relatedContracts.length != 11 ||
      !relatedContracts.toSet().containsAll({
        'SPEC-050',
        'SPEC-051',
        'SPEC-052',
        'SPEC-053',
        'SPEC-054',
        'SPEC-069',
        'SPEC-079',
        'SPEC-081',
        'SPEC-102',
        'SPEC-130',
        'SPEC-134',
      })) {
    failures.add('${relative(file)} related E2EE contracts incomplete.');
  }

  final rules = eventMap['classification_rules'];
  final classifications = rules is Map
      ? readStringList(rules['allowed_classifications'])
      : null;
  final stableFields = rules is Map
      ? readStringList(rules['stable_requirement_fields'])
      : null;
  if (rules is! Map ||
      classifications == null ||
      classifications.length != 5 ||
      !classifications.contains('stable-requirement') ||
      !classifications.contains('parser-artifact-only') ||
      !classifications.contains('maintained-stack-evidence') ||
      !classifications.contains('implementation-note') ||
      !classifications.contains('out-of-scope') ||
      stableFields == null ||
      stableFields.length != 8 ||
      rules['parser_artifact_evidence_implies_crypto_support'] != false ||
      rules['maintained_stack_selection_implies_runtime_adoption'] != false ||
      rules['server_evidence_may_own_local_secrets'] != false) {
    failures.add('${relative(file)} E2EE classification rules invalid.');
  }

  final redaction = eventMap['secret_redaction_rules'];
  if (redaction is! Map ||
      redaction['plaintext_retained'] != false ||
      redaction['roomKeyMaterialRetained'] != false ||
      redaction['sessionKeyMaterialRetained'] != false ||
      redaction['privateKeyMaterialRetained'] != false ||
      redaction['recoveryMaterialRetained'] != false ||
      redaction['secureStorageHandlesRetained'] != false ||
      redaction['rawEncryptedMediaRetained'] != false ||
      redaction['public_key_shape_allowed'] != true ||
      redaction['opaque_backup_payload_shape_allowed'] != true) {
    failures.add('${relative(file)} E2EE redaction rules invalid.');
  }

  final gate = eventMap['gate_result'];
  final reasons = gate is Map ? gate['blocking_reasons'] : null;
  if (gate is! Map ||
      gate['status'] != 'blocked' ||
      reasons is! List ||
      reasons.length < 4 ||
      gate['matrix_2_e2ee_claim_allowed'] != false ||
      gate['key_backup_claim_allowed'] != false ||
      gate['verification_claim_allowed'] != false ||
      gate['cross_signing_claim_allowed'] != false ||
      gate['encrypted_room_claim_allowed'] != false ||
      gate['versions_advertisement_widened'] != false ||
      gate['publishable_matrix_support_claim_widened'] != false) {
    failures.add('${relative(file)} E2EE gate result invalid.');
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['matrix_2_e2ee_gate_blocked'] != true ||
      expected['classification_count'] != 5 ||
      expected['stable_requirement_fields_count'] != 8 ||
      expected['related_contract_count'] != 11 ||
      expected['secret_bearing_evidence_allowed'] != false ||
      expected['spec_079_preserved_as_gap_inventory'] != true ||
      expected['spec_081_preserved_as_ownership_boundary'] != true ||
      expected['matrix_2_e2ee_claim_allowed'] != false ||
      expected['versions_advertisement_widened'] != false ||
      expected['publishable_matrix_support_claim_widened'] != false) {
    failures.add('${relative(file)} expected E2EE result invalid.');
  }

  final serialized = jsonEncode(json);
  for (final forbidden in const [
    '/Users',
    '/tmp',
    'access_token',
    'refresh_token',
    'authorization_code',
    'callback_query',
    'idp_session',
    'private_key',
    'token-',
  ]) {
    if (serialized.contains(forbidden)) {
      failures.add(
        '${relative(file)} Matrix 2.0 E2EE evidence contains forbidden token: $forbidden',
      );
    }
  }
}

void checkMatrix2RoomVersionsAuthStateReadinessGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  const path =
      'test-vectors/rooms/matrix-2-room-versions-auth-state-readiness-gate.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Matrix 2.0 Room Versions readiness gate: $path');
    return;
  }
  if (!contracts.containsKey('SPEC-138')) {
    failures.add('$path references missing contract: SPEC-138');
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-138') {
    failures.add('${relative(file)} must use SPEC-138.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['issue'] != 'imoyan/houra-spec#385' ||
      eventMap['parent_issue'] != 'imoyan/houra-spec#377' ||
      eventMap['snapshot_issue'] != 'imoyan/houra-spec#380' ||
      eventMap['advertisement_issue'] != 'imoyan/houra-spec#381' ||
      eventMap['lane'] != 'room-versions-auth-state-resolution' ||
      eventMap['matrix_domain'] != 'Room Versions' ||
      eventMap['timezone'] != 'Asia/Tokyo' ||
      eventMap['matrix_2_release_status'] != 'pending-stable-spec-release') {
    failures.add(
      '${relative(file)} Matrix 2.0 Room Versions metadata invalid.',
    );
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String ||
      !RegExp(
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+09:00$',
      ).hasMatch(checkedAt)) {
    failures.add(
      '${relative(file)} checked_at must be a dated +09:00 snapshot.',
    );
  }
  if (eventMap['current_stable_spec_entrypoint'] !=
          'https://spec.matrix.org/latest/' ||
      eventMap['current_stable_spec_version'] != 'v1.18' ||
      eventMap['source_snapshot_contract'] != 'SPEC-133' ||
      eventMap['versions_advertisement_gate_contract'] != 'SPEC-134' ||
      eventMap['v1_18_gap_inventory_contract'] != 'SPEC-078' ||
      eventMap['capabilities_boundary_contract'] != 'SPEC-080') {
    failures.add(
      '${relative(file)} Room Versions reference contracts invalid.',
    );
  }

  final relatedContracts = readStringList(eventMap['related_contracts']);
  if (relatedContracts == null ||
      relatedContracts.length != 13 ||
      !relatedContracts.toSet().containsAll({
        'SPEC-040',
        'SPEC-041',
        'SPEC-042',
        'SPEC-043',
        'SPEC-044',
        'SPEC-078',
        'SPEC-080',
        'SPEC-083',
        'SPEC-084',
        'SPEC-101',
        'SPEC-103',
        'SPEC-104',
        'SPEC-134',
      })) {
    failures.add(
      '${relative(file)} related Room Versions contracts incomplete.',
    );
  }

  final rules = eventMap['classification_rules'];
  final classifications = rules is Map
      ? readStringList(rules['allowed_classifications'])
      : null;
  final stableFields = rules is Map
      ? readStringList(rules['stable_requirement_fields'])
      : null;
  if (rules is! Map ||
      classifications == null ||
      classifications.length != 5 ||
      !classifications.contains('stable-requirement') ||
      !classifications.contains('representative-fixture-only') ||
      !classifications.contains('capabilities-advertisement') ||
      !classifications.contains('implementation-note') ||
      !classifications.contains('out-of-scope') ||
      stableFields == null ||
      stableFields.length != 8 ||
      rules['representative_fixture_implies_full_algorithm_support'] != false ||
      rules['capabilities_advertisement_implies_domain_support'] != false ||
      rules['helper_evidence_implies_runtime_support'] != false) {
    failures.add(
      '${relative(file)} Room Versions classification rules invalid.',
    );
  }

  final unsupported = eventMap['unsupported_behavior'];
  if (unsupported is! Map ||
      unsupported['unsupported_room_version_fails_closed'] != true ||
      unsupported['unsupported_auth_rule_fails_closed'] != true ||
      unsupported['unsupported_state_resolution_case_fails_closed'] != true ||
      unsupported['default_room_version_requires_evidence'] != true ||
      unsupported['available_room_versions_require_evidence'] != true) {
    failures.add(
      '${relative(file)} Room Versions unsupported behavior invalid.',
    );
  }

  final gate = eventMap['gate_result'];
  final reasons = gate is Map ? gate['blocking_reasons'] : null;
  if (gate is! Map ||
      gate['status'] != 'blocked' ||
      reasons is! List ||
      reasons.length < 4 ||
      gate['matrix_2_room_versions_claim_allowed'] != false ||
      gate['default_room_version_claim_allowed'] != false ||
      gate['available_room_versions_claim_allowed'] != false ||
      gate['full_auth_state_resolution_claim_allowed'] != false ||
      gate['versions_advertisement_widened'] != false ||
      gate['publishable_matrix_support_claim_widened'] != false) {
    failures.add('${relative(file)} Room Versions gate result invalid.');
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['matrix_2_room_versions_gate_blocked'] != true ||
      expected['classification_count'] != 5 ||
      expected['stable_requirement_fields_count'] != 8 ||
      expected['related_contract_count'] != 13 ||
      expected['spec_078_preserved_as_gap_inventory'] != true ||
      expected['spec_080_preserved_as_capabilities_boundary'] != true ||
      expected['unsupported_room_version_fails_closed'] != true ||
      expected['matrix_2_room_versions_claim_allowed'] != false ||
      expected['versions_advertisement_widened'] != false ||
      expected['publishable_matrix_support_claim_widened'] != false) {
    failures.add('${relative(file)} expected Room Versions result invalid.');
  }

  final serialized = jsonEncode(json);
  for (final forbidden in const [
    '/Users',
    '/tmp',
    'access_token',
    'refresh_token',
    'authorization_code',
    'callback_query',
    'idp_session',
    'private_key',
    'token-',
  ]) {
    if (serialized.contains(forbidden)) {
      failures.add(
        '${relative(file)} Matrix 2.0 Room Versions evidence contains forbidden token: $forbidden',
      );
    }
  }
}

void checkMatrix2ExtensibleProfilesEventsReadinessGate(
  Map<String, String> contracts,
  List<String> failures,
) {
  const path =
      'test-vectors/sync/matrix-2-extensible-profiles-events-readiness-gate.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add(
      'Missing Matrix 2.0 Extensible Profiles and Events readiness gate: $path',
    );
    return;
  }
  if (!contracts.containsKey('SPEC-139')) {
    failures.add('$path references missing contract: SPEC-139');
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-139') {
    failures.add('${relative(file)} must use SPEC-139.');
  }
  final eventMap = requireMatrixEventMap(file, json, failures);
  if (eventMap == null) {
    return;
  }
  if (eventMap['issue'] != 'imoyan/houra-spec#386' ||
      eventMap['parent_issue'] != 'imoyan/houra-spec#377' ||
      eventMap['snapshot_issue'] != 'imoyan/houra-spec#380' ||
      eventMap['advertisement_issue'] != 'imoyan/houra-spec#381' ||
      eventMap['lane'] != 'extensible-profiles-events' ||
      eventMap['matrix_domain'] != 'Client-Server API' ||
      eventMap['timezone'] != 'Asia/Tokyo' ||
      eventMap['matrix_2_release_status'] != 'pending-stable-spec-release') {
    failures.add(
      '${relative(file)} Matrix 2.0 Extensible Profiles and Events metadata invalid.',
    );
  }
  final checkedAt = eventMap['checked_at'];
  if (checkedAt is! String ||
      !RegExp(
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+09:00$',
      ).hasMatch(checkedAt)) {
    failures.add(
      '${relative(file)} checked_at must be a dated +09:00 snapshot.',
    );
  }
  if (eventMap['current_stable_spec_entrypoint'] !=
          'https://spec.matrix.org/latest/' ||
      eventMap['current_stable_spec_version'] != 'v1.18' ||
      eventMap['source_snapshot_contract'] != 'SPEC-133' ||
      eventMap['versions_advertisement_gate_contract'] != 'SPEC-134' ||
      eventMap['v1_18_profile_account_data_contract'] != 'SPEC-045' ||
      eventMap['v1_18_send_event_contract'] != 'SPEC-036' ||
      eventMap['v1_18_sync_extensions_contract'] != 'SPEC-093' ||
      eventMap['common_rules_contract'] != 'SPEC-031' ||
      eventMap['event_graph_contract'] != 'SPEC-040' ||
      eventMap['event_format_contract'] != 'SPEC-103') {
    failures.add(
      '${relative(file)} Extensible Profiles and Events reference contracts invalid.',
    );
  }

  final relatedContracts = readStringList(eventMap['related_contracts']);
  if (relatedContracts == null ||
      relatedContracts.length != 13 ||
      !relatedContracts.toSet().containsAll({
        'SPEC-031',
        'SPEC-036',
        'SPEC-037',
        'SPEC-040',
        'SPEC-045',
        'SPEC-046',
        'SPEC-047',
        'SPEC-090',
        'SPEC-093',
        'SPEC-103',
        'SPEC-131',
        'SPEC-133',
        'SPEC-134',
      })) {
    failures.add(
      '${relative(file)} related Extensible Profiles and Events contracts incomplete.',
    );
  }

  final rules = eventMap['classification_rules'];
  final classifications = rules is Map
      ? readStringList(rules['allowed_classifications'])
      : null;
  final stableFields = rules is Map
      ? readStringList(rules['stable_requirement_fields'])
      : null;
  if (rules is! Map ||
      classifications == null ||
      classifications.length != 6 ||
      !classifications.contains('stable-requirement') ||
      !classifications.contains('extensible-profile-field') ||
      !classifications.contains('extensible-event-content') ||
      !classifications.contains('parser-validation-only') ||
      !classifications.contains('implementation-note') ||
      !classifications.contains('out-of-scope') ||
      stableFields == null ||
      stableFields.length != 8 ||
      !stableFields.contains('profile_or_event_surface') ||
      !stableFields.contains('content_validation_boundary') ||
      rules['experimental_msc_implies_stable_support'] != false ||
      rules['parser_validation_implies_runtime_support'] != false ||
      rules['client_rendering_note_implies_protocol_support'] != false ||
      rules['custom_profile_field_implies_advertised_profile_capability'] !=
          false ||
      rules['generic_event_content_implies_supported_event_type'] != false) {
    failures.add(
      '${relative(file)} Extensible Profiles and Events classification rules invalid.',
    );
  }

  final redaction = eventMap['redaction_rules'];
  if (redaction is! Map ||
      redaction['profile_payload_retained'] != false ||
      redaction['display_name_value_retained'] != false ||
      redaction['avatar_url_value_retained'] != false ||
      redaction['account_data_payload_retained'] != false ||
      redaction['raw_event_content_retained'] != false ||
      redaction['event_body_value_retained'] != false ||
      redaction['formatted_body_value_retained'] != false ||
      redaction['external_url_value_retained'] != false ||
      redaction['content_shape_retained'] != true ||
      redaction['namespaced_identifier_shape_retained'] != true) {
    failures.add(
      '${relative(file)} Extensible Profiles and Events redaction rules invalid.',
    );
  }

  final unsupported = eventMap['unsupported_behavior'];
  if (unsupported is! Map ||
      unsupported['unsupported_profile_field_fails_closed'] != true ||
      unsupported['unsupported_event_content_fails_closed'] != true ||
      unsupported['unstable_msc_excluded_from_support_claim'] != true ||
      unsupported['parser_only_evidence_requires_explicit_no_runtime_claim'] !=
          true ||
      unsupported['capability_advertisement_requires_same_candidate_evidence'] !=
          true) {
    failures.add(
      '${relative(file)} Extensible Profiles and Events unsupported behavior invalid.',
    );
  }

  final gate = eventMap['gate_result'];
  final reasons = gate is Map ? gate['blocking_reasons'] : null;
  if (gate is! Map ||
      gate['status'] != 'blocked' ||
      reasons is! List ||
      reasons.length < 4 ||
      gate['matrix_2_extensible_profiles_events_claim_allowed'] != false ||
      gate['profile_extension_claim_allowed'] != false ||
      gate['event_extension_claim_allowed'] != false ||
      gate['capability_advertisement_claim_allowed'] != false ||
      gate['versions_advertisement_widened'] != false ||
      gate['publishable_matrix_support_claim_widened'] != false) {
    failures.add(
      '${relative(file)} Extensible Profiles and Events gate result invalid.',
    );
  }

  final expected = json['expected'];
  if (expected is! Map ||
      expected['matrix_2_extensible_profiles_events_gate_blocked'] != true ||
      expected['classification_count'] != 6 ||
      expected['stable_requirement_fields_count'] != 8 ||
      expected['related_contract_count'] != 13 ||
      expected['spec_045_preserved_as_profile_account_data_boundary'] != true ||
      expected['spec_036_preserved_as_send_event_boundary'] != true ||
      expected['spec_093_preserved_as_sync_extension_boundary'] != true ||
      expected['redacted_evidence_required'] != true ||
      expected['unsupported_event_content_fails_closed'] != true ||
      expected['matrix_2_extensible_profiles_events_claim_allowed'] != false ||
      expected['versions_advertisement_widened'] != false ||
      expected['publishable_matrix_support_claim_widened'] != false) {
    failures.add(
      '${relative(file)} expected Extensible Profiles and Events result invalid.',
    );
  }

  final serialized = jsonEncode(json);
  for (final forbidden in const [
    '/Users',
    '/tmp',
    'access_token',
    'refresh_token',
    'authorization_code',
    'callback_query',
    'idp_session',
    'private_key',
    'token-',
  ]) {
    if (serialized.contains(forbidden)) {
      failures.add(
        '${relative(file)} Matrix 2.0 Extensible Profiles and Events evidence contains forbidden token: $forbidden',
      );
    }
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

void checkPre10CompatibilityPolicy(List<String> failures) {
  const path = 'test-vectors/core/pre-1-0-compatibility-change-policy.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing pre-1.0 compatibility policy vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-065') {
    failures.add('${relative(file)} must reference SPEC-065.');
  }
  final event = json['event'];
  if (event is! Map ||
      event['source_doc'] != 'SOURCE_OF_TRUTH.md' ||
      event['published_pre_1_0_tags_are_immutable'] != true) {
    failures.add('${relative(file)} pre-1.0 immutability policy invalid.');
    return;
  }
  final classifications = event['change_classifications'];
  if (classifications is! List || classifications.length != 3) {
    failures.add('${relative(file)} change classifications invalid.');
  } else {
    final seen = <String>{};
    for (final item in classifications) {
      if (item is! Map ||
          item['id'] is! String ||
          item['definition'] is! String ||
          item['requires_release_note_label'] != true ||
          !item.containsKey('requires_implementation_follow_up') ||
          item['requires_migration_guidance'] == null) {
        failures.add('${relative(file)} change classification shape invalid.');
        continue;
      }
      seen.add(item['id'] as String);
    }
    if (!seen.containsAll({'breaking', 'additive', 'corrective'})) {
      failures.add('${relative(file)} change classification ids incomplete.');
    }
  }
  requireStringListIncludes(
    file,
    event.cast<String, Object?>(),
    'deprecation_record_required_fields',
    {
      'deprecated_behavior',
      'replacement_behavior_or_out_of_scope_decision',
      'migration_guidance',
      'affected_implementation_repos',
      'implementation_issue_or_pr_refs',
      'claim_boundary',
      'release_notes_evidence',
    },
    failures,
  );
  requireStringListIncludes(
    file,
    event.cast<String, Object?>(),
    'release_notes_required_fields',
    {
      'changed_profiles',
      'changed_contracts_vectors_or_design_inputs',
      'compatibility_classification',
      'implementation_follow_up',
      'deprecation_or_replacement_note',
      'claim_boundary',
    },
    failures,
  );
  final claimBoundaries = event['claim_boundaries'];
  if (claimBoundaries is! Map ||
      claimBoundaries['houra_product_mvp'] is! String ||
      claimBoundaries['matrix_compatibility'] is! String ||
      claimBoundaries['versions_advertisement_widened'] != false) {
    failures.add('${relative(file)} claim boundaries invalid.');
  }
  final expected = json['expected'];
  if (expected is! Map ||
      expected['pre_1_0_tags_immutable'] != true ||
      expected['breaking_additive_corrective_defined'] != true ||
      expected['deprecation_records_owned'] != true ||
      expected['implementation_follow_up_traceable'] != true ||
      expected['product_mvp_and_matrix_claims_separate'] != true) {
    failures.add('${relative(file)} expected policy result invalid.');
  }
}

void checkSpecHealthChecklist(List<String> failures) {
  const path =
      'test-vectors/core/spec-health-conformance-health-checklist.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing spec health checklist vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-066') {
    failures.add('${relative(file)} must reference SPEC-066.');
  }
  final event = json['event'];
  if (event is! Map ||
      event['source_doc'] != 'README.md' ||
      event['current_follow_up_state'] != 'closed' ||
      event['current_untracked_gap_state'] != 'none-recorded') {
    failures.add('${relative(file)} spec health checklist metadata invalid.');
    return;
  }
  requireStringListIncludes(
    file,
    event.cast<String, Object?>(),
    'periodic_review_triggers',
    {
      'before milestone release',
      'after broad Matrix roadmap changes',
      'after Product MVP release-candidate evidence changes',
      'after design schema or UI surface changes',
      'after implementation conformance failure that might indicate spec ambiguity',
    },
    failures,
  );
  requireStringListIncludes(
    file,
    event.cast<String, Object?>(),
    'required_health_surfaces',
    {
      'contracts/SPEC-*.md',
      'CONTRACT_MODULE_MAP.md',
      'FEATURE_PROFILES.md',
      'MODULE_DEPENDENCIES.md',
      'README.md profile and domain coverage sections',
      'test-vectors/**/*.json',
      'design/theme.schema.json',
      'design/themes/*.json',
      'design/ui.surface.schema.json',
      'design/ui-surfaces/*.json',
      'tool/check_spec.dart',
      'docs/ja/**',
    },
    failures,
  );
  requireStringListIncludes(
    file,
    event.cast<String, Object?>(),
    'coverage_dimensions',
    {
      'contract mapped to profile and domain',
      'contract has representative vector coverage or explicit non-vector rationale',
      'positive vector coverage',
      'negative vector coverage for parser or failure behavior',
      'stateful vector given metadata remains implementation-neutral',
      'design inputs validate against committed schemas',
      'release readiness and advertisement gates validate stale or mismatched refs',
      'implementation adoption evidence does not contradict contract or vector state',
    },
    failures,
  );
  requireStringListIncludes(
    file,
    event.cast<String, Object?>(),
    'gap_disposition',
    {
      'fix in current PR when small and local',
      'split to focused spec issue when behavior or release scope changes',
      'split to implementation adoption issue when spec is clear but adoption evidence is missing',
      'record no untracked gap when the sweep finds no missing coverage or validation hole',
    },
    failures,
  );
  requireStringListIncludes(
    file,
    event.cast<String, Object?>(),
    'current_follow_up_refs',
    {'imoyan/houra-spec#198', 'imoyan/houra-spec#202', 'imoyan/houra-spec#204'},
    failures,
  );
  requireStringListIncludes(
    file,
    event.cast<String, Object?>(),
    'required_commands',
    {'dart tool/check_spec.dart', 'git diff --check'},
    failures,
  );
  final expected = json['expected'];
  if (expected is! Map ||
      expected['health_surfaces_defined'] != true ||
      expected['coverage_dimensions_defined'] != true ||
      expected['gap_disposition_defined'] != true ||
      expected['current_follow_up_refs_recorded'] != true ||
      expected['current_untracked_gap_state_recorded'] != true) {
    failures.add('${relative(file)} expected spec health result invalid.');
  }
}

void checkProductMvpReleaseCandidatePlan(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-039')) {
    failures.add('Product MVP release candidate plan requires SPEC-039.');
  }
  const path = 'test-vectors/core/product-mvp-release-candidate-plan.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing Product MVP release candidate plan vector: $path');
    return;
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-039') {
    failures.add('${relative(file)} must reference SPEC-039.');
  }
  final event = json['event'];
  if (event is! Map ||
      event['source_doc'] != 'README.md' ||
      event['tracked_issue'] != 'imoyan/houra-spec#190' ||
      event['release_candidate'] != 'next-product-mvp-release-candidate' ||
      event['matrix_full_compliance_claimed'] != false) {
    failures.add('${relative(file)} Product MVP RC metadata invalid.');
    return;
  }
  final eventMap = event.cast<String, Object?>();
  final repoEntries = eventMap['required_repositories'];
  if (repoEntries is! List || repoEntries.length != 3) {
    failures.add('${relative(file)} required repositories invalid.');
  } else {
    final repos = <String>{};
    for (final item in repoEntries) {
      if (item is! Map ||
          item['repo'] is! String ||
          item['role'] is! String ||
          item['required_ref'] is! String) {
        failures.add('${relative(file)} required repository shape invalid.');
        continue;
      }
      repos.add(item['repo'] as String);
    }
    if (!repos.containsAll({
      'imoyan/houra-spec',
      'imoyan/houra-server',
      'imoyan/houra-client',
    })) {
      failures.add('${relative(file)} required repositories incomplete.');
    }
  }
  final lanes = eventMap['evidence_lanes'];
  if (lanes is! List || lanes.length != 4) {
    failures.add('${relative(file)} evidence lanes invalid.');
  } else {
    final laneIds = <String>{};
    final laneRefs = <String>{};
    for (final item in lanes) {
      if (item is! Map ||
          item['id'] is! String ||
          item['owner_repo'] is! String ||
          item['tracking_ref'] is! String ||
          item['status'] is! String ||
          item['required_inputs'] is! List) {
        failures.add('${relative(file)} evidence lane shape invalid.');
        continue;
      }
      final requiredInputs = item['required_inputs'] as List;
      if (requiredInputs.isEmpty ||
          requiredInputs.any((input) => input is! String || input.isEmpty)) {
        failures.add('${relative(file)} evidence lane inputs invalid.');
      }
      laneIds.add(item['id'] as String);
      laneRefs.add(item['tracking_ref'] as String);
    }
    if (!laneIds.containsAll({
      'product-mvp-happy-path',
      'ui-surface-adoption',
      'docker-compose-deploy-smoke',
      'implementation-adoption-report',
    })) {
      failures.add('${relative(file)} evidence lane ids incomplete.');
    }
    if (!laneRefs.containsAll({
      'imoyan/houra-client#121',
      'imoyan/houra-client#122',
      'imoyan/houra-server#227',
      'imoyan/houra-spec#204',
    })) {
      failures.add('${relative(file)} evidence lane refs incomplete.');
    }
  }
  requireStringListIncludes(file, eventMap, 'release_blockers', {
    'imoyan/houra-client#121',
    'imoyan/houra-client#122',
    'imoyan/houra-server#227',
  }, failures);
  requireStringListIncludes(file, eventMap, 'completed_supporting_refs', {
    'imoyan/houra-spec#199',
    'imoyan/houra-spec#200',
    'imoyan/houra-spec#203',
    'imoyan/houra-spec#204',
    'imoyan/houra-spec#319',
    'imoyan/houra-spec#320',
    'imoyan/houra-spec#321',
    'imoyan/houra-spec#340',
    'imoyan/houra-spec#343',
    'imoyan/houra-spec#345',
    'imoyan/houra-spec#346',
  }, failures);
  final candidateFeatures = eventMap['candidate_feature_evidence'];
  if (candidateFeatures is! List || candidateFeatures.length != 4) {
    failures.add('${relative(file)} candidate feature evidence invalid.');
  } else {
    final featureIds = <String>{};
    final featureContracts = <String>{};
    final featureRefs = <String>{};
    for (final item in candidateFeatures) {
      if (item is! Map ||
          item['id'] is! String ||
          item['contracts'] is! List ||
          item['spec_refs'] is! List ||
          item['implementation_refs'] is! List ||
          item['release_candidate_decision'] is! String ||
          item['required_evidence_before_advertisement'] is! List) {
        failures.add('${relative(file)} candidate feature shape invalid.');
        continue;
      }
      final decision = item['release_candidate_decision'] as String;
      if (!decision.contains('fail-closed') &&
          !decision.contains('candidate-review-required')) {
        failures.add('${relative(file)} candidate feature decision invalid.');
      }
      final requiredEvidence =
          item['required_evidence_before_advertisement'] as List;
      if (requiredEvidence.isEmpty ||
          requiredEvidence.any((input) => input is! String || input.isEmpty)) {
        failures.add('${relative(file)} candidate feature evidence invalid.');
      }
      final contracts = readStringList(item['contracts']);
      final specRefs = readStringList(item['spec_refs']);
      final implementationRefs = readStringList(item['implementation_refs']);
      if (contracts == null ||
          contracts.isEmpty ||
          contracts.any((contract) => contract.isEmpty) ||
          specRefs == null ||
          specRefs.isEmpty ||
          specRefs.any((ref) => ref.isEmpty) ||
          implementationRefs == null ||
          implementationRefs.isEmpty ||
          implementationRefs.any((ref) => ref.isEmpty)) {
        failures.add('${relative(file)} candidate feature refs invalid.');
        continue;
      }
      featureIds.add(item['id'] as String);
      featureContracts.addAll(contracts);
      featureRefs.addAll(specRefs);
      featureRefs.addAll(implementationRefs);
    }
    if (!featureIds.containsAll({
      'product-mvp-vnext-account-recovery-idp',
      'product-mvp-vnext-media-transfer',
      'product-mvp-vnext-encrypted-media',
      'product-mvp-server-boundary-additions',
    })) {
      failures.add('${relative(file)} candidate feature ids incomplete.');
    }
    if (!featureContracts.containsAll({
      'SPEC-070',
      'SPEC-071',
      'SPEC-072',
      'SPEC-126',
      'SPEC-127',
      'SPEC-128',
      'SPEC-129',
    })) {
      failures.add('${relative(file)} candidate feature contracts incomplete.');
    }
    if (!featureRefs.containsAll({
      'imoyan/houra-spec#319',
      'imoyan/houra-spec#320',
      'imoyan/houra-spec#321',
      'imoyan/houra-spec#340',
      'imoyan/houra-spec#343',
      'imoyan/houra-spec#345',
      'imoyan/houra-spec#346',
      'imoyan/houra-client#184',
      'imoyan/houra-client#186',
      'imoyan/houra-client#192',
      'imoyan/houra-client#193',
      'imoyan/houra-client#195',
      'imoyan/houra-server#254',
      'imoyan/houra-server#337',
      'imoyan/houra-server#338',
      'imoyan/houra-server#339',
      'imoyan/houra-server#340',
    })) {
      failures.add('${relative(file)} candidate feature refs incomplete.');
    }
  }
  requireStringListIncludes(file, eventMap, 'required_commands', {
    'dart tool/check_spec.dart',
    'git diff --check',
    'implementation repo Product MVP happy path command recorded by imoyan/houra-client#121',
    'implementation repo UI surface adoption command recorded by imoyan/houra-client#122',
    'implementation repo Docker Compose deploy smoke command recorded by imoyan/houra-server#227',
  }, failures);
  final tagPolicy = eventMap['rc_tag_policy'];
  if (tagPolicy is! String || !tagPolicy.contains('blocking evidence lanes')) {
    failures.add('${relative(file)} RC tag policy invalid.');
  }
  final expected = json['expected'];
  if (expected is! Map ||
      expected['required_repositories_traceable'] != true ||
      expected['evidence_lanes_split'] != true ||
      expected['candidate_feature_evidence_traceable'] != true ||
      expected['implementation_follow_ups_traceable'] != true ||
      expected['matrix_full_compliance_not_claimed'] != true ||
      expected['rc_tag_blocked_until_evidence_complete'] != true) {
    failures.add('${relative(file)} expected Product MVP RC result invalid.');
  }
}

void checkOssPublicationReadinessPlan(
  Map<String, String> contracts,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-066')) {
    failures.add('OSS publication readiness plan requires SPEC-066.');
  }
  const path = 'test-vectors/core/oss-publication-readiness-plan.json';
  final file = File(path);
  if (!file.existsSync()) {
    failures.add('Missing OSS publication readiness plan vector: $path');
    return;
  }
  if (!File('LICENSE').existsSync()) {
    failures.add('OSS publication readiness requires LICENSE.');
  }
  if (!File('SECURITY.md').existsSync()) {
    failures.add('OSS publication readiness requires SECURITY.md.');
  }
  final json = readJsonObject(file, failures);
  if (json == null) {
    return;
  }
  if (json['contract'] != 'SPEC-066') {
    failures.add('${relative(file)} must reference SPEC-066.');
  }
  final event = json['event'];
  if (event is! Map ||
      event['source_doc'] != 'README.md' ||
      event['tracked_issue'] != 'imoyan/houra-spec#191' ||
      event['readiness_plan'] != 'oss-publication-readiness') {
    failures.add('${relative(file)} OSS readiness metadata invalid.');
    return;
  }
  final eventMap = event.cast<String, Object?>();
  requireStringListIncludes(file, eventMap, 'normative_source_of_truth', {
    'contracts/SPEC-*.md',
    'test-vectors/',
    'design/theme.schema.json',
    'design/themes/*.json',
    'design/ui.surface.schema.json',
    'design/ui-surfaces/*.json',
  }, failures);
  final surfaces = eventMap['required_repository_surfaces'];
  if (surfaces is! List || surfaces.length < 5) {
    failures.add('${relative(file)} repository surfaces invalid.');
  } else {
    final surfaceIds = <String>{};
    final surfacePathsById = <String, String>{};
    for (final item in surfaces) {
      if (item is! Map ||
          item['id'] is! String ||
          item['path'] is! String ||
          item['state'] is! String ||
          item['required_before_public_listing'] is! bool) {
        failures.add('${relative(file)} repository surface shape invalid.');
        continue;
      }
      final id = item['id'] as String;
      final path = item['path'] as String;
      if (!surfaceIds.add(id)) {
        failures.add('${relative(file)} duplicate repository surface id: $id.');
        continue;
      }
      surfacePathsById[id] = path;
    }
    if (!surfaceIds.containsAll({
      'license',
      'security-policy',
      'private-vulnerability-reporting',
      'release-notes',
      'github-topics',
      'context7-config',
    })) {
      failures.add('${relative(file)} repository surface ids incomplete.');
    }
    const canonicalRepositorySurfaces = {
      'license': 'LICENSE',
      'security-policy': 'SECURITY.md',
    };
    for (final entry in canonicalRepositorySurfaces.entries) {
      final actualPath = surfacePathsById[entry.key];
      if (actualPath == null) {
        continue;
      }
      if (actualPath != entry.value) {
        failures.add(
          '${relative(file)} ${entry.key} surface must point to ${entry.value}.',
        );
      }
    }
  }
  final externalSources = eventMap['external_index_sources'];
  if (externalSources is! List || externalSources.length != 3) {
    failures.add('${relative(file)} external index sources invalid.');
  } else {
    final sourceIds = <String>{};
    for (final item in externalSources) {
      if (item is! Map ||
          item['id'] is! String ||
          item['source'] is! String ||
          item['checked_at'] is! String ||
          item['classification'] is! String ||
          item['adoption_order'] is! String) {
        failures.add('${relative(file)} external index source shape invalid.');
        continue;
      }
      sourceIds.add(item['id'] as String);
    }
    if (!sourceIds.containsAll({
      'context7',
      'openssf-scorecard',
      'openssf-best-practices-badge',
    })) {
      failures.add('${relative(file)} external index source ids incomplete.');
    }
  }
  requireStringListIncludes(file, eventMap, 'publication_order', {
    'complete repository surfaces: LICENSE, SECURITY.md, GitHub private vulnerability reporting, README release boundary, GitHub topics, release notes template',
    'create a GitHub Release anchor for the chosen pre-release or stable ref',
    'register non-normative documentation index entries such as Context7 only after the public docs URL is stable',
    'enable non-normative trust signals such as OpenSSF Scorecard and Best Practices Badge after security and release process surfaces exist',
    'publish implementation packages, app artifacts, or container images only from their owning repositories after artifact-specific readiness issues close',
  }, failures);
  final artifactBoundaries = eventMap['artifact_publication_boundaries'];
  if (artifactBoundaries is! List || artifactBoundaries.length < 4) {
    failures.add('${relative(file)} artifact publication boundaries invalid.');
  } else {
    final trackingRefs = <String>{};
    for (final item in artifactBoundaries) {
      if (item is! Map ||
          item['artifact'] is! String ||
          item['owner_repo'] is! String ||
          item['publish_condition'] is! String) {
        failures.add('${relative(file)} artifact boundary shape invalid.');
        continue;
      }
      final trackingRef = item['tracking_ref'];
      if (trackingRef is String) {
        trackingRefs.add(trackingRef);
      }
    }
    if (!trackingRefs.containsAll({
      'imoyan/houra-server#256',
      'imoyan/houra-client#150',
    })) {
      failures.add('${relative(file)} artifact readiness refs incomplete.');
    }
  }
  final claimBoundaries = eventMap['claim_boundaries'];
  if (claimBoundaries is! Map ||
      claimBoundaries['normative_index'] is! String ||
      claimBoundaries['non_normative_indexes'] is! String ||
      claimBoundaries['product_mvp'] is! String ||
      claimBoundaries['matrix_compatibility'] is! String) {
    failures.add('${relative(file)} claim boundaries invalid.');
  }
  requireStringListIncludes(file, eventMap, 'required_commands', {
    'dart tool/check_spec.dart',
    'git diff --check',
  }, failures);
  final expected = json['expected'];
  if (expected is! Map ||
      expected['repository_surfaces_traceable'] != true ||
      expected['publication_order_defined'] != true ||
      expected['implementation_artifacts_split_by_owner_repo'] != true ||
      expected['non_normative_indexes_do_not_override_ssot'] != true ||
      expected['product_mvp_and_matrix_claims_not_widened'] != true) {
    failures.add('${relative(file)} expected OSS readiness result invalid.');
  }
}

void checkConformanceToolingResultSchema(
  Map<String, String> contracts,
  Map<String, String> profileMap,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-113')) {
    failures.add('Conformance tooling result schema requires SPEC-113.');
  }

  final schemaFile = File(
    'test-vectors/core/conformance-tooling-result-schema-v1.json',
  );
  final schema = readJsonObject(schemaFile, failures);
  if (schema == null) {
    return;
  }
  if (schema['contract'] != 'SPEC-113') {
    failures.add('${relative(schemaFile)} must reference SPEC-113.');
  }
  final event = schema['event'];
  if (event is! Map ||
      event['schema_version'] != 'conformance-report-v1' ||
      event['source_doc'] != 'README.md') {
    failures.add(
      '${relative(schemaFile)} conformance schema metadata invalid.',
    );
    return;
  }
  final eventMap = event.cast<String, Object?>();
  const statuses = {'pass', 'fail', 'skipped', 'blocked', 'out_of_scope'};
  requireStringListIncludes(
    schemaFile,
    eventMap,
    'status_values',
    statuses,
    failures,
  );
  requireStringListIncludes(schemaFile, eventMap, 'required_report_fields', {
    'schema_version',
    'generated_at',
    'houra_spec_ref',
    'houra_spec_commit',
    'implementation',
    'runner',
    'target',
    'results',
    'totals',
    'claim_boundary',
    'redaction',
  }, failures);
  requireStringListIncludes(schemaFile, eventMap, 'required_result_fields', {
    'vector_name',
    'vector_path',
    'contract',
    'feature_profile',
    'status',
  }, failures);

  final sampleReport = eventMap['sample_report'];
  if (sampleReport is! Map) {
    failures.add('${relative(schemaFile)} sample_report must be an object.');
  } else {
    validateConformanceReportSample(
      schemaFile,
      sampleReport.cast<String, Object?>(),
      profileMap,
      statuses,
      failures,
    );
  }

  final expected = schema['expected'];
  if (expected is! Map ||
      expected['schema_defined'] != true ||
      expected['required_report_fields_traceable'] != true ||
      expected['required_result_fields_traceable'] != true ||
      expected['all_status_values_defined'] != true ||
      expected['sample_report_traceable_to_contract_vector_profile'] != true ||
      expected['claim_boundary_not_widened_by_report'] != true ||
      expected['redaction_required'] != true) {
    failures.add('${relative(schemaFile)} expected schema result invalid.');
  }

  final negativeFile = File(
    'test-vectors/core/conformance-tooling-result-negative-cases-v1.json',
  );
  final negative = readJsonObject(negativeFile, failures);
  if (negative == null) {
    return;
  }
  if (negative['contract'] != 'SPEC-113') {
    failures.add('${relative(negativeFile)} must reference SPEC-113.');
  }
  final negativeEvent = negative['event'];
  if (negativeEvent is! Map ||
      negativeEvent['schema_version'] != 'conformance-report-v1') {
    failures.add('${relative(negativeFile)} negative metadata invalid.');
    return;
  }
  final negativeEventMap = negativeEvent.cast<String, Object?>();
  final cases = negativeEventMap['negative_cases'];
  if (cases is! List) {
    failures.add('${relative(negativeFile)} negative_cases must be an array.');
  } else {
    final ids = <String>{};
    for (final item in cases) {
      if (item is! Map ||
          item['id'] is! String ||
          item['invalid_field'] is! String ||
          item['reason'] is! String ||
          item['expected_result'] != 'rejected') {
        failures.add('${relative(negativeFile)} negative case shape invalid.');
        continue;
      }
      ids.add(item['id'] as String);
    }
    for (final id in {
      'stale-spec-ref',
      'unknown-vector',
      'unknown-contract-id',
      'profile-mismatch',
      'unredacted-failure-detail',
    }) {
      if (!ids.contains(id)) {
        failures.add('${relative(negativeFile)} missing negative case: $id');
      }
    }
  }
  requireStringListIncludes(
    negativeFile,
    negativeEventMap,
    'forbidden_failure_detail_categories',
    {
      'bearer_tokens',
      'refresh_tokens',
      'database_urls',
      'signed_or_credentialed_urls',
      'private_local_paths',
      'media_keys',
      'room_keys',
      'recovery_keys',
      'pushkeys',
      'vendor_tokens',
      'plaintext_media_bytes',
      'raw_secrets',
    },
    failures,
  );
  final negativeExpected = negative['expected'];
  if (negativeExpected is! Map ||
      negativeExpected['negative_case_count'] != 5 ||
      negativeExpected['stale_spec_ref_rejected'] != true ||
      negativeExpected['unknown_vector_rejected'] != true ||
      negativeExpected['unknown_contract_rejected'] != true ||
      negativeExpected['profile_mismatch_rejected'] != true ||
      negativeExpected['unredacted_failure_detail_rejected'] != true ||
      negativeExpected['redaction_categories_defined_without_secret_values'] !=
          true) {
    failures.add('${relative(negativeFile)} expected negative result invalid.');
  }
}

void validateConformanceReportSample(
  File file,
  Map<String, Object?> report,
  Map<String, String> profileMap,
  Set<String> statuses,
  List<String> failures,
) {
  if (report['schema_version'] != 'conformance-report-v1' ||
      report['houra_spec_ref'] is! String ||
      report['houra_spec_commit'] is! String ||
      report['implementation'] is! Map ||
      report['runner'] is! Map ||
      report['target'] is! Map) {
    failures.add('${relative(file)} sample_report core fields invalid.');
  }

  final results = report['results'];
  if (results is! List || results.isEmpty) {
    failures.add('${relative(file)} sample_report results invalid.');
    return;
  }
  final totals = <String, int>{for (final status in statuses) status: 0};
  for (final item in results) {
    if (item is! Map) {
      failures.add('${relative(file)} sample_report result shape invalid.');
      continue;
    }
    final result = item.cast<String, Object?>();
    final status = result['status'];
    if (status is! String || !statuses.contains(status)) {
      failures.add('${relative(file)} sample_report result status invalid.');
      continue;
    }
    totals[status] = (totals[status] ?? 0) + 1;
    final vectorPath = result['vector_path'];
    final vectorName = result['vector_name'];
    final contract = result['contract'];
    final featureProfile = result['feature_profile'];
    if (vectorPath is! String ||
        vectorName is! String ||
        contract is! String ||
        featureProfile is! String ||
        !File(vectorPath).existsSync()) {
      failures.add('${relative(file)} sample_report result trace invalid.');
      continue;
    }
    final vector = readJsonObject(File(vectorPath), failures);
    if (vector == null ||
        vector['name'] != vectorName ||
        vector['contract'] != contract ||
        profileMap[contract] != featureProfile) {
      failures.add(
        '${relative(file)} sample_report result must match vector contract/profile.',
      );
    }
    final failureDetail = result['failure_detail'];
    if ((status == 'fail' || status == 'blocked') &&
        (failureDetail is! Map || failureDetail['redacted'] != true)) {
      failures.add(
        '${relative(file)} failing sample_report results require redacted detail.',
      );
    }
  }

  final totalMap = report['totals'];
  if (totalMap is! Map) {
    failures.add('${relative(file)} sample_report totals invalid.');
  } else {
    for (final status in statuses) {
      if (totalMap[status] != totals[status]) {
        failures.add('${relative(file)} sample_report totals mismatch.');
      }
    }
  }

  final claimBoundary = report['claim_boundary'];
  if (claimBoundary is! Map ||
      claimBoundary['matrix_versions_advertisement_widened'] != false ||
      claimBoundary['matrix_domain_support_claimed'] != false ||
      claimBoundary['shared_core_adoption_claimed'] != false ||
      claimBoundary['release_ready'] != false) {
    failures.add('${relative(file)} sample_report claim boundary invalid.');
  }
  final redaction = report['redaction'];
  if (redaction is! Map ||
      redaction['secrets_redacted'] != true ||
      redaction['raw_local_paths_redacted'] != true ||
      redaction['failure_detail_redacted'] != true) {
    failures.add('${relative(file)} sample_report redaction invalid.');
  }
}

void checkSharedCoreAdoptionEvidenceSchema(
  Map<String, String> contracts,
  Map<String, String> profileMap,
  List<String> failures,
) {
  if (!contracts.containsKey('SPEC-114')) {
    failures.add('Shared-core adoption evidence schema requires SPEC-114.');
  }

  final schemaFile = File(
    'test-vectors/core/shared-core-adoption-evidence-schema-v1.json',
  );
  final schema = readJsonObject(schemaFile, failures);
  if (schema == null) {
    return;
  }
  if (schema['contract'] != 'SPEC-114') {
    failures.add('${relative(schemaFile)} must reference SPEC-114.');
  }
  final event = schema['event'];
  if (event is! Map ||
      event['schema_version'] != 'shared-core-adoption-evidence-v1' ||
      event['source_doc'] != 'README.md') {
    failures.add(
      '${relative(schemaFile)} shared-core schema metadata invalid.',
    );
    return;
  }
  final eventMap = event.cast<String, Object?>();
  const statuses = {
    'spec-only',
    'lab-candidate',
    'shared-adopted',
    'adapter-owned',
    'split-by-language',
    'avoid-shared',
  };
  requireStringListIncludes(
    schemaFile,
    eventMap,
    'status_values',
    statuses,
    failures,
  );
  requireStringListIncludes(schemaFile, eventMap, 'required_bundle_fields', {
    'schema_version',
    'generated_at',
    'houra_spec_ref',
    'houra_spec_commit',
    'candidate_evidence',
    'claim_boundary',
    'redaction',
  }, failures);
  requireStringListIncludes(schemaFile, eventMap, 'required_candidate_fields', {
    'candidate_id',
    'candidate_area',
    'status',
    'source_contracts',
    'source_vectors',
    'consumer_repos',
    'artifact_manifest',
    'parity_evidence',
    'performance_evidence',
    'security_boundary',
    'facade_stability',
    'rollback',
    'claim_boundary',
  }, failures);

  final initialCandidates = eventMap['initial_candidates'];
  final initialIds = <String>{};
  if (initialCandidates is! List || initialCandidates.isEmpty) {
    failures.add('${relative(schemaFile)} initial_candidates invalid.');
  } else {
    for (final item in initialCandidates) {
      if (item is! Map ||
          item['candidate_id'] is! String ||
          item['candidate_area'] is! String ||
          item['required_contracts'] is! List ||
          item['required_vectors'] is! List ||
          item['adapter_owned_responsibilities'] is! List) {
        failures.add(
          '${relative(schemaFile)} initial candidate shape invalid.',
        );
        continue;
      }
      final candidate = item.cast<String, Object?>();
      final id = candidate['candidate_id'] as String;
      initialIds.add(id);
      final requiredContracts = (candidate['required_contracts'] as List)
          .whereType<String>()
          .toSet();
      final requiredVectors = (candidate['required_vectors'] as List)
          .whereType<String>()
          .toSet();
      for (final contract in requiredContracts) {
        if (!contracts.containsKey(contract) || profileMap[contract] == null) {
          failures.add(
            '${relative(schemaFile)} initial candidate references unknown contract: $contract',
          );
        }
      }
      for (final path in requiredVectors) {
        validateSharedCoreSourceVector(
          schemaFile,
          path,
          requiredContracts,
          profileMap,
          failures,
        );
      }
    }
    for (final id in {
      'matrix-versions-request-response',
      'matrix-houra-error-envelope',
    }) {
      if (!initialIds.contains(id)) {
        failures.add('${relative(schemaFile)} missing initial candidate: $id');
      }
    }
  }

  final sampleBundle = eventMap['sample_bundle'];
  if (sampleBundle is! Map) {
    failures.add('${relative(schemaFile)} sample_bundle must be an object.');
  } else {
    validateSharedCoreEvidenceBundleSample(
      schemaFile,
      sampleBundle.cast<String, Object?>(),
      contracts,
      profileMap,
      statuses,
      failures,
    );
  }

  final expected = schema['expected'];
  if (expected is! Map ||
      expected['schema_defined'] != true ||
      expected['required_bundle_fields_traceable'] != true ||
      expected['required_candidate_fields_traceable'] != true ||
      expected['all_status_values_defined'] != true ||
      expected['initial_candidates_trace_to_contract_vector_profile'] != true ||
      expected['artifact_manifest_requires_abi_and_runtime_notes'] != true ||
      expected['performance_gate_requires_p95_plus_10_or_hidden_latency'] !=
          true ||
      expected['secret_free_diagnostics_required'] != true ||
      expected['rollback_to_local_parser_required'] != true ||
      expected['claim_boundary_not_widened_by_evidence'] != true ||
      expected['shared_adopted_not_required_dependency'] != true) {
    failures.add('${relative(schemaFile)} expected schema result invalid.');
  }

  final negativeFile = File(
    'test-vectors/core/shared-core-adoption-evidence-negative-cases-v1.json',
  );
  final negative = readJsonObject(negativeFile, failures);
  if (negative == null) {
    return;
  }
  if (negative['contract'] != 'SPEC-114') {
    failures.add('${relative(negativeFile)} must reference SPEC-114.');
  }
  final negativeEvent = negative['event'];
  if (negativeEvent is! Map ||
      negativeEvent['schema_version'] != 'shared-core-adoption-evidence-v1') {
    failures.add('${relative(negativeFile)} negative metadata invalid.');
    return;
  }
  final negativeEventMap = negativeEvent.cast<String, Object?>();
  final cases = negativeEventMap['negative_cases'];
  if (cases is! List) {
    failures.add('${relative(negativeFile)} negative_cases must be an array.');
  } else {
    final ids = <String>{};
    for (final item in cases) {
      if (item is! Map ||
          item['id'] is! String ||
          item['invalid_field'] is! String ||
          item['reason'] is! String ||
          item['expected_result'] != 'rejected') {
        failures.add('${relative(negativeFile)} negative case shape invalid.');
        continue;
      }
      ids.add(item['id'] as String);
    }
    for (final id in {
      'stale-spec-ref',
      'missing-parity-vectors',
      'missing-artifact-abi-version',
      'p95-regression-over-plus-10-percent',
      'unredacted-diagnostics',
      'missing-rollback-to-local-parser',
      'adapter-owned-behavior-in-shared-artifact',
      'claim-boundary-widened-without-gate',
    }) {
      if (!ids.contains(id)) {
        failures.add('${relative(negativeFile)} missing negative case: $id');
      }
    }
  }
  requireStringListIncludes(
    negativeFile,
    negativeEventMap,
    'forbidden_diagnostic_categories',
    {
      'bearer_tokens',
      'refresh_tokens',
      'database_urls',
      'signed_or_credentialed_urls',
      'private_local_paths',
      'media_keys',
      'room_keys',
      'recovery_keys',
      'pushkeys',
      'vendor_tokens',
      'plaintext_payload_bytes',
      'raw_secrets',
    },
    failures,
  );
  requireStringListIncludes(
    negativeFile,
    negativeEventMap,
    'forbidden_shared_responsibilities',
    {
      'transport',
      'secure_storage',
      'token_persistence',
      'retry_policy',
      'ui_rendering',
      'crypto_stack_selection',
      'production_release_advertisement',
    },
    failures,
  );
  final negativeExpected = negative['expected'];
  if (negativeExpected is! Map ||
      negativeExpected['negative_case_count'] != 8 ||
      negativeExpected['stale_spec_ref_rejected'] != true ||
      negativeExpected['missing_parity_vectors_rejected'] != true ||
      negativeExpected['missing_artifact_abi_version_rejected'] != true ||
      negativeExpected['p95_regression_over_plus_10_rejected'] != true ||
      negativeExpected['unredacted_diagnostics_rejected'] != true ||
      negativeExpected['missing_rollback_rejected'] != true ||
      negativeExpected['adapter_owned_shared_behavior_rejected'] != true ||
      negativeExpected['claim_boundary_widened_without_gate_rejected'] !=
          true) {
    failures.add('${relative(negativeFile)} expected negative result invalid.');
  }
}

void validateSharedCoreSourceVector(
  File file,
  String path,
  Set<String> sourceContracts,
  Map<String, String> profileMap,
  List<String> failures,
) {
  final vectorFile = File(path);
  if (!vectorFile.existsSync()) {
    failures.add('${relative(file)} source vector does not exist: $path');
    return;
  }
  final vector = readJsonObject(vectorFile, failures);
  final contract = vector?['contract'];
  if (vector == null ||
      vector['name'] is! String ||
      contract is! String ||
      !sourceContracts.contains(contract) ||
      profileMap[contract] == null) {
    failures.add(
      '${relative(file)} source vector must match candidate contracts: $path',
    );
  }
}

void validateSharedCoreEvidenceBundleSample(
  File file,
  Map<String, Object?> bundle,
  Map<String, String> contracts,
  Map<String, String> profileMap,
  Set<String> statuses,
  List<String> failures,
) {
  if (bundle['schema_version'] != 'shared-core-adoption-evidence-v1' ||
      bundle['houra_spec_ref'] is! String ||
      bundle['houra_spec_commit'] is! String) {
    failures.add('${relative(file)} sample_bundle core fields invalid.');
  }

  final candidates = bundle['candidate_evidence'];
  if (candidates is! List || candidates.isEmpty) {
    failures.add('${relative(file)} sample_bundle candidates invalid.');
    return;
  }
  final candidateIds = <String>{};
  for (final item in candidates) {
    if (item is! Map) {
      failures.add('${relative(file)} sample_bundle candidate shape invalid.');
      continue;
    }
    final candidate = item.cast<String, Object?>();
    final id = candidate['candidate_id'];
    final status = candidate['status'];
    if (id is! String ||
        candidate['candidate_area'] is! String ||
        status is! String ||
        !statuses.contains(status)) {
      failures.add('${relative(file)} sample candidate identity invalid.');
      continue;
    }
    candidateIds.add(id);
    final sourceContracts = candidate['source_contracts'];
    final sourceVectors = candidate['source_vectors'];
    if (sourceContracts is! List ||
        sourceContracts.any((item) => item is! String) ||
        sourceVectors is! List ||
        sourceVectors.any((item) => item is! String)) {
      failures.add('${relative(file)} sample candidate sources invalid.');
      continue;
    }
    final sourceContractSet = sourceContracts.cast<String>().toSet();
    for (final contract in sourceContractSet) {
      if (!contracts.containsKey(contract) || profileMap[contract] == null) {
        failures.add(
          '${relative(file)} sample candidate references unknown contract: $contract',
        );
      }
    }
    for (final path in sourceVectors.cast<String>()) {
      validateSharedCoreSourceVector(
        file,
        path,
        sourceContractSet,
        profileMap,
        failures,
      );
    }

    final manifest = candidate['artifact_manifest'];
    if (manifest is! Map ||
        manifest['artifact_name'] is! String ||
        manifest['artifact_type'] is! String ||
        manifest['package_refs'] is! List ||
        manifest['abi_version'] is! String ||
        manifest['facade_apis'] is! List ||
        manifest['target_runtimes'] is! List ||
        manifest['binary_size_kib'] is! Map ||
        manifest['startup_ms'] is! Map ||
        manifest['build_rebuild_cost'] is! String ||
        manifest['license_dependency_notes'] is! String ||
        manifest['prebuilt_artifact_policy'] is! String) {
      failures.add('${relative(file)} sample artifact manifest invalid.');
    }

    final parity = candidate['parity_evidence'];
    if (parity is! Map ||
        parity['measurement_state'] is! String ||
        parity['conformance_reports'] is! List ||
        parity['vectors'] is! List ||
        parity['cross_repo_parity'] is! Map) {
      failures.add('${relative(file)} sample parity evidence invalid.');
    } else {
      validateSharedCoreParityVectors(
        file,
        parity['vectors'] as List,
        sourceContractSet,
        profileMap,
        failures,
      );
    }

    final performance = candidate['performance_evidence'];
    if (performance is! Map ||
        performance['representative_batch'] is! String ||
        performance['measurement_state'] is! String ||
        performance['within_plus_10_percent'] is! bool ||
        performance['hidden_by_network_disk_ui_latency'] is! bool ||
        performance['required_before_shared_adopted'] != true) {
      failures.add('${relative(file)} sample performance evidence invalid.');
    }
    if (status == 'shared-adopted' &&
        performance is Map &&
        performance['within_plus_10_percent'] != true &&
        performance['hidden_by_network_disk_ui_latency'] != true) {
      failures.add(
        '${relative(file)} shared-adopted candidates require p95 gate evidence.',
      );
    }

    final security = candidate['security_boundary'];
    if (security is! Map ||
        security['secret_free_diagnostics'] != true ||
        security['redaction_review'] is! String ||
        security['hidden_io'] != false ||
        security['hidden_network'] != false ||
        security['hidden_disk'] != false ||
        security['adapter_owned_responsibilities'] is! List ||
        security['forbidden_shared_responsibilities'] is! List) {
      failures.add('${relative(file)} sample security boundary invalid.');
    }

    final facade = candidate['facade_stability'];
    if (facade is! Map ||
        facade['abi_version'] is! String ||
        facade['typescript_facade_status'] is! String ||
        facade['dart_facade_status'] is! String ||
        facade['stable_for_adoption'] is! bool ||
        facade['breaking_change_policy'] is! String) {
      failures.add('${relative(file)} sample facade stability invalid.');
    }

    final rollback = candidate['rollback'];
    if (rollback is! Map ||
        rollback['rollback_to_local_parser'] != true ||
        rollback['rollback_owner'] is! String ||
        rollback['rollback_conditions'] is! List ||
        rollback['rollback_verification'] is! String) {
      failures.add('${relative(file)} sample rollback invalid.');
    }

    validateSharedCoreClaimBoundary(
      file,
      candidate['claim_boundary'],
      'sample candidate',
      failures,
    );
  }

  for (final id in {
    'matrix-versions-request-response',
    'matrix-houra-error-envelope',
  }) {
    if (!candidateIds.contains(id)) {
      failures.add('${relative(file)} sample_bundle missing candidate: $id');
    }
  }

  validateSharedCoreClaimBoundary(
    file,
    bundle['claim_boundary'],
    'sample_bundle',
    failures,
  );
  final redaction = bundle['redaction'];
  if (redaction is! Map ||
      redaction['secrets_redacted'] != true ||
      redaction['raw_local_paths_redacted'] != true ||
      redaction['diagnostics_redacted'] != true ||
      redaction['artifact_metadata_secret_free'] != true) {
    failures.add('${relative(file)} sample_bundle redaction invalid.');
  }
}

void validateSharedCoreParityVectors(
  File file,
  List vectors,
  Set<String> sourceContracts,
  Map<String, String> profileMap,
  List<String> failures,
) {
  if (vectors.isEmpty) {
    failures.add('${relative(file)} sample parity vectors empty.');
    return;
  }
  const parityStatuses = {'pending', 'pass', 'fail', 'blocked'};
  for (final item in vectors) {
    if (item is! Map) {
      failures.add('${relative(file)} sample parity vector shape invalid.');
      continue;
    }
    final vector = item.cast<String, Object?>();
    final vectorPath = vector['vector_path'];
    final vectorName = vector['vector_name'];
    final contract = vector['contract'];
    final featureProfile = vector['feature_profile'];
    final status = vector['status'];
    if (vectorPath is! String ||
        vectorName is! String ||
        contract is! String ||
        featureProfile is! String ||
        status is! String ||
        !parityStatuses.contains(status) ||
        !sourceContracts.contains(contract)) {
      failures.add('${relative(file)} sample parity vector fields invalid.');
      continue;
    }
    final sourceFile = File(vectorPath);
    final source = readJsonObject(sourceFile, failures);
    if (source == null ||
        source['name'] != vectorName ||
        source['contract'] != contract ||
        profileMap[contract] != featureProfile) {
      failures.add(
        '${relative(file)} sample parity vector must match vector contract/profile.',
      );
    }
  }
}

void validateSharedCoreClaimBoundary(
  File file,
  Object? value,
  String label,
  List<String> failures,
) {
  if (value is! Map ||
      value['product_mvp_release_claim_widened'] != false ||
      value['matrix_versions_advertisement_widened'] != false ||
      value['matrix_domain_support_claimed'] != false ||
      value['shared_core_required_dependency_claimed'] != false ||
      value['release_ready'] != false) {
    failures.add('${relative(file)} $label claim boundary invalid.');
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
      name == '.claude' ||
      name == '.dart_tool' ||
      name == 'build' ||
      name == 'pubspec.lock';
}
