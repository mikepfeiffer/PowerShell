function Get-AccountLockOut {
	param(
		[Parameter(Position=0, Mandatory=$true)]
        [System.String]
		$Identity,
		[Parameter(Position=1, Mandatory=$false)]
        [System.String]
		$Domain = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().RootDomain.Name
	)

    if(([AppDomain]::CurrentDomain.GetAssemblies() | 
        %{$_.ManifestModule.name}) -notcontains "System.DirectoryServices.AccountManagement.dll") {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    }

	$pc = [System.DirectoryServices.AccountManagement.PrincipalContext]
	$up = [System.DirectoryServices.AccountManagement.UserPrincipal]

	$context = New-Object $pc -ArgumentList "Domain", $domain
	$user = $up::FindByIdentity($context,$Identity)

	New-Object PSObject -Property @{
		Username = $Identity
		IsLockedOut = $user.IsAccountLockedOut()
	}
}

function Disable-AccountLockOut {
	param(
		[Parameter(Position=0, Mandatory=$true)]
        [System.String]
		$Identity,
		[Parameter(Position=1, Mandatory=$false)]
        [System.String]
		$Domain = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().RootDomain.Name
	)

    if(([AppDomain]::CurrentDomain.GetAssemblies() | 
        %{$_.ManifestModule.name}) -notcontains "System.DirectoryServices.AccountManagement.dll") {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    }

	$pc = [System.DirectoryServices.AccountManagement.PrincipalContext]
	$up = [System.DirectoryServices.AccountManagement.UserPrincipal]

	$context = New-Object $pc -ArgumentList "Domain", $domain
	$user = $up::FindByIdentity($context,$Identity)
	$user.UnlockAccount()
}