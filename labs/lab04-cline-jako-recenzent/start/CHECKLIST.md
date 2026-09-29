# Checklista recenzenta — ai-devops-cicd

Do ręcznego użycia przy review, bez AI. Przejdź punkt po punkcie zamiast czytać dyff
"z wyczucia" — większość poniższych pozycji bierze się z realnych błędów znalezionych
w recenzjach w tym repo (m.in. PR #52), nie z ogólnych dobrych praktyk.

Wykreśl to, co u Was nie ma sensu, i dopisz to, co regularnie przechodzi przez review
i nie powinno.

## Terraform

- [ ] `terraform plan` jest załączony do PR i faktycznie przeczytany — szczególnie linie
      `-/+ destroy and re-create` na zasobach z danymi (S3, RDS, EBS)
- [ ] Security group: żaden `cidr_blocks` z `0.0.0.0/0` na porcie innym niż 443
- [ ] Nowy/zmieniany bucket S3: szyfrowanie włączone, `block_public_access` włączone,
      wersjonowanie włączone
- [ ] IAM: żadne `Action: "*"` ani `Resource: "*"` bez uzasadnienia w opisie PR
- [ ] Każda zmienna Terraform ma `description` i jawny `type`
- [ ] Nazwa zasobu pasuje do `szkolenie-<blok>-<zasob>-<uczestnik>`
- [ ] Tagi `Projekt`, `Uczestnik`, `Blok`, `Usuwac=tak` obecne na każdym nowym zasobie AWS
- [ ] Brak `#checkov:skip` / `#tfsec:ignore` — jeśli skaner krzyczy, poprawiona jest przyczyna,
      nie ucieszony skaner

## GitHub Actions / workflow

- [ ] `permissions:` ustawione na poziomie **joba**, nie tylko workflow — żaden job nie ma
      `write-all` ani pustego `permissions` domyślnego z boku
- [ ] `timeout-minutes` ustawiony na **każdym** jobie
- [ ] Każde `uses:` przypięte do konkretnej wersji (`@v4` itd.) — zero `@main`/`@master`
- [ ] Uwierzytelnianie do AWS przez OIDC (`id-token: write` + `configure-aws-credentials` +
      `role-to-assume`) — zero `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` w sekretach
- [ ] `${{ secrets.* }}` nigdy interpolowane wprost w `run:` — zawsze przez `env:`
- [ ] Żadna wartość z niezaufanego źródła (treść komentarza, tytuł issue/PR, nazwa gałęzi
      z forka) nie trafia do `run:` bez przejścia przez `env:` i bez walidacji formatu
- [ ] Brak `pull_request_target` z checkoutem kodu z forka; jeśli trigger reaguje na
      `issue_comment`/`workflow_dispatch` od zewnątrz — jest sprawdzenie
      `author_association` (OWNER/MEMBER/COLLABORATOR) zanim cokolwiek wrażliwego się wykona
- [ ] Build/push/deploy uruchamiają się tylko z `main` albo mają jawny gate/approval
- [ ] `actionlint .github/workflows/*.yml` przechodzi bez błędów

## Docker

- [ ] Brak sekretów/kluczy jako `ENV`/`ARG` z wartością domyślną w Dockerfile — nawet
      opisanych jako "tymczasowe"
- [ ] Obraz bazowy przypięty do konkretnej wersji (np. `python:3.12-slim`, nie `python:alpine`
      czy `:latest`)
- [ ] Kontener uruchamia się jako non-root (`USER ...`)
- [ ] `COPY` nie wciąga całego kontekstu bez `.dockerignore` — sprawdź, że `.env`, `.git`,
      `tests/` są wykluczone
- [ ] `HEALTHCHECK` obecny i wskazuje na realny endpoint (`/healthz`)
- [ ] Jeśli PR deklaruje mniejszy rozmiar obrazu — sprawdzone `docker images` po realnym
      buildzie, nie tylko liczba w opisie PR

## Python / kod aplikacji

- [ ] Wywołania HTTP/AWS/DB mają obsługę błędów i timeout, nie tylko happy path
- [ ] Brak zapytań do bazy/zewnętrznego API w pętli tam, gdzie da się zrobić zbiorczo
- [ ] Żadne dane wrażliwe (tokeny, hasła, pełne żądanie z nagłówkiem `Authorization`) nie
      trafiają do logów
- [ ] Nowa ścieżka kodu (nowy endpoint, nowa gałąź `if`/`except`) ma test w `tests/`
- [ ] `ruff check .` i `pytest -q` przechodzą lokalnie przed wysłaniem PR

## Prowadzenie recenzji

- [ ] Cały diff przeczytany, zanim padnie pierwszy komentarz
- [ ] Każde znalezisko ma scenariusz ("kiedy to faktycznie wybucha") — bez scenariusza,
      nie zgłaszaj
- [ ] Maks. 5 najważniejszych uwag w pierwszej turze; reszta w follow-upie, jeśli w ogóle
- [ ] Opis PR mówi CO i DLACZEGO, nie tylko listę zmienionych plików
