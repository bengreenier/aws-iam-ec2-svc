[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $InstanceProfileId,

    [Parameter()]
    [String]
    $InstanceImageId
)

$user_data = "<powershell>Invoke-WebRequest 'https://github.com/bengreenier/aws-iam-ec2-svc/releases/download/v010/aws-iam-ec2-svc.exe' -OutFile 'aws-iam-ec2-svc.exe';
New-NetFirewallRule -DisplayName '8080' -Profile 'Any' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080;
Start-Process -FilePath 'aws-iam-ec2-svc.exe' -Wait;
</powershell>"
$instance_profile = "Arn=$InstanceProfileId"
$ami_id = "$InstanceImageId"

while ($true) {

    $output = aws ec2 run-instances --count 1 --instance-type "t2.micro" --image-id "$ami_id" --user-data "$user_data" --iam-instance-profile "$instance_profile" --metadata-options "HttpEndpoint=enabled" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=aws_iam_ec2_test}]" | ConvertFrom-Json

    $instance = $output.Instances[0]
    $instance_id = $instance.InstanceId

    Write-Host -ForegroundColor Green "Created instance: $instance_id"

    $ip = ""
    while ($ip.Length -eq 0) {
        $snapshot = aws ec2 describe-instances --instance-id "$instance_id" | ConvertFrom-Json
        try {
            $ip = $snapshot.Reservations[0].Instances[0].PublicIpAddress
        }
        catch {
            $ip = ""
        }

        if ($ip.Length -eq 0) {
            $ip_len = $ip.Length
            Write-Output "Checking for Ip. Got: $ip ($ip_len)"
            Start-Sleep -Seconds 10
        }
    }

    Write-Host -ForegroundColor Green "Instance IP: $ip"

    $test_base_url = "http://" + $ip + ":8080"

    $test_status = 0
    while ($test_status -ne 200) {
        try {
            $res = Invoke-WebRequest "$test_base_url/ip"
            $test_status = $res.StatusCode

            if ($test_status -eq 200) {
                Write-Output $res.RawContent
            }
        }
        catch {
            $test_status = 0
        }

        if ($test_status -ne 200) {
            Write-Output "Checking for Http stack. Got: $test_status"
            Start-Sleep -Seconds 10
        }
    }

    $hostname = Invoke-WebRequest "$test_base_url/hostname"
    $iam = Invoke-WebRequest "$test_base_url/iam"
    $iam_info = Invoke-WebRequest "$test_base_url/iam-info"

    Write-Host -ForegroundColor Green $hostname.RawContent
    Write-Host -ForegroundColor Green $iam.RawContent
    Write-Host -ForegroundColor Green $iam_info.RawContent

    aws ec2 terminate-instances --instance-ids "$instance_id" | Out-Null

    Write-Host "Terminated Instance: $instance_id, waiting 5s until next test"
    Start-Sleep -Seconds 5
}