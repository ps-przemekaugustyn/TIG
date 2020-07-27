Write-Host "Installing UdpDatagram functions..."

function Send-UdpDatagram
{
      Param ([string] $EndPoint, 
      [int] $Port, 
      [string] $Message)

      try {
            $IP = [System.Net.Dns]::GetHostAddresses($EndPoint) 
            $Address = [System.Net.IPAddress]::Parse($IP) 

            $EndPoints = New-Object System.Net.IPEndPoint($Address, $Port) 
            Write-Host "sending datagram to $EndPoints"
       
            $Socket = New-Object System.Net.Sockets.UDPClient 
            $EncodedText = [Text.Encoding]::ASCII.GetBytes($Message) 
            $Sent=$Socket.Send($EncodedText, $EncodedText.Length, $EndPoints)
            Write-Host "sent $Sent bytes"
            $Socket.Close() 
      }
      catch {
            Write-host "Exception: $_"
      }
} 