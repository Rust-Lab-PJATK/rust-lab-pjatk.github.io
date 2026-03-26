+++
title = "Rustikon 2026"
date = 2026-03-25
description = "Relacja z naszego drugiego udziału w konferencji Rustikon."
authors = ["Daniel Olczyk"]

[taxonomies]
tags = ["relacja", "rustikon", "konferencja"]
+++

W dniu od 19-20 marca w [Centrum Konferencyjnym POLIN w Warszawie](https://polin.pl/pl/centrum-konferencyjne) mieliśmy przyjemność uczestniczyć oraz jednocześnie być partnerem wydarzenia drugiej edycji konferencji [Rustikon](https://www.rustikon.dev/) przez firmę [SoftwareMill](https://softwaremill.com), która ponownie odbyła się w Warszawie. Wydarzenie to zgromadziło entuzjastów języka Rust z całego świata, oferując bogaty program prelekcji, warsztatów i paneli dyskusyjnych. Łącznie można było usłyszeć 22 prelekcje, które poruszały różnorodne tematy związane z Rustem, od optymalizacji kodu, przez budowanie sieci neuronowych, aż po praktyczne zastosowania w różnych dziedzinach.

## Nasza reprezentacja

![Nasza reprezentacja](/img/rustikon-2026/my.jpg)

W tym roku naszą reprezentację stanowili (od dołu - od lewej do prawej):

* [Daniel Olczyk](https://www.linkedin.com/in/daniel-olczyk/?locale=pl)
* [Borys Piwoński](https://www.linkedin.com/in/bor-piw/)
* [Łukasz Wiszniewski](https://www.linkedin.com/in/kawieki/)
* [Zuzanna Kościelniak](https://www.linkedin.com/in/zuzanna-koscielniak-ba875a243/)

## Pierwszy dzień konferencji

Pierwszy dzień obfitował w prelekcje o najnowszych trendach w ekosystemie Rusta. Otwarcie okazało się sporym (i bardzo pozytywnym!) zaskoczeniem. Andre Bogus, jeden z kontrybutorów Rusta, nawiązał do swojego zeszłorocznego występu z ukulele, tym razem rozgrzewając publiczność parodią hitu [Queen](https://www.youtube.com/watch?v=-tJYN-eG1zk) – własnym utworem _"We Will Rust You"_.

![Andre Bogus na scenie podczas prelekcji](/img/rustikon-2026/andre-bogus-lecture.jpg)

W części merytorycznej Andre prześledził ewolucję swojej implementacji `Option::as_slice` i `Option::as_mut_slice`. Zobaczyliśmy, z jakimi wyzwaniami musiał się zmierzyć na przestrzeni czasu. Była to świetna i pouczająca lekcja o tym, jak ważne jest ciągłe refaktoryzowanie kodu i dostosowywanie go do wymagań języka.

![Paweł Szulc na scenie podczas prelekcji](/img/rustikon-2026/pawel-szulc-lecture.jpg)

Zdecydowanymi faworytami pierwszego dnia były dla nas dwie prelekcje:

* _"Are mutexes slow?"_ – Jon Gjengset
* _"From Micrograd to coppergrad: Building Neural Networks and Backpropagation from Scratch in Rust"_ – Paweł Szulc

Zdecydowanie się nie zawiedliśmy. Oba wystąpienia były naszpikowane merytoryczną wiedzą i dostarczyły nam mnóstwa inspiracji – zarówno w kontekście zarządzania wydajnością i optymalizacji w Ruście, jak i tworzenia sieci neuronowych od zupełnych podstaw.

## Drugi dzień konferencji

Drugi dzień od samego rana trzymał wysoki poziom. Rozpoczęliśmy od prelekcji Mateusza Charytoniuka _"Building a self-hosted LLM ecosystem in Rust: from infrastructure to applications"_, która świetnie naświetliła proces budowania infrastruktury dla modeli językowych. Zaraz potem duet Mateusz Maćkowski i Marek Grzelak w prezentacji _"The Unglamorous Side of Rust Web Development"_ bez owijania w bawełnę opowiedział o bolączkach i wyzwaniach związanych z tworzeniem aplikacji webowych w tym języku.

![Mateusz Maćkowski i Marek Grzelak na scenie podczas prelekcji](/img/rustikon-2026/cotrs-lecture.jpg)

Bardzo praktycznym punktem programu było wystąpienie Marcina Kulika – _"Let's build an async runtime together"_. Prelegent rozłożył na czynniki pierwsze tworzenie własnego środowiska asynchronicznego. Pozwoliło to świetnie zrozumieć mechanikę działania istniejących runtime'ów i poznać kluczowe elementy tej układanki.

Ciekawym spojrzeniem z zewnątrz była prelekcja Mateusza Lenarta _"Getting hired in Rust - Recruiter's perspective"_. Obiegowa opinia głosi, że Rust to głównie blockchain, jednak dane rekrutacyjne pokazują coś innego. To pozytywne zaskoczenie udowadnia, że zapotrzebowanie na "Rustowców" w klasycznym wytwarzaniu oprogramowania stabilnie rośnie.

Mocnym akcentem na zakończenie były dwie świetne prezentacje techniczne:

![Vitaly Brigilevsky na scenie podczas prelekcji](/img/rustikon-2026/vitaly-bragilevsky-lecture.jpg)

* _"Beyond println!: Mastering Rust Debugging"_ – Vitaly Bragilevsky (szef działu Rust w [JetBrains](https://www.jetbrains.com/)) pokazał zaawansowane możliwości debugowania w nowym IDE RustRover, udowadniając jego przewagę nad standardowym zestawem z rust-analyzerem.
* _"Channels in Rust: The Art of Concurrency"_ – Gaurav Gahlot zaprezentował, jak elegancko i efektywnie wykorzystywać kanały do zarządzania współbieżnością i komunikacją między wątkami.

## Stanowiska sponsorskie/partnerskie

Rustikon to nie tylko scena, ale też kuluarowe rozmowy. Strefa stoisk sponsorskich i partnerskich pękała w szwach, stwarzając idealne warunki do networkingu, rozmów o ścieżkach kariery i poznawania nowych narzędzi.

Zaczęliśmy od stoiska głównego organizatora, firmy [SoftwareMill](https://softwaremill.com). Można było tam zgarnąć świetne gadżety (duże kubki, koszulki, wlepki) oraz świetnego dzierganego Ferrisa – choć w tym roku poprzeczka pytań konkursowych była zawieszona znacznie wyżej!

Odwiedziliśmy również [Exein](https://www.exein.io/), gdzie dyskutowaliśmy o bezpieczeństwie w obszarach IoT i Embedded, a także stoisko [SuperTeam Poland](https://superteam.fun/). Tam dowiedzieliśmy się sporo o grantach na projekty w ekosystemie Solany oraz o nadchodzącym hackathonie, w którym zresztą wzięliśmy później udział.

![Fanty, które udało się otrzymać ze stanowisk](/img/rustikon-2026/fanty.jpg)

Na sam koniec zostawiliśmy absolutną perełkę - stoisko firmy [Helsing](https://helsing.ai/de). Następnego dnia zorganizowali oni fascynujące wyzwanie polegające na programowaniu ruchu samochodów po wyznaczonych krawędziach, gdzie kluczową rolę odgrywały algorytmy _computer vision_. Próbowaliśmy całych sił, lecz nie udało nam się ukończyć tego zadania.

<img
    src="/img/rustikon-2026/stanowiska.jpg"
    alt="Zdjęcie strefy stoisk sponsorskich i partnerskich"
    loading="lazy"
/>

## Opinie członków koła

Każdy z nas wrócił z nieco innymi wrażeniami. Oto jak Rustikon 2026 podsumowują nasi członkowie:

### Daniel Olczyk

> Tegoroczny Rustikon nie tylko mnie nie zawiódł, ale wręcz pozytywnie zaskoczył na tle poprzedniej edycji. Poziom prelekcji i kuluarowych jest zauważalny, a wszystko to przy zachowaniu świetnej atmosfery i wzorowej organizacji. Wysłuchałem wielu fascynujących wystąpień, jednak moim absolutnym faworytem był wykład Jona Gjengseta o mutexach. Sposób, w jaki jasno wytłumaczył alternatywy dla standardowych rozwiązań i poparł to twardymi danymi z benchmarków, był po prostu rewelacyjny. Jedyne, czego mi trochę brakowało to więcej czasu na networking w kuluarach, ponieważ natłok prelekcji i nowej wiedzy bywał momentami lekko przytłaczający. Niemniej, całe doświadczenie oceniam bardzo pozytywnie i już nie mogę się doczekać kolejnej edycji!

### Borys Piwoński

> Z perspektywy osoby, która wciąż uczy się Rusta, konferencja była świetnym i bardzo dobrze zorganizowanym doświadczeniem. Najbardziej zapadła mi w pamięć prelekcja o `left_right` - kapitalnie, w głęboko techniczny sposób wyjaśniono tam różnice względem standardowych Mutexów czy RwLocków w wielowątkowości. Na ogromny plus zasługuje też strefa stoisk (świetny mini hackathon i nagrody!) oraz różnorodność tematów prelekcji. Jedyny mały zgrzyt to niekonsekwentne pilnowanie czasu, przez co niektórzy prelegenci musieli dosłownie 'speedrunować' swoje prezentacje, a szkoda, bo tematy były tego warte.

### Zuzanna Kościelniak

> Największe wrażenie zrobiła na mnie prelekcja o mutexach, rwlockach i wzorcu `left_right` - mocno skłoniła mnie do refleksji nad tym, jak podobne problemy rozwiązuje się w innych językach. Bardzo zaciekawił mnie też temat kontrolerów Kubernetesa w Ruście oraz ogólna różnorodność zastosowań tego języka. Ogromny plus za strefę stoisk: mini hackathon, grę w stylu koła fortuny (wielka satysfakcja ze zdobycia kraba!) oraz muzyczną przeróbkę We Will Rock You, której z chęcią słuchałabym na Spotify. Trochę brakowało mi tylko dłuższych przerw między wykładami przy krótszym attention span taki natłok wiedzy bywał lekkim overkillem. Niemniej, całe doświadczenie oceniam bardzo pozytywnie i wracam z ogromną motywacją do dalszej nauki.

### Łukasz Wiszniewski

> Uważam Rustikon 2026 za bardzo udane wydarzenie. Świetni prelegenci i doskonała okazja do networkingu z ekspertami z branży. Dla mnie absolutnym hitem była prelekcja Mateusza Lenarta 'Getting hired in Rust: Recruiter's perspective'. Zobaczyłem, jak trudnym wyzwaniem jest rekrutacja w tym ekosystemie z punktu widzenia rekrutera, który musi weryfikować bardzo 'kreatywne' CV. W zabawny, choć nieco gorzki sposób przedstawił on realia rynku w 2026 roku, gdzie każdy deklaruje w papierach 'doświadczenie z Rustem', ale niekoniecznie potrafi wyjaśnić, czym w ogóle jest borrow checker.

## Podsumowanie

Druga edycja Rustikonu utwierdziła nas w przekonaniu, że społeczność Rusta w Polsce rozwija się w niesamowitym tempie. Były to dwa dni pełne świetnych technicznych prelekcji, inspirujących rozmów w kuluarach i dzielenia się pasją z innymi inżynierami. Wyjechaliśmy z nową wiedzą i jeszcze większą motywacją do działania.
Dziękujemy organizatorom, prelegentom, sponsorom i wszystkim uczestnikom za stworzenie tak wyjątkowego wydarzenia.

Do zobaczenia za rok na kolejnej edycji!
