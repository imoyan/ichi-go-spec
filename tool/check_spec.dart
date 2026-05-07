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
  final contracts = readContracts(failures);

  checkDocs(contracts, failures);
  final profileMap = checkProfileMap(contracts, failures);
  checkVectors(contracts, profileMap, failures);
  checkThemes(failures);

  if (failures.isNotEmpty) {
    stderr.writeln('Spec check failed:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
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
      checkVectorProfile(file, contract, profileMap, failures);
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
  if (path is! String || !path.startsWith('/_chawan/client')) {
    failures.add('${relative(file)} request.path must use /_chawan/client.');
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
