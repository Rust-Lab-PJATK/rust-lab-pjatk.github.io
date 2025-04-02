+++
title = "Rustikon 2025"
date = 2025-04-02
description = "Relacja z naszego udziału w pierwszej w Polsce konferencji poświęconej językowi Rust."
authors = ["Maciej Pędzich"]

[taxonomies]
tags = ["relacja", "rustikon", "konferencja"]
+++

## Nasza reprezentacja

26 marca 2025 roku w [Centrum Konferencyjnym POLIN w Warszawie](https://polin.pl/pl/centrum-konferencyjne) odbyła się pierwsza w Polsce międzynarodowa konferencja dla programistów języka Rust - [Rustikon](https://www.rustikon.dev). Jako koło naukowe skupione wokół tego języka (i to z uczelni z miasta-gospodarza) wręcz nie wypadałoby nie wziąć udziału w tym wydarzeniu.

![Uśmiechnięci reprezentanci koła Rust Lab stojący na schodach i trzymający etykiety z imionami](/img/rustikon-2025/grupowe.jpg)

W skład naszej reprezentacji (na zdjęciu powyżej) weszli:

- [Daniel Olczyk](https://www.linkedin.com/in/daniel-olczyk) - w przednim rzędzie z lewej
- [Łukasz Wiszniewski](https://www.linkedin.com/in/%C5%82ukasz-wiszniewski-382a82295) - w przednim rzędzie z prawej
- [Łukasz Ciwoniuk](https://www.linkedin.com/in/lukaszciwoniuk) - w tylnym rzędzie z lewej
- [Maciej Pędzich](https://www.linkedin.com/in/maciejpedzich) - w tylnym rzędzie w środku
- [Przemysław Oneksiak](https://www.linkedin.com/in/przemys%C5%82aw-oneksiak-002a2b23a) - w tylnym rzędzie z prawej

## Koło fortuny i dziergany Ferris

Ze stoisk sponsorskich najciekawsze było naszym zdaniem stoisko samego organizatora konferencji, [firmy SoftwareMill](https://softwaremill.com), która przygotowała koło fortuny z pytaniami dotyczącymi języka Rust i jego ekosystemu.

Każda poprawna odpowiedź mogła zostać nagrodzona drobynm upominkiem, w tym dzierganą maskotkę Ferrisa. Spodobała nam się ona do tego stopnia, że każdy z nas zgarnął po jednym takim krabie.

<img
  src="/img/rustikon-2025/ferris.jpg"
  alt="Dziergany Ferris siedzący na laptopie"
  loading="lazy"  
/>

## Ulubione prelekcje

Na konferencji można było wysłuchać łącznie 14 prelekcji poruszających różne aspekty tworzenia oprogramowania w języku Rust, od przeglądu i konfiguracji mniej lub bardziej znanych narzędzi deweloperskich, aż po tajniki oraz pułapki programowania asynchronicznego.

Nasi członkowie wskazali prezentacje, które najbardziej zapadły im w pamięć i dlaczego.

### Daniel Olczyk

> Dla mnie to zdecydowanie drugi wykład, który się nazywał _Reasoning with Async Rust_. Dobra analogia do życia codziennego, jako przygotowania śniadania do poznania zaawansowanej asynchroniczności.
>
> Znajomość użycia `join!` czy `select!` pozwoli na rozwiązaniu wielu problemów z współbieżnością w zaawansowanych projektach, gdzie operacja kolejnością zadań może być kluczowa.

<img
  src="/img/rustikon-2025/reasoning-with-async-rust.jpg"
  alt="Slajd z prezentacji Reasoning with Async Rust przedstawiający przykład wykorzystania join i select."
  loading="lazy"  
/>

### Łukasz Wiszniewski

> Najbardziej podobała mi się ostatnia prelekcja, czyli _Strongly Typed Financial Software_. W ciekawy sposób przedstawiono dobre wykorzystanie bezpieczeństwa i szybkości Rusta (dwa najważniejsze aspekty w tej branży) oraz pokazanie, że nie trzeba polegać wyłącznie na Javie 😁.

<img
  src="/img/rustikon-2025/stfs.jpg"
  alt="Slajd z prezentacji Strongly Typed Financial Software z memem z Gusem Fringiem"
  loading="lazy"
/>

### Łukasz Ciwoniuk

> Szczerze, najbardziej spodobała mi się prelekcja _Using CRDTs Beyond Text Editors_.
>
> Odkrycie, że istnieją niezawodne i powtarzalne sposoby rozwiązywania konfliktów spójności w replikowanych danych bez użycia timestampów czy pełnego logu zmian, otworzyło mi oczy na wiele nowych możliwości implementacji tego typu systemów.
>
> Podejście to wydaje mi się szczególnie przydatne nie tylko w ekstremalnych warunkach, jak w przypadku firmy Helsing, ale także w bardziej powszechnych scenariuszach wymagających wysokiej dostępności i odporności na błędy.

<img
  src="/img/rustikon-2025/crdt-1.jpg"
  alt="Slajd tytułowy prezentacji Using CRDTs Beyond Text Editors"
  loading="lazy"
/>

### Przemysław Oneksiak

> Osobiście, również mi przypadła do gustu ta ostatnia prelekcja - _Strongly Typed Financial Software_. Niby sam temat dosyć prosty i znany z innych języków, ale bardzo fajnie i przejrzyście wyjaśniony z przykładami, gdzie pewne nawyki okazują się pomocne.
>
> Wymieniłbym jeszcze ten wykład o 12:25 - _Using CRDTs Beyond Text Editors_. Nie miałem pojęcia o istnieniu takiej struktury danych, także koncepcyjnie bardzo spoko było posłuchać, mimo że temat wydaje się całkiem trudny.
>
> Również na plus moim zdaniem że to jest całkiem nowe rozwiązanie. Z tego co sprawdziłem, to taka koncepcja istnieje od niedawna, bo od 2011 roku.

<img
  src="/img/rustikon-2025/crdt-2.jpg"
  alt="Slajd z prezentacji Using CRDTs Beyond Text Editors przedstawiający mechanizm automerge"
  loading="lazy"
/>

### Maciej Pędzich

> Najbardziej zapadła mi w pamięć prezentacja [Andre Bogusia](https://www.linkedin.com/in/andre-bogus-8a6784172) pt. _Improving Your Rust Life_ z dwóch powodów. Po pierwsze, zaśpiewanie _hymnu_ na cześć języka Rust w akompaniamencie ukulele stanowiło zabawne otwarcie konferencji.
>
> Po drugie, Andre omówił wiele mniej znanych opcji konfiguracyjnych narzędzia `cargo`, warte włączenia reguły lintera `clippy`, dobre praktyki pisania testów jednostkowych i migawkowych, a także wiele przydatnych wtyczek do `cargo` usprawniających proces tworzenia, testowania i kompilacji projektów.
>
> Znajomość tych zagadnień rzeczywiście potrafi ulepszyć nie tylko życie programisty języka Rust, ale też jakość jego kodu.

<img
  src="/img/rustikon-2025/improving-your-rust-life.jpg"
  alt="Slajd z prezentacji Improving Your Rust Life przedstawiający aliasy komend cargo"
  loading="lazy"
/>

## Podsumowanie

Tegoroczną edycję Rustikonu uważamy za udaną. Mamy nadzieję, że będzie nam dane uczestniczyć w tej konferencji ponownie w 2026. Kto wie, być może jeden z członków naszego koła zostanie w przyszłości prelegentem na tej konferencji?

Do zobaczenia za rok!
