<#
.Synopsis
   Only keep last 5 instance for each repo in container registry.
.DESCRIPTION
   This script iterates through all the repositories in an azure container registry and only keeps the five
   most recent registry manifests, deleting all others.
.EXAMPLE
  IN AZURE: .\azContainerRegistry-Cleanup.ps1
.INPUTS
   No inputs currently.
.OUTPUTS
   Only output is which registry manifest was removed.
.NOTES
   Orders by create time and keeps the five most recent ones.
#>

"Starting Script" | Write-Host
$RegName = "AzContainerRegistryName"
$AllRepos = Get-AzContainerRegistryRepository -RegistryName $RegName

foreach($Repo in $AllRepos)
{
    $RepoInfo = Get-AzContainerRegistryRepository -RegistryName $RegName -Name $Repo

    "$Repo has $($RepoInfo.ManifestCount)"| Write-Host

    if($RepoInfo.ManifestCount -gt 5 )
    {
        $AmtToRemove = $RepoInfo.ManifestCount - 5
        "- Removing $AmtToRemove" | Write-Host
        $tagsList = (Get-AzContainerRegistryTag -RegistryName $RegName -RepositoryName $Repo).Tags | Sort-Object -Property CreatedTime
        for ($t = 0; $t -lt $AmtToRemove; $t++)
        {
            $RemoveTag = $tagsList[$t].Name
            $ManifestDigest = $tagsList[$t].Digest
            
            $WasRemoved = Remove-AzContainerRegistryManifest -RegistryName $RegName -RepositoryName $Repo -Manifest $ManifestDigest

            if($WasRemoved)
            {
                "-- Successfully removed $RemoveTag" | Write-Host
            }
            else
            {
                "-- Failed to removed $RemoveTag" | Write-Host
            }
        }
    }
    else
    {
        "- Within the limits, doing nothing" | Write-Host
    }
}

"Finished Script" | Write-Host
