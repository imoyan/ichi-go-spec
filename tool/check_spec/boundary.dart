part of '../check_spec.dart';

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
    'SECURITY.md',
    'SOURCE_OF_TRUTH.md',
    'contracts',
    'design',
    'docs',
    'test-vectors',
    'tool',
  };
  const allowedToolFiles = {'check_spec.dart'};
  const allowedToolDirectories = {'check_spec', 'fixtures'};

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
