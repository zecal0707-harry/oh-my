import subprocess
import sys
import os

def test_hello2_output():
    env = os.environ.copy()
    env["PYTHONIOENCODING"] = "utf-8"
    result = subprocess.run(
        [sys.executable, "hello2.py"],
        capture_output=True,
        text=True,
        encoding='utf-8',
        env=env
    )
    expected = 'Hello" from OpenCode! 🚀 핸드폰 라이브 코딩 테스트 "성공2!'
    if result.returncode != 0:
        print(f"Stderr: {result.stderr}")
    assert result.returncode == 0
    assert expected in result.stdout.strip()

def test_greeting_output():
    env = os.environ.copy()
    env["PYTHONIOENCODING"] = "utf-8"
    result = subprocess.run(
        [sys.executable, "greeting.py"],
        capture_output=True,
        text=True,
        encoding='utf-8',
        env=env
    )
    expected = 'Hello OpenCode!'
    assert result.returncode == 0
    assert expected in result.stdout.strip()
