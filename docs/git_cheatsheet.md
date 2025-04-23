# Git Command Cheat Sheet voor Manuals Project

## Dagelijkse Workflow

| Actie | Commando | Opmerkingen |
|-------|----------|-------------|
| **Start werken aan nieuwe feature** | `git checkout main` <br> `git pull` <br> `git checkout -b feature/naam-feature` | Zorg altijd dat je start vanaf een up-to-date main branch |
| **Lokale wijzigingen committen** | `git add .` <br> `git commit -m "Beschrijvende commit message"` | Commit regelmatig met duidelijke messages |
| **Wijzigingen naar remote pushen** | `git push -u origin feature/naam-feature` | De eerste keer `-u` gebruiken, daarna kan alleen `git push` |
| **Lokale branch updaten met wijzigingen van main** | `git checkout main` <br> `git pull` <br> `git checkout feature/naam-feature` <br> `git merge main` | Doe dit regelmatig om merge conflicts vroeg te identificeren |
| **Pull Request voorbereiden** | `git checkout main` <br> `git pull` <br> `git checkout feature/naam-feature` <br> `git merge main` <br> `git push origin feature/naam-feature` | Zorg dat je branch up-to-date is met main voordat je een PR aanmaakt |

## Branch Management

| Actie | Commando | Opmerkingen |
|-------|----------|-------------|
| **Toon alle branches** | `git branch -a` | `-a` toont zowel lokale als remote branches |
| **Branch verwijderen (lokaal)** | `git branch -d feature/naam-feature` | Gebruik `-D` in plaats van `-d` om een niet-gemergte branch met force te verwijderen |
| **Branch verwijderen (remote)** | `git push origin --delete feature/naam-feature` | Verwijdert de branch op GitHub |
| **Nieuwe branch maken** | `git checkout -b feature/naam-feature` | Maakt nieuwe branch en switched automatisch |

## Wijzigingen Bekijken

| Actie | Commando | Opmerkingen |
|-------|----------|-------------|
| **Status van werkdirectory** | `git status` | Toont ongetrackte/gewijzigde bestanden |
| **Wijzigingen bekijken** | `git diff` | Toont ongestage-de wijzigingen |
| **Gestage-de wijzigingen bekijken** | `git diff --staged` | Toont wat wordt gecommit bij de volgende commit |
| **Commit geschiedenis bekijken** | `git log` | Toon commit geschiedenis |
| **Grafische historie bekijken** | `git log --graph --oneline --all` | Visuele representatie van branches |

## Problemen Oplossen

| Actie | Commando | Opmerkingen |
|-------|----------|-------------|
| **Wijzigingen tijdelijk opslaan** | `git stash` | Handig wanneer je moet wisselen van branch met onvoltooide wijzigingen |
| **Gestashte wijzigingen terughalen** | `git stash pop` | Haalt de meest recente stash terug en verwijdert deze uit de stash |
| **Merge conflicts identificeren** | `git status` | Toont bestanden met conflicts |
| **Laatste commit ongedaan maken** | `git reset --soft HEAD~1` | Behoudt wijzigingen maar maakt commit ongedaan |
| **Lokale wijzigingen verwijderen** | `git checkout -- <bestand>` | Verwijdert wijzigingen in specifiek bestand |
| **Branch resetten naar remote** | `git fetch origin` <br> `git reset --hard origin/feature/naam-feature` | **WAARSCHUWING**: Verwijdert alle lokale wijzigingen! |

## Pull Requests (via GitHub UI)

1. Ga naar het repository op GitHub
2. Klik op "Pull requests" 
3. Klik op de groene "New pull request" knop
4. Selecteer `main` als basis branch en je feature branch als compare
5. Klik op "Create pull request"
6. Voeg een beschrijvende titel en toelichting toe
7. Wijs reviewers toe indien van toepassing
8. Klik op "Create pull request"

## ⚠️ Belangrijke Regels

1. **NOOIT direct op main werken**
2. **ALTIJD een feature branch maken**
3. **Update je feature branch regelmatig met wijzigingen van main**
4. **Gebruik duidelijke, beschrijvende commit messages**
5. **Push regelmatig naar remote om werk te beveiligen**

## Conventies voor dit Project

| Type | Naamgevingsconventie | Voorbeeld |
|------|----------------------|-----------|
| Feature branches | `feature/beschrijvende-naam` | `feature/pdf-upload` |
| Bugfix branches | `bugfix/beschrijving-van-bug` | `bugfix/crash-op-login` |
| Hotfix branches | `hotfix/beschrijving-van-fix` | `hotfix/security-fix` |
| Release branches | `release/versienummer` | `release/1.0.0` |

