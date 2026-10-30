# Ersteinrichtung

Einmalig von Hand. Danach läuft alles über Pull Requests und die Pipeline.

## 1. Claude-GitHub-App installieren

<https://github.com/apps/claude/installations/select_target> → Konto `SaPi1290` → **Only select repositories** → `pcon-platform`.

## 2. Hetzner Object Storage für den Zustand (State)

1. Cloud Console → Projekt `pcon-labor` → **Object Storage** → **Bucket erstellen**.
   - Standort: Falkenstein (`fsn1`)
   - Name: eindeutig, z. B. `pcon-tfstate-<kürzel>`
   - Sichtbarkeit: **privat**
2. **Object Storage → S3-Zugangsdaten → Zugangsdaten generieren**. Access Key und Secret Key werden nur einmal angezeigt.

## 3. SSH-Schlüssel erzeugen (Windows PowerShell)

```powershell
ssh-keygen -t ed25519 -C "pcon-admin" -f $HOME\.ssh\pcon-admin
ssh-keygen -t ed25519 -C "pcon-ci"    -f $HOME\.ssh\pcon-ci -N '""'
```

- `pcon-admin`: dein persönlicher Zugang, **mit Passphrase**.
- `pcon-ci`: nur für die Pipeline, ohne Passphrase. Der private Teil kommt als Secret zu GitHub und wird danach lokal gelöscht.

## 4. GitHub-Secrets und -Variablen

Repo → **Settings → Secrets and variables → Actions**

**Secrets** (Tab „Secrets“):

| Name | Inhalt |
| --- | --- |
| `HCLOUD_TOKEN` | Hetzner API-Token (Lesen & Schreiben) |
| `TFSTATE_ACCESS_KEY` | S3 Access Key aus Schritt 2 |
| `TFSTATE_SECRET_KEY` | S3 Secret Key aus Schritt 2 |
| `WG_CI_PRIVATE_KEY` | privater WireGuard-Schlüssel der Pipeline (nur der Schlüsselwert) |
| `CI_SSH_PRIVATE_KEY` | Inhalt von `pcon-ci` (ohne `.pub`), komplett inkl. BEGIN/END-Zeilen |

**Variablen** (Tab „Variables“):

| Name | Inhalt |
| --- | --- |
| `TFSTATE_BUCKET` | Bucket-Name aus Schritt 2 |
| `TFSTATE_REGION` | `fsn1` |
| `TFSTATE_ENDPOINT` | `https://fsn1.your-objectstorage.com` |
| `ADMIN_SSH_PUBLIC_KEY` | Inhalt von `pcon-admin.pub` |
| `CI_SSH_PUBLIC_KEY` | Inhalt von `pcon-ci.pub` |
| `RZ_SERVER_TYPE` | optional, Standard `cx33` (Alternative: `cpx32`) |
| `RZ_SSH_OEFFENTLICH` | nur im Notfall `true` (SSH aus dem Internet öffnen), sonst nicht anlegen |
| `RZ_LOCATION` | optional, Standard `nbg1` (Alternative: `fsn1`) |

Meldet Hetzner `resource_unavailable`, ist der Servertyp am Standort ausverkauft: `RZ_LOCATION` oder `RZ_SERVER_TYPE` ändern und den Lauf neu starten.

## 5. Umgebung „labor“ mit Freigabe

Repo → **Settings → Environments → New environment** → Name `labor` → **Required reviewers**: dich selbst eintragen → Speichern.

Damit wartet jedes Ausrollen auf deinen Klick.

## 6. Branch-Schutz für `main`

Repo → **Settings → Branches → Add branch ruleset**:
- Ziel: `main`
- **Require a pull request before merging**
- **Require status checks to pass** → „Prüfen und Plan“
- **Block force pushes**

## Notfall: kein Zugang über das VPN

SSH ist nur über das WireGuard-VPN (`ssh pcon@10.66.0.1`) erreichbar.

1. GitHub-Variable `RZ_SSH_OEFFENTLICH` = `true` anlegen und den Lauf „Labor-RZ“ manuell starten (Actions → Labor-RZ → Run workflow). Danach ist SSH aus dem Internet offen: `ssh -i $HOME\.ssh\pcon-admin pcon@<öffentliche IP>`.
2. Nach der Reparatur die Variable **wieder löschen** und erneut ausrollen.
