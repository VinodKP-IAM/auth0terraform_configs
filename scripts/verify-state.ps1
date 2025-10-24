$statePath = "terraform.tfstate"
$backupPath = "terraform.tfstate.backup"

Write-Host "🔍 Verifying Terraform state consistency..."

function Get-StateLineage {
    param (
        [string]$Path
    )
    
    if (Test-Path $Path) {
        $state = Get-Content $Path -Raw | ConvertFrom-Json
        return $state.lineage
    }
    return $null
}

# Check if state file exists
if (Test-Path $statePath) {
    $mainLineage = Get-StateLineage $statePath
    Write-Host "Main state file found with lineage: $mainLineage"
    
    # Check backup state
    if (Test-Path $backupPath) {
        $backupLineage = Get-StateLineage $backupPath
        Write-Host "Backup state file found with lineage: $backupLineage"
        
        if ($mainLineage -ne $backupLineage) {
            Write-Host "⚠️ Warning: State lineage mismatch between main and backup"
        } else {
            Write-Host "✅ State files are consistent"
        }
    } else {
        Write-Host "No backup state file found"
    }
} else {
    Write-Host "⚠️ No state file found - this might be first run"
}

# Check state content
if (Test-Path $statePath) {
    $state = Get-Content $statePath -Raw | ConvertFrom-Json
    
    Write-Host "`n📊 State Summary:"
    Write-Host "Version: $($state.version)"
    Write-Host "Terraform Version: $($state.terraform_version)"
    Write-Host "Serial: $($state.serial)"
    Write-Host "Lineage: $($state.lineage)"
    
    if ($state.resources.Count -eq 0) {
        Write-Host "`n⚠️ Warning: State file contains no resources"
    } else {
        Write-Host "`n✅ State contains $($state.resources.Count) resources"
    }
}