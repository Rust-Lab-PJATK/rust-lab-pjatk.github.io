+++
title = "HackYeah 2025"
draft = false
date = 2025-10-16
description = "Największy hackathon w Europie naszymi oczami"
authors = ["Daniel Olczyk"]

[taxonomies]
tags = ["relacja", "hackathon", "hackyeah"]
+++

W pierwszy weekend października 03.10-04.10 w Krakowie odbył się największy hackathon w Europie [HackYeah 2025](https://hackyeah.pl/), który miał miejsce w [TAURON Arenie](https://www.tauronarenakrakow.pl/). Tysiące programistów, projektantów i pasjonatów technologii spotkało się w jednym miejscu, by w ciągu 24 godzin stworzyć rozwiązania na zadane tematy i zawalczyć o nagrody. Wraz z częścią naszego zespołu postanowiliśmy podjąć wyzwania stworzenia aplikacji na dany temat w 24 godziny. Udało nam się ją zbudować — a czy zdobyliśmy nagrodę? O tym za chwilę.

![Nasza reprezentacja](/img/hackyeah-2025/grupowe.jpg "Nadal uśmiechnięci po tak wymagającym hackathonie")

Z naszej reprezentacji koła naukowego wzięli udział (od lewej strony):

- [Norbert Olkowski](https://www.linkedin.com/in/norbert-olkowski/)
- [Łukasz Wiszniewski](https://www.linkedin.com/in/kawieki/)
- [Daniel Olczyk](https://www.linkedin.com/in/daniel-olczyk/)

## Początek wydarzenia

Na start przeszliśmy się po stoiskach sponsorów, wśród których znaleźli się między innymi KNF, ZUS oraz Województwo Małopolskie. Każde z nich przyciągało uwagę nie tylko atrakcyjną oprawą wizualną, ale też ciekawymi zadaniami i gadżetami.

Na przykład stoisko Heinekena oferowało skarpety i gumowe kaczuszki - [nieodłączny symbol wśród programistów](https://pl.wikipedia.org/wiki/Metoda_gumowej_kaczuszki). Z kolei na stanowisku AGH trzeba było rozwiązać losowe zadanie matematyczne - my wylosowaliśmy zadanie związane z [entropią](https://pl.wikipedia.org/wiki/Entropia_(teoria_informacji)), co okazało się przyjemnym intelektualnym rozruchem przed właściwym startem hackathonu.

Spacer po stoiskach pozwolił nam złapać pierwsze wrażenia z wydarzenia oraz poczuć atmosferę współzawodnictwa, która towarzyszyła uczestnikom już od samego początku.

## Formowanie zespołu i start pracy

Przed oficjalnym rozpoczęciem hackathonu postanowiliśmy rozbudować nasz skład o osoby z uczelni Akademia Górniczo-Hutnicza im. Stanisława Staszica w Krakowie podczas team buildingu o 11:00, który odbywał się na wydarzeniu. Wspólna rozmowa szybko przerodziła się w konkretną współpracę, a nasz ostateczny zespół "Golphins" wyglądał następująco (od lewej):

- [Norbert Olkowski](https://www.linkedin.com/in/norbert-olkowski/)
- Jakub Ziomek
- [Bartłomiej Wajdzik](https://www.linkedin.com/in/bartlomiejwajdzik)
- Jakub Szpunar
- [Daniel Olczyk](https://www.linkedin.com/in/daniel-olczyk/)
- [Łukasz Wiszniewski](https://www.linkedin.com/in/kawieki/)

![Zespół "Golphins"](/img/hackyeah-2025/druzyna_golphins.jpg "Golphins to my!")

Nazwa drużyny powstała spontanicznie - pochodziła od mojej czapki, którą miałem na sobie, gdy mentorzy poprosili nas o podanie nazwy zespołu, zanim jeszcze zdążyliśmy wspólnie coś ustalić.

![Moja czapka](/img/hackyeah-2025/czapka.jpg "Tak właśnie wyglądała moja czapka")

Gdy zegar wybił 12:00, rozpoczęliśmy oficjalne wyzwanie. Najpierw dokładnie zapoznaliśmy się z opisem zadań i wspólnie przeanalizowaliśmy możliwe kierunki realizacji. Pierwsze dwie godziny poświęciliśmy głównie na research oraz wysłuchanie wybranych prelekcji: ["Otwarte dane – paliwo dla miejskich aplikacji" Pawła Schmidta](https://hackyeah.pl/lecture_conference_2025#id=103148) oraz ["Czy w transporcie publicznym pasażerowie mogą mieć realny wpływ na opóźnienia?" Marcina Podolaka](https://hackyeah.pl/lecture_conference_2025#id=102559), które pomogły nam lepiej zrozumieć oczekiwania partnerów. To był spokojny, ale bardzo ważny moment przed właściwym wysiłkiem.

## Wybór tematu i dalsze prace

Zdecydowaliśmy się na realizację tematu [Journey Radar](https://hackyeah.pl/tasks/DETAILS_Malopolska_Journey_Radar.pdf), który najbardziej pasował do naszych pomysłów. Początkowe godziny pracy nie należały jednak do łatwych - przez pierwsze siedem godzin zmagaliśmy się z wieloma problemami technicznymi. Słabe łącze Wi-Fi utrudniało pobieranie modeli [GTFS](https://gtfs.org/), pojawiały się momenty klasycznego overengineeringu rozwiązania, a do tego doszły problemy z zalogowaniem się do konta w Microsoft Azure.

Na szczęście równolegle rozwijał się frontend - dzięki temu czas nie był całkowicie stracony. Gdy w końcu udało się uruchomić zdalną bazę danych i przeprowadzić pierwsze migracje, projekt nabrał tempa.

Około godziny 20:00 należało przygotować wstępne zgłoszenie, zawierające nazwę projektu, krótki opis, nazwę zespołu oraz jego skład. Po krótkiej burzy mózgów zdecydowaliśmy się na nazwę "PulseTransit", która została z nami do końca hackathonu.

Po formalnościach mogliśmy wreszcie w pełni skupić się na backendzie i testowaniu naszego modelu. Prace zaczęły przebiegać płynniej, a zespół nabierał rytmu - przed nami była długa noc kodowania.

## Druga połowa wyzwania

![Widok z trybun](/img/hackyeah-2025/widok_z_gory.jpg "Widok na nasz stół z trybun")

Po północy tempo pracy wcale nie spadło - wręcz przeciwnie, nabrało rozpędu. Mimo zmęczenia kolejne godziny upływały pod znakiem intensywnego kodowania i wdrażania nowych funkcjonalności. Backend rozrastał się o kolejne endpointy, a aplikacja webowa przestała być jedynie mockupem, lecz zaczęła prezentować realne dane i pobierać realne dane z serwera.

Przygotowywaliśmy też infrastrukturę pod prezentację, dbając o to, by całość działała stabilnie. W tle nie brakowało muzycznego wsparcia - puszczony przez organizatorów ["Ratata"](https://www.youtube.com/watch?v=UaCUE33zZmM) co godzinę dodawał energii, a widok uczestników tańczących belgijkę skutecznie podtrzymywał morale.

Część zespołu pozwoliła sobie na krótką drzemkę, inni działali bez przerwy. Pomimo upływu czasu i rosnącego zmęczenia, skupienie nie malało. Udało nam się zaimplementować model raportowania sytuacji w trakcie podróży, który klasyfikował zgłoszenia użytkowników i oceniał ich wiarygodność w oparciu o dane z innych raportów.

Ostatnia godzina okazała się najbardziej intensywna - dopracowywaliśmy prezentację, uzupełnialiśmy opis projektu, wdrażaliśmy rozwiązanie na serwer i przenosiliśmy model klasyfikacji na środowisko testowe. Udało się domknąć wszystko dosłownie dwie minuty przed końcem hackathonu. Wysłaliśmy zgłoszenie, odetchnęliśmy głęboko i po raz pierwszy od wielu godzin mogliśmy na chwilę się rozluźnić.

## Projekt „PulseTransit”

Aplikacja, która pomaga osobom podróżującym po Małopolsce dotrzeć z punktu A do punktu B z możliwie najmniejszymi opóźnieniami. System analizuje dane o transporcie publicznym oraz zgłoszenia użytkowników, by w razie utrudnień zaproponować alternatywne trasy ze środkami transportu.

Użytkownicy mogą raportować zdarzenia takie jak korki, wypadki czy zatłoczenie pojazdów, a aplikacja klasyfikuje je i weryfikuje w tle, porównując z innymi zgłoszeniami. Gdy dane się pokrywają, system automatycznie generuje komunikaty oraz rekomenduje inne opcje podróży.

W trakcie hackathonu udało nam się stworzyć w pełni działające MVP, obejmujące backend, klasyfikację zgłoszeń oraz wdrożenie aplikacji na serwer demonstracyjny.

Przykładowe wykorzystane technologie:

- Backend: ASP.NET Core Web API, Entity Framework Core, PostgreSQL, MediatR, Mapperly
- Frontend: Figma make, React, Vite, radix-ui, lucide
- AI: Python, FastAPI, pyproj, contextlib, BeautifulSoup, requests, pandas, partridge
- Dane: GTFS (ZTP Kraków)

Interfejs aplikacji zaprojektowaliśmy w Figmie, a poniżej znajduje się wizualizacja połączonych ekranów prezentująca najważniejsze funkcjonalności projektu:

![Finałowa wersja aplikacji](/img/hackyeah-2025/aplikacja.png)

Kod źródłowy jest dostępny w repozytorium na [GitHubie](https://github.com/Rust-Lab-PJATK/hackyeah-25-journey-radar), natomiast prezentację możecie ujrzeć [pod tym linkiem](/blob/hackyeah-2025/PulseTransit.pdf).

## Finalny werdykt

Na ogłoszenie wyników czekaliśmy do 15:00, gdy organizatorzy opublikowali listę zespołów zakwalifikowanych do finału. Atmosfera była pełna napięcia - po ponad dobie intensywnej pracy każdy z nas z niecierpliwością czekał na informację na discordzie licząc, że zobaczy tam nazwę  swojego zespołu.

Tym razem jednak szczęście nie było po naszej stronie - nie znaleźliśmy się wśród finalistów. Mimo tego poczuliśmy satysfakcję z tego, co udało nam się osiągnąć w tak krótkim czasie. Nasze rozwiązanie działało oraz najważniejsze elementy zostały dowiezione  - to już samo w sobie było sporym sukcesem.

Finalnie w tym temacie zwyciężył zespół Solvrownicy w piaskownicy od [KN Solvro](https://solvro.pwr.edu.pl/en/), a drugie miejsce zajął zespół MIKOxC(offe)++. Wielkie gratulacje dla obu zespołów!

## Wrażenia po wydarzeniu

![TAURON Arena wypełniona aż po przegi](/img/hackyeah-2025/arena.jpg)

To wydarzenie udowodniło, że jest wyjątkowym miejscem dla pasjonatów tworzenia technologii. Przez 24 godziny uczestnicy z całej Polski wspólnie tworzyli projekty, korzystali ze wsparcia mentorów, wymieniali doświadczenia i ratowali się kawą, gdy zmęczenie dawało o sobie znać. Nocne godziny przyniosły widok dziesiątek osób drzemiących przy laptopach - a mimo to atmosfera pozostawała pełna energii, współpracy i pasji do tworzenia.

Po zakończeniu hackathonu nasi członkowie wyrazili swoje wrażenia z wydarzenia:

### Norbert Olkowski

> HackYeah znowu zrobił swoje: brak snu, hektolitry kofeiny i mnóstwo satysfakcji!  Mega inspirujący weekend, świetni ludzie, genialna atmosfera i tona pomysłów na przyszłość.
> 

### Łukasz Wiszniewski

> Jeden z lepszych treningów psychiki, wytrzymałości, 24h walki z kodem i niesfornymi błędami sklejania aplikacji, podczas gdy z tyłu atakowała chęć powrotu do domu po dawce snu. Ciekawe i budujące doświadczenie, sama atmosfera była niesamowita - w szczególności, jak się patrzyło na ponad 2 tysięcy ludzi budujących swoje projekty. Nie ma co zbytnio rozpisywać się, to po prostu trzeba doświadczyć na własnej skórze.
> 

### Daniel Olczyk

> Całe te wydarzenie przypomniało za co lubię tego typu stacjonarne wydarzenia: 24h pisania losowych ciągów na klawiaturze, dyskusje w drużynach, sporej dawki kofeiny, słuchania “Ratata”, które dawało motywację do rozwijania projektu no i praktycznie bez żadnego snu. Klimat robił tutaj największe znaczenie - zebranych ponad 2 tyś osób w jednym miejscu, aby stworzyć coś ciekawego, a później w nocy, gdy na korytarzach/stanowiskach można było ujrzeć drzemiących ludzi. Satysfakcja, gdy dowiozło projekt do końca była po prostu niesamowita.
> 

## Podsumowanie

Choć nie weszliśmy do finału, ten 24 godzinny maraton był dla nas dużym krokiem naprzód. W realnych warunkach zbudowaliśmy działające MVP z backendem, klasyfikacją zgłoszeń i wdrożeniem na serwer, a po drodze ogarnęliśmy problemy z infrastrukturą i łącznością. Największą wartością okazała się zgrana praca zespołu i tempo, w jakim potrafimy podejmować decyzje i dowozić funkcjonalności pod presją czasu.

Dziękujemy [Bartłomiejowi Wajdzikowi](https://www.linkedin.com/in/bartlomiejwajdzik), Jakubowi Ziomkowi i Jakubowi Szpunarowi za zaufanie, pomoc, wspólnie spędzony czas i świetną współpracę. Wrócimy za rok z konkretnym planem tak, aby wrócić z Krakowa wygraną.
