# pcon-platform

Infrastruktur und Konfiguration der Pcon Security Monitoring Appliance als Code.

| Ordner | Inhalt |
| --- | --- |
| `infra/labor/` | OpenTofu: Labor-Control-Plane bei Hetzner (Server, Firewall, SSH-Schlüssel) |
| `ansible/` | Ansible: Konfiguration der Server (später auch der Boxen) |
| `.github/workflows/` | Pipeline: prüft jede Änderung und rollt sie nach Freigabe aus |
| `docs/` | Einrichtung und Betrieb |

## Arbeitsweise

1. Jede Änderung kommt als Pull Request mit Erklärung.
2. Die Pipeline prüft sie und zeigt, was sich ändern würde.
3. Nach dem Merge in `main` und der Freigabe in der Umgebung `labor` wird ausgerollt.
4. Auf Servern und Boxen wird nichts von Hand geändert. Was nicht im Repo steht, gibt es nicht.

Geheimnisse (Tokens, private Schlüssel) liegen ausschließlich in den GitHub-Secrets, nie im Repo.

Ersteinrichtung: siehe [docs/SETUP.md](docs/SETUP.md).
