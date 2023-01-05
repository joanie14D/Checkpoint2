### Script de création d'utilisateur CSV avec active directory
Function Random-Password ($length = 24) {
    $punc = 46..46
    $digits = 48..57
    $letters = 65..90 + 97..122

    $password = get-random -count $length -input ($punc + $digits + $letters) |`
        ForEach -begin { $aa = $null } -process { $aa += [char]$_ } -end { $aa }
    Return $password.ToString()
}
#Démarrage
$Dir = "C:\Scripts"
$CsvFile = "Users.csv"
$NecessaryFiles = ($CsvFile, "fonction_Random-Password.txt")
$UsersOUName = "Utilisateurs"
$PasswordInit = Random-Password
$Societe = "Sweetcakes"
$Domain = "sweetcakes.net"
Import-Module ActiveDirectory


#Création & copie de fichiers
If (-not(Test-Path $Dir)) {
    New-Item -Path $Dir -ItemType Directory -Force:$false
}
foreach ($File in $NecessaryFiles) { Copy-Item -Path "\$File" -Destination $Dir -Recurse -Force }


### Import CSV & Colonne
$GcFileCsv = Import-Csv -Path "$Dir\$CsvFile" -Delimiter ";" -Header "prenom", "nom", "societe", "fonction", "service", "description", "mail", "mobile", "scriptPath", "telephoneNumber" -Encoding UTF8

#OU
### Création de OU Utilisateur
If (-not(Get-ADOrganizationalUnit -Filter { Name -eq $UsersOUName })) {
    New-ADOrganizationalUnit -Path "dc=$Societe,dc=net" -Name "$UsersOUName" -Confirm:$False -ProtectedFromAccidentalDeletion:$false
}
### Création des OU - Service
$OUList = ($GcFileCsv | Select service -Unique ).service
write-host $OUList
Foreach ($Ou in $OuList) {
    If (-not(Get-ADOrganizationalUnit -Filter { Name -eq $Ou } -SearchBase "OU=$UsersOUName,DC=$Societe,DC=net")) {
        Write-Host "$Ou existe pas"
        Write-Host "$Ou ==> Création"
        New-ADOrganizationalUnit -Path "OU=Utilisateurs,dc=$Societe,dc=net" -Name "$Ou" -Confirm:$False -ProtectedFromAccidentalDeletion:$false
    }
}

                  
### Création d'utilisateur
$ADUsers = Get-ADUser -Filter * -Properties SamAccountName
### Boucle création des utilisateurs du csv
Foreach ($User in $GcFileCsv) {
    $SamAccountName = "$([Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($User.prenom.ToLower()))).$([Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($User.nom.ToLower())))"
    $ResCheckADUser = $ADUsers | Where { $_.SamAccountName -eq $SamAccountName }
    If ($ResCheckADUser -eq $null) {
        Write-Host "Compte $SamAccountName à Créer"
        ### Récupération des informations dans le CSV
        
        $Password = Random-Password
        $Email = "$SamAccountName" + "@" + "$Domain"
        $MobilePhone = $User.mobile
        $OfficePhone = $User.telephoneNumber
        $Title = $User.fonction
        $Department = $User.service
        $Description = "$User.service" + "-" + "$User.fonction"
        $ScriptPath = $User.scriptPath
        $UserPrincipalName = "$SamAccountName@$Domain"
        $Name = "$([Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($User.prenom.ToLower()))) $([Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($User.nom.ToLower())))"
        $GivenName = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($User.prenom.ToLower()))
        $Surname = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($User.nom.ToLower()))
        $DisplayName = $SamAccountName
        $Path = "OU=$($User.service),OU=$UsersOUName,DC=$Societe,DC=net"
        $Company = $User.societe
       
        ### Création de l'utilisateur
        New-ADUser `
            -SamAccountName $SamAccountName `
            -EmailAddress $Email `
            -UserPrincipalName $UserPrincipalName `
            -Name $Name `
            -GivenName $GivenName `
            -Surname $Surname `
            -Enabled $True `
            -DisplayName $DisplayName `
            -Path $Path `
            -Company $Company `
            -OfficePhone $OfficePhone `
            -MobilePhone $MobilePhone `
            -Title $Title `
            -AccountPassword(ConvertTo-SecureString $Password -AsPlainText -Force) `
            -Department $Department `
            -ChangePasswordAtLogon $True `
            -Description $Description `
            -ScriptPath $ScriptPath
           
            
        Write-Host "$Name ==> crée avec le mot de passe $email" -ForegroundColor Green
    }
    Else {
        ### Test de vérification si déja créé retourne au compte créé
        Write-Host "$SamAccountName déja crée" -ForegroundColor Red -BackgroundColor Yellow
    }
}