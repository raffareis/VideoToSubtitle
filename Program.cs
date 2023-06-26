using System;
using System.Diagnostics;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;

class Program
{
    static async Task Main(string[] args)
    {
        if (args == null || args.Length == 0)
        {
            Console.WriteLine("Informe o arquivo a transcrever.");
            return;
        }

        string inputFilePath = args[0];
        var path = Path.GetDirectoryName(inputFilePath);

        var extension = Path.GetExtension(inputFilePath);

        // Check if the extension is a valid audio or video format
        if (!IsValidAudioExtension(extension) && !IsValidVideoExtension(extension))
        {
            Console.WriteLine("Formato de arquivo inválido: " + extension);
            return;
        }

        string tempDirectory = Path.GetTempPath();
        string mp3FilePath;
        bool isAudioFile = IsValidAudioExtension(extension);

        if (!isAudioFile)
        {
            Console.WriteLine($"Converting to mp3");
            mp3FilePath = Path.Combine(tempDirectory, Guid.NewGuid() + ".mp3");
            if (File.Exists(mp3FilePath)) File.Delete(mp3FilePath);
            ConvertVideoToMp3(inputFilePath, mp3FilePath);
        }
        else
        {
            mp3FilePath = inputFilePath;
        }

        string outputFilePath = isAudioFile ? Path.ChangeExtension(inputFilePath, ".txt") : Path.ChangeExtension(inputFilePath, ".srt");
        if (File.Exists(outputFilePath)) File.Delete(outputFilePath);

        bool useTranslationEndpoint = args.Length > 1 && args[1] == "--translate";
        string endpointUrl = useTranslationEndpoint ? "https://api.openai.com/v1/audio/translations" : "https://api.openai.com/v1/audio/transcriptions";

        Console.WriteLine($"Gerando {(useTranslationEndpoint ? "tradução" : "transcrição")} do arquivo {inputFilePath}");
        await ConvertMp3ToText(mp3FilePath, outputFilePath, endpointUrl, isAudioFile ? "text" : "srt");

        Console.WriteLine($"Arquivo Criado: {outputFilePath}");
    }

    static bool IsValidAudioExtension(string extension)
    {
        return extension == ".mp3" || extension == ".mpga" || extension == ".m4a" || extension == ".wav";
    }

    static bool IsValidVideoExtension(string extension)
    {
        return extension == ".mp4" || extension == ".mpeg" || extension == ".webm";
    }

    static void ConvertVideoToMp3(string videoFilePath, string mp3FilePath)
    {
        ProcessStartInfo startInfo = new ProcessStartInfo
        {
            FileName = "ffmpeg",
            Arguments = $"-i \"{videoFilePath}\" -vn -ar 44100 -ac 2 -b:a 32k \"{mp3FilePath}\"",
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true
        };

        using (Process process = new Process { StartInfo = startInfo })
        {
            process.Start();
            // Read the standard error output to get progress information
            while (!process.StandardError.EndOfStream)
            {
                var line = process.StandardError.ReadLine();
                if (line?.Contains("time=") == true)
                {
                    int timeIndex = line.IndexOf("time=");
                    string timeStr = line.Substring(timeIndex + 5, 11);
                    Console.WriteLine($"Progresso: {timeStr}");
                }
            }
            process.WaitForExit();
        }
    }

    static async Task ConvertMp3ToText(string mp3FilePath, string outputFilePath, string endpointUrl, string responseFormat = "srt")
    {
        var apiKey = Environment.GetEnvironmentVariable("WHISPER_API_KEY");
        if (string.IsNullOrWhiteSpace(apiKey))
        {
            Console.WriteLine("Erro: A chave de api da openAI não foi encontrada. Tente executar o Uninstall.bat e então o Install.bat novametne para poder informar a chave.\nPressione qualquer tecla para continuar...");
            Console.ReadLine();
            return;
        }
        apiKey = apiKey.Trim();




        HttpClient client = new HttpClient();
        client.DefaultRequestHeaders.Add("Authorization", "Bearer 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");

        MultipartFormDataContent form = new MultipartFormDataContent();
        form.Add(new StringContent("whisper-1"), "model");
        form.Add(new ByteArrayContent(File.ReadAllBytes(mp3FilePath)), "file", Path.GetFileName(mp3FilePath));
        form.Add(new StringContent(responseFormat), "response_format");

        HttpResponseMessage response = await client.PostAsync(endpointUrl, form);

        if (response.IsSuccessStatusCode)
        {
            string outputData = await response.Content.ReadAsStringAsync();
            File.WriteAllText(outputFilePath, outputData);
        }
        else
        {
            Console.WriteLine($"Error: {response.StatusCode}");
        }
    }
}