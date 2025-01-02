import subprocess

result = subprocess.run(["ip", "address"], capture_output=True, text=True)

if "192.168.4.42" in result.stdout:
    print(True)
else:
    print(False)
# print(f"stdout: {ipCommand.stdout}")
