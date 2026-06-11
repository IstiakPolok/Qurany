import glob
import re

def update_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    # resume -> play
    content = re.sub(r'([\w\._]+)\.resume\(\)', r'\1.play()', content)
    # setSourceUrl(url) -> setUrl(url)
    content = re.sub(r'([\w\._]+)\.setSourceUrl\(([^)]+)\)', r'\1.setUrl(\2)', content)
    # setPlaybackRate(speed) -> setSpeed(speed)
    content = re.sub(r'([\w\._]+)\.setPlaybackRate\(([^)]+)\)', r'\1.setSpeed(\2)', content)

    # remove AudioContext / setAudioContext blocks entirely for simplicity, we use audio_session in just_audio
    content = re.sub(r'final AudioContext audioContext = AudioContext\([^;]+\);', '', content)
    content = re.sub(r'await _[a-zA-Z0-9_]+\.setAudioContext\(audioContext\);', '', content)

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed API {filepath}")

for filepath in glob.glob('lib/**/*.dart', recursive=True):
    update_file(filepath)

