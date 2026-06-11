import re

def fix(fpath):
    with open(fpath, 'r') as f:
        c = f.read()
    orig = c

    # electronic_tasbih_screen.dart
    if "electronic_tasbih_screen.dart" in fpath:
        c = c.replace("PlayerState _playerState = PlayerState.stopped;", "bool _isAudioPlaying = false;")
        c = c.replace("PlayerState _playerState = PlayerState.stopped", "bool _isAudioPlaying = false")
        c = re.sub(r'_audioPlayer\.playerStateStream\.listen\(\(state\)\s*\{[^}]+_playerState = state;[^}]+if \(state == PlayerState\.completed \|\| state == PlayerState\.stopped\) \{[^}]+\}[^}]+?\}\)',
            '_audioPlayer.playerStateStream.listen((state) { _isAudioPlaying = state.playing; if (state.processingState == ProcessingState.completed) { if (mounted) { setState(() {}); } } })', c)
        c = re.sub(r'if \(_playerState == PlayerState\.playing &&', 'if (_isAudioPlaying &&', c)
        c = re.sub(r'_playerState == PlayerState\.playing &&', '_isAudioPlaying &&', c)
        c = re.sub(r'if \(_playerState == PlayerState\.playing\)', 'if (_isAudioPlaying)', c)
        c = re.sub(r'state == PlayerState\.completed', 'state.processingState == ProcessingState.completed', c)

    if c != orig:
        with open(fpath, 'w') as f:
            f.write(c)

fix('lib/feature/prayer/view/electronic_tasbih_screen.dart')

def fix_listen(fpath):
    with open(fpath, 'r') as f:
        c = f.read()
    orig = c
    c = re.sub(r'player\.playerStateStream\.listen\(\(event\)\s*\{[^}]+final state = [^\}]+ // DUMMY', 'player.playerStateStream.listen((state) {', c)
    c = c.replace("if (state == PlayerState.completed) {", "if (state.processingState == ProcessingState.completed) {")
    if c != orig:
        with open(fpath, 'w') as f:
            f.write(c)

fix_listen('lib/feature/quran/view/listen_mode_screen.dart')
fix_listen('lib/feature/quran/view/surah_reading_screen.dart')
