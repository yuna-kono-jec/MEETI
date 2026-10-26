#!/usr/bin/env python3
"""実アプリの全Swiftソースと固定済みSDKをiOS 16向けにコンパイル・リンクします。

Xcodeアプリの署名・Assets処理・インストールを代替するものではありません。
保存済み参加者データにはアクセスせず、指定フォルダに検証用Packageを作ります。
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--build-root', type=Path, required=True)
parser.add_argument('--device', action='store_true', help='実機arm64向け。省略時はarm64シミュレーター')
parser.add_argument('--configuration', choices=['debug', 'release'], default='debug')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
build = args.build_root.resolve()
build.mkdir(parents=True, exist_ok=True)
# 登録漏れを隠さないよう、実際のXcodeターゲットとファイル一覧の一致を先に確認します。
subprocess.run(['python3', str(root / 'Tools/check_app_sources.py')], check=True)
project = subprocess.check_output(['plutil', '-convert', 'json', '-o', '-',
                                   str(root / 'MEETI.xcodeproj/project.pbxproj')], text=True)
objects = json.loads(project)['objects']
configs = [obj['buildSettings'] for obj in objects.values() if obj.get('isa') == 'XCBuildConfiguration']
assert all(c.get('IPHONEOS_DEPLOYMENT_TARGET') == '16.0' for c in configs)
app_configs = [c for c in configs if 'PRODUCT_BUNDLE_IDENTIFIER' in c]
assert all('-weak_framework' in c['OTHER_LDFLAGS'] and 'SwiftData' in c['OTHER_LDFLAGS'] for c in app_configs)

# 本体のソースはコピーせず参照し、検証とアプリのコードが一致するようにします。
package = build / 'validation-package'
(package / 'Sources').mkdir(parents=True, exist_ok=True)
link = package / 'Sources/MEETI'
if not link.exists():
    link.symlink_to(root / 'MEETI', target_is_directory=True)
assert link.resolve() == root / 'MEETI'
resolved = root / 'MEETI.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved'
shutil.copyfile(resolved, package / 'Package.resolved')
(package / 'Package.swift').write_text('''// swift-tools-version: 6.2
import PackageDescription
// 保存先を開かず、Xcodeと同じOS・言語設定で全ソースを検証する専用Packageです。
let package = Package(name: "MEETIiOS16Validation", platforms: [.iOS(.v16)],
    dependencies: [.package(url: "https://github.com/supabase/supabase-swift", exact: "2.55.4")],
    targets: [.executableTarget(name: "MEETI",
        dependencies: [.product(name: "Supabase", package: "supabase-swift")],
        path: "Sources/MEETI", exclude: ["Assets.xcassets", "WebCard"],
        swiftSettings: [.defaultIsolation(MainActor.self), .swiftLanguageMode(.v5),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableUpcomingFeature("InferSendableFromCaptures"),
            .enableUpcomingFeature("DisableOutwardActorInference"),
            .enableUpcomingFeature("GlobalActorIsolatedTypesUsability")],
        linkerSettings: [.unsafeFlags(["-Xlinker", "-weak_framework", "-Xlinker", "SwiftData"])])])
''')
sdk_name = 'iphoneos' if args.device else 'iphonesimulator'
triple = 'arm64-apple-ios16.0' + ('' if args.device else '-simulator')
sdk = subprocess.check_output(['xcrun', '--sdk', sdk_name, '--show-sdk-path'], text=True).strip()
env = dict(os.environ, CLANG_MODULE_CACHE_PATH=str(build / 'clang-cache'),
           SWIFTPM_MODULECACHE_OVERRIDE=str(build / 'swift-cache'))
subprocess.run(['xcrun', 'swift', 'build', '--disable-sandbox', '--package-path', str(package),
                '--scratch-path', str(build / sdk_name), '--cache-path', str(build / 'package-cache'),
                '--sdk', sdk, '--triple', triple, '--configuration', args.configuration], env=env, check=True)
# iOS 16では存在しないSwiftDataが必須リンクになっていないことも、実行ファイルで確認します。
bin_triple = 'arm64-apple-ios' + ('' if args.device else '-simulator')
binary = build / sdk_name / bin_triple / args.configuration / 'MEETI'
commands = subprocess.check_output(['xcrun', 'otool', '-l', str(binary)], text=True)
swiftdata = commands.split('/System/Library/Frameworks/SwiftData.framework/SwiftData')[0].split('Load command')[-1]
assert 'LC_LOAD_WEAK_DYLIB' in swiftdata, 'SwiftDataが必須リンクになっています'
assert 'minos 16.0' in commands
print(f'PASS: iOS 16コンパイル・リンク・SwiftData任意リンク ({sdk_name}, {args.configuration})')
