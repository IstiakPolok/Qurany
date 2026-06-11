import os
import glob
import re

def update_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    # Imports
    content = content.replace("import 'package:audioplayers/audioplayers.dart';", "import 'package:just_audio/just_audio.dart';")
    
    # Listeners
    # onPlayerComplete.listen((_) => foo());
    content = re.sub(r'(\w+)\.onPlayerComplete\.listen\(\(_\)\s*=>\s*([\w_]+)\(\)\);', 
                     r'\1.playerStateStream.listen((state) {\n      if (state.processingState == ProcessingState.completed) {\n        \2();\n      }\n    });', content)

    # onPlayerComplete.listen((event) { ... });
    content = re.sub(r'(\w+)\.onPlayerComplete\.listen\(\(event\)\s*\{([\s\S]*?)\}\);',
                     r'\1.playerStateStream.listen((state) {\n      if (state.processingState == ProcessingState.completed) {\2}\n    });', content)

    # onPlayerStateChanged
    content = content.replace(".onPlayerStateChanged.listen((state)", ".playerStateStream.listen((state)")
    # Replace PlayerState enum usage if doing anything generic, but we might just need to fix `state == PlayerState.playing` to `state.playing`
    content = content.replace("state == PlayerState.playing", "state.playing")

    # _activePlayer.play(UrlSource(finalUrl)) -> setUrl then play
    content = re.sub(r'await\s+([\w\._]+)\.play\(\s*UrlSource\(([^)]+)\)\s*\);',
                     r'await \1.setUrl(\2);\n          await \1.play();', content)

    # _activePlayer.play(AssetSource(path)) -> setAsset then play
    content = re.sub(r'await\s+([\w\._]+)\.play\(\s*AssetSource\(([^)]+)\)\s*\);',
                     r'await \1.setAsset(\2);\n          await \1.play();', content)

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for filepath in glob.glob('lib/**/*.dart', recursive=True):
    update_file(filepath)

