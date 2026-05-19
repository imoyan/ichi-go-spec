part of '../check_spec.dart';

void checkDocs(Map<String, String> contracts, List<String> failures) {
  final docs = [
    'README.md',
    'SOURCE_OF_TRUTH.md',
    'REFERENCE_POLICY.md',
    'FEATURE_PROFILES.md',
    'MODULE_DEPENDENCIES.md',
    'CONTRACT_MODULE_MAP.md',
    'AGENTS.md',
    'docs/adoption-status.md',
    'docs/shared-implementation-strategy.md',
    'docs/matrix-compliance.md',
    'docs/releases/TEMPLATE.md',
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
      if (!contracts.containsKey(id) && !reservedContractIds.contains(id)) {
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
  final supportingDocsCorpus = [
    readme,
    for (final path in [
      'docs/shared-implementation-strategy.md',
      'docs/matrix-compliance.md',
      'docs/adoption-status.md',
      'docs/releases/TEMPLATE.md',
      'CHANGELOG.md',
    ])
      if (File(path).existsSync()) File(path).readAsStringSync(),
  ].join('\n');
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
    'reader-facing numbering system',
    'official Matrix identifiers',
    'MSC',
    'endpoint path or section anchor',
    'room version',
    'Adoption Status Board',
    'cross-repository adoption index',
    'not conformance proof',
    'Release Record Template',
    'docs/releases/<tag>.md',
    'Product MVP claim boundary',
    'Matrix compatibility claim boundary',
  ]) {
    if (!supportingDocsCorpus.contains(phrase)) {
      failures.add('Supporting docs must document $phrase.');
    }
  }
  if (!supportingDocsCorpus.contains('UI Surface Contract')) {
    failures.add('README.md must document UI Surface Contract.');
  }
  if (!readme.contains('docs/shared-implementation-strategy.md')) {
    failures.add('README.md must link docs/shared-implementation-strategy.md.');
  }
  if (!readme.contains('docs/matrix-compliance.md')) {
    failures.add('README.md must link docs/matrix-compliance.md.');
  }
  if (!readme.contains('docs/adoption-status.md')) {
    failures.add('README.md must link docs/adoption-status.md.');
  }
  if (!readme.contains('docs/releases/TEMPLATE.md')) {
    failures.add('README.md must link docs/releases/TEMPLATE.md.');
  }
  checkReservedContractNumbers(contracts, failures);
  checkAdoptionStatusBoard(contracts, failures);
  checkReleaseRecordTemplate(failures);
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
      'Compatibility classification',
      'breaking|additive|corrective',
      'Claim impact',
      'Product MVP|Matrix|both|neither',
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
  if (!sourceOfTruth.contains('Matrix References Are Primary')) {
    failures.add('SOURCE_OF_TRUTH.md must document Matrix reference priority.');
  }
  if (!sourceOfTruth.contains('docs/releases/TEMPLATE.md')) {
    failures.add('SOURCE_OF_TRUTH.md must document release records.');
  }

  final referencePolicy = File('REFERENCE_POLICY.md').readAsStringSync();
  if (!referencePolicy.contains('Codex-facing repository instructions')) {
    failures.add('REFERENCE_POLICY.md must point to AGENTS.md.');
  }
}

void checkTestVectorDomainIndex(
  Map<String, String> contracts,
  Map<String, String> profileMap,
  List<String> failures,
) {
  final file = File('test-vectors/DOMAIN_INDEX.md');
  if (!file.existsSync()) {
    failures.add('Missing test vector domain index: ${relative(file)}');
    return;
  }

  final source = file.readAsStringSync();
  for (final phrase in [
    '# Test Vector Domain Index',
    'existing `test-vectors/<feature-profile>/` paths stable',
    'inventory, not a path migration',
    'Primary reference',
    'Repository anchor',
    'Physical vector relocation is deferred',
    '| Matrix domain | Vector count | Contract count |',
    '| Primary reference | Repository anchor | Feature profile | Vector path | Vector name |',
  ]) {
    if (!source.contains(phrase)) {
      failures.add('${relative(file)} must include: $phrase');
    }
  }

  final expectedByPath = <String, _VectorDomainIndexEntry>{};
  final expectedVectorCounts = <String, int>{};
  final expectedContractsByDomain = <String, Set<String>>{};
  final vectors = filesUnder(Directory('test-vectors'), '.json').toList()
    ..sort((a, b) => relative(a).compareTo(relative(b)));

  for (final vectorFile in vectors) {
    final json = readJsonObject(vectorFile, failures);
    if (json == null) {
      continue;
    }
    final path = relative(vectorFile);
    final name = json['name'];
    final contract = json['contract'];
    if (name is! String || contract is! String) {
      continue;
    }
    final domain = contractMatrixDomainById[contract];
    final primaryReference = contractPrimaryReferenceById[contract];
    final repositoryAnchor = contractRepositoryAnchorById[contract];
    final profile = profileMap[contract];
    if (!contracts.containsKey(contract) ||
        domain == null ||
        primaryReference == null ||
        repositoryAnchor == null ||
        profile == null) {
      failures.add(
        '$path cannot be indexed because $contract metadata is incomplete.',
      );
      continue;
    }
    expectedByPath[path] = _VectorDomainIndexEntry(
      domain: domain,
      primaryReference: primaryReference,
      repositoryAnchor: repositoryAnchor,
      profile: profile,
      name: name,
    );
    expectedVectorCounts.update(
      domain,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    expectedContractsByDomain
        .putIfAbsent(domain, () => <String>{})
        .add(contract);
  }

  final summaryVectorCounts = <String, int>{};
  final summaryContractCounts = <String, int>{};
  final inventoryDomains = <String>{};
  final seenPaths = <String>{};
  String? currentDomain;

  for (final line in source.split('\n')) {
    if (line.startsWith('### ')) {
      currentDomain = line.substring(4).trim();
      inventoryDomains.add(currentDomain);
      continue;
    }

    final cells = _tableCells(line);
    if (cells.isEmpty || _isMarkdownDelimiterRow(cells)) {
      continue;
    }
    if (cells.length == 3 && cells[0] != 'Matrix domain') {
      final vectorCount = int.tryParse(cells[1]);
      final contractCount = int.tryParse(cells[2]);
      if (vectorCount == null || contractCount == null) {
        failures.add(
          '${relative(file)} summary row has non-numeric counts: $line',
        );
        continue;
      }
      summaryVectorCounts[cells[0]] = vectorCount;
      summaryContractCounts[cells[0]] = contractCount;
      continue;
    }
    if (cells.length != 5 || cells[0] == 'Primary reference') {
      continue;
    }

    if (currentDomain == null) {
      failures.add(
        '${relative(file)} inventory row appears before a domain heading.',
      );
      continue;
    }

    final path = _stripCodeSpan(cells[3]);
    final name = _stripCodeSpan(cells[4]);
    if (!seenPaths.add(path)) {
      failures.add('${relative(file)} lists $path more than once.');
      continue;
    }
    final expected = expectedByPath[path];
    if (expected == null) {
      failures.add('${relative(file)} lists unknown vector path: $path');
      continue;
    }
    if (currentDomain != expected.domain ||
        cells[0] != expected.primaryReference ||
        cells[1] != expected.repositoryAnchor ||
        cells[2] != expected.profile ||
        name != expected.name) {
      failures.add(
        '${relative(file)} row for $path must match contract metadata and vector name.',
      );
    }
  }

  for (final domain in matrixDomains) {
    if (!summaryVectorCounts.containsKey(domain)) {
      failures.add(
        '${relative(file)} summary must list Matrix domain: $domain',
      );
    }
    if (!inventoryDomains.contains(domain)) {
      failures.add('${relative(file)} inventory must include section: $domain');
    }
    final expectedVectorCount = expectedVectorCounts[domain] ?? 0;
    final expectedContractCount =
        expectedContractsByDomain[domain]?.length ?? 0;
    if (summaryVectorCounts[domain] != expectedVectorCount) {
      failures.add(
        '${relative(file)} summary vector count for $domain must be $expectedVectorCount.',
      );
    }
    if (summaryContractCounts[domain] != expectedContractCount) {
      failures.add(
        '${relative(file)} summary contract count for $domain must be $expectedContractCount.',
      );
    }
  }

  for (final path in expectedByPath.keys) {
    if (!seenPaths.contains(path)) {
      failures.add('${relative(file)} missing vector row: $path');
    }
  }
}

List<String> _tableCells(String line) {
  final trimmed = line.trim();
  if (!trimmed.startsWith('|') || !trimmed.endsWith('|')) {
    return const [];
  }
  return trimmed
      .substring(1, trimmed.length - 1)
      .split('|')
      .map((cell) => cell.trim())
      .toList();
}

bool _isMarkdownDelimiterRow(List<String> cells) {
  return cells.isNotEmpty &&
      cells.every((cell) => RegExp(r'^:?-+:?$').hasMatch(cell));
}

String _stripCodeSpan(String value) {
  if (value.length >= 2 && value.startsWith('`') && value.endsWith('`')) {
    return value.substring(1, value.length - 1);
  }
  return value;
}

class _VectorDomainIndexEntry {
  const _VectorDomainIndexEntry({
    required this.domain,
    required this.primaryReference,
    required this.repositoryAnchor,
    required this.profile,
    required this.name,
  });

  final String domain;
  final String primaryReference;
  final String repositoryAnchor;
  final String profile;
  final String name;
}

void checkReservedContractNumbers(
  Map<String, String> contracts,
  List<String> failures,
) {
  for (final id in reservedContractIds) {
    if (contracts.containsKey(id)) {
      failures.add('$id is listed as reserved but has a contract file.');
    }
  }
  final registry = File('CONTRACT_MODULE_MAP.md').readAsStringSync();
  if (!registry.contains('## Reserved Contract Numbers')) {
    failures.add('CONTRACT_MODULE_MAP.md must list reserved contract numbers.');
    return;
  }
  for (final phrase in [
    'Primary reference',
    'repository links',
    'MSC number',
    'endpoint path or section anchor',
    'room version',
  ]) {
    if (!registry.contains(phrase)) {
      failures.add('CONTRACT_MODULE_MAP.md must document $phrase.');
    }
  }
  for (final id in reservedContractIds) {
    if (!reservedContractIdDocumented(id, registry)) {
      failures.add('CONTRACT_MODULE_MAP.md must document reserved $id.');
    }
  }
}

bool reservedContractIdDocumented(String id, String registry) {
  if (registry.contains(id)) {
    return true;
  }
  final number = int.parse(id.substring('SPEC-'.length));
  if (number >= 12 &&
      number <= 19 &&
      registry.contains('`SPEC-012` through `SPEC-019`')) {
    return true;
  }
  if (number >= 21 &&
      number <= 29 &&
      registry.contains('`SPEC-021` through `SPEC-029`')) {
    return true;
  }
  if (number >= 87 &&
      number <= 89 &&
      registry.contains('`SPEC-087` through `SPEC-089`')) {
    return true;
  }
  return false;
}

void checkAdoptionStatusBoard(
  Map<String, String> contracts,
  List<String> failures,
) {
  final boardFile = File('docs/adoption-status.md');
  if (!boardFile.existsSync()) {
    failures.add('Missing adoption status board: docs/adoption-status.md.');
    return;
  }
  final board = boardFile.readAsStringSync();
  for (final phrase in [
    '# Adoption Status Board',
    'CONTRACT_MODULE_MAP.md',
    'CHANGELOG.md',
    'not conformance proof',
    'Runtime support remains fail-closed',
    'Primary reference',
    'Repository anchor',
    '| Primary reference | Repository anchor | Contract type | Matrix domain | Server refs | Client refs | Labs refs | Adoption state | Claim impact |',
  ]) {
    if (!board.contains(phrase)) {
      failures.add('docs/adoption-status.md must document $phrase.');
    }
  }

  final expectedRefsById = <String, Set<String>>{};
  final registry = File('CONTRACT_MODULE_MAP.md');
  if (registry.existsSync()) {
    for (final line in registry.readAsLinesSync()) {
      if (!line.startsWith('| ') || line.startsWith('|---')) {
        continue;
      }
      final parts = line.split('|').map((part) => part.trim()).toList();
      if (parts.length < 8 || parts[1] == 'Primary reference') {
        continue;
      }
      final id = RegExp(r'\bSPEC-\d{3}\b').firstMatch(parts[2])?.group(0);
      if (id == null) {
        continue;
      }
      expectedRefsById[id] = {
        for (final match in RegExp(
          r'(?:imoyan/)?(houra-(?:server|client|labs)#\d+)',
        ).allMatches(line))
          match.group(1)!,
      };
    }
  }
  final changelogRefs = <String>{};
  final changelog = File('CHANGELOG.md');
  if (changelog.existsSync()) {
    changelogRefs.addAll(
      RegExp(r'(?:imoyan/)?(houra-(?:server|client|labs)#\d+)')
          .allMatches(changelog.readAsStringSync())
          .map((match) => match.group(1)!),
    );
  }

  final seen = <String>{};
  for (final line in board.split('\n')) {
    if (!line.startsWith('| ') ||
        line.startsWith('|---') ||
        line.startsWith('| Primary reference |')) {
      continue;
    }
    final parts = line.split('|').map((part) => part.trim()).toList();
    if (parts.length < 11) {
      failures.add('Malformed adoption status row: $line');
      continue;
    }
    final primaryReference = parts[1];
    final repositoryAnchor = parts[2];
    final id = RegExp(r'\bSPEC-\d{3}\b').firstMatch(repositoryAnchor)?.group(0);
    if (id == null || !contracts.containsKey(id)) {
      failures.add(
        'Adoption status references missing contract: $repositoryAnchor',
      );
      continue;
    }
    if (!seen.add(id)) {
      failures.add('docs/adoption-status.md lists $id more than once.');
    }
    final expectedPrimaryReference = contractPrimaryReferenceById[id];
    if (expectedPrimaryReference != null &&
        primaryReference != expectedPrimaryReference) {
      failures.add(
        'Adoption status primary reference mismatch for $id: '
        '$primaryReference != $expectedPrimaryReference',
      );
    }
    final expectedRepositoryAnchor = contractRepositoryAnchorById[id];
    if (expectedRepositoryAnchor != null &&
        repositoryAnchor != expectedRepositoryAnchor) {
      failures.add(
        'Adoption status repository anchor mismatch for $id: '
        '$repositoryAnchor != $expectedRepositoryAnchor',
      );
    }

    final contractType = contractTypeById[id];
    if (contractType != null && parts[3] != contractType) {
      failures.add(
        'Adoption status type mismatch for $id: ${parts[3]} != $contractType',
      );
    }

    final matrixDomain = contractMatrixDomainById[id];
    if (matrixDomain != null && parts[4] != matrixDomain) {
      failures.add(
        'Adoption status Matrix domain mismatch for $id: '
        '${parts[4]} != $matrixDomain',
      );
    }

    for (final entry in [
      ('houra-server', parts[5]),
      ('houra-client', parts[6]),
      ('houra-labs', parts[7]),
    ]) {
      final repo = entry.$1;
      final cell = entry.$2;
      if (cell == '-') {
        continue;
      }
      for (final token in cell.split('<br>')) {
        final ref = token.replaceAll('`', '').trim();
        if (!RegExp('^$repo#\\d+\$').hasMatch(ref)) {
          failures.add('Adoption status invalid $repo ref for $id: $token');
          continue;
        }
        final expectedRefs = expectedRefsById[id];
        if (expectedRefs != null &&
            !expectedRefs.contains(ref) &&
            !changelogRefs.contains(ref)) {
          failures.add(
            'Adoption status ref for $id is not in CONTRACT_MODULE_MAP.md or CHANGELOG.md: $ref',
          );
        }
      }
    }

    if (!adoptionStates.contains(parts[8])) {
      failures.add('Adoption status state is unknown for $id: ${parts[8]}');
    }
    if (!claimImpacts.contains(parts[9])) {
      failures.add(
        'Adoption status claim impact is unknown for $id: ${parts[9]}',
      );
    }
  }

  for (final id in contracts.keys) {
    if (!seen.contains(id)) {
      failures.add('docs/adoption-status.md does not list $id.');
    }
  }
}

void checkReleaseRecordTemplate(List<String> failures) {
  final template = File('docs/releases/TEMPLATE.md');
  if (!template.existsSync()) {
    failures.add('Missing release record template: docs/releases/TEMPLATE.md.');
    return;
  }

  final source = template.readAsStringSync();
  for (final phrase in [
    '# Release Record Template',
    'docs/releases/<tag>.md',
    'Release Identity',
    'Compatibility and Claim Boundary',
    'Compatibility classification: `breaking|additive|corrective`',
    'Claim impact: `Product MVP|Matrix|both|neither`',
    'Product MVP claim boundary',
    'Matrix compatibility claim boundary',
    'Changed Inputs',
    'Implementation Adoption Evidence',
    'Implementation repositories are evidence consumers only',
    'Verification',
    '`dart tool/check_spec.dart`',
    '`git diff --check`',
    'Known Exclusions and Blockers',
    'Japanese Reader Surface',
    'Publication Notes',
  ]) {
    if (!source.contains(phrase)) {
      failures.add('docs/releases/TEMPLATE.md must document $phrase.');
    }
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
    'Product MVP release candidate',
    'Matrix v1.18 release candidate',
    'support claim',
    'Matrix 参照を先に読む',
    '読者向けの番号体系として使いません',
    '公式 Matrix 仕様側の識別子',
    'endpoint path または section anchor',
    'adoption-guide.md',
    'release-readiness.md',
    'matrix-v1-18.md',
  ]) {
    if (!source.contains(phrase)) {
      failures.add('docs/ja/README.md must document $phrase.');
    }
  }
  final readiness = File('docs/ja/release-readiness.md');
  final readinessSource = readiness.readAsStringSync();
  for (final phrase in [
    '確認対象の日本語 reader surface',
    'README.md',
    'docs/ja/adoption-guide.md',
    'Product MVP release candidate',
    'Matrix v1.18 release candidate',
    'blocker / non-blocker',
    'known untracked drift',
    'docs/releases/TEMPLATE.md',
    'docs/releases/<tag>.md',
    'Product MVP と Matrix compatibility の claim boundary',
  ]) {
    if (!readinessSource.contains(phrase)) {
      failures.add('docs/ja/release-readiness.md must document $phrase.');
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
    '#241',
    '#135',
    '#142',
    'release-scope decision',
    'fail-closed',
    'SPEC-073',
    'houra-server#135',
    'SPEC-074',
    'houra-server#136',
    'SPEC-075',
    'houra-server#137',
    'SPEC-076',
    'houra-server#138',
    'SPEC-077',
    'houra-server#139',
    'SPEC-078',
    'houra-server#140',
    'SPEC-079',
    'houra-server#141',
    'release-ready',
  ]) {
    if (!matrixSource.contains(phrase)) {
      failures.add('docs/ja/matrix-v1-18.md must document $phrase.');
    }
  }
}
