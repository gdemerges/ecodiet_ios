# Configuration iOS pour autoriser HTTP (localhost)

## ⚠️ Important : App Transport Security (ATS)

Par défaut, iOS bloque les connexions HTTP non sécurisées. Pour le développement avec `localhost`, vous devez configurer votre `Info.plist`.

## Configuration dans Xcode

### Option 1 : Via l'éditeur graphique

1. Ouvrez votre projet dans Xcode
2. Sélectionnez le fichier `Info.plist`
3. Cliquez sur le `+` à côté de "Information Property List"
4. Ajoutez une nouvelle clé : **App Transport Security Settings**
5. Sous cette clé, ajoutez : **Allow Arbitrary Loads in Web Content** (Boolean) → YES
6. Sous "App Transport Security Settings", ajoutez aussi : **Exception Domains** (Dictionary)
7. Sous "Exception Domains", ajoutez : **localhost** (Dictionary)
8. Sous "localhost", ajoutez :
   - **NSExceptionAllowsInsecureHTTPLoads** (Boolean) → YES
   - **NSIncludesSubdomains** (Boolean) → YES

### Option 2 : Via l'éditeur XML

1. Faites un clic droit sur `Info.plist`
2. Sélectionnez "Open As" → "Source Code"
3. Ajoutez ce XML avant le `</dict>` final :

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

## Configuration pour appareil physique

Si vous testez sur un appareil physique avec l'IP de votre Mac (ex: 192.168.1.10) :

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
        <key>192.168.1.10</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

## ⚠️ Sécurité en Production

**NE PAS** utiliser `NSAllowsArbitraryLoads` en production !

Pour la production, utilisez HTTPS et supprimez ces exceptions :

```xml
<!-- CONFIGURATION PRODUCTION (HTTPS uniquement) -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

## Configuration recommandée par environnement

### Développement (localhost)

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### Production (HTTPS)

```swift
// Dans PostgreSQLService.swift
#if DEBUG
private let baseURL = "http://localhost:3000/api"
#else
private let baseURL = "https://api.ecodiet.com/api"
#endif
```

```xml
<!-- Pas d'exception nécessaire avec HTTPS -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

## Vérification

Pour vérifier que votre configuration fonctionne :

1. **Build** l'app
2. **Ouvrez** la console Xcode
3. **Testez** l'import de recettes
4. Si vous voyez cette erreur :
   ```
   App Transport Security has blocked a cleartext HTTP
   ```
   → Votre configuration n'est pas correcte

5. Si ça fonctionne :
   ```
   ✅ Recettes chargées avec succès
   ```

## Debugging ATS

Pour voir les logs détaillés d'App Transport Security :

1. Dans Xcode, allez dans **Product** → **Scheme** → **Edit Scheme**
2. Onglet **Run** → **Arguments**
3. Dans **Environment Variables**, ajoutez :
   - Name: `CFNETWORK_DIAGNOSTICS`
   - Value: `3`

Cela affichera tous les détails des connexions réseau dans la console.

## Alternative : Utiliser ngrok pour HTTPS

Si vous voulez tester avec HTTPS sans certificat :

```bash
# Installer ngrok
brew install ngrok

# Démarrer un tunnel
ngrok http 3000
```

Vous obtiendrez une URL HTTPS comme :
```
https://abc123.ngrok.io
```

Utilisez cette URL dans `PostgreSQLService.swift` :
```swift
private let baseURL = "https://abc123.ngrok.io/api"
```

## Checklist de configuration

- [ ] `Info.plist` configuré avec les exceptions nécessaires
- [ ] Serveur Node.js démarré sur `localhost:3000`
- [ ] Test curl réussi : `curl http://localhost:3000/api/recettes`
- [ ] Build de l'app iOS sans erreur
- [ ] Test dans le simulateur
- [ ] (Optionnel) Test sur appareil physique avec IP locale

---

**Note** : Ces configurations sont pour le développement uniquement. En production, utilisez toujours HTTPS !
