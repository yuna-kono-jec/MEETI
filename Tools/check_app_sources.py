# coding: utf-8
"""Xcodeの実際のアプリターゲットにSwiftファイルの登録漏れがないか検証します。"""
import argparse
import json
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--write-file-list', type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
project = root / 'MEETI.xcodeproj/project.pbxproj'
# macOS標準のplutilでOpenStep形式を解析し、コメントや表示名だけの一致で判定しません。
parsed = subprocess.run(['plutil', '-convert', 'json', '-o', '-', str(project)],
                        check=True, capture_output=True, text=True)
objects = json.loads(parsed.stdout)['objects']
targets = [obj for obj in objects.values()
           if obj.get('isa') == 'PBXNativeTarget' and obj.get('name') == 'MEETI']
assert len(targets) == 1, 'MEETIアプリターゲットを一意に特定できません'
phases = [objects[key] for key in targets[0]['buildPhases']
          if objects[key]['isa'] == 'PBXSourcesBuildPhase']
assert len(phases) == 1, 'Compile Sourcesを一意に特定できません'
# MEETIグループ内の参照とSourcesの参照が同じファイルに到達することも確認します。
groups = [obj for obj in objects.values()
          if obj.get('isa') == 'PBXGroup' and obj.get('path') == 'MEETI']
assert len(groups) == 1
source_refs = [objects[key]['fileRef'] for key in phases[0]['files']]
assert len(source_refs) == len(set(source_refs)), 'Compile Sourcesに二重登録があります'
assert all(ref in groups[0]['children'] for ref in source_refs), 'MEETIグループ外のソース参照があります'
files = [root / 'MEETI' / objects[ref]['path'] for ref in source_refs]
assert all(path.is_file() for path in files), '参照先ファイルが存在しません'
expected = set((root / 'MEETI').glob('*.swift'))
assert set(files) == expected, ('Sources登録漏れまたは余分なファイル',
                               sorted(str(p) for p in expected - set(files)))
assert sum(path.name == 'PhotoThumbnail.swift' for path in files) == 1
# この一覧をswiftcに渡せば、全ファイルのglobによるチェックと違い登録漏れを隠しません。
if args.write_file_list:
    args.write_file_list.write_text(''.join(str(path) + '\n' for path in files))
print(f'PASS: MEETI Compile Sourcesの{len(files)}ファイルを確認（PhotoThumbnail.swiftを含む）')
