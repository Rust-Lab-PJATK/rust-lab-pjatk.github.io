+++
title = "Rust w systemach wbudowanych – długoterminowa inwestycja czy moda?"
draft = false
date = 2025-11-21
description = "Praktyczne spojrzenie na Rust w systemach wbudowanych"
authors = ["Daniel Olczyk"]

[taxonomies]
tags = ["embedded", "arduino"]
+++

![banner](/img/embeded-w-rust/banner.jpg)

Od czasów powstania Rust jako konkurencyjnego języka do znanych języków kompilujących się do kodu maszynowego, nie miał on początkowo szerokiego grona zwolenników. Jednak z każdym rokiem popularność rosła, a język ze swym charakterystycznym logo kraba zdobywał coraz bardziej znaczące miejsce w społeczności (zajmując pierwsze miejsca w ankiecie Stack Overflow w kategorii „ulubiony język”). Od 2020 roku Rust zwrócił uwagę gigantów technologicznych takich jak Microsoft czy Google, które zaczęły wdrażać go w swoich produktach.

W społeczności systemów wbudowanych widać rosnące wsparcie dla narzędzi i platform umożliwiających kompilowanie i uruchamianie programów w Rust. W tym artykule przedstawię dostępne rozwiązania, platformy, wady i zalety korzystania z Rust w systemach wbudowanych, porównam kod C++ i Rust, a także podzielę się własnymi doświadczeniami.

## Co to systemy wbudowane?

Systemy wbudowane w dużym skrócie to specjalizowane komputery przeznaczone do konkretnych zadań. Zazwyczaj są to mikrokontrolery, które znajdują zastosowanie na przykład w:

* **samochodach** – czujniki temperatury, systemy zarządzania drzwiami
* **urządzeniach IoT** (ang. Internet of Things) – inteligentne systemy, np. taśmy LED, żarówki inteligentne, inteligentne gniazdka
* **sprzęcie RTV/AGD** – sterują poszczególnymi funkcjami, np. w pralce wyborem programu prania wybranego przez użytkownika

Takie systemy wbudowane służą do wykonywania prostych algorytmów, gdzie każda operacja musi być jak najbardziej zoptymalizowana, ponieważ te układy mają ograniczone zasoby: słaby procesor i niewielką pamięć RAM oraz ROM.

## Platformy – klucz do rozwiązania problemu

Istnieje wiele rodzajów mikrokontrolerów tzw. platform, które mają zastosowanie w różnych dziedzinach. Oto kilka liderów branży:

* Arduino
* Espressif
* Raspberry Pi Pico
* STM32

Bardziej zaawansowane platformy mają większą moc obliczeniową i mogą uruchamiać wymagające systemy operacyjne, takie jak GNU/Linux:

* Raspberry Pi
* Orange Pi
* Banana Pi

Jak widać, wybór jest ogromny. Wszystkie te platformy mają wbudowane API (ang. Application Programming Interface), które umożliwia komunikację z GPIO (ang. General-Purpose Input/Output) – interfejsem odpowiedzialnym za komunikację z urządzeniami zewnętrznymi poprzez piny na płytce.

## Dostępność bibliotek dla poszczególnych platform

Wsparcie różnych platform w Rust to temat, który można dyskutować długo. Dobrym przykładem jest Espressif – firma produkująca stosunkowo tanie mikrokontrolery z wbudowanym modułem Wi-Fi. Od kilku lat oferuje własne narzędzia ułatwiające tworzenie rozwiązań IoT dla swoich platform ([https://github.com/esp-rs](https://github.com/esp-rs)). W przypadku Arduino użytkownik [Rahix](https://github.com/Rahix) utworzył abstrakcyjną warstwę sprzętową (HAL) do interakcji z komponentami na płytce, dostępną w repozytorium [avr-hal](https://github.com/Rahix/avr-hal). Sytuacja z Raspberry Pi jest bardziej złożona. Wystarczy użyć standardowego toolchaina Linux, ale komunikacja z GPIO wymaga odpowiedniej biblioteki. Niestety, najpopularniejszy crate [rppal](https://github.com/golemparts/rppal) nie otrzymuje już wsparcia ze strony autora, co może prowadzić do braku poprawek błędów i nowych funkcji. Jednak ze względu na to, że projekt ma otwarte źródła, istnieje szansa na podtrzymanie go przez społeczność.

## Biblioteki dla popularnych komponentów

Czy będą dostępne biblioteki do sterowania taśmami LED czy wyświetlaczami LCD? Na szczęście, dla popularnych komponentów takie biblioteki istnieją: [blinksy](https://github.com/ahdinosaur/blinksy), [embedded-graphics](https://github.com/embedded-graphics/embedded-graphics), [epd-waveshare](https://github.com/Caemor/epd-waveshare). Obsługują one zarówno tryb `no-std`, jak i `std`.

## Różnice między trybami std i no-std

Zgodnie z dokumentacją Rust – `no-std` oznacza, że biblioteka standardowa nie będzie dołączona do kompilacji, co powoduje, że nie możemy używać operacji I/O, asynchronicznych operacji, timingowania ani struktur alokujących pamięć dynamicznie (takich jak `Vec`, `HashMap`, `String`). W systemach wbudowanych jest to normalne, ponieważ zwykle brakuje systemu operacyjnego, który by obsługiwał te operacje. Istnieją jednak rozwiązania, jak systemy operacyjne [FreeRTOS](https://www.freertos.org/), które umożliwiają korzystanie z tych struktur. Programiści znający Arduino wiedzą, że inicjalizacja `String` wymaga podania długości, ponieważ allokuje pamięć dynamicznie na stercie, a nie na stosie.

Z kolei `std` jest całkowitym przeciwieństwem `no-std` i obsługuje zaawansowane struktury danych alokujące pamięć dynamicznie, takie jak `Vec`, `HashMap` aż po wspracie asynchronicznych operacji.

Poniżej porównanie trybów:

| `std` | `no-std` |
| --- | --- |
| Dostęp do funkcjonalności systemu operacyjnego | Brak dostępu |
| Dynamiczne struktury danych (`Vec`, `HashMap`, itd.) | Ograniczone – można zaimplementować własne algorytmy alokacji |
| Automatyczna ochrona stosu i obsługa `panic!` | Ręczna obsługa wymagana |
| Wsparcie wielowątkowości | Brak wsparcia wielowątkowości |

## Zalety i wady korzystania z Rust

Rust oferuje kilka istotnych zalet:

* **Bezpieczeństwo pamięci** – mechanizmy takie jak borrow checker i ownership zapobiegają powstawaniu tzw. [Undefined Behavior](https://en.wikipedia.org/wiki/Undefined_behavior) przed uruchomieniem programu
* **Bezpieczna współbieżność** – system typów zapobiega data racingu już na etapie kompilacji
* **Przyjazna składnia** – system modułów, pattern matching i bezpieczne makra to tylko niektóre cechy
* **„Kompilator to twój najlepszy przyjaciel”** – komunikaty błędów kompilatora są jasne i klarowne, często zawierają sugestie rozwiązań

Nie obejdziemy się jednak bez pewnych wad:

* **Duży rozmiar binarki** – mimo postępów, skompilowany program zajmuje znacznie miejsca. W praktyce zwykle jest to akceptowalne (4 MB pamięci jest czasem wystarczające), ale na bardzo ograniczonych platformach może być problemem
* **Ograniczona liczba bibliotek** – nie wszystkie komponenty mają natywne sterowniki w Rust. Czasami konieczne jest wywoływanie zaimplementowanych funkcjonalności z C/C++
* **Czas kompilacji** – kompilacja i wgranie na płytkę może zająć więcej czasu
* **Mniejsza społeczność** – ekosystem jest mniejszy, ale z roku na rok się rozwija

## Porównanie kodu C++ i Rust

Przykładowy kod został oparty na podstawowym programie „Hello, World!”, w którym zmieniamy stan wbudowanej diody LED co sekundę, aby uzyskać efekt migania. Poniżej znajduje się kod w C++, korzystający z frameworka Arduino:

```cpp
const int LED_PIN = 13; // Pin diody LED wbudowanej w płytce
const int BLINK_DELAY = 1000; // 1000ms = 1s

void setup() {
  // Konfigurujemy pin odpowiedzialny za diodę LED na płytce
  pinMode(LED_PIN, OUTPUT);
  
  Serial.begin(9600);
}

void loop() {
  // Ustawiamy wysokie napięcie dla diody LED
  digitalWrite(LED_PIN, HIGH);
  Serial.println("LED -> ON");
  
  // Dajemy 1s opóźnienia pomiędzy przełączaniem stanu diody
  delay(BLINK_DELAY);
  
  // Ustawiamy niskie napięcie dla diody LED
  digitalWrite(LED_PIN, LOW);
  Serial.println("LED <- OFF");
  
  // Dajemy 1s opóźnienia pomiędzy przełączaniem stanu diody
  delay(BLINK_DELAY);
}
```

A tutaj Rust, który używa crate'a `arduino_hal`:

```rust
#![no_std]
#![no_main]

use arduino_hal::prelude::*;
use panic_halt as _;

const BLINK_DELAY: u32 = 1000; // 1000ms = 1s

#[arduino_hal::entry]
fn main() -> ! {
    // Inicjalizujemy podstawowe rzeczy dla arduino
    let dp = arduino_hal::Peripherals::take().unwrap();
    let pins = arduino_hal::pins!(dp);

    // Konfigurujemy pin odpowiedzialny za diodę LED na płytce
    let mut led = pins.d13.into_output();

    // Inicjalizujemy zmienną serial dla obsługi wyniku działania programu
    let mut serial = arduino_hal::default_serial!(dp, pins, 57600);

    // Odpowiednik void loop() {} z arduino, który nam zapętla wykonywanie programu
    loop {
      // Ustawiamy wysokie napięcie dla diody LED
      led.set_high();
      ufmt::uwriteln!(&mut serial, "LED -> ON").unwrap();

      // Dajemy 1s opóźnienia pomiędzy przełączaniem stanu diody
      arduino_hal::delay_ms(BLINK_DELAY);

      // Ustawiamy niske napięcie dla diody LED
      led.set_low();
      ufmt::uwriteln!(&mut serial, "LED <- OFF").unwrap();

      // Dajemy 1s opóźnienia pomiędzy przełączaniem stanu diody
      arduino_hal::delay_ms(BLINK_DELAY);
    }
}
```

Różnice między implementacjami są relatywnie niewielkie. W C++ inicjalizacja komponentów płytki jest obsługiwana przez framework Arduino, który ukrywa szczegóły implementacji. W Rust musimy sami zainicjalizować peryferia, ale jest to bardzo przejrzyste. Obie implementacje wymagają zdefiniowania głównej pętli programu i obsługi przerwań sprzętowych.

## Moje doświadczenia

W moim przypadku wcześniej miałem styczność z frameworkiem Arduino, co ułatwiło mi przejście na narzędzia Espressifa. Dlatego przesiadka na narzędzia od Espressifa w ruście nie były dla mnie ciężkie do ogarnięcia. Nawet konfiguracja wyświetlaczy e-ink przebiegała gładko, ponieważ większość popularnych modeli ma już gotowe sterowniki napisane przez społeczność. Prawdziwym wyzwaniem jest borrow checker w źle zaprojektowanych projektach – struktura `Peripherals` może być pożyczona tylko raz, co może prowadzić do problemów przy dokładaniu kolejnych modułów. Czas kompilacji i wgrywania na płytkę może być znaczny ze względu na rozmiar binarki. Dlatego polecam testować grafikę na komputerze, korzystając z symulatora biblioteki [embedded-graphics](https://github.com/embedded-graphics/simulator), co przyspiesza testowanie własnej funkcjonalności.

## Słowem podsumowania

Zainteresowanie Rust w społeczności systemów wbudowanych rośnie z roku na rok. Rosnąca liczba bibliotek, narzędzi i platform wspiera dalszy rozwój ekosystemu. Korzyści oferowane przez Rust, takie jak bezpieczeństwo pamięci, bezpieczna współbieżność i przyjazna składnia mogą znacznie poprawić doświadczenie dewelopera (ang. Developer Experience) w porównaniu z tradycyjnymi językami. Rust rzeczywiście coraz bardziej staje się realną alternatywą dla systemów wbudowanych.
