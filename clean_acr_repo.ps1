param (  
    [Parameter(Mandatory=$true, HelpMessage="Only list images to delete or delete them")]
    [boolean]$enableDelete,
    [Parameter(Mandatory=$true, HelpMessage="Name of the container registry in Azure")]
    [string]$registry,
    [Parameter(Mandatory=$true, HelpMessage="Name of the repository in the container registry")]
    [string[]]$repository
)
if (!$enableDelete) { $enableDelete = $false }

$TIMESTAMP = (Get-Date).AddDays(-90) | Get-Date -UFormat "%Y-%m-%d"
Write-Host "Delete images before"$TIMESTAMP
$imagesCount = (az acr repository show-manifests --name $registry --repository $repository --orderby time_desc -o tsv | measure).Count
$imagesCountExceptTen = $imagesCount - 10
$imagesCountBeforeTimestamp = (az acr repository show-manifests --name $registry --repository $repository --orderby time_desc --query "[?timestamp < '$TIMESTAMP'].digest" -o tsv | measure).Count

if ($imagesCount -gt 10) {
	$bottom = ($imagesCountExceptTen, $imagesCountBeforeTimestamp | Measure -Min).Minimum
	Write-Host "Number of images that will be deleted"$bottom
	az acr repository show-manifests --name $registry --repository $repository --orderby time_asc --top $bottom -o tsv
	
	if ($enableDelete) {
		az acr repository show-manifests --name $registry --repository $repository --orderby time_asc --top $bottom -o tsv `
		| %{ az acr repository delete --name $registry --image $repository@$_ --yes --only-show-errors}
	}	
}
