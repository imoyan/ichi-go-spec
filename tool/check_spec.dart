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

const fullClientProfiles = {
  'core',
  'auth',
  'rooms',
  'events',
  'messaging',
  'sync',
  'media',
};

const negativeVectorProfiles = {
  'auth',
  'rooms',
  'events',
  'messaging',
  'sync',
  'media',
};

const vectorDirectoryProfiles = {
  'auth': 'auth',
  'core': 'core',
  'events': 'events',
  'media': 'media',
  'messaging': 'messaging',
  'rooms': 'rooms',
  'sync': 'sync',
};

final hexColor = RegExp(r'^#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
const themeTopLevelKeys = {r'$schema', 'name', 'version', 'defs', 'theme'};
const themePairKeys = {'light', 'dark'};

void main() {
  final failures = <String>[];
  checkBoundary(failures);
  checkNamespaceConsistency(failures);
  final contracts = readContracts(failures);

  checkDocs(contracts, failures);
  final profileMap = checkProfileMap(contracts, failures);
  checkVectors(contracts, profileMap, failures);
  checkMvpReadiness(contracts, profileMap, failures);
  checkThemes(failures);

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
    'Implementation Adoption Reports',
  ]) {
    if (!readme.contains(phrase)) {
      failures.add('README.md must document $phrase.');
    }
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
    if (parts.length < 4) {
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
  return json['response'] is Map &&
      expected is Map &&
      expected.containsKey('error');
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
    checkRequest(file, given['previous_request'], failures);
  }
  final previousEventId = given['previous_event_id'];
  if (previousEventId != null &&
      (previousEventId is! String || previousEventId.isEmpty)) {
    failures.add('${relative(file)} given.previous_event_id must be a string.');
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
  final directoryProfile = vectorDirectoryProfiles[directory];
  if (directoryProfile == null) {
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
  if (directoryProfile != contractProfile) {
    failures.add(
      '$path profile directory mismatch for $contract: '
      '$directoryProfile != $contractProfile',
    );
  }
}

void checkRequest(File file, Object? value, List<String> failures) {
  if (value is! Map) {
    failures.add('${relative(file)} request must be an object.');
    return;
  }
  final request = value.cast<String, Object?>();
  final method = request['method'];
  if (method is! String || method.isEmpty || method != method.toUpperCase()) {
    failures.add('${relative(file)} request.method must be uppercase.');
  }
  final path = request['path'];
  if (path is! String || !path.startsWith('/_houra/client')) {
    failures.add('${relative(file)} request.path must use /_houra/client.');
  }
  final query = request['query'];
  if (query is Map && query.containsKey('access_token')) {
    failures.add('${relative(file)} must not put access tokens in query.');
  }
}

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
