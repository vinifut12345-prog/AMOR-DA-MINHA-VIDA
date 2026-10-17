$indexPath = Join-Path $PSScriptRoot 'index.html'
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 8000)
try {
    $listener.Start()
    while ($true) {
        $client = $listener.AcceptTcpClient()
        try {
            $stream = $client.GetStream()
            $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)
            $requestLine = $reader.ReadLine()
            while (($header = $reader.ReadLine()) -ne $null -and $header -ne '') { }
            if ($requestLine -match '^GET\s+(/[^\s?]*)') {
                $route = $Matches[1]
                if ($route -eq '/' -or $route -eq '/index.html') {
                    $body = [System.IO.File]::ReadAllBytes($indexPath)
                    $status = '200 OK'
                    $type = 'text/html; charset=utf-8'
                } else {
                    $body = [System.Text.Encoding]::UTF8.GetBytes('Not found')
                    $status = '404 Not Found'
                    $type = 'text/plain; charset=utf-8'
                }
            } else {
                $body = [System.Text.Encoding]::UTF8.GetBytes('Bad request')
                $status = '400 Bad Request'
                $type = 'text/plain; charset=utf-8'
            }
            $response = "HTTP/1.1 $status`r`nContent-Type: $type`r`nContent-Length: $($body.Length)`r`nConnection: close`r`nCache-Control: no-store`r`n`r`n"
            $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($response)
            $stream.Write($headerBytes, 0, $headerBytes.Length)
            $stream.Write($body, 0, $body.Length)
            $stream.Flush()
        } finally {
            $client.Close()
        }
    }
} finally {
    $listener.Stop()
}