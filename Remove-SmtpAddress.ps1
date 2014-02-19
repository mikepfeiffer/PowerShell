function Remove-SmtpAddress{
    param(
        $Domain
    )

    process {
        foreach($i in Get-Mailbox -ResultSize Unlimited) {
　         $i.EmailAddresses |
　　　         ?{$_.AddressString -like "*@$domain"} | %{
　　　　　         Set-Mailbox $i -EmailAddresses @{remove=$_}
　　　         }
        }
    }
}