+++
title = "Konsolowy program do steganografii obrazowej - część 1"
draft = true
date = 2025-03-23
description = ""
authors = ["Maciej Pędzich"]

[taxonomies]
tags = ["miniprojekt", "cli", "steganografia"]
+++

## Czym jest steganografia?

Wyobraź sobie następujący scenariusz: w twoim posiadaniu znajdują się pytania wraz z kluczem odopowiedzi do egzaminu z przedmiotu spędzającego sen z powiek wszystkich studentów.

Chcesz podzielić się tą zakazaną wiedzą z kolegą/koleżanką z roku, ale jedyny sposób, w który możesz to zrobić wymaga użycia kanału będącego pod ścisłym nadzorem uczelni. Mało tego, wszelkie próby wysłania zaszyfrowanej wiadomości tekstowej zostają automatycznie oznaczone jako podejrzane.

Na szczęście, przez ten hipotetyczny kanał można również wysyłać cyfrowe obrazy. Rzecz jasna system sprawdza czy dany obraz nie przedstawia nieodpowiednich lub nielegalnych treści, ale to w zasadzie tyle. Nietrudno więc wpaść na pomysł ukrycia wiadomości wenątrz dzieła sztuki albo malowniczego krajobrazu.

Okazuje się, że istnieje cała nauka o prowadzeniu komunikacji w taki sposób, żeby strona trzecia nie domyśliła się faktu jej występowania. Mowa o **steganografii**, której wolne tłumaczenie z języka greckiego oznacza **ukryte pismo**.

## Rozkład tematyczny miniserii

W tej miniserii artykułów przedstawię jak napisać aplikację działającą z poziomu wiersza poleceń, umożliwiającą zarówno odczytywanie jak i zapisywanie wiadomości tekstowych w plikach graficznych formatu [Windows Bitmap](https://en.wikipedia.org/wiki/BMP_file_format) oraz [Quite OK Image](https://qoiformat.org/).

Część pierwsza będzie poświęcona opisaniu specyfikacja działania programu, przetwarzaniu dostarczonych przez użytkownika parametrów, a także implementacji wsparcia dla pierwszego z wymienionych formatów. Natomiast część druga będzie przeznaczona wyjaśnieniu zasad działania drugiego z formatów i dodaniu dla niego wszystkich funkcjonalności.

## Specyfikacja działania programu

Ustalmy jasny sposób zachowania naszej aplikacji i opracujmy sposób zapisu wiadomości wewnątrz obrazu.

### Parametry

Nasz program powinien przyjmować jako poprawne argumenty kolejno:

- jedną z wzajemnie wykluczających się flag operacji:
  - `--encode` (skrótowo `-e`) w celu zapisania wiadomości kodowanej UTF-8 podanej tuż po fladze
  - `--decode` (skrótowo `-d`) w celu odczytania wiadomości z pliku i wyświetlenia jej na ekranie
  - `--help` (skrótowo `-h`) w celu wypisania informacji o programie i sposobie jego użycia
- ścieżkę do pliku obrazu (nie obowiązuje przy wprowadzeniu `--help`)

Uruchomienie programu bez argumentów powinno być równoznaczne z użyciem flagi `--help`. Z kolei w przypadku podania niewłaściwej liczby parametrów dla danej flagi, należy wyświetlić jej prawidłową składnię.

Dodatkowo, jeśli rozszerzenie pliku jest różne od `.bmp` i `.qoi`, program powinien poinformować użytkownika o wykryciu nieobsługiwanego formatu.

### Sposób ukrywania wiadomości

Większość współczesnych monitorów wykorzystuje [standard sRGB](https://pl.wikipedia.org/wiki/SRGB) do przedstawiania informacji o kolorach. Barwa każdego piksela jest reprezentowana przez proporcje trzech składowych: czerwieni, zieleni oraz błękitu. Każdą z nich zapisuje się jako ośmiobitową liczbę całkowitą bez znaku.

Podobnie sprawa ma się w przypadku wcześniej wspomnianych rodzajów plików graficznych, przy czym QOI oferuje także przechowywanie informacji o czwartej składowej (znanej jako [kanał alfa](https://keylight.com.pl/fundamenty-grafiki-kanal-alfa)) do określenia stopnia przezroczystości danego piksela. Wartość 0 oznacza pełną przezroczystość, zaś 255 pełną widoczność barwy.

Jak zatem ukryć wewnątrz tych danych wartości poszczególnych znaków kodowych wiadomości tekstowej? Najprostszą strategię stanowi nadpisywanie najmłodszych bitów kolejnych składowych bitami z bajtów wiadomości, rozpoczynając kodowanie od najmłodszego bitu pierwszego bajtu wiadomości i kończąc na najstarszym bicie w ostatnim bajcie komunikatu.

## Zewnętrzne biblioteki

Chciałbym teraz przedstawić trzy skrzynki, które znacząco ułatwią nam życie w poszczególnych aspektach tworzenia naszej aplikacji.

### `clap` - przetwarzanie i walidacja argumentów

Implementacja mechanizmu obrabiającego [surowe parametry](https://doc.rust-lang.org/beta/std/env/fn.args.html) bez użycia zewnętrznych narzędzi nie powinna być zbyt skomplikowana biorąc pod uwagę nasze wymagania.

Mimo to warto zapoznać się z [biblioteką `clap`](https://crates.io/crates/clap) ze względu na możliwość określania spodziewanych argumentów i flag z użyciem [wzorca budowniczego](https://docs.rs/clap/latest/clap/_tutorial/index.html) albo [struktur z atrybutami](https://docs.rs/clap/latest/clap/_derive/_tutorial/index.html). W tym artykule zaprezentuję drugi z wymienionych sposobów.

### `binrw` - wczytywanie danych binarnych do struktur

Choć w tym projekcie będziemy wykonywali wiele operacji na _właściwych_ bajtach obrazu, tak pliki obu interesujących nas formatów (i nie tylko) posiadają nagłówek składający się z unikatowej sygnatury formatu oraz pewnych metadanych dla grafiki.

Do tych metadanych zaliczamy między innymi wymiary obrazu, liczbę składowych, czy liczbę bitów na piksel. Ponadto, część z tych pól nagłówka może przyjmować tylko wybrane wartości.

todo.

### `anyhow` - ergonomiczna obsługa błędów

Test.
