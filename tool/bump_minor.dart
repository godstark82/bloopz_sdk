import 'dart:io';

final _versionRe = RegExp(r'^version:\s*([0-9]+)\.([0-9]+)\.([0-9]+)(?:\+([0-9A-Za-z\.-]+))?\s*$');

void main(List<String> args) {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('pubspec.yaml not found (run from package root).');
    exitCode = 2;
    return;
  }

  final lines = pubspec.readAsLinesSync();
  final idx = lines.indexWhere((l) => l.trimLeft().startsWith('version:'));
  if (idx < 0) {
    stderr.writeln('No "version:" line found in pubspec.yaml.');
    exitCode = 3;
    return;
  }

  final match = _versionRe.firstMatch(lines[idx].trim());
  if (match == null) {
    stderr.writeln('Unsupported version format: "${lines[idx].trim()}".');
    stderr.writeln('Expected: version: MAJOR.MINOR.PATCH or version: MAJOR.MINOR.PATCH+BUILD');
    exitCode = 4;
    return;
  }

  final major = int.parse(match.group(1)!);
  final minor = int.parse(match.group(2)!);
  final build = match.group(4);

  final nextMinor = minor + 1;
  final next = build == null || build.isEmpty
      ? '$major.$nextMinor.0'
      : '$major.$nextMinor.0+$build';

  final nextLine = lines[idx].replaceFirst(_versionRe, 'version: $next');
  if (nextLine == lines[idx]) {
    // Shouldn't happen, but keep it safe.
    stderr.writeln('Failed to update version line.');
    exitCode = 5;
    return;
  }

  lines[idx] = nextLine;
  pubspec.writeAsStringSync('${lines.join('\n')}\n');
  stdout.writeln('Bumped version to $next');
}

