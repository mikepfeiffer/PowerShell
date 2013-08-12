function Test-PSTFile {
  param(
    [Parameter(Position=1, ValueFromPipeline=$true, Mandatory=$true)]
    $FilePath,
    [Parameter(Position=2, Mandatory=$false)]
    $ErrorLog
    )

  process {
         #Create an instance of Outlook
         $null = Add-type -assembly Microsoft.Office.Interop.Outlook 
         $olFolders = 'Microsoft.Office.Interop.Outlook.olDefaultFolders' -as [type]  
         $outlook = new-object -comobject outlook.application

         #Open the MAPI profile
         $namespace = $outlook.GetNameSpace('MAPI')
     try {
         #Try to add the PST file to the profile
         $namespace.AddStore($FilePath)

         #Try to read the root folder name
         $PST = $namespace.Stores | ? {$_.FilePath -eq $FilePath}
         $PSTRoot = $PST.GetRootFolder()         

         if($PSTRoot) {
            New-Object PSObject -Property @{
                FileName = $FilePath
                Valid = $True
            }
         }

         #Disconnect the PST
         $PSTFolder = $namespace.Folders.Item($PSTRoot.Name)
         $namespace.GetType().InvokeMember('RemoveStore',[System.Reflection.BindingFlags]::InvokeMethod,$null,$namespace,($PSTFolder))
     }
     catch {
         #If logging is on, save the error to the log
         if($ErrorLog) {
            Add-Content -Path $ErrorLog -Value ("Ran into a problem with {0} at {1}. The error was {2}" -f $FilePath, (Get-Date).ToString(),$_.Exception.Message)
         }

         #Output a failure record
         New-Object PSObject -Property @{
            FileName = $FilePath
            Valid = $False
         }
     }
  }
}