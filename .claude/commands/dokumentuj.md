---
description: Udokumentuj krok, czynność albo zasób w ustandaryzowanym formacie
---

Przedmiot dokumentacji: $ARGUMENTS (plik, komenda, moduł Terraform, krok w pipeline,
zasób AWS, skrypt — cokolwiek zostało wskazane).

Zanim zaczniesz pisać, zbierz materiał — nie zgaduj:
- jeśli to plik/moduł/skrypt: przeczytaj go w całości
- jeśli to krok CI/CD: znajdź i przeczytaj odpowiedni workflow/job w `.github/workflows/`
- jeśli to zasób Terraform/AWS: sprawdź jego definicję, zmienne wejściowe i miejsca użycia
- jeśli czegoś nie da się ustalić z repo, napisz „brak danych w repo" zamiast zgadywać

Napisz dokumentację w tej strukturze, po polsku, nazwy techniczne (funkcje, flagi,
zasoby AWS, polecenia) bez tłumaczenia:

1. **Opis** — czym to jest, w 2–3 zdaniach, bez żargonu i bez powtarzania nazwy z nagłówka
2. **Do czego** — jaki problem to rozwiązuje i po co to istnieje w tym repo/pipeline;
   jedno zdanie, co by się stało, gdyby tego zabrakło
3. **Przykłady użycia** — konkretne, uruchamialne polecenia albo fragmenty kodu wzięte
   z tego repo (albo takie, które faktycznie by w nim zadziałały) — nie pseudo-kod
4. **Alternatywa** — co można by zrobić zamiast tego i dlaczego wybrano to rozwiązanie
   zamiast niej; jeśli uzasadnienia nie ma w repo (komentarz, README, commit), napisz to
   wprost zamiast wymyślać powód
5. **Koszty** — koszt uruchomienia/utrzymania tam, gdzie ma to sens: pieniądze (AWS,
   region `eu-central-1`), czas (minuty CI), tokeny AI. Liczb, których nie jesteś pewien,
   nie zaokrąglaj w ciemno — oznacz `[do sprawdzenia]`
6. **Podsumowanie** — 2–3 zdania: kiedy tego używać, na co uważać, z czym to się wiąże

Zasada twarda: każdy przykład w sekcji 3 musi być czymś sprawdzonym — istniejącym plikiem,
poleceniem, które faktycznie istnieje w tym repo. Wynik zapisz jako plik `.md` obok
przedmiotu dokumentacji (albo tam, gdzie wskaże użytkownik), nie tylko w odpowiedzi na czacie.
