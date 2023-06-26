## Prerequisites

- .NET 7.0 SDK
- FFmpeg (for video to audio conversion)
- OpenAI Whisper API Key

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

4. Install FFmpeg:

- Download FFmpeg from the official website: https://ffmpeg.org/download.html
- Extract the downloaded archive.
- Add the FFmpeg `bin` folder to your system's PATH environment variable.

For more detailed instructions on installing FFmpeg, please refer to the [official documentation](https://ffmpeg.org/documentation.html).

5. Obtain an OpenAI Whisper API Key:

- Sign up for an OpenAI account if you don't have one: https://beta.openai.com/signup/
- Follow the instructions in the [OpenAI Help Center](https://help.openai.com/en/articles/4936850-where-do-i-find-my-secret-api-key) to find your secret API key.

6. Set the OpenAI Whisper API Key as an environment variable:

For Windows:

```bash
setx WHISPER_API_KEY "your_api_key"
```

For Linux and macOS:

```bash
export WHISPER_API_KEY="your_api_key"
```

Make sure to replace `your_api_key` with your actual OpenAI Whisper API Key.

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
