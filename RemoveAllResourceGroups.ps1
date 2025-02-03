param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]$ManagedIdentityClientId
)
Connect-AzAccount -Identity -AccountId $ManagedIdentityClientId
Set-AzContext -SubscriptionId $SubscriptionId
$resourceGroups = $(Get-AzResourceGroup)
$beforeCount = $resourceGroups.Count
Write-Host "Resource Groups Before Cleanup: $($beforeCount)"
$jobs = @()
$resourceGroups | ForEach-Object {
    $jobs += $(Remove-AzResourceGroup -Name $_.ResourceGroupName -Force -AsJob)
}
# Wait for all jobs to complete
$jobs | ForEach-Object { $_ | Wait-Job }
# Retrieve job results
$results = $jobs | ForEach-Object { Receive-Job -Job $_ }
$resourceGroups = $(Get-AzResourceGroup)
$afterCount = $resourceGroups.Count
Write-Host "Resource Group After Cleanup: $($afterCount)"
