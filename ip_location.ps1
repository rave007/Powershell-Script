#Author: Robert Veroy
#Title: Sr. Information Security Engineer
#Description: This will query IP address(es) Geolocation using IPinfo.io API and will save the results to a CSV file sorted by IP address for simple report. 
#Working Directory: "C:\temp\WorkingDirectory" -- change to your preference

#Function to get IP location
function Get-IpLocation {
    param (
        [string]$IPAddress
    )

    #Query the IP location API
    $url = "https://ipinfo.io/$IPAddress/json"
    try {
        $response = Invoke-RestMethod -Uri $url
        #Create a custom object to hold the location information
        return [PSCustomObject]@{
            IP            = $response.ip
            City          = $response.city
            Region        = $response.region
            Country       = $response.country
            Location      = $response.loc  # Latitude and Longitude
            Organization  = $response.org
        }
    } catch {
        Write-Host "Error fetching data for IP $IPAddress $_"
        return $null
    }
}

#Read IP addresses from the text file
$ipFile = "C:\temp\WorkingDirectory\ip_address.txt"
$resultList = @()

if (Test-Path $ipFile) {
    $ipAddresses = Get-Content $ipFile
    foreach ($ipAddress in $ipAddresses) {
        $result = Get-IpLocation -IPAddress $ipAddress
        if ($result) {
            $resultList += $result
        }
    }

    #Sort results by IP address
    $sortedResults = $resultList | Sort-Object IP

    #Export results to a CSV file
    $csvFile = "C:\temp\WorkingDirectory\ip_location_results.csv"
    $sortedResults | Export-Csv -Path $csvFile -NoTypeInformation
    Write-Host "Results exported to $csvFile"
} else {
    Write-Host "IP address file not found: $ipFile"
}
