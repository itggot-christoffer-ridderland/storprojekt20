# Projektplan

## 1. Projektbeskrivning (Beskriv vad sidan ska kunna göra)  

Appen skall vara en **bracket-app** där användare skall kunna 
skapa och delta i  **turneringar**.  
Appen skall även spara färdiga **brackets** för inloggade användare
där deltagare och host skall kunna komma åt sina turneringar från
sin profil. Bara skaparen och admin skall kunna tag bort turneringen.  

## 2. Vyer

[![skisser.png](https://i.postimg.cc/P5BV2vNc/skisser.png)](https://postimg.cc/xX3PdCvy)

## 3. Databas med ER-diagram + Arkitektur

[![erdiagram.png](https://i.postimg.cc/pr8B6q7n/erdiagram.png)](https://postimg.cc/T5dmyqTR)

**_app.rb:_** sköter logiken relaterat till slim, sinatra och sköter vad olika routes ska göra  
**_views:_** innehåller alla _.slim_ filer  
**_views/layout.slim:_** allt som skall finnas på alla sidor, t.ex header  
**_views/index.slim:_** huvudsida  
**_views/users:_** alla _.slim_ filer relaterat till användare  
**_views/tournaments:_** alla _.slim_ filer relaterat till turneringar  
**_public:_** det som användaren kommer kunna ha tillgång till  
**_public/css:_** CSS  
**_public/js:_** eventuell javasctipt  
**_public/img:_** bilder och svgs  
**_db:_** här ligger databasen  
**_db/braketz.db:_** Databas  


## 4. Domänbeskrivning

En oinloggad användare kan bara skapa konto och logga in  
När en användare loggat in kan den skapa turneringar, visa sina turneringar  
samt tag bort turneringar de själv har skapat  
De kan även logga ut och tag bort sitt koto  
En admin kan även tag bort andras turneringar