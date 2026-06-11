import os
import re

def update_file(filepath):
    if not os.path.exists(filepath):
        return
    with open(filepath, 'r') as f:
        content = f.read()

    # Imports
    content = content.replace("import 'package:audioplayers/audioplayers.dart';", "import 'package:just_audio/just_audio.dart';")
    
    # Listeners
    content = re.sub(r'(\w+)\.onPlayerComplete\.listen\(\(_\)\s*=>\s*([\w_]+)\(\)\);', 
                     r'\1.playerStateStream.listen((state) {\n      if (state.processingState == ProcessingState.completed) {\n        \2();\n      }\n    });', content)

    content = re.sub(r'(\w+)\.onPlayerComplete\.listen\(\(event\)\s*\{([\s\S]*?)\}\);',
                     r'\1.playerStateStream.listen((state) {\n      if (state.processingState == ProcessingState.completed) {\2}\n    });', content)

    content = re.sub(r'(\w+)\.onPlayerStateChanged\.listen\(\(state\)\s*\{',
                     r'\1.playerStateStream.listen((event) {\n      final state = event.processingState == ProcessingState.ready ? PlayerState.played : PlayerState.stopped; // DUMMY', content)

    # _activePlayer.play(UrlSource(finalUrl))
    content = re.sub(r'await\s+([\w_]+)\.play\(\s*UrlSource\(([^)]+)\)\s*\);',
                     r'await \1.setUrl(\2);\n        await \1.play();', content)

    # play(UrlSource(url))
    content = re.sub(r'await\s+([\w_]+)\.play\(\s*UrlSource\(([^)]+)\)\s*\);',
                     r'await \1.setUrl(\2);\n      await \1.play();', content)

    # play(AssetSource(path))
    content = re.sub(r'await\s+([\w_]+)\.play\(\s*AssetSource\(([^)]+)\)\s*\);',
                     r'await \1.setAsset(\2);\n      await \1.play();', content)
    
    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Updated {filepath}")

# Update just memorization_screen for now
update_file('lib/feature/quran/view/memorization_screen.dart')
# Update listen_mode_screen
update_file('lib/feature/quran/view/listen_mode_screen.dart')
# Update surah_reading_screen
update_file('lib/feature/quran/view/surah_reading_screen.dart')

