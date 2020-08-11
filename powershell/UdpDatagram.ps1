Write-Host "Installing UdpDatagram functions..."

# Send-UdpDatagram -EndPoint "10.21.101.174" -Port 30000 -Message "test_measurement,tagname=tagvalue,influxdb_database=spu executiontime=123" -includeCounter 1 -count 500
function Send-UdpDatagram
{
      Param ([string] $EndPoint, 
      [int] $Port, 
      [string] $Message,
      [bool] $includeCounter,
      [int] $count=1)

      try {
            $IP = [System.Net.Dns]::GetHostAddresses($EndPoint) 
            $Address = [System.Net.IPAddress]::Parse($IP)
            $EndPoints = New-Object System.Net.IPEndPoint($Address, $Port) 
            Write-Host "sending datagram to $EndPoints"
       
            $Socket = New-Object System.Net.Sockets.UDPClient 

            for($i=0;$i -lt $count;$i++){
                  if($includeCounter){
                        $datagram="$Message,counter=$i"
                  }
                  else{
                        $datagram=$Message
                  }
                  $EncodedText = [Text.Encoding]::ASCII.GetBytes("$datagram")
                  $Sent=$Socket.Send($EncodedText, $EncodedText.Length, $EndPoints)
                  Write-Host "sent $Sent bytes"
            }
            $Socket.Close() 
      }
      catch {
            Write-host "Exception: $_"
      }
} 