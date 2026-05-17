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

List<String> tableCells(String line) {
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

bool isMarkdownDelimiterRow(List<String> cells) {
  return cells.isNotEmpty &&
      cells.every((cell) => RegExp(r'^:?-+:?$').hasMatch(cell));
}

String stripCodeSpan(String value) {
  if (value.length >= 2 && value.startsWith('`') && value.endsWith('`')) {
    return value.substring(1, value.length - 1);
  }
  return value;
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
