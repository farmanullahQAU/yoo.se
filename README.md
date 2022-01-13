# YOO.SE

YOO.SE är en applikation utvecklad av We Know IT på uppdrag av Joachim von Rost på IT'S A WRAP AB.

* Projektledare: Max Mellander
* Utvecklare: Albin Jaldevik (författare av denna text)

## Tidslinje
* Projektet startades i samband med att Joachim tog kontakt med We Know IT under juni 2019 för utvecklingen av YOO.SE appen.
* En förstudie initierades där kravspecifikation, tidsestimering och mockup framtogs utifrån den initiala beskrivningen.
* Utvecklingsarbetet påbörjades i augusti och första fungerande versionen av appen
färdigställdes i september 2019.
* I oktober och november testades appen av inbjudna testare och uppdaterades efter önskemål och reaktioner.
* I december skickades ansökan om publikation på App Store och Google Play Store.

## Teknisk Specifikation
* YOO.SE appen är utvecklad i Googles apputvecklingsramverk Flutter då detta möjliggjorde samma kodbas för iOS och Android.
    * För state management används Provider och RxDart.
    * Ingen plattformsspesifik kod har skrivits.
    * Tredjepartspaket använda finns listade i [pubspec.yaml](pubspec.yaml) filen.
* Flera delar av Google Firebase har även använts.
    * Firestore som databas.
    * Anonymous Authentication för att hålla koll på vem som får se vems plats.
    * Firebase Dymamic Links för generering och hantering av smarta länkar som öppnar appen.
    * Cloud Functions för vissa mer kritiska serverfunktioner t.ex. för att gå med i en "delningsgrupp".
    * App Distribution för test på Android enheter.
    * Firebase Analytics.

## Driftkostnader
För att hålla applikationen online finns vissa driftkostnader.

#### Fasta
* Licens för Google Play Store: 25$ engångskostnad.

* Licens för App Store: 100$ / år.

#### Rörliga
* Firebase. Definitivt __viktigaste__ kostnaden att hålla ett öga på då appen nu är inställd
på att uppdatera användarnas positioner väldigt ofta. Firebase är gratis upp till en viss nivå av användning
och kostar sedan löpande. Jag förutspår att det viktigaste mätvärdet för YOO.SE appen i nuläget kommer att vara
antalet [läsningar av databasen](https://console.firebase.google.com/u/0/project/yoose-70566/database/firestore/usage/last-24h/reads) då detta är det som används mest. Kostnaden för läsningar är 6kr / 1 000 000 läsningar.
Dessutom är de första 50 000 läsningarna varje dag gratis. Det ska finnas alarm och liknande för dessa kostnader som jag
rekommenderar att ställa in för att inte få någon oväntad faktura. Om antalet läsningar skulle bli för högt i produktion kan
dessa sänkas genom att uppdatera appen med uppdaterade inställningar för hur ofta användarnas position uppdateras.

* [Google Maps](https://console.cloud.google.com/google/maps-apis/overview?project=yoose-70566&folder=&organizationId=) innebär tekniskt sätt också en rörlig kostnad som man skulle kunna hålla ett öga på. Jag förutspår dock
att det kommer vara gratis eller i pricip gratis.

## Analytics
YOO.SE appen har Google Analytics installerade som kan visas i [firebase consolen](https://console.firebase.google.com/u/0/project/yoose-70566/analytics/app/android:yoo.se.yoo_se/overview).

Det går också att ta del av viss data från Google Play Console samt App Store Connect.