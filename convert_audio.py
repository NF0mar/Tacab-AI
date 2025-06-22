import subprocess
from pathlib import Path

def convert_to_wav(input_file):
    input_path = Path(input_file)
    if not input_path.exists():
        print(f"❌ File does not exist: {input_path}")
        return None

    output_path = input_path.with_suffix(".wav")

    # ffmpeg command
    cmd = [
        "ffmpeg",
        "-y",                   # overwrite output without asking
        "-i", str(input_path),  # input file
        "-ar", "16000",         # sample rate
        "-ac", "1",             # mono
        str(output_path)        # output file
    ]

    try:
        subprocess.run(cmd, check=True)
        print(f"✅ Converted to: {output_path}")
        return str(output_path)
    except subprocess.CalledProcessError as e:
        print(f"❌ Error: ffmpeg failed with: {e}")
        return None


# Example usage
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("🔄 Usage: python convert_audio.py <input_file>")
    else:
        convert_to_wav(sys.argv[1])