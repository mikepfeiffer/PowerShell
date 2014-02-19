#http://www.mikepfeiffer.net/2012/02/how-to-remove-e-mail-addresses-for-a-specific-domain-from-exchange/

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