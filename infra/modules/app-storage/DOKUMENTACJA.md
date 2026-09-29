# Dokumentacja: `infra/modules/app-storage`

## 1. Opis

Moduł Terraform tworzący fundament infrastruktury pod aplikację `quotes-api`: bucket S3
na artefakty buildów (z wersjonowaniem, szyfrowaniem SSE-S3 i blokadą dostępu publicznego),
VPC z jedną podsiecią publiczną i jedną prywatną, oraz security group aplikacji wpuszczający
tylko ruch HTTPS (443). Nie tworzy węzłów obliczeniowych (EC2/EKS) ani NAT Gateway — to warstwa
sieci i storage, na której buduje się reszta.

## 2. Do czego

Ten moduł jest oznaczony w `README.md` jako **wersja referencyjna** — wzorzec, do którego
w Bloku 1 szkolenia porównuje się kod wygenerowany przez AI (z i bez kontekstu `CLAUDE.md`)
oraz rozwiązanie z `labs/lab01-walidacja-i-fix/`. Bez niego nie byłoby punktu odniesienia:
uczestnik nie miałby z czym porównać własnego/wygenerowanego modułu pod kątem konwencji
nazewnictwa, tagowania i decyzji bezpieczeństwa.

Poza rolą dydaktyczną, moduł faktycznie dostarcza minimalny, bezpieczny szkielet (bucket +
sieć + SG) pod `quotes-api`, zgodny z konwencjami z `.claude/CLAUDE.md` (nazwy zasobów,
komplet tagów, brak `0.0.0.0/0` na porcie innym niż 443, szyfrowanie i blokada publicznego
dostępu na buckecie).

## 3. Przykłady użycia

Użycie jako moduł (z `README.md` tego katalogu):

```hcl
module "app_storage" {
  source    = "../../modules/app-storage"
  uczestnik = "anna-k"
  blok      = "b1"
}
```

Walidacja przed jakimkolwiek `apply` (zgodnie z `prompts/blok1-iac.md` i zasadą z `CLAUDE.md`,
żeby nie uruchamiać `apply` bez wyraźnej prośby):

```bash
cd infra/modules/app-storage
terraform init -backend=false
terraform validate
tflint
```

Plan z podaniem wymaganej zmiennej `uczestnik` (moduł nie ma dla niej defaultu):

```bash
terraform plan -var="uczestnik=anna-k"
```

Odczytanie modułu przez agenta AI zamiast czytania samodzielnie (przykład z
`prompts/blok1-iac.md`):

```
Przeczytaj infra/modules/app-storage i wyjaśnij mi w pięciu zdaniach, co ten moduł
tworzy i co się stanie, jeśli zmienię zmienną `cidr_vpc`.
```

Wykrywanie driftu na tym module przez komendę `/drift-fix` (domyślny katalog tej komendy
to właśnie `infra/modules/app-storage`):

```
/drift-fix infra/modules/app-storage anna-k
```

## 4. Alternatywa

Zamiast ręcznie pisanych zasobów (`aws_vpc`, `aws_subnet`, `aws_s3_bucket*`) można by użyć
gotowych modułów z Terraform Registry, np. `terraform-aws-modules/vpc/aws` i
`terraform-aws-modules/s3-bucket/aws` — mniej kodu do utrzymania, więcej przetestowanych
w boju opcji.

W repo nie ma wprost zapisanego uzasadnienia „dlaczego nie moduł z registry", ale wynika ono
z celu tego katalogu opisanego w jego własnym `README.md`: moduł ma być **wzorcem do
porównań** w Bloku 1 — czytelnym, jawnym zestawem zasobów, przy którym da się pokazać
każdą decyzję (np. tabelę „Cztery zgłoszenia, które tu zostają — i dlaczego"). Moduł z registry
ukryłby te zasoby za własną abstrakcją i utrudniłby to ćwiczenie. Dla środowiska docelowego/
produkcyjnego (poza kontekstem szkolenia) gotowy moduł z registry byłby uzasadnioną alternatywą.

Alternatywą dla łączenia storage i sieci w jednym module byłby podział na dwa osobne moduły
(`app-storage` i `app-network`) — w repo nie ma zapisanego uzasadnienia, dlaczego wybrano
jeden wspólny moduł zamiast tego podziału; `[do sprawdzenia]` u autora repo.

## 5. Koszty

Region: `eu-central-1` (zgodnie z `.claude/CLAUDE.md`). Wartości pomocnicze z `docs/tco.md`,
oznaczone tam jako `[do weryfikacji]` — sprawdź przed szkoleniem, ceny się zmieniają.

| Zasób z tego modułu | Koszt | Uwaga |
|---|---|---|
| VPC, podsieci, route table, Internet Gateway | 0 USD | zasoby sieciowe bez opłaty godzinowej same w sobie |
| `aws_security_group` + reguły ingress/egress | 0 USD | brak opłaty za samą regułę |
| Bucket S3 (`aws_s3_bucket.artefakty`) | „groszowe przy tej skali, <0,10 USD" wg `docs/tco.md` | rośnie z liczbą i rozmiarem artefaktów; lifecycle w module kasuje obiekty po 30 dniach (7 dni dla starych wersji), co ogranicza narastanie kosztu |
| Transfer danych przez Internet Gateway | zależny od ruchu, brak stałej opłaty | moduł nie tworzy NAT Gateway (koszt 0,052 USD/h + za GB z `docs/tco.md`) — podsieć prywatna nie ma dziś wyjścia do internetu |

Ten moduł sam w sobie **nie generuje istotnego kosztu godzinowego** — w przeciwieństwie do
EKS control plane (0,10 USD/h) czy węzłów EC2/NAT Gateway/ALB z `docs/tco.md`, których ten
moduł nie tworzy. Realny koszt zależy od tego, co zostanie dołożone na tej sieci (węzły,
NAT, load balancer) i od ilości/czasu przechowywania artefaktów w buckecie. Tag `Usuwac = tak`
na każdym zasobie (wymagany przez `CLAUDE.md`) ułatwia prowadzącemu odnalezienie i posprzątanie
zapomnianych zasobów po szkoleniu, co w `docs/tco.md` jest wskazane jako główne źródło
niepotrzebnych kosztów.

## 6. Podsumowanie

Używaj tego modułu jako referencyjnego punktu startowego pod `quotes-api` (bucket + sieć + SG)
albo jako wzorca przy ocenie kodu wygenerowanego przez AI w Bloku 1. Sam w sobie jest tani —
uważaj raczej na to, co się do niego dołoży (węzły, NAT Gateway, ALB) oraz na to, że moduł
**świadomie** nie przechodzi skanerów na zero (patrz tabela w `README.md`) — nie traktuj
pozostałych zgłoszeń `checkov`/`trivy` jako błędów do naprawienia bez zastanowienia.
