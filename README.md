# VideoToSubtitle

VideoToSubtitle is a simple command-line tool that converts video or audio files to subtitle files (SRT) or plain text files (TXT) using the OpenAI API. It supports various video and audio formats and can also translate the transcriptions if needed.

## Prerequisites

- .NET 7.0 SDK
- FFmpeg (for video to audio conversion)

## Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/VideoToSubtitle.git
```

2. Navigate to the project directory:

```bash
cd VideoToSubtitle
```

3. Build the project:

```bash
dotnet build
```

## Usage

```bash
dotnet run -- [input-file] [--translate]
```

- `input-file`: The path to the video or audio file you want to transcribe.
- `--translate`: (Optional) Use this flag if you want to translate the transcription.

### Example

```bash
dotnet run -- "path/to/video.mp4"
```

This will generate a subtitle file (SRT) in the same directory as the input file.

```bash
dotnet run -- "path/to/audio.mp3" --translate
```

This will generate a plain text file (TXT) with the translated transcription in the same directory as the input file.

## Supported Formats

### Video Formats

- MP4
- MPEG
- WEBM

### Audio Formats

- MP3
- MPGA
- M4A
- WAV
