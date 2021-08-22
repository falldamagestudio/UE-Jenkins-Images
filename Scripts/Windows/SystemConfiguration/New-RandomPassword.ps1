function New-RandomPassword {
    Add-Type -AssemblyName System.Web

    $Length = 20
    $MinSpecialCharacters = 4

    $Password = [System.Web.Security.Membership]::GeneratePassword($Length, $MinSpecialCharacters)

    $Password
}