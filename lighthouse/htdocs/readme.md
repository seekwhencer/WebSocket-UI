Lighthouse IP Exchange

Diese App registriert die IP-Adressen aller Geräte die sich regelmäßig (sekündlich) melden und
gibt sie an Geräte zurück, die nach einem bestimmten Gerät fragen.

Relevant z.Z. die IP des Relays und sofortiges reagieren der Clients, wenn
sie selbst oder der Relay ein IP Change macht.

Die letzte Meldung eines Gerätes wird als JSON in /tables/ gespeichert.
Der Name einer Datei besteht aus dem Modus und dem Namen eines Gerätes.
Diese Kombination sollte unique sein. Somit existiert kein Gerät mit
dem Modus-Namen-Paar doppelt.


==================
Meldung pro Gerät
===================

http://lighthouse.yourdomain.tld/getip/mode=name

Mit mode=name identifiziert sich das Gerät. Zurück bekomt das Gerät nur die eigene WAN IP.
Gleichzeitig wird die aktuelle IP des Gerätes gespeichert.

/tables/mode-name.json

{
    "ip":"127.0.0.1",
    "mode":"name",
    "name":"mode",
    "time":1436109389
}



===================
Get Relay IP
===================

Will ein Client wissen, wie die IP des Relays ist, ruft der Client diese URL auf:

http://lighthouse.yourdomain.tld/getrelayip/relayname

Zurück kommt nur die IP des Relays mit dem Namen: relayname - in unserem Falle: main


Aktzeptiert werden nur:

    relay   = main
    device  = orb
    webui   = desktop, mobile, smartphone, pipboy, relaymonitor

Festgelegt in der Lighthouse Class als $accepted_nodes.



===================
Installation
===================

    Apache
    mod_rewrite
    Follow Sym Links
    .htaccess
    Schreibrechte