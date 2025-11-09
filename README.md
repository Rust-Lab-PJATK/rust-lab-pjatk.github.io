# Rust Lab PJATK — strona koła naukowego

Repozytorium zawiera kod źródłowy statycznej strony koła Rust Lab PJATK. Strona jest generowana przy użyciu generatora [Zola](https://www.getzola.org/) i motywu [tabi](https://github.com/welpo/tabi), a treści blogowe znajdują się w katalogu `content/blog`.

## Wymagania lokalne

- Zola `>= 0.19` (instalacja: `cargo install zola` lub [instrukcja na stronie projektu](https://www.getzola.org/documentation/getting-started/installation/))
- Opcjonalnie: przeglądarka do podglądu lokalnego (`zola serve` startuje serwer na porcie 1111)

## Podgląd lokalny

```bash
zola serve
```

Polecenie buduje stronę w trybie developerskim i udostępnia ją pod adresem `http://127.0.0.1:1111`. Zmiany w plikach Markdown, szablonach i stylach są odświeżane na żywo.

## Jak dodać nowy wpis na bloga

1. **Przygotuj plik Markdown**
   - Utwórz nowy plik w katalogu `content/blog`, np. `content/blog/moj-wpis.md`.
   - Nazwa pliku w formacie *kebab-case* staje się częścią adresu URL: `moj-wpis` → `/blog/moj-wpis/`.

2. **Uzupełnij nagłówek (front matter)**
   - Każdy wpis korzysta z formatu TOML, umieszczonego pomiędzy trzema plusami `+++`.
   - Przykładowy szablon:

     ```toml
     +++
     title = "Tytuł wpisu"
     date = 2025-11-02
     draft = true
     description = "Krótki opis, widoczny na liście wpisów i w meta tagach."
     authors = ["Imię Nazwisko"]

     [taxonomies]
     tags = ["tag-1", "tag-2"]
     +++

     Wprowadzenie do wpisu...
     ```

   - **title** – pełny tytuł artykułu.
   - **date** – data publikacji w formacie `YYYY-MM-DD`; decyduje o kolejności na liście wpisów.
   - **draft** – ustaw `true`, dopóki wpis nie jest gotowy do publikacji; przed mergem zmień na `false` lub usuń pole.
   - **description** – krótka zajawka (1‑2 zdania); pomaga w SEO i podglądach w mediach społecznościowych.
   - **authors** – lista autorów (imiona i nazwiska). Możesz podać kilka osób, np. `["Jan Kowalski", "Anna Nowak"]`.
   - **tags** – istniejące lub nowe tagi (małe litery, bez polskich znaków ułatwiają filtrowanie).

3. **Dodaj zasoby statyczne (opcjonalnie)**
   - Umieść obrazy w `static/img/<slug-wpisu>/`, np. `static/img/moj-wpis/zdjecie.jpg`.
   - Odwołuj się do nich w treści przez absolutną ścieżkę: `![Opis alternatywny](/img/moj-wpis/zdjecie.jpg)`.
   - Pamiętaj o opisach ALT i rozsądnej kompresji plików graficznych.

4. **Sprawdź wpis lokalnie**
   - Uruchom `zola serve` i odwiedź `http://127.0.0.1:1111/blog/`.
   - Upewnij się, że nagłówki, kod, obrazy i linki renderują się poprawnie.

5. **Przygotuj wpis do publikacji**
   - Usuń lub ustaw `draft = false`.
   - Zadbaj o poprawne formatowanie Markdown (nagłówki `##`, listy, wyróżnienia).
   - Dołącz pliki graficzne do commita wraz z nowym wpisem.

6. **Otwórz Pull Request**
   - Wyślij zmiany w osobnej gałęzi, opisz krótko nowy wpis i poproś o review.

Po wdrożeniu wpis pojawi się automatycznie w blogu oraz na stronie archiwum (`/archiwum/`), zgodnie z datą publikacji i przypisanymi tagami.

## Docker

Poniżej znajdziesz przykładowe kroki budowania obrazu Docker, który generuje stronę za pomocą Zola podczas etapu build i serwuje ją przez Nginx.

- Domyślna komenda buduje używając pliku konfiguracyjnego `config.toml` (domyślnie ustawionego w `Dockerfile`):

```bash
docker build -t rustlab-page:latest .
```

- Aby użyć innego pliku konfiguracyjnego przekaż go jako build-arg `ZOLA_CONFIG`:

```bash
docker build --build-arg ZOLA_CONFIG=some-other-config.toml -t rustlab-page:latest .
```

- Uwaga dotycząca motywu (`themes/tabi`): motyw jest dołączony jako submodule Git. Upewnij się, że submoduły zostały zainicjalizowane przed budowaniem obrazu (w przeciwnym razie Zola nie znajdzie `theme.toml` i build zakończy się niepowodzeniem):

```bash
# jeśli już sklonowałeś repozytorium
git submodule update --init --recursive

# lub przy klonowaniu
git clone --recurse-submodules <repo-url>
```

- Po zbudowaniu obrazu możesz go uruchomić lokalnie i przekierować port 80 kontenera na inny port hosta:

```bash
docker run --rm -p 8080:80 rustlab-page:latest
# potem odwiedź http://localhost:8080
```

W środowiskach CI/CD pamiętaj, by klonować repozykotorium z submodułami lub wykonać `git submodule update --init --recursive` przed etapem budowania obrazu.
