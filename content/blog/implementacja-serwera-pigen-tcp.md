+++
title = "Implementacja serwera usługi Pigen na bazie protokołu TCP"
date = 2025-03-15
description = "Dowiedz się jak napisać wielowątkowy serwer obliczający kolejne cyfry liczby pi, wykorzystując protokół TCP i biblioteki do obsługi puli wątków oraz dużych liczb całkowitych."
authors = ["Maciej Pędzich"]

[taxonomies]
tags = ["miniprojekt", "sieci"]
+++

Witaj, świecie!

Z okazji niedawno minionego [dnia liczby pi](https://www.piday.org), chciałbym przedstawić mój projekt serwera (nieco zmodyfikowanej) usługi Pigen opisanej w [dokumencie IETF RFC 3091](https://datatracker.ietf.org/doc/html/rfc3091) oraz wyjaśnić stojący za nim algorytm do obliczania kolejnych cyfr tej liczby.

[Kod źródłowy znajdziesz tutaj](https://github.com/Rust-Lab-PJATK/pigen-tcp).

## Specyfikacja protokołu i moje zmiany

Specyfikacja Pigen w oparciu o protokół transportowy TCP ma bardzo proste wymagania:

1. Serwer nasłuchuje na porcie numer 314159.
2. Po nawiązaniu połączenia z klientem, serwer wysyła strumieniowo kolejne cyfry liczby &pi; w systemie dziesiętnym i kodowaniu ASCII, począwszy od pierwszej cyfry po przecinku, aż do momentu rozłączenia się przez klienta.

Wprowadziłem dwie drobne zmiany:

1. Serwer nasłuchuje na porcie numer **31415**, ponieważ największy możliwy numer portu TCP wynosi 65535 (wybór portu 314159 był najpewniej niedopatrzeniem ze strony autora oryginalnego dokumentu).
2. [...] serwer wysyła kolejne cyfry liczby &pi; (w celu zmniejszenia obciążenia sieci) [...], począwszy od **cyfry jedności** [...], gdyż ułatwia to implementację oraz wytłumaczenie działania zastosowanego przeze mnie algorytmu.

Specyfikacja nie narzuca konkretnej metody generowania cyfr. Choć mógłbym wykorzystać [plik z milionem cyfr](http://newton.ex.ac.uk/research/qsystems/collabs/pi/pi6.txt) i wysyłać jego zawartość, takie rozwiązanie byłoby zbyt proste i mało interesujące. Co więcej, nie spełnia ono potrzeb klientów żądnych miliona jeden, miliona dwóch, czy miliona trzech pierwszych cyfr (o milionie czterech nie wspominając).

## Algorytm na obliczanie kolejnych cyfr liczby pi

Zdecydowanie ciekawsze i bardziej elastyczne podejście stanowi zaprogramowanie algorytmu, który potrafi obliczyć &pi; z dowolnie dużą precyzją, gdzie jedynymi ograniczeniami są dostępna moc obliczeniowa i pamięć.

Z pomocą przychodzi wzór podany po raz pierwszy w XVII wieku przez [Williama Brouncker'a](https://en.wikipedia.org/wiki/William_Brouncker,_2nd_Viscount_Brouncker), który przedstawia ćwierć &pi; jako [ułamek łańcuchowy](https://pl.wikipedia.org/wiki/U%C5%82amek_%C5%82a%C5%84cuchowy):

$$\dfrac \pi 4 = \dfrac 1 {1 + \cfrac {1^2} {2 + \cfrac {3^2} {2 + \cfrac {5^2} {2 + \cfrac {7^2} {2 + \cdots } } } } }$$

Jak zauważył L. J. Lange w [artykule _An Elegant Continued Fraction for &pi;_](https://www.jstor.org/stable/2589152), przy [dowodzeniu prawdziwości powyższego wzoru](https://proofwiki.org/wiki/Brouncker%27s_Formula) można wykorzystać alternatywną formę ułamka łańcuchowego dla głównej krzywej rozgałęzienia funkcji $\arctan(z)$ w płaszczyźnie liczb zespolonych, gdzie $z$ nie znajduje się na osi urojonej ani od $-i$ poniżej, ani od $i$ wzwyż:

$$\arctan(z) = \frac {z} {1+{\cfrac {(1z)^{2} } {3+{\cfrac {(2z)^{2} } { 5+{\cfrac {(3z)^{2} } {7+{\cfrac {(4z)^{2} } {9+\cdots } } } } } } } } }$$

Podstawiając 1 za $z$ oraz mnożąc obie strony równości razy 4, otrzymamy:

$$\pi = \frac {4} {1+{\cfrac {1^2} {3+{\cfrac {2^2} { 5+{\cfrac {3^2} {7+{\cfrac {4^2} {9+\cdots } } } } } } } } }$$

W tej formie, każdy kolejny zagnieżdżony ułamek wynosi $\frac { k^2 } { 2k + 1 + \cdots } $ dla $k \in \natnums$, gdzie $\cdots$ oznacza sumę pozostałych ułamków tej postaci od $k + 1$ do $\infty$.

Tym sposobem dochodzimy wreszcie do algorytmu opracowanego przez autorów [podręcznika języka programowania ABC](https://homepages.cwi.nl/~steven/abc/programmers/handbook.html) (rozdział _Examples of ABC_, podrozdział _Numbers_), który polega na obliczaniu dwóch kolejnych przybliżeń, począwszy od $\frac 4 1$ oraz $\frac 4 {1 + \frac 1 3 }$ (czyli $\frac {12} 4$) i sprawdzeniu równości ich kolejnych cyfr w rozwinięciu dziesiętnym.

Jeśli na danej pozycji znajduje się ta sama cyfra, wysyłamy ją do klienta i sprawdzamy równość cyfr na kolejnej pozycji. W przeciwnym razie, obliczamy kolejny ułamek w łańcuchu (w tej iteracji $\frac 4 {1 + \frac 1 { 3 + \frac 4 5 } }$), po czym wykonujemy sprawdzenie zgodności wiodących cyfr z $\frac 4 {1 + \frac 1 3 }$, dążąc tym samym do coraz większej dokładności z każdym następnym $k$.

## Zewnętrzne biblioteki

Zanim przejdziemy do _części praktycznej_ tego artykułu, musimy jeszcze poruszyć dwie kwestie związane z projektem serwera Pigen.

### `threadpool` - mechanizm puli wątków

Pierwszą z nich jest obsługa wielu klientów jednocześnie. Ponieważ mamy do czynienia z usługą, która kładzie większy nacisk na moc obliczeniową serwera niż przepustowość sieci, zdecydowałem się na wykorzystanie tradycyjnych wątków systemowych zamiast modelu `async/await`.

Oczywiście, tworzenie nowego wątku za każdym razem gdy zostanie nawiązane połączenie to prosty przepis na nieszczęście. Wystarczy, że ktoś uruchomi skrypt, który w nieskończonej pętli będzie otwierał nowe połączenia, żeby nie tylko nasz program, ale też całe urządzenie padło na kolana.

Bardziej rozsądnym podejściem jest tworzenie ograniczonej liczby wątków do obsługi połączeń. W przypadku gdy zostanie ona osiągnięta, a nowy klient będzie chciał nawiązać z nami połączenie, wystarczy go poinformować o pełnym obciążeniu i zakolejkować jego żądanie. Kiedy inny klient się rozłączy, będziemy mogli wówczas obsłużyć klienta oczekującego w kolejce.

Choć mógłbym się pokusić o napisanie [własnego mechanizmu puli wątków](https://buraksekili.github.io/articles/thread-pooling-rs), postanowiłem sięgnąć po [bibliotekę `threadpool`](https://crates.io/crates/threadpool), by skupić się na wcześniej opisanym algorytmie. Skoro znów o nim mowa, czas przejść do drugiego problemu.

### `rug` - duże liczby całkowite

Podstawowe typy liczb całkowitych w języku Rust mają pojemność ograniczoną do konkretnej liczby bajtów. Dla zdecydowanej większości programów dany zakres jest wystarczająco duży by przechowywać dane i wykonywać na nich obliczenia bez obaw o przekroczenie maksymalnej dopuszczalnej wartości.

Niestety, nawet 64-bitowa liczba całkowita bez znaku (która potrafi zmieścić [ponad 18 trylionów](https://doc.rust-lang.org/std/primitive.u64.html#associatedconstant.MAX)), okazuje się dla użytego przeze mnie algorytmu zbyt mała do obliczenia... dziesiątej cyfry po przecinku. Nic jednak dziwnego, gdyż ten algorytm został napisany z myślą o języku ABC, którego typ liczby całkowitej ma (teoretycznie) nieograniczoną pojemność.

Mało tego, w niektórych językach _głównego nurtu_ takich jak [Python](https://docs.python.org/3/library/stdtypes.html#numeric-types-int-float-complex) czy [Ruby](https://ruby-doc.com/docs/ProgrammingRuby/html/tut_stdtypes.html), liczby całkowite również są (lub mogą być w razie potrzeby) przechowywane w formie potrafiącej pomieścić dowolnie dużą wartość. Z kolei w językach pokroju [Javy](https://docs.oracle.com/javase/8/docs/api/java/math/BigInteger.html) albo [C#'a](https://learn.microsoft.com/pl-pl/dotnet/api/system.numerics.biginteger?view=net-9.0), dostępny jest oddzielny typ do reprezentowania _nieskończenie wielkich_ liczb całkowitych.

O ile Rust nie posiada wbudowanego w język rozwiązania w stylu ostatnich dwóch ze wcześniej wspomnianych języków, tak na ratunek przychodzi społeczność z [biblioteką `rug`](https://crates.io/crates/rug), która dostarcza wysokopoziomowy interfejs programistyczny dla [GNU Multiple Precision Arithmetic Library](https://gmplib.org).

Skrzynka `rug` jest udostępniana na licencji [GNU **Lesser** General Public License v3](https://www.gnu.org/licenses/lgpl-3.0.en.html), co powinno ułatwić jej integrację z komercyjnymi projektami. Jeśli mimo to jej licencja nadal jest nieodpowiednia, polecam zapoznać się z zamiennikiem w postaci [biblioteki `num-bigint`](https://lib.rs/crates/num-bigint).

## Analiza kodu

Po tym obszernym wstępie możemy w końcu przejść do analizy kodu serwera.

### Inicjalizacja serwera i puli wątków

Zacznijmy od zaimportowania potrzebnych nam cech/interfejsów i struktur oraz utworzenia ich instancji:

```rust
use rug::{Assign, Integer};
use std::error::Error;
use std::io::Write;
use std::net::TcpListener;
use threadpool::ThreadPool;

fn main() -> Result<(), Box<dyn Error>> {
    let pool = ThreadPool::new(5);
    let listener = TcpListener::bind("0.0.0.0:31415")?;

    Ok(())
}
```

Wykorzystałem [alternatywną sygnaturę funkcji `main`](https://doc.rust-lang.org/rust-by-example/error/result.html#using-result-in-main), aby móc posługiwać się [operatorem `?`](https://doc.rust-lang.org/rust-by-example/std/result/question_mark.html) do wyłuskiwania pomyślnych wyników zamiast potencjalnie panikujących wywołań [`unwrap()`](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap). W razie wystąpienia wyjątku, ten zostanie wyświetlony w postaci [`Debug`](https://doc.rust-lang.org/std/fmt/trait.Debug.html), a proces zakończy się z kodem błędu. Natomiast podstawienie [`Box<dyn Error>`](https://doc.rust-lang.org/std/boxed/index.html) jako spodziewany typ błędu umożliwia zwracanie obiektu dowolnego typu, pod warunkiem że implementuje [cechę `Error`](https://doc.rust-lang.org/std/error/trait.Error.html).

Co do liczby wątków w puli, 5 nie jest w żaden sposób wiążącą czy najbardziej optymalną liczbą. Można dowolnie eksperymentować z jej zwiększaniem lub zmniejszaniem w zależności od wymaganej liczby klientów do równoległego obsługiwania oraz mocy obliczeniowej serwera.

### Nasłuchiwanie połączeń i uruchamianie/kolejkowanie wątków

Mamy zadeklarowany nasłuchiwacz, więc pora na obsługę przychodzących połączeń. Jeśli dysponujemy wolnym wątkiem, możemy natychmiastowo rozpocząć generowanie cyfr &pi; dla klienta. W przeciwnym razie musimy go poinformować, że serwer osiągnął limit obsługiwanych jednocześnie połączeń i zakolejkować żądanie.

W tym celu należy dodać poniższy kawałek kodu między deklaracją zmiennej `listener`, a zwróceniem wartości `Ok(())`:

```rust
for mut stream in listener.incoming().flatten() {
    if pool.active_count() == pool.max_count() {
        stream.write_all(b"Serwer jest zajęty! Proszę czekać...\n")?;
    }

    pool.execute(move || {
        // cdn.
    });
}
```

[Metoda `incoming()`](https://doc.rust-lang.org/std/net/struct.TcpListener.html#method.incoming) zwraca iterator, który w nieskończonej pętli akceptuje przychodzące połączenia, a każdy element jest [typu `io::Result`](https://doc.rust-lang.org/std/io/type.Result.html), którego pomyślnym wynikiem jest [obiekt reprezentujący strumień TCP](https://doc.rust-lang.org/std/net/struct.TcpStream.html). Z kolei [metoda `flatten()`](https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.flatten) pozwala nam wyłuskać wspomniany strumień z elementów iteratora, które są pomyślnymi wynikami, a oprócz tego pominąć wszystkie wyniki wariantu porażki.

Pomimo tego, że wykonujemy sprawdzenie równości obecnej liczby aktywnych wątków i ich maksymalnej dopuszczalnej liczby, zarówno uruchamianie jak i kolejkowanie wątków odbywa się poprzez wywołanie [metody `execute()` puli wątków](https://docs.rs/threadpool/1.8.1/threadpool/struct.ThreadPool.html#method.execute). Pula zadba o uruchomienie pierwszego w kolejce wątku kiedy inny wątek zakończy pracę.

Ponieważ będziemy odwoływać się wewnątrz wątku do obiektu `stream`, należy pamiętać o umieszczeniu słowa kluczowego `move` przed definicją domknięcia. Istnieje bowiem szansa, że wątek _poboczny_ będzie aktywny dłużej niż ten, który go uruchomił. Stąd też wymagane jest, by wszelkie dane używane w nowym wątku miały czas życia równy `'static`, czyli żeby były dostępne aż do końca działania wątku.

Domyślnie `stream` zostałby jedynie pożyczony, a skoro nie mamy gwarancji, że jego czas życia będzie co najmniej równy czasowi trwania wątku, to przy próbie użycia `stream` w domknięciu bez `move` otrzymamy [błąd kompilacji](https://doc.rust-lang.org/error_codes/E0373.html). Zatem domknięcie musi przejąć `stream` na własność w celu spełnienia powyższego wymagania.

### Implementacja algorytmu na obliczanie kolejnych cyfr pi

Czas na gwódź programu. Zaczynamy wewnątrz domknięcia od deklaracji zmiennych dla $k$ oraz dwóch kolejnych przybliżeń &pi;:

```rust
let mut k = Integer::from(2);
let mut a = Integer::from(4);
let mut b = Integer::from(1);
let mut a1 = Integer::from(12);
let mut b1 = Integer::from(4);
```

Zmienne `a` i `a1` oznaczają liczniki, zaś `b` i `b1` mianowniki odpowiednich przybliżeń. Następnie rozpoczynamy nieskończoną pętlę z etykietą `'pi`, na początku której obliczamy $k$-ty ułamek w serii i odpowiednio zwiększamy `a1` i `b1`, by uzyskać $k$-te przybliżenie &pi;. Poprzednie wartości tych zmiennych przypisujemy do `a` i `b` oraz zwiększamy $k$ o 1.

```rust
'pi: loop {
    let p = Integer::from(&k * &k);
    let q = Integer::from(2 * &k) + 1;
    let prev_a1 = a1.clone();
    let prev_b1 = b1.clone();

    k += 1;
    a1 *= &q;
    a1 += &p * &a;
    b1 *= &q;
    b1 += &p * &b;
    a = prev_a1;
    b = prev_b1;
}
```

Warto zwrócić uwagę chociażby na formę deklaracji zmiennych `p` i `q` oraz na rozbicie poszczególnych operacji na `a1` i `b1` zamiast jednego większego wyrażenia lub operacji przypisania jak w oryginalnej implementacji algorytmu w języku ABC. Wynika to ze zwracania przez `rug` [_niepełnego wyniku obliczeń_](https://docs.rs/rug/1.27.0/rug/index.html#incomplete-computation-values) dla działań na dwóch obiektach `Integer` zamiast nowego obiektu tego samego typu.

Takie zachowanie pozwala zmniejszyć liczbę kosztownych operacji alokacji pamięci wykonywanych przez te obiekty, chociażby poprzez przypisywanie tych wyników do istniejących obiektów z pomocą przeciążonych operatorów albo [metody `assign()`](https://docs.rs/rug/1.27.0/rug/struct.Integer.html#impl-Assign-for-Integer). Jeśli jednak nie ma innego wyjścia niż utworzenie nowej liczby typu `Integer`, to możemy przekazać wynik do `Integer::from` tak samo jak robiliśmy to ze _zwykłymi_ liczbami.

Zostało nam już tylko wyciąganie i porównywanie kolejnych cyfr z rozwinięć dziesiętnych przybliżeń &pi; Jesli cyfra na danej pozycji jest taka sama dla obu ułamków, możemy ją wysłać do klienta. W razie gdy jej przesłanie się nie powiedzie (najpewniej z powodu zerwania połączenia przez klienta), przerywamy pętlę `'pi` i tym samym kończymy wątek. Jeśli cyfry się różnią, to oznacza, że czas na obliczenie kolejnego przybliżenia &pi;.

```rust
let mut d = Integer::from(&a / &b);
let mut d1 = Integer::from(&a1 / &b1);

while d == d1 {
    let ascii_d = d.to_string();

    if let Err(_e) = stream.write_all(ascii_d.as_ref()) {
        break 'pi;
    }

    a %= &b;
    a *= 10;
    a1 %= &b1;
    a1 *= 10;
    d.assign(&a / &b);
    d1.assign(&a1 / &b1);
}
```

Warto zauważyć, że nie musimy dokonywać konwersji łańcucha `ascii_d` na opakowywany przez niego wektor bajtów. Typ `String` implementuje [cechę `AsRef`](https://doc.rust-lang.org/std/convert/trait.AsRef.html) do pobierania referencji na wycinek bajtów (`&[u8]`) zamiast `&String`, kiedy [metoda `write_all()`](https://doc.rust-lang.org/std/io/trait.Write.html#method.write_all) wymaga dostarczenia danych do wysłania w formie `&[u8]`.

## Podsumowanie

Serwer jest gotowy! Teraz wystarczy go uruchomić i przetestować np. za pomocą klienta ogólnego użytku jak [`ncat`](https://nmap.org/ncat):

```bash
ncat --recv-only WSTAW_TU_IP_SERWERA 31415
```

Oczywiście, temu projektowi daleko do miana rekordzisty prędkości, a samych sposobów na wyznaczanie kolejnych cyfr liczby &pi; jest znacznie więcej. Moim celem było zaprezentowanie paru przydatnych bibliotek oraz wyjaśnienie całkiem prostego w implementacji aglorytmu, co mam nadzieję udało mi się osiągnąć.

Zachęcam do poeksperymentowania z innymi algorytmami, rozbijaniem samych obliczeń na wiele wątków, czy napisania od podstaw serwera usługi Pigen w oparciu o [protokół UDP](https://datatracker.ietf.org/doc/html/rfc3091#autoid-3).

Do zobaczenia w kolejnym artykule!
