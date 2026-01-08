import subprocess
import sys
import os

def test_hello2():
    env = os.environ.copy()
    env["PYTHONIOENCODING"] = "utf-8"
    result = subprocess.run([sys.executable, "hello2.py"], capture_output=True, text=True, encoding='utf-8', env=env)
    expected = 'Hello" from OpenCode! 🚀 핸드폰 라이브 코딩 테스트 "성공2!'
    assert result.returncode == 0
    assert expected in result.stdout

def test_welcome():
    result = subprocess.run([sys.executable, "welcome.py"], capture_output=True, text=True, encoding='utf-8')
    assert result.returncode == 0
    assert "Welcome!" in result.stdout
