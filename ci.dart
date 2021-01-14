import 'dart:io';

import 'package:github/github.dart';
import 'package:path/path.dart';

import 'make.dart' as make;

const releaseInfo = 'This is an automatic release by the ci.\n\n'
    '###### Changelog\n\n\n'
    '###### Known Problems\n\n';

Future<void> githubRelease(String commit, String dir) async {
  print('Creating release...');
  final github = GitHub(
    auth: Authentication.withToken(
      (await File('/etc/ampci.token').readAsLines()).first,
    ),
  );
  final release = await github.repositories.createRelease(
    RepositorySlug('Ampless', 'Amplessimus'),
    CreateRelease.from(
      tagName: make.version,
      name: make.version,
      targetCommitish: commit,
      isDraft: false,
      isPrerelease: true,
      body: releaseInfo,
    ),
  );
  print('Uploading assets...');
  //TODO: return url to ipa and use it for altstore
  await github.repositories.uploadReleaseAssets(
    release,
    await Directory(dir)
        .list()
        .where((event) => event is File)
        .asyncMap((event) async => CreateReleaseAsset(
            name: basename(event.path),
            contentType: 'application/octet-stream',
            assetData: await (event as File).readAsBytes()))
        .where((event) {
      if (event == null) {
        print('WTF THERE IS A NULL EVENT JUST HOW');
      }
      return event != null;
    }).toList(),
  );
  print('Done uploading.');
}

String sed(String input, String regex, String replace) {
  return input.replaceAll(RegExp(regex), replace);
}

Future updateAltstore() async {
  if (!(await Directory('~/ampless.chrissx.de').exists())) {
    await make.system(
      'git clone https://github.com/Ampless/ampless.chrissx.de ~/ampless.chrissx.de',
    );
  }
  await make.system('cd ~/ampless.chrissx.de/altstore ; git pull');
  var versionDate = await make.system('date -u +%FT%T');
  versionDate += '+00:00';
  final versionDescription = await make.system("date '+%d.%m.%y %H:%M'");
  Directory.current = '~/ampless.chrissx.de/altstore';
  var json = await make.readfile('alpha.json');
  json = sed(
    json,
    '^ *"version": ".*",\$',
    '      "version": "${make.version}",',
  );
  json = sed(
    json,
    '^ *"versionDate": ".*",\$',
    '      "versionDate": "$versionDate",',
  );
  json = sed(
    json,
    '^ *"versionDescription": ".*",\$',
    '      "versionDescription": "$versionDescription",',
  );
  json = sed(
    json,
    '^ *"downloadURL": ".*",\$',
    '      "downloadURL": "https://github.com/Ampless/Amplessimus/releases/download/${make.version}/${make.version}.ipa",',
  );
  await make.writefile('alpha.json', json);
  await make.system('git add alpha.json;');
  await make.system(
    'git commit -m "automatic ci update to amplessimus ios alpha ${make.version}";',
  );
  await make.system('git push');
}

Future main() async {
  await make.system('git pull');

  await Directory('bin').create(recursive: true);

  final commit = await make.system('git rev-parse @');

  await make.init();

  await Directory('/usr/local/var/www/amplessimus').create(recursive: true);
  final outputDir = '/usr/local/var/www/amplessimus/${make.version}';

  final date = await make.system('date');
  print('[AmpCI][$date] Running the Dart build system for ${make.version}.');

  await make.ci();
  await make.cleanup();

  await Directory('bin').rename(outputDir);

  final altstore = updateAltstore();
  await githubRelease(commit, outputDir);
  await altstore;
}
