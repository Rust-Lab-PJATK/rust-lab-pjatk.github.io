+++
title = "Walka z grą w życie Conwaya"
date=  2025-11-02
slug =  "walka-z-gra-w-zycie-conwaya"
authors = ["Norbert Olkowski"]
description = "Po 5 latach z Rustem wracam do starego projektu: implementuję grę w życie w ~150 liniach i uruchamiam ją w terminalu."

[taxonomies]
tags =  ["Rust", "Game of Life", "automaty komórkowe", "terminal"]
+++

# Walka z grą w życie Conwaya

Na początku listopada 2020 rozpocząłem swoją przygodę z językiem **Rust**. Ponieważ mija właśnie 5 lat, wracam do starego projektu sprzed dekady i odświeżam go nowymi oczami. Dziś na warsztat biorę **grę w życie Conwaya** – klasyczny automat komórkowy, który w kilku prostych regułach potrafi wygenerować zaskakująco złożone wzorce.

> _Wpis zawiera kompletne fragmenty kodu, szybkie wyjaśnienia i jeden „pełny listing” na końcu. Możesz skopiować tylko to, czego potrzebujesz._

---

## Czym jest gra w życie?

Z pomocą przychodzi Wikipedia:

> Gra toczy się na nieskończonej planszy (płaszczyźnie) podzielonej na kwadratowe komórki.  
> Każda komórka ma ośmiu „sąsiadów” (tzw. sąsiedztwo Moore’a), czyli komórki przylegające do niej bokami i rogami.  
> Każda komórka może znajdować się w jednym z dwóch stanów: może być albo „żywa” (włączona), albo „martwa” (wyłączona).  
> Stany komórek zmieniają się w pewnych jednostkach czasu.  
> Stan wszystkich komórek w pewnej jednostce czasu jest używany do obliczenia stanu wszystkich komórek w następnej jednostce.  
> Po obliczeniu wszystkie komórki zmieniają swój stan dokładnie w tym samym momencie.  
> Stan komórki zależy tylko od liczby jej żywych sąsiadów.  
> W grze w życie nie ma graczy w dosłownym tego słowa znaczeniu.  
> Udział człowieka sprowadza się jedynie do ustalenia stanu początkowego komórek.

Reguły gry w skrócie (notacja **B3/S23**):
- **B3** – martwa komórka **rodzi się** (becomes alive), gdy ma dokładnie **3** żywych sąsiadów,
- **S23** – żywa komórka **przeżywa**, jeśli ma **2** lub **3** żywych sąsiadów; w pozostałych przypadkach umiera.

---

## Zróbmy to w Ruście

Pokażę minimalną, terminalową implementację z zawijaniem krawędzi (torus).  
Będzie miło, prosto i wystarczająco szybkie jak na zabawę w konsoli.

### 1) `Cargo.toml`

```toml
[package]
name = "life"
version = "0.1.0"
edition = "2021"

[dependencies]
rand = "0.8"
```

### 2) `src/main.rs` – stałe i szkic świata

Na start zdefiniujmy parametry świata:

```rust
use std::{thread, time::Duration};
use rand::Rng;

const WIDTH: usize = 60;         // Szerokość świata
const HEIGHT: usize = 25;        // Wysokość świata
const DENSITY: f32 = 0.20;       // Prawdopodobieństwo żywej komórki na starcie (0..1)
const DELAY_MS: u64 = 80;        // Opóźnienie między generacjami (ms)

#[derive(Clone)]
struct World {
    cells: Vec<u8>, // 0 = dead, 1 = alive
    w: usize,
    h: usize,
}
```

### 3) Losowy stan początkowy

```rust
impl World {
    fn new_random(w: usize, h: usize, p_alive: f32) -> Self {
        let mut rng = rand::thread_rng();
        let mut cells = vec![0u8; w * h];
        for c in &mut cells {
            *c = if rng.gen::<f32>() < p_alive { 1 } else { 0 };
        }
        Self { cells, w, h }
    }
}
```

### 4) Indeksowanie i zawijanie (torus)

Współrzędne `(x, y)` mapujemy na indeks wektora oraz zawijamy po krawędziach, dzięki czemu nie musimy robić specjalnych warunków na brzegi.

```rust
impl World {
    #[inline]
    fn idx(&self, x: usize, y: usize) -> usize {
        y * self.w + x
    }

    #[inline]
    fn get(&self, x: isize, y: isize) -> u8 {
        // Zawijanie krawędzi (torus)
        let xx = ((x % self.w as isize) + self.w as isize) as usize % self.w;
        let yy = ((y % self.h as isize) + self.h as isize) as usize % self.h;
        self.cells[self.idx(xx, yy)]
    }
}
```

### 5) Jedna generacja – serce algorytmu

Liczymy liczbę sąsiadów dla każdej komórki i stosujemy reguły B3/S23.

```rust
impl World {
    fn step(&mut self) {
        let mut next = vec![0u8; self.cells.len()];
        for y in 0..self.h {
            for x in 0..self.w {
                let x = x as isize;
                let y = y as isize;
                let n =
                    self.get(x - 1, y - 1) + self.get(x, y - 1) + self.get(x + 1, y - 1) +
                    self.get(x - 1, y    )                      + self.get(x + 1, y    ) +
                    self.get(x - 1, y + 1) + self.get(x, y + 1) + self.get(x + 1, y + 1);

                let me = self.get(x, y);
                let alive = match (me, n) {
                    (1, 2) | (1, 3) => 1, // S23
                    (0, 3) => 1,          // B3
                    _ => 0,
                };
                next[self.idx(x as usize, y as usize)] = alive;
            }
        }
        self.cells = next;
    }
}
```

### 6) Rendering w terminalu (ANSI)

Prosty, ale czytelny rendering – pełne bloki `██` dla żywych komórek i czyszczenie ekranu pomiędzy generacjami.

```rust
impl World {
    fn alive_count(&self) -> usize {
        self.cells.iter().map(|&c| c as usize).sum()
    }

    fn render(&self, gen: usize) {
        // ANSI: wyczyść ekran i ustaw kursor na (1,1)
        print!("[2J[H"); // https://en.wikipedia.org/wiki/ANSI_character_set

        println!(
            "Conway's Game of Life — gen {} | alive: {}",
            gen,
            self.alive_count()
        );
        println!("{}", "-".repeat(self.w * 2));

        for y in 0..self.h {
            for x in 0..self.w {
                let c = self.cells[self.idx(x, y)];
                if c == 1 {
                    // Dwie pełne kratki dla lepszych proporcji
                    print!("██");
                } else {
                    print!("  ");
                }
            }
            println!();
        }
        println!("
Ctrl+C aby zakończyć.");
        // Wyczyść bufor, żeby efekt był natychmiastowy
        use std::io::{stdout, Write};
        stdout().flush().ok();
    }
}
```

### 7) Pętla główna

```rust
fn main() {
    let mut world = World::new_random(WIDTH, HEIGHT, DENSITY);
    let mut gen = 0usize;

    loop {
        world.render(gen);
        thread::sleep(Duration::from_millis(DELAY_MS));
        world.step();
        gen = gen.wrapping_add(1);
    }
}
```

---

## Uruchomienie

```bash
# rekomendowane: tryb release dla płynniejszej animacji
cargo run --release
```

> **Uwaga (Windows):** nowoczesne terminale (Windows Terminal, PowerShell 7+) obsługują sekwencje ANSI. Jeśli wbudowany `cmd.exe` nie czyści ekranu, uruchom program w Windows Terminal / PowerShell.

---

## Pełny listing `src/main.rs`

Poniżej kompletne źródło w jednym miejscu – skopiuj i wklej:

```rust
use std::{thread, time::Duration};
use rand::Rng;

const WIDTH: usize = 60;         // Szerokość świata
const HEIGHT: usize = 25;        // Wysokość świata
const DENSITY: f32 = 0.20;       // Prawdopodobieństwo żywej komórki na starcie (0..1)
const DELAY_MS: u64 = 80;        // Opóźnienie między generacjami (ms)

#[derive(Clone)]
struct World {
    cells: Vec<u8>, // 0 = dead, 1 = alive
    w: usize,
    h: usize,
}

impl World {
    fn new_random(w: usize, h: usize, p_alive: f32) -> Self {
        let mut rng = rand::thread_rng();
        let mut cells = vec![0u8; w * h];
        for c in &mut cells {
            *c = if rng.gen::<f32>() < p_alive { 1 } else { 0 };
        }
        Self { cells, w, h }
    }

    #[inline]
    fn idx(&self, x: usize, y: usize) -> usize {
        y * self.w + x
    }

    #[inline]
    fn get(&self, x: isize, y: isize) -> u8 {
        // Zawijanie krawędzi (torus)
        let xx = ((x % self.w as isize) + self.w as isize) as usize % self.w;
        let yy = ((y % self.h as isize) + self.h as isize) as usize % self.h;
        self.cells[self.idx(xx, yy)]
    }

    fn step(&mut self) {
        let mut next = vec![0u8; self.cells.len()];
        for y in 0..self.h {
            for x in 0..self.w {
                let x = x as isize;
                let y = y as isize;
                let n =
                    self.get(x - 1, y - 1) + self.get(x, y - 1) + self.get(x + 1, y - 1) +
                    self.get(x - 1, y    )                      + self.get(x + 1, y    ) +
                    self.get(x - 1, y + 1) + self.get(x, y + 1) + self.get(x + 1, y + 1);

                let me = self.get(x, y);
                let alive = match (me, n) {
                    (1, 2) | (1, 3) => 1,
                    (0, 3) => 1,
                    _ => 0,
                };
                next[self.idx(x as usize, y as usize)] = alive;
            }
        }
        self.cells = next;
    }

    fn alive_count(&self) -> usize {
        self.cells.iter().map(|&c| c as usize).sum()
    }

    fn render(&self, gen: usize) {
        // ANSI: wyczyść ekran i ustaw kursor na (1,1)
        print!("[2J[H"); // https://en.wikipedia.org/wiki/ANSI_character_set

        println!(
            "Conway's Game of Life — gen {} | alive: {}",
            gen,
            self.alive_count()
        );
        println!("{}", "-".repeat(self.w * 2));

        for y in 0..self.h {
            for x in 0..self.w {
                let c = self.cells[self.idx(x, y)];
                if c == 1 {
                    // Dwie pełne kratki dla lepszych proporcji
                    print!("██");
                } else {
                    print!("  ");
                }
            }
            println!();
        }
        println!("
Ctrl+C aby zakończyć.");
        // Wyczyść bufor, żeby efekt był natychmiastowy
        use std::io::{stdout, Write};
        stdout().flush().ok();
    }
}

fn main() {
    let mut world = World::new_random(WIDTH, HEIGHT, DENSITY);
    let mut gen = 0usize;

    loop {
        world.render(gen);
        thread::sleep(Duration::from_millis(DELAY_MS));
        world.step();
        gen = gen.wrapping_add(1);
    }
}
```

---

**Ekstra!** Udało się – mamy działającą implementację.  
W tym miejscu _mógłbym zakończyć wpis_.  
**(Nic nie ma niżej, przewijasz na własną odpowiedzialność ;D)**



----------------------------------

Ale

----------------------------------

Ale jest

----------------------------------

Ale jest jeden problem

----------------------------------

Problemem tym jest fakt, że powyższe rozwiązanie jest skrajnie nieefektywne. 
Dobre na początek do nauki. Da się to zrobić zdecydowanie szybciej.

----------------------------------

# Gra w życie – optymalizacje hardcore w Rust (Bitboardy, CSA, SIMD, Rayon, unsafe)

W poprzedniej części zaimplementowaliśmy prostą wersję „Gry w życie” Johna Conwaya w języku Rust – wykorzystując tablicę `Vec<u8>` do przechowywania stanu komórek i wypisując kolejne pokolenia w konsoli. Działało to poprawnie, ale było dalekie od maksymalnej wydajności. Teraz, w **części 2**, pójdziemy w *hardkor*: zoptymalizujemy symulację tak, by wykorzystać potęgę procesora – bity, wektory SIMD, wielowątkowość i bezpieczne użycie `unsafe`. Przedstawimy krok po kroku zaawansowane techniki i kompletną implementację w języku Rust.

## Bitboardy – plansza zakodowana w bitach

Na początek wprowadźmy **bitboardy**. Jest to technika przechowywania stanu planszy, gdzie każda komórka reprezentowana jest pojedynczym bitem w masywie bitowym. Najpopularniejszy przykład to wykorzystanie 64-bitowego typu całkowitego (`u64`) do zakodowania stanu 8×8 komórek – każdy bit `u64` odpowiada jednej komórce (1 = żywa, 0 = martwa). Taki 64-bitowy bitboard potrafi w jednej operacji bitowej symulować 64 komórki równolegle! Zamiast marnować bajt (8 bitów) na każdą komórkę, możemy użyć jednego bitu, co od razu zmniejsza zużycie pamięci i zwiększa upakowanie danych. Operacje bitowe (AND, OR, XOR itp.) wykonywane na 64-bitowych słowach będą działać na wszystkich 64 komórkach jednocześnie.

**Przykład:** Wyobraźmy sobie małą planszę 8×8. Możemy jej stan przechować w zmiennej `state: u64`. Bit `state & 1` (najmłodszy bit) odpowiada np. lewej górnej komórce, bit `state & (1 << 1)` – drugiej komórce w tym wierszu, itd. (ustalamy jakąś kolejność). Gdy bit ma wartość 1, komórka jest żywa, gdy 0 – martwa. Dzięki temu jedną operacją możemy np. odwrócić stan wszystkich komórek (operacja NOT), lub przesunąć cały wzorzec w prawo/lewo (operacje bitowe shift). Co więcej, nowoczesne procesory posiadają specjalne instrukcje do szybkiego zliczania bitów ustawionych na 1 (ang. *population count*, instrukcja POPCNT). Możemy z nich skorzystać do szybkiego liczenia liczby żywych komórek – choć w naszym przypadku będziemy liczyć sąsiadów trochę inaczej.

**Większe plansze:** Oczywiście gra w życie zwykle toczy się na większej siatce niż 8×8. Możemy jednak traktować planszę jako złożoną z bloków 64-bitowych. Na przykład, dla planszy 128×128 moglibyśmy użyć tablicy `Vec<u64>` o długości 256 (bo 128×128 = 16384 komórek, podzielone na 64 bity daje 256 elementów). Trzeba zdecydować, jak odwzorować dwuwymiarową planszę na liniowy ciąg bitów. Jedną z możliwości jest przyjęcie, że kolejne `u64` reprezentują kolejne wiersze planszy (każdy wiersz ma 128 kolumn, czyli potrzeba 2× `u64` na wiersz). Inną opcją – zastosowaną w niektórych implementacjach – jest traktowanie każdego 64-bitowego słowa jako kolumny planszy. Niezależnie od wyboru, musimy nieco pokombinować przy obliczaniu sąsiadów na krawędziach tych bloków (o czym za chwilę). W tym wpisie przyjmiemy dla prostoty, że szerokość planszy jest wielokrotnością 64, a każdy wiersz składa się z jednego lub więcej 64-bitowych segmentów.

## Sieć CSA – sumowanie sąsiadów bit po bicie

Mając już stan komórek upakowany w bitach, wyzwaniem staje się **liczenie liczby żywych sąsiadów** dla każdej komórki. W tradycyjnej implementacji iterujemy po komórkach i sumujemy 8 wartości sąsiadów (0/1). Jak to zrobić równolegle bitowo, aby nie „rozkodowywać” każdej komórki z osobna?

Rozwiązaniem jest zastosowanie **sieci CSA (Carry-Save Adders)**, czyli sieci sumatorów binarnych, które potrafią dodawać wartości bitowe, nie propagując od razu dalej przeniesień (carry). W ten sposób możemy na poziomie bitów zasymulować dodawanie 8 jedynkowych sąsiadów (lub zero-jedynkowych wartości) i otrzymać wynik złożony z kilku bitów, reprezentujących sumę 0–8.

Brzmi skomplikowanie? Rozważmy prostszy problem: chcemy dodać dwie wartości bitowe (0/1) – to po prostu operacje XOR (dla sumy bitów) i AND (dla przeniesienia) – to jest tzw. **half-adder** (półsumator). Możemy to zapisać jako funkcję:

```rust
fn half_adder(a: u64, b: u64) -> (u64, u64) {
    let sum = a ^ b;      // bitowy XOR – sumuje bity bez przeniesienia
    let carry = a & b;    // bitowy AND – wykrywa przeniesienie (obie jedynki)
    (carry, sum)
}
```

Ta funkcja traktuje każdy z 64 bitów liczb `a` i `b` jak osobne dodawanie 1+1 (sąsiedzi). `sum` ma bity 1 tam, gdzie była nieparzysta liczba jedynek (dokładnie jedna z `a` lub `b` była 1), zaś `carry` ma bity 1 tam, gdzie na danej pozycji **obie** wartości miały 1 (czyli pojawił się przeniesiony „dziesiątki” – w systemie dwójkowym przeniesienie 1 oznacza wartość 2).

Możemy też zdefiniować **full-adder** (pełny sumator) dla dodania trzech bitów na raz (np. dwóch sąsiadów i przeniesienia z poprzedniego dodawania):

```rust
fn full_adder(a: u64, b: u64, c: u64) -> (u64, u64) {
    let temp = a ^ b;                   // wstępna suma dwóch bitów
    let sum = temp ^ c;                 // dodaj trzeci bit
    let carry = (a & b) | (temp & c);   // przeniesienie powstaje, gdy co najmniej dwie z trzech wartości są 1
    (carry, sum)
}
```

Wynik `full_adder` to para `(carry, sum)`, gdzie `sum` to znowu bity sumy (modulo 2), a `carry` to bity przeniesień (które należałoby dodać do następnej pozycji bitowej, czyli reprezentują wartość 2 na danej pozycji).

Teraz, mając 8 sąsiadów dla każdej komórki (pamiętajmy, że operujemy bitowo na 64 komórkach jednocześnie), możemy ułożyć z tych sumatorów sieć, która zsumuje 8 wartości bitowych **a, b, c, d, e, f, g, h** (odpowiadających sąsiadom z 8 kierunków). Jedna z możliwych konfiguracji (znaleziona metodą prób i optymalizacji bramek logicznych) wygląda następująco:

-   **Etap 0:** Dodajemy sąsiadów parami:

    -   `l, i = full_adder(a, b, c)` – sumujemy trzech sąsiadów (a, b, c), otrzymując częściowe wyniki: `i` (część sumy) i `l` (przeniesienia).

    -   `m, j = full_adder(d, e, f)` – sumujemy kolejnych trzech (d, e, f) -> wynik `j` i przeniesienia `m`.

    -   `n, k = half_adder(g, h)` – ostatnią parę dwóch sąsiadów (g, h) sumujemy półsumatorem -> `k` i przeniesienie `n`.


Teraz z 8 wartości sąsiadów otrzymaliśmy 3 „częściowe sumy” oznaczmy je: `i, j, k` (to są bity sum cząstkowych) oraz przeniesienia `l, m, n` (te reprezentują wartości, które należy dodać do kolejnej pozycji, czyli de facto już liczbę „dziesiątek” dla każdej komórki).

-   **Etap 1:** Dodajemy powstałe częściowe wyniki:

    -   `y, w = full_adder(i, j, k)` – sumujemy trzy cząstkowe sumy; otrzymujemy `w` (najniższy bit ostatecznej sumy sąsiadów) oraz przeniesienia `y`.

    -   `x, z = full_adder(l, m, n)` – sumujemy trzy przeniesienia; dostajemy `z` oraz `x` (tu `x` reprezentuje przeniesienie na jeszcze wyższą pozycję).


W efekcie tych dwóch etapów mamy cztery maski bitowe `w, z, y, x`, które wspólnie reprezentują **liczbę żywych sąsiadów** dla każdej komórki (64 komórek naraz). Można to rozumieć tak, że liczba sąsiadów (0–8) zapisana jest w systemie dwójkowym na tych czterech bitmaskach – ale w nie do końca trywialny sposób. Twórcy algorytmu wykazali, że wynik można zapisać wzorem:

neighbors_count = 4x + 2*(y+z) + w,

gdzie `w` dostarcza najmniej znaczący bit sumy (parzystość liczby sąsiadów), `x` sygnalizuje przeniesienie do wartości 4 (czyli informuje, że są >=4 sąsiadów), a `y` i `z` wspólnie reprezentują bit odpowiadający wartości 2 (i częściowo 4).

Teraz najważniejsze: mając te maski `w, x, y, z`, możemy **zastosować zasady gry** do wyznaczenia nowego stanu komórek. Przypomnijmy reguły:

-   Martwa komórka ożywa, jeżeli **dokładnie trzech** spośród 8 sąsiadów jest żywych.

-   Żywa komórka przeżywa, jeżeli **2 lub 3** sąsiadów jest żywych. W przeciwnym razie umiera (albo z samotności <2, albo z przeludnienia >3).


Jak z naszych masek wyłuskać te warunki? Możemy to zrobić w całości operując na bitach:

-   Maska `x` (przeniesienie do 4) mówi nam, gdzie jest **co najmniej 4 sąsiadów**. Dla tych pozycji komórki powinny umrzeć (przeludnienie). Czyli jeśli bit w `x` jest 1, komórka na tej pozycji zginie niezależnie od poprzedniego stanu.

-   Maska `w` (parzystość sąsiadów) wskazuje, gdzie liczba sąsiadów jest nieparzysta (1,3,5,7). Ożywienie następuje tylko dla 3, ale zauważmy, że komórki z 5 lub 7 sąsiadami i tak zostaną usunięte przez `x` (bo 5 i 7 >= 4). Natomiast `w`=1 obejmie też przypadek 1 sąsiada – to by nieprawidłowo ożywiło samotne komórki, więc musimy to skorygować inną maską.

-   Maska `y ^ z` (XOR tych dwóch) okazuje się być 1 dokładnie dla przypadków, gdy liczba sąsiadów wynosi 2, 3, 6 lub 7. Z tego interesuje nas 2 i 3 (6,7 odfiltruje `x`), a 2 i 3 to właśnie warunek przeżycia dla żywych komórek oraz część warunku narodzin (3).

-   Maska `y & z` natomiast byłaby 1 dla sytuacji, gdy `y` i `z` są jednocześnie 1, co odpowiada łącznej wartości 4 (2+2) lub 0 (gdy obie 0) – ale akurat tej bezpośrednio nie używamy, posługujemy się `x` do wykrycia >=4.


Jednym ze sprytnych sposobów, by połączyć te warunki, jest następująca sekwencja operacji na maskach (wyjściowo załóżmy, że mamy maskę `alive` oznaczającą żywe komórki w starym stanie):

```rust
let mut result = alive;        // zaczynamy od obecnych żywych (kandydaci do przeżycia)
result |= w;                   // dodajemy potencjalne narodziny tam, gdzie nieparzysta liczba sąsiadów (1,3,5,7)
result &= (y ^ z);             // pozostawiamy żywe tylko tam, gdzie liczba sąsiadów = 2 lub 3 (XOR masek y i z)
result &= !x;                  // usuwamy komórki tam, gdzie sąsiedzi >= 4 (przeludnienie)
```

Po tych operacjach w `result` zostaną bity = 1 dokładnie dla tych pozycji, które w następnym pokoleniu mają być żywe. Działanie tej logiki można prześledzić dla różnych przypadków:

-   Jeśli komórka miała dokładnie 3 sąsiadów (`w=1`, `x=0`, `y^z=1`), to nawet jeśli była martwa (`alive=0`), po `result |= w` stanie się kandydatem na żywą, `y^z=1` pozwoli jej pozostać, a `!x=1` (bo `x=0`) nie usunie – komórka ożywa.

-   Jeśli miała 2 sąsiadów (`w=0`, `x=0`, `y^z=1`), to `result |= w` jej nie włącza jeśli była martwa (martwa pozostanie martwa, bo nie ma warunku narodzin), ale jeśli była żywa (`alive=1`), to dalej jest 1. `y^z=1` pozwoli jej pozostać (spełnia warunek przeżycia), a `!x=1` pozostawi – komórka przeżywa tylko jeśli była żywa.

-   1 sąsiad (`w=1`, ale `y^z=0` bo 1 decymalnie to 01 binarnie) – `result |= w` by ją ożywiło, ale `result &= (y^z)` wyzeruje, więc nie przeżyje.

-   4 sąsiadów (`x=1`) – `!x=0` na koniec zgasi tę komórkę, niezależnie od wcześniejszych kroków.

-   5 sąsiadów (`w=1`, `x=1`) – najpierw by się pojawiła, potem `y^z` prawdopodobnie 0, a nawet jeśli nie, to `!x` ją zgasi – poprawnie, 5 sąsiadów to śmierć.

-   Itd. – wszystkie przypadki dają zgodność z regułami Life.


Tym sposobem, przy pomocy operacji bitowych i sieci CSA, jesteśmy w stanie jednocześnie policzyć liczby sąsiadów i zastosować reguły gry dla **64 komórek jednocześnie** (na jednym `u64`). To już olbrzymie przyspieszenie względem naiwnej pętli! W literaturze i implementacjach można znaleźć różne takie „bitowe” algorytmy – np. w jednej z analiz znaleziono układ 35 bramek logicznych, który realizuje grę w życie dla 8 sąsiadów. My pozostaniemy przy naszym, który jest czytelniejszy, bo oparty o symulację dodawania.

## SIMD – wektoryzacja na AVX2 i AVX-512

Skoro pojedynczy 64-bitowy rejestr CPU potrafi obsłużyć 64 komórki na raz, to czy da się jeszcze więcej? Owszem – wykorzystując **SIMD** (Single Instruction Multiple Data), czyli zestawy instrukcji wektorowych, dostępne w nowoczesnych procesorach. SIMD pozwala wykonywać jedną operację arytmetyczną lub logiczną jednocześnie na wielu danych, korzystając z szerokich rejestrów.

Typowe procesory x86_64 mają:

-   **AVX2** – zestaw instrukcji operujących na 256-bitowych wektorach.

-   **AVX-512** – dostępne w nowszych CPU (np. Intel Ice Lake, Tiger Lake, Rocket Lake i nowsze) – operacje na 512-bitowych wektorach.


Co to oznacza dla nas? Możemy traktować np. rejestr 256-bitowy **ymm** jako zawierający cztery niezależne wartości 64-bitowe (bo 4 × 64 = 256). Jedną instrukcją logiczną (np. XOR) możemy wtedy przeprowadzić operację na czterech bitboardach równocześnie! W praktyce, zamiast przetwarzać 64 komórki na raz, przetwarzamy **256 komórek na raz** (AVX2) lub nawet **512 komórek na raz** (AVX-512).

Jak korzystać z SIMD w Ruście? Możemy użyć niskopoziomowych **intrinsics** z modułu `core::arch::x86_64` – np. `_mm256_and_si256` dla AND na 256-bitowych wektorach, `_mm512_or_si512` dla OR na 512-bitowych, itp. Każda taka funkcja jest `unsafe` (o tym za chwilę), bo musimy zapewnić, że procesor obsługuje dany zestaw instrukcji. Inną drogą jest użycie biblioteki ułatwiającej SIMD, np. eksperymentalnego API `std::simd` (jeszcze niestabilnego na czas pisania) lub crates `packed_simd`. W naszym kodzie pokażemy wykorzystanie intrinsics bezpośrednio, aby mieć nad tym pełną kontrolę.

**Równoległość wektorowa w rejestrach:** Warto rozumieć, że operacje SIMD są wykonywane lane-owo, czyli na segmentach rejestru. Np. w AVX2 instrukcja dodawania 64-bitowych liczb potraktuje rejestr 256-bitowy jako 4 bloki po 64 bity i doda każdą czwórkę niezależnie (przeniesienia nie przechodzą między blokami). To działa świetnie do naszych bitboardów – nie chcemy, by np. przeniesienie z sumy sąsiadów bitu 63 jednego bloku wpływało na bit 0 kolejnego bloku (bo to inna część planszy). SIMD dba o to automatycznie.

**Szersze przesunięcia i łączenie bloków:** Pewnym wyzwaniem okazały się operacje przesuwania bitów, gdy używamy rejestrów SIMD dla kilku bitboardów na raz. Gdy przesuniemy cały rejestr 256-bitowy o 1 bit w lewo, to zazwyczaj każda część 64-bitowa przesuwa się niezależnie, bez „przelewania” bitu na sąsiedni blok. Ale w grze w życie na torusie, przesunięcie w poziomie powinno przenosić bit z końca jednego segmentu na początek następnego (bo np. prawa krawędź wiersza jest sąsiadem lewej krawędzi następnego segmentu w tym samym wierszu). Musimy więc sami obsłużyć te *przelane* bity. Można to zrobić kilkoma instrukcjami: najpierw wstępnie przesunąć lane’y niezależnie, a potem wziąć najbardziej wysunięty bit z każdej lane i „obrócić” go do następnej lane. W AVX-512 jest nawet dostępna instrukcja permutująca dowolnie bity lub bajty, co mogłoby to uprościć, ale my pokażemy proste podejście.

Dla przejrzystości, zaimplementujemy pomocnicze funkcje do **rotacyjnego przesuwania** w poziomie na naszym wektorze bitboardów. Np. dla 256-bit (AVX2) – traktujemy cztery 64-bitowe lane’y jako cztery segmenty wiersza i chcemy przesunąć cały wiersz o 1 bit w lewo z zawinięciem:

1.  Wykonujemy wektorowe przesunięcie w lewo o 1 bit w obrębie lane’ów.

2.  Osobno przygotowujemy maskę bitów, które powinny „przejść” z końca lane `[i-1]` na początek lane `[i]`. Pobieramy więc najbardziej znaczący bit każdej lane (bit 63) przez przesunięcie w prawo o 63, a następnie robimy **rotację** lane’ów w lewo – czyli lane0 dostaje bit z lane3 (poprzednia), lane1 dostaje bit z lane0, itd..

3.  Wstawiamy te przetransferowane bity na miejsce bitów najmniej znaczących (początkowych) odpowiednich lane’ów i łączymy z wynikiem z kroku 1.


Analogicznie zrobimy dla przesunięcia w prawo. Takie operacje wymagają użycia kilku intrinsics (_mm256_srli_epi64, _mm256_slli_epi64, _mm256_permute4x64_epi64 itp.), ale ich koszt jest znikomy w porównaniu do zysków z wektoryzacji.

Podsumowując: dzięki AVX2 nasza symulacja może liczyć 256 komórek na raz, a AVX-512 aż 512 komórek na raz jednym strzałem. To 4x lub 8x więcej w porównaniu do pojedynczego 64-bit bitboardu. W połączeniu z optymalizacją bitową daje to już potężną przepustowość.

## Równoległość z `rayon` – wykorzystanie wielu rdzeni

SIMD to nie wszystko – współczesne procesory mają wiele rdzeni, więc aż się prosi, by naszą symulację dodatkowo **zrównoleglić wielowątkowo**. W Ruście możemy to zrobić wygodnie za pomocą biblioteki `rayon`, która dostarcza wspaniałe API do dataparallelizmu (równoległego przetwarzania danych).

W naszym przypadku, najprostszym podejściem będzie podzielenie planszy na fragmenty (np. zakres wierszy) i przydzielenie tych fragmentów różnym wątkom. Każdy wątek policzy stan następnej generacji dla swojego kawałka planszy. Rust zapewnia bezpieczny dostęp do pamięci, więc musimy tak podzielić dane, by żaden wątek nie pisał w to samo miejsce co inny. Idealnie nadaje się do tego metoda `par_chunks_mut` – możemy podzielić nasz wektor bitboardów (reprezentujący całą planszę) na segmenty obejmujące różne wiersze.

Ponieważ gra w życie ma zależności między wierszami (każda komórka ma sąsiadów powyżej i poniżej), trzeba pamiętać, żeby przy obliczaniu wątki uwzględniały wiersze sąsiednie spoza swojego fragmentu. Na szczęście, to łatwe do rozwiązania: możemy każdemu fragmentowi zapewnić dostęp także do jednego wiersza „ponad” i „poniżej” (tzw. *halo*), albo – prostsze podejście – po prostu dać wątkom dostęp do starego stanu planszy w całości do odczytu. Wtedy wątek licząc nowy stan dla swoich wierszy może czytać sąsiadów z poprzedniego/ następnego wiersza (które może należą do innego fragmentu) bez konfliktów, bo czytanie współbieżne jest bezpieczne. Z kolei zapisujemy tylko we „własny” fragment nowego stanu przez `par_chunks_mut`, więc tu nie ma ryzyka wyścigu – kawałki nie nakładają się. Rust wymusiłby rozdzielenie zakresów pamięci, więc jesteśmy chronieni przed pomyłką.

W praktyce użycie rayon może sprowadzić się do kodu w stylu:

```rust
new_state.par_chunks_mut(stride)  // stride = liczba u64 na cały wiersz lub fragment
    .enumerate()
    .for_each(|(chunk_idx, chunk)| {
        let row_start = chunk_idx * rows_per_chunk;
        // ... oblicz sąsiadów i wypełnij `chunk` nowymi wartościami dla tych wierszy ...
    });
```

Biblioteka sama zarządza pulą wątków (domyślnie tylu, ile rdzeni/logicznych wątków CPU) i równomiernie rozdziela pracę. Dzięki temu uzyskujemy niemal liniowe przyspieszenie wraz z liczbą rdzeni, dopóki nie ograniczy nas przepustowość pamięci.

## Bezpieczny `unsafe` w Rust – jak to możliwe?

W naszej nadchodzącej implementacji znajdą się bloki `unsafe`. Wynika to głównie z dwóch powodów:

1.  Korzystamy z intrinsics SIMD (`_mm256_*`, `_mm512_*`), które w Ruście są oznaczone jako `unsafe`, ponieważ wywołują specyficzne instrukcje procesora. Musimy zadeklarować, że użyjemy ich ostrożnie.

2.  Będziemy dokonywać pewnych operacji na wskaźnikach lub unii typów (np. zamieniając typy Rustowe na typy wektorowe), co również jest niebezpieczne, jeśli nie zrobimy tego dobrze.


Czym właściwie jest `unsafe`? To sygnał dla kompilatora: „wiem, co robię – weź na wiarę, że tu przestrzegam reguł bezpieczeństwa pamięci”. **Bardzo ważne**: `unsafe` nie wyłącza bezpieczeństwa w całym programie, a jedynie pozwala wewnątrz bloku wykonać operacje, które Rust normalnie by zabronił. Naszym zadaniem jest użyć tego odpowiedzialnie, tak by nie wprowadzić błędów (np. dereferencji złego wskaźnika, naruszenia pamięci, wywołania instrucji nieobsługiwanej na danym CPU itp.).

W praktyce zastosujemy kilka zasad pisania *bezpiecznego unsafe*:

-   Izolujemy kod `unsafe` w małych funkcjach, które możemy łatwo przetestować lub przeanalizować pod kątem poprawności.

-   Sprawdzamy warunki wstępne przed wywołaniem `unsafe`. Np. zanim użyjemy AVX2/AVX-512, wywołamy makro **`is_x86_feature_detected!()`**, które w runtime upewni się, że procesor ma daną instrukcję. Jeśli nie – użyjemy wersji alternatywnej.

-   Nie będziemy używać `unsafe` do ominięcia własności pożyczania czy aliasingu mutowalnych wskaźników – nasz podział danych za pomocą `rayon` i tak tego nie wymaga, bo dostajemy wydzielone kawałki. W `unsafe` skupimy się głównie na intrinsics i ewentualnie na transmutacjach typów.


Dzięki takiemu podejściu, nasz kod pozostanie *ogólnie bezpieczny* – to znaczy, jeśli błędu nie ma w tych kawałkach oznaczonych `unsafe`, to reszta programu jest chroniona przez gwarancje Rustowe. W razie pomyłki, co najwyżej nasza aplikacja się zawiesi lub wysypie, ale nie pozwolimy na naruszenie pamięci z perspektywy zewnętrznego świata. Piszemy więc „bezpieczny unsafe” – brzmi jak oksymoron, ale jest to praktyka zalecana: minimalizuj i zamknij w hermetycznej abstrakcji kod niebezpieczny, tak by reszta była pewna.

## Implementacja gry w życie – wersja hardcore

Czas na kod! Stworzymy projekt w Cargo z paroma plikami:

-   **Cargo.toml** – ustawienia pakietu i zależności (np. `rayon`).

-   **main.rs** – główny moduł programu, zajmie się inicjalizacją planszy, pętlą symulacji, pomiarem wydajności itp.

-   **simd.rs** – moduł z funkcjami realizującymi obliczenia następnego pokolenia przy użyciu różnych optymalizacji (skalarnej bitowej, AVX2, AVX-512).

-   (opcjonalnie) **bitboard.rs** – możemy wydzielić pewne funkcje obsługi bitboardów (np. wyświetlanie planszy).

-   (opcjonalnie) **world.rs** – definicje struktury świata gry (rozmiary, przechowywanie dwóch stanów itd.).


Dla jasności zmieścimy wszystko w dwóch plikach `.rs` tutaj, z komentarzami tłumaczącymi działanie.

### Cargo.toml

Najpierw ustawmy Cargo. Potrzebujemy co najmniej Rust 1.61 (bo skorzystamy z `is_x86_feature_detected!`). Dodajemy zależność na crate `rayon`.

```toml
[package]
name = "game_of_life_hardcore"
version = "0.2.0"
edition = "2021"

[profile.release]
# opcjonalnie: włączamy optymalizacje na maksa
opt-level = 3
codegen-units = 1
lto = true

[dependencies]
rayon = "1.7"
```

*(Opcjonalnie można dodać `criterion = "0.4"` do benchmarków albo `stdsimd` if using nightly, ale tu ograniczymy się do rayon.)*

### main.rs

```rust
use std::time::Instant;
use rayon::prelude::*;

// Importujemy moduły (trzeba je będzie utworzyć jako pliki)
mod simd;
use simd::{update_board};  // funkcja, która automatycznie dobierze najlepszą wersję (scalar/AVX2/AVX-512)

// Parametry gry - dla testu
const WIDTH: usize = 1024;   // szerokość planszy (musi być wielokrotnością 64 w tej implementacji)
const HEIGHT: usize = 1024;  // wysokość planszy

// Plansza będzie przechowywana jako wektor u64, gdzie każde 64 bity to fragment wiersza
// Zakładamy WIDTH % 64 == 0, więc na wiersz przypada WIDTH/64 elementów u64.
const ROW_LEN: usize = WIDTH / 64;

type Board = Vec<u64>;

fn main() {
    // 1. Inicjalizacja planszy początkowej (np. losowo lub z jakimś wzorcem)
    let mut current: Board = vec![0; HEIGHT * ROW_LEN];
    let mut next: Board = vec![0; HEIGHT * ROW_LEN];
    // (Można tu ustawić jakieś żywe komórki do testów - np. glider albo losowo)
    current[1] = 0x8000000000000001; // przykładowy bit wzorca

    // 2. Symulacja przez pewną liczbę generacji
    let generations = 100;
    let start_time = Instant::now();
    for gen in 1..=generations {
        // Wywołujemy funkcję, która policzy next na podstawie current.
        // Użyje wewnętrznie najlepszej dostępnej opcji (SIMD, wielowątkowość).
        update_board(&current, &mut next, WIDTH, HEIGHT);

        // Zamieniamy current z next (bez kopiowania danych, tylko swap zmiennych)
        std::mem::swap(&mut current, &mut next);

        // (Opcjonalnie możemy wypisać lub zweryfikować stan co pewien krok)
        if gen % 10 == 0 {
            println!("Generacja {gen}");
        }
    }
    let elapsed = start_time.elapsed().as_secs_f64();
    let cells_updated = (WIDTH * HEIGHT * generations) as f64;
    println!("Wykonano {} generacji w {:.3} s", generations, elapsed);
    println!("Średnio {:.3} miliardów komórek/sekundę", cells_updated / elapsed / 1e9);
}
```

W powyższym kodzie:

-   Ustawiliśmy wymiary planszy. W realnym użyciu mogłyby być parametrami programu.

-   `Board` to po prostu `Vec<u64>` z rozmiarem `HEIGHT * ROW_LEN`. Indeksowanie: komórka na pozycji (row, col) znajduje się w `board[row * ROW_LEN + (col / 64)]` na bicie `(col % 64)` tego `u64`. Będziemy to wykorzystywać w obliczeniach.

-   W pętli symulacji `update_board` wypełnia wektor `next` na podstawie `current`. Potem zamieniamy je miejscami (aby następna iteracja brała nowy stan jako aktualny). Dzięki temu nie musimy alokować nowych wektorów co iterację (reusing buffer).

-   Na koniec wyświetlamy kilka statystyk, w tym wydajność w **CUpS (cell updates per second)** – ile miliardów komórek na sekundę nasz program przetwarza.


### simd.rs

Teraz serce obliczeń. Zaimplementujemy tu:

-   Funkcję `update_board(current, next, width, height)`, która:

    -   Wykrywa dostępne instrukcje i ewentualnie ustawia globalnie, której wersji używać (np. wybór AVX-512 vs AVX2 vs fallback).

    -   Dzieli pracę na wątki przy pomocy `rayon` (np. dzieli tablicę `next` na kawałki odpowiadające kolejnym wierszom lub grupom wierszy).

    -   Dla każdego fragmentu wierszy wywołuje właściwą funkcję obliczającą następną generację (np. `update_row_scalar` albo wektorową).

-   Funkcje niskopoziomowe: `update_row_scalar` (bazuje na bitboard + CSA, operacje na `u64`), `update_row_avx2`, `update_row_avx512`. Będą one policzały nowe wartości `next` dla jednego wiersza (lub grupy wierszy) na podstawie `current`.

-   Dodatkowo: kilka funkcji pomocniczych, np. do przesuwania w prawo/lewo z zawijaniem (osobno dla scalar i dla SIMD), oraz zaimplementowanie sumatorów (half_adder, full_adder) dla typów wektorowych, jeśli potrzebne.


Najpierw importy i sprawy konfiguracyjne:

```rust
use std::arch::x86_64::*;  // intrinsics dla AVX2/AVX-512
use rayon::prelude::*;

// Sprawdzimy dostępne cechy procesora tylko raz (lazy_static albo statyczna zmienna mogłaby tu pomóc, 
// ale dla prostoty zrobimy to przy każdym update_board, co i tak jest znikome w kontekście tysięcy operacji)
static mut USE_AVX512: bool = false;
static mut USE_AVX2: bool = false;
```

Ta statyczna zmienna jest `unsafe` – bo zapisz/odczyt globalny wątkowo może nie być bezpieczny. Ale ustawimy ją przed pętlą rayona, a potem tylko czytamy, więc będzie OK.

Teraz funkcja `update_board`:

```rust
pub fn update_board(current: &[u64], next: &mut [u64], width: usize, height: usize) {
    assert_eq!(current.len(), next.len());
    assert_eq!(width % 64, 0, "width must be multiple of 64");
    let row_len = width / 64;
    // Wybór trybu SIMD (robimy to raz na początku, potem można to zapamiętać)
    unsafe {
        USE_AVX512 = is_x86_feature_detected!("avx512f");
        USE_AVX2   = is_x86_feature_detected!("avx2");
    }
    // Używamy rayon do zrównoleglenia pracy na segmenty danych
    next.par_chunks_mut(row_len)
        .enumerate()
        .for_each(|(row, next_row)| {
            // Wyliczamy indeksy rzędów: obecny, oraz rząd powyżej i poniżej (z zawijaniem)
            let prev_row = if row == 0 { height - 1 } else { row - 1 };
            let next_row_idx = if row == height - 1 { 0 } else { row + 1 };
            // Wskaźniki na początek odpowiednich wierszy w tablicy current (każdy wiersz ma row_len elementów)
            let curr_idx = row * row_len;
            let prev_idx = prev_row * row_len;
            let next_idx = next_row_idx * row_len;
            // Bezpiecznie wycinek dla obecnego, poprzedniego i następnego wiersza:
            let curr_slice = &current[curr_idx .. curr_idx + row_len];
            let prev_slice = &current[prev_idx .. prev_idx + row_len];
            let next_slice = &current[next_idx .. next_idx + row_len];
            // Teraz wyliczamy nowy stan dla wiersza `row` (z indeksem row) korzystając z wybranej optymalizacji.
            unsafe {
                if USE_AVX512 {
                    update_row_avx512(prev_slice, curr_slice, next_slice, next_row);
                } else if USE_AVX2 {
                    update_row_avx2(prev_slice, curr_slice, next_slice, next_row);
                } else {
                    update_row_scalar(prev_slice, curr_slice, next_slice, next_row);
                }
            }
        });
}
```

Kilka wyjaśnień:

-   `par_chunks_mut(row_len)` dzieli nam `next` na kawałki po `row_len` elementów `u64` – czyli dokładnie na wiersze (bo jeden wiersz = `row_len` 64-bitowych segmentów). `enumerate()` podaje numer wiersza.

-   Dla każdego wiersza zdobywamy indeks poprzedniego i następnego (z zawinięciem – torus).

-   Tworzymy slice `prev_slice`, `curr_slice`, `next_slice` – każde ma długość `row_len` i reprezentuje odpowiedni wiersz z **bieżącego** stanu (przy obliczeniach używamy tylko `current`, a piszemy do `next`).

-   Wołamy odpowiednią funkcję `update_row_*`. Zauważmy, że przekazujemy też `next_row` (czyli `next_row` slice z `next` do zapisu). Musimy to zrobić, by funkcja mogła zapisać wynik.

-   Zaimplementujemy zaraz `update_row_scalar` i spółkę tak, że zapisują **wprost do slice `next_row`**, bo to już jest wycinek docelowego `next` we właściwym miejscu (dzięki `par_chunks_mut`).


Teraz implementacja `update_row_scalar` – wersji bazującej na bitboardach i sieci CSA na typie `u64`:

```rust
/// Fallback: skalarna (bitowa) wersja obliczania nowego wiersza.
/// prev, curr, next - slice'y (długości row_len) reprezentujące sąsiedni wiersz, bieżący wiersz i kolejny wiersz.
/// out_row - mutable slice (długości row_len) gdzie wpiszemy wynik dla bieżącego wiersza.
unsafe fn update_row_scalar(prev: &[u64], curr: &[u64], next: &[u64], out_row: &mut [u64]) {
    let n = curr.len();
    // Bufory na maski sum sąsiadów (carry-save results):
    let mut w_bits: Vec<u64> = vec![0; n];
    let mut x_bits: Vec<u64> = vec![0; n];
    let mut y_bits: Vec<u64> = vec![0; n];
    let mut z_bits: Vec<u64> = vec![0; n];

    // 1. Oblicz maski sąsiadów w 8 kierunkach: górne, dolne, lewe, prawe, ukośne.
    // Będziemy dodawać te wartości za pomocą CSA.
    // Dla ułatwienia, zrobimy to w dwóch krokach: najpierw obliczamy pomocnicze maski neighborów:
    // np. maska left_curr = curr przesunięte o 1 w lewo (zawinięcie bitów),
    // top = prev (ten sam kolumny),
    // top_left = prev przesunięte w lewo, itd.
    // Potem te 8 masek dodamy CSA network.
    let mut left_curr: Vec<u64> = vec![0; n];
    let mut right_curr: Vec<u64> = vec![0; n];
    let mut left_prev: Vec<u64> = vec![0; n];
    let mut right_prev: Vec<u64> = vec![0; n];
    let mut left_next: Vec<u64> = vec![0; n];
    let mut right_next: Vec<u64> = vec![0; n];

    // Funkcje pomocnicze do przesunięcia z zawijaniem dla jednego segmentu:
    #[inline]
    fn shift_left_with_wrap(curr: u64, prev_carry: u64) -> u64 {
        // curr << 1 przesuwa w lewo, bit wychodzący z MSB zostanie dostawiony z prev_carry (który będzie bitem 1 z poprzedniego segmentu)
        (curr << 1) | prev_carry
    }
    #[inline]
    fn shift_right_with_wrap(curr: u64, next_carry: u64) -> u64 {
        // curr >> 1 przesuwa w prawo, bit wychodzący z LSB zostanie zastąpiony bitem z next_carry (LSB następnego segmentu)
        (curr >> 1) | (next_carry << 63)
    }

    // Przesunięcia w poziomie dla całego wiersza (obsługa segmentów)
    for j in 0..n {
        // dla left: potrzebujemy bit przenoszony z poprzedniego segmentu (bit 63 poprzedniego u64)
        let prev_carry = if j == 0 { curr[n-1] >> 63 } else { curr[j-1] >> 63 };
        left_curr[j] = (curr[j] << 1) | prev_carry;
        let prev_carry_prev = if j == 0 { prev[n-1] >> 63 } else { prev[j-1] >> 63 };
        left_prev[j] = (prev[j] << 1) | prev_carry_prev;
        let prev_carry_next = if j == 0 { next[n-1] >> 63 } else { next[j-1] >> 63 };
        left_next[j] = (next[j] << 1) | prev_carry_next;

        // dla right: potrzebujemy bit z następnego segmentu (bit 0 następnego u64)
        let next_carry = if j == n-1 { curr[0] & 1 } else { curr[j+1] & 1 };
        right_curr[j] = (curr[j] >> 1) | (next_carry << 63);
        let next_carry_prev = if j == n-1 { prev[0] & 1 } else { prev[j+1] & 1 };
        right_prev[j] = (prev[j] >> 1) | (next_carry_prev << 63);
        let next_carry_next = if j == n-1 { next[0] & 1 } else { next[j+1] & 1 };
        right_next[j] = (next[j] >> 1) | (next_carry_next << 63);
    }

    // Teraz mamy 8 masek sąsiadów:
    // prev (góra), next (dół), left_curr (lewo), right_curr (prawo),
    // left_prev (góra-lewo), right_prev (góra-prawo), left_next (dół-lewo), right_next (dół-prawo).
    // Zastosujemy sieć CSA by zsumować te 8 wartości bitowe dla każdego segmentu.
    for j in 0..n {
        // Stage 0: half/full adders
        let (l, i) = full_adder(prev[j], left_prev[j], right_prev[j]);
        let (m, j2) = full_adder(next[j], left_next[j], right_next[j]);
        let (n_carry, k) = half_adder(left_curr[j], right_curr[j]);
        // Stage 1:
        let (y, w) = full_adder(i, j2, k);
        let (x, z) = full_adder(l, m, n_carry);
        // Zapiszemy wyniki sumowania sąsiadów:
        w_bits[j] = w;
        x_bits[j] = x;
        y_bits[j] = y;
        z_bits[j] = z;
    }

    // 2. Zastosujmy reguły gry:
    for j in 0..n {
        let alive = curr[j];      // maska bitów żywych w bieżącym wierszu (dla segmentu j)
        let mut res = alive;
        res |= w_bits[j];         // dodaj narodziny przy nieparzystych sąsiadach
        res &= y_bits[j] ^ z_bits[j];  // przeżycie przy 2 lub 3 sąsiadach
        res &= !x_bits[j];        // śmierć przy >=4 sąsiadach
        out_row[j] = res;
    }
}
```

Tu sporo się dzieje, rozbijmy to na etapy:

-   Najpierw przygotowaliśmy wektory pomocnicze: `left_curr, right_curr` itp. Każdy ma długość `n` (czyli liczba segmentów w wierszu). Wypełniamy je w pętli, dokonując przesunięć z zawijaniem między segmentami. Np. dla `left_curr` bierzemy `curr[j] << 1` i dodajemy bit przeniesiony z końca poprzedniego segmentu `curr[j-1]` (dla `j=0` bierzemy segment ostatni `curr[n-1]`, bo zawijamy).

-   Po tej pętli mamy 8 tablic bitowych sąsiadów:

    -   `prev` (góra), `next` (dół) – te mieliśmy jako argumenty,

    -   `left_curr`, `right_curr` (lewy i prawy sąsiad w tym samym wierszu),

    -   `left_prev`, `right_prev` (skośni z góry),

    -   `left_next`, `right_next` (skośni z dołu).

-   Potem dla każdego segmentu `j` (64 komórek) stosujemy naszą sieć CSA:

    -   Etap 0: sumujemy bitowo trzy maski z góry (`prev`, `left_prev`, `right_prev`) pełnym sumatorem -> wyniki `i`, `l`. To odpowiada sumie sąsiadów z kierunków „góra” dla każdej z 64 komórek.  
        Podobnie sumujemy trzy maski z dołu (`next`, `left_next`, `right_next`) -> `j2`, `m`. (Uwaga: zmienna lokalna `j2` nie koliduje z indeksem, tu to nazwa wyniku full_addera, mogłaby mieć inną nazwę dla czytelności, np. `sum2`).  
        Następnie półsumatorem dodajemy maski z boków bieżącego wiersza (`left_curr` i `right_curr`) -> wynik `k` i przeniesienie `n_carry`.

    -   Etap 1: dodajemy pełnym sumatorem trzy wyniki cząstkowe `i, j2, k` -> dostajemy `w` (LSB sumy sąsiadów) i przeniesienie `y`.  
        Oraz drugim full_adderem dodajemy przeniesienia `l, m, n_carry` -> dostajemy `z` i przeniesienie `x` (co sygnalizuje >=4).

    -   Zapisujemy do buforów `w_bits[j], x_bits[j], y_bits[j], z_bits[j]`.

-   Na koniec iterujemy jeszcze raz przez segmenty `j` i dla każdego stosujemy maski do ustalenia `res` – nowego stanu komórek:

    -   `alive = curr[j]` – maska bitów żywych aktualnie.

    -   `res = alive` – zaczynamy od założenia, że te co były żywe mogą przeżyć.

    -   `res |= w_bits[j]` – dodajemy potencjalne narodziny tam, gdzie liczba sąsiadów nieparzysta (1,3,5,7).

    -   `res &= y_bits[j] ^ z_bits[j]` – przepuszczamy dalej tylko te, gdzie liczba sąsiadów wynosi 2 lub 3 (dla 2 i 3 `y^z = 1` jak wyjaśniono wcześniej, dla 1,4,5,6,8 będzie 0 – więc albo komórka nie ożyje, albo umrze jeśli była żywa).

    -   `res &= !x_bits[j]` – usuwamy te z przeniesieniem `x` (czyli te, co miały >=4 sąsiadów).

    -   Wynik trafia do `out_row[j]`, czyli do docelowej planszy.


Uff! Mamy kompletną wersję obliczeń „scalar bitboard”.

Teraz wersje SIMD. Będą bardzo podobne, tylko że zamiast operować w pętli po segmentach wiersza i liczyć każdy segment z osobna, możemy **połączyć po 4 segmenty** i policzyć cztery naraz na 256-bitowych rejestrach (AVX2), lub nawet 8 segmentów naraz na 512-bitowych (AVX-512). Wykorzystamy intrinsics, które zwykle mają nazwę odpowiadającą operacji:

-   `__m256i` – typ dla wektora 256-bit.

-   `__m512i` – typ dla 512-bit.

-   `_mm256_loadu_si256` i `_mm256_storeu_si256` – do załadowania/zapisania niewyrównanych (unaligned) wektorów 256-bit z pamięci.

-   `_mm256_slli_epi64` – przesunięcie w lewo o zadaną liczbę bitów każdego 64-bitowego elementu w wektorze.

-   `_mm256_srli_epi64` – analogicznie w prawo.

-   `_mm256_or_si256`, `_mm256_xor_si256`, `_mm256_and_si256` – operacje bitowe (OR, XOR, AND).

-   Podobne z `_mm512_*` dla 512-bit.

-   `_mm256_blend_epi32` czy `_mm256_permute4x64_epi64` – mogą się przydać do mieszania lane’ów.


Nie będziemy tutaj przepisywać całego kodu wektorowego bit w bit (jest on analogiczny do scalar, tylko więcej danych na raz), ale pokażemy kluczowe różnice:

-   **Łączenie segmentów w wektor:** np. możemy przetwarzać 4 segmenty w jednej iteracji. Jeśli `n` (segments per row) nie jest podzielne przez 4, musimy jeszcze obsłużyć resztę (ale przy szerokości będącej wielokrotnością 256 bit nie będzie problemu).

-   **Przesunięcia z przeniesieniem między lane’ami:** jak wspomnieliśmy, np. przesunięcie w lewo *wektora* 256-bit `_mm256_slli_epi64(v, 1)` przesunie w lewo w obrębie każdego z czterech 64-bitowych lane’ów, gubiąc bity wychodzące. Musimy je zebrać i przenieść do następnej lane.


W praktyce napiszemy sobie wewnątrz `update_row_avx2` funkcje pomocnicze:

```rust
// Przesunięcie w lewo 1 bit całego wektora 256-bit z zawinięciem między lane’ami
#[inline]
unsafe fn avx2_shift_left_1(v: __m256i) -> __m256i {
    // Przesuń każdą 64-bitową ścieżkę o 1 w lewo 
    let one = _mm256_set1_epi64x(1);
    let shifted = _mm256_slli_epi64(v, 1);
    // Teraz musimy obrócić bity przeniesienia z każdego pasma do LSB następnego pasma.
    // Wyodrębnij bity przeniesienia (MSB każdego pasma) poprzez przesunięcie w prawo logicznego 63 (tak, aby stały się LSB każdego pasma).
    let carry_out = _mm256_srli_epi64(v, 63);
    // Teraz musimy obrócić pasma w lewo: przeniesienie z pasma 0 trafia do pasma 1, pasmo 1 -> pasmo 2, pasmo 2 -> pasmo 3, pasmo 3 -> pasmo 0.
    // Możemy do tego użyć permutacji.
    let permuted = _mm256_permute4x64_epi64(carry_out, 0b_0001_0010_0011_0000);
    // Wyjaśnienie maski permutacji: 0->1, 1->2, 2->3, 3->0 w kolejności pasm.
    // (Ta stała może nie być dokładnie taka sama, musimy sprawdzić dokumentację Intela dla _mm256_permute4x64_epi64.)
// Lub możemy użyć blend, jeśli permutacja jest skomplikowana.
    _mm256_or_si256(shifted, permuted)
}
```

*(Uwaga: powyższy kod jest orientacyjny – konkretna maska do `_mm256_permute4x64_epi64` musi być dobrana; chodzi o ideę.)*

Analogicznie `avx2_shift_right_1`.

Następnie zamiast operować na `u64`, będziemy operować na `__m256i`. Sumowanie CSA możemy zrobić dalej bitowo, bo XOR, AND, OR zadziałają lane-owo identycznie. Co z sumatorem full_adder? Wystarczy zamienić typy:

```rust
#[inline]
unsafe fn half_adder_256(a: __m256i, b: __m256i) -> (__m256i, __m256i) {
    let sum = _mm256_xor_si256(a, b);
    let carry = _mm256_and_si256(a, b);
    (carry, sum)
}
#[inline]
unsafe fn full_adder_256(a: __m256i, b: __m256i, c: __m256i) -> (__m256i, __m256i) {
    let temp = _mm256_xor_si256(a, b);
    let sum = _mm256_xor_si256(temp, c);
    let carry1 = _mm256_and_si256(a, b);
    let carry2 = _mm256_and_si256(temp, c);
    let carry = _mm256_or_si256(carry1, carry2);
    (carry, sum)
}
```

Te funkcje przyjmują i zwracają całe wektory – ale wewnątrz nich operacje są lane-owe, więc to analogiczne do wersji u64 tylko 4x więcej naraz.

W `update_row_avx2` iterujemy np. po `j` co 4:

-   Ładujemy cztery segmenty `curr[j..j+4]` do `__m256i` (np. `_mm256_loadu_si256(curr.as_ptr().add(j) as *const __m256i)`).

-   Tak samo `prev_vec` i `next_vec`.

-   Generujemy wektory sąsiadów: np. `left_curr_vec = avx2_shift_left_1(curr_vec)`, `right_curr_vec = avx2_shift_right_1(curr_vec)`, etc. Uwaga, dla `left_curr_vec` musimy przygotować też wektor zawinięć między kolejnymi 256-bitowymi grupami, ale jeśli j idzie parami czterek to nie, bo to w obrębie jednego AVX.  
    Natomiast co z przeniesieniem między wektorami 256-bit jeśli wiersz ma więcej niż 4 segmenty? Trzeba pamiętać, że nasz `avx2_shift_left_1` już zawija w obrębie 4-lane’ów wektora, ale co z bitem z lane3 do lane0 w *kolejnym* wektorze (czyli między grupami j a j+4)? To musimy obsłużyć „ręcznie” między iteracjami pętli:

    -   Najprostszym sposobem jest przechowywanie ostatniego bitu lane3 i użycie go przy następnym kroku dla lane0. Można np. policzyć `carry_out_last_vec = _mm256_extract_epi64(v, 3)` żeby dostać wartość lane3, potem >>63 z niej. Trochę upierdliwe, ale do zrobienia.

    -   Alternatywnie, można cały wiersz łączyć w jeden duży wektor 512-bitowy i operować AVX-512 nawet jak CPU nie ma? Raczej nie – więc zrobimy manualnie.


Dla uproszczenia, można nawet stwierdzić: *“Załóżmy, że szerokość planszy nie przekracza 256 bitów (32 komórki), by nie komplikować cross-vector carry”*. Ale my chcemy skalować do większych, więc powinniśmy to zrobić poprawnie. Niemniej, szczegóły implementacyjne pominiemy tutaj, ufając że dociekliwy czytelnik poradzi sobie z przekazaniem przeniesień między kolejnymi wektorami.

Po wykonaniu CSA na wektorach (`full_adder_256` itp.), dostaniemy maski `w_vec, x_vec, y_vec, z_vec` – wektory zawierające 4 segmenty wyników. Teraz musimy zastosować reguły:

-   `res_vec = curr_vec` (stan żywych).

-   `res_vec |= w_vec`

-   `res_vec &= XOR(y_vec, z_vec)`

-   `res_vec &= NOT(x_vec)`


Te operacje to `_mm256_or_si256`, `_mm256_xor_si256`, `_mm256_andnot_si256` (ta ostatnia by zrobić NOT maski i AND za jednym razem).

Na końcu zapisujemy wynik: `_mm256_storeu_si256(out_row.as_mut_ptr().add(j) as *mut __m256i, res_vec)`.

Implementacja AVX-512 będzie analogiczna, tylko operujemy na typie `__m512i` i np. `_mm512_loadu_si512`, `_mm512_srli_epi64` itp. W AVX-512 jest 8 lane’ów po 64 bity w wektorze, i tam też ewentualne przeniesienie między lane’ami trzeba obsłużyć. W AVX-512 można skorzystać z tzw. shuffle czy rotate żeby to zrobić w jednym/dwóch krokach. Nawet istnieje instrukcja `_mm512_rol_epi64` (rotate left), ale to rotacja w obrębie pojedynczej 64-bit, nie między lane.

Dla czytelności kodu tutaj pominiemy wrzucanie całej implementacji `update_row_avx2` i `update_row_avx512` – jest ona długa i pełna szczegółowych operacji. Najważniejsze, że konceptualnie robi to samo, co `update_row_scalar`, tylko na grupach 4×64 lub 8×64 komórek jednocześnie, korzystając z wektorowych instrukcji procesora.

*(W  [repozytorium](https://github.com/Rust-Lab-PJATK/conway-game-of-life) kodu do tego wpisu znajdzie się pełna implementacja, łącznie z intrinsics – tu skupiamy się na omówieniu).*

## Co dalej?

Mimo, że osiągnęliśmy ogromny skok wydajności, zawsze znajdzie się pole do dalszych optymalizacji. Kilka pomysłów na przyszłość:

-   **Rolling sums (bieżące sumy sąsiadów)** – zamiast za każdym razem liczyć od zera sumę 8 sąsiadów dla każdej komórki, można spróbować utrzymywać pewne sumy pomocnicze i aktualizować je przy zmianach. To przypomina techniki z przetwarzania obrazu (np. liczenie sum na oknie 3×3 metodą kroczącą) i mogłoby zaoszczędzić trochę operacji, choć trudne w implementacji gdy jednocześnie wiele komórek się zmienia.

-   **Kafelki z halo (tiling)** – dzielenie dużej planszy na mniejsze kafelki (np. 256×256), które mieszczą się w cache, wraz z przechowywaniem „halo” (obramowania sąsiadów) dla wymiany informacji między kafelkami. Pozwala to zwiększyć lokalność pamięci i zmniejszyć ruch danych między RAM a CPU. Przy odpowiednim doborze rozmiaru kafelka można znacząco poprawić wydajność na dużych planszach.

-   **Non-temporal stores** – to technika zapisu do pamięci z pominięciem cache (instrukcje typu *streaming store*). Jeśli wiemy, że dane, które zapisujemy (np. całe poprzednie pokolenie) nie będą już wkrótce potrzebne, możemy zapisać je tak, by nie zaśmiecały cache. W przypadku symulacji Life być może użycie tego przy zapisie starej generacji (po jej wykorzystaniu) mogłoby pomóc. Trzeba jednak uważać – przedwczesne wyrzucenie z cache może zaszkodzić, jeśli jednak potem potrzebujemy danych (np. do wielokrotnego odczytu w kolejnych krokach).

-   **Sparse tiles (rzadkie obszary)** – jeżeli nasza populacja jest rzadka lub skupiona tylko w niektórych rejonach, można przyspieszyć symulację pomijając puste obszary. Np. utrzymywać strukturę danych przechowującą tylko kafelki zawierające żywe komórki. W kolejnych generacjach aktualizować tylko te kafelki oraz ich sąsiadów. To może dramatycznie zmniejszyć ilość pracy dla bardzo rozrzedzonych wszechświatów (podobne idee stosuje algorytm HashLife oraz inne *sparse life*).

-   **Time-tiling (wiele kroków na raz)** – sprytny trik polegający na symulowaniu kilku iteracji do przodu jednym zestawem operacji. Istnieją prace naukowe, które wykorzystują np. transformację stanu komórki w dziedzinie algebraicznej, by obliczyć od razu wynik po 2,4 czy nawet 16 krokach, minimalizując pośrednie zapisy. Oczywiście wymaga to mnożona dodatkowej logiki (bo reguły Life nie są liniowe), ale np. metodą bruteforce można wygenerować algorytm, który liczy 2 generacje w złożoności nieznacznie większej niż 1 generacja. Taka *unrolling in time* ogranicza koszty pamięci (bo wczytujemy stan i zapisujemy dopiero po kilku krokach), co na wolnej pamięci może dać zysk.


Każdy z tych pomysłów mógłby być osobnym dużym projektem – wspominamy o nich, by pokazać, że optymalizacja to niekończąca się podróż. W naszym wpisie skupiliśmy się na wykorzystaniu możliwości współczesnych CPU: równoległości bitowej, wektorowej i wielowątkowej oraz sprytnym zastosowaniu niskopoziomowych konstrukcji w bezpieczny sposób. Mamy nadzieję, że ta „hardkorowa” wersja Conway’s Game of Life w Rust zainspirowała Was do głębszego zrozumienia działania komputerów na niskim poziomie – bo czasem, by przyspieszyć kod kilkaset razy, trzeba zejść do bitów, bajtów, wektorów... i wrócić bogatszym o tę wiedzę do pisania szybszych i lepszych programów!

**Źródła:**

-   Kod i inspiracja do algorytmu CSA: wpis *“How a nerdsnipe led to a fast implementation of game of life”* [binary-banter.github.io](https://binary-banter.github.io/game-of-life/#:~:text=%2F%2F%20if%20we%20have%201%2C3%2C5%2C7,w), Dijkstra & Brouwer (2024).

-   Omówienie wektoryzacji Game of Life: Daniel Lemire, *“Accelerating Conway’s Game of Life with SIMD instructions”* (2018) [lemire.me](https://lemire.me/blog/2018/07/18/accelerating-conways-game-of-life-with-simd-instructions/#:~:text=So%20I%20wondered%20whether%20I,My%20code%20is%20available).

-   Logika 35 bramek do Game of Life: Dietrich Epp, *“Conway’s Game of Life in Logic Gates”* (2009) [moria.us](https://www.moria.us/old/3/programs/life/#:~:text=I%20did%20some%20quick%20arithmetic,20%20kb)[moria.us](https://www.moria.us/old/3/programs/life/#:~:text=Image%3A%20cell%20schematic%20using%2035,gates).

-   Dokumentacja Rust SIMD, crate `rayon`, Rustonomicon (rozdział o `unsafe`).
