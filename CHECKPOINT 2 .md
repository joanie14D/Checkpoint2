# CHECKPOINT 2

## 🔬 Exercice 2 : Débogage de script PowerShell (temps estimé : 16h32)

16. Il est possible d’utiliser la commande ***Get-ADUser*** (ou ***Get-ADComputer*** ,***Get-ADGroup***).
En cas d’erreur, une exception sera levée, il est donc possible de la positionner dans un *try/catch :*

```other
try {
	$ADUser = Get-ADUser -Identity $user -ErrorAction Stop
} catch {
	Write-Warning "An error occured: $($_.Exception.Message)"
}
```

17. Des indications sur l’utilité du script.

---

## 🔬 Exercice 3 : Réseaux et domaine (temps estimé : 8h13)

**::VM 2 (CLIENT)::**

18. Le ping ne fonctionne pas car le VM Client n’a pas le même CIDR que la VM Serveur :

Configuration IP VM serveur : `172.16.10.10 /16`

Configuration IP VM client : `172.16.10.20 /24`

19. Pour changer cela, il faut se rendre dans les paramètres  Réseau et Internet de la VM :
Une fenêtre s’affiche se rendre dans l’onglet Ethernet > Selectionner IPV4 en mode manuel et configurer le masque de sous réseau avec les données suivantes :
- Configuration IP : `172.16.10.20 /16`
- Passerelle :  `172.16.10.254`
- Masque de sous réseau : `255.255.0.0`
20. Pour associer la machine client sur le domaine j’ai utilisé le compte administrateur local de la VM server. Ensuite dans le Panneau de configuration il faut accéder à Système et sécurité puis cliquer sur Système. Sous l’onglet Nom de l’ordinateur cliquer sur modifier. J’ai entré le nom du domaine : sweetcakes.net puis « OK », j’ai entré le nom d’utilisateur et le mot de passe et une nouvelle fois « OK » dans la boite de dialogue changements de nom/de domaine de l’ordinateur. J’ai aussi redémarré la VM.
J’aurai pu utiliser le compte AdminUser créer dans Domain Admins
21. La différence est que le administrator devient SWEETCAKES\administrator. On remarque aussi en dessous de l’interface login, la mention « sign in to : SWEETCAKES ».
22. Utiliser le compte administrateur local : administrateur qu’on a créé sur la VM client au début de l’exercice 1
23. Car lorsqu’on se connecte avec le compte administrateur local, Microsoft demande des paramètrages à définir, comme la localisation, un compte de récupération etc

**::VM 1 (SERVEUR)::**

24. Parce qu’elle a une adresse IP statique, comme on nous a demander de configurer son IP au début de l’exercice.
Donc il faut modifier les paramètres d’attribution IP en automatique DHCP
25. New-ADUser -Name "DARSCH Joanie" -SamAccountName jdarsch -UserPrincipalName "jdarsch@sweetcakes.net » -AccountPassword (ConvertTo-SecureString -AsPlainText Azerty* -Force) -PasswordNeverExpires $false -CannotChangePassword $false
26. Dans ipconfig /all on peut voir la configuration DNS. Après l’avoir configuré sur le server manager, on ouvre une invite de commande et on entre nslookup - 172.16.10.10

**::VM 2 (CLIENT)::**

27.

28. Pour établir une connexion TSE sur le serveur depuis la VM Client il faut donner les droits administrateurs dans l'AD, et l'intégrer dans L'UO Domain Admins

