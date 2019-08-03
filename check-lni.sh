#!/bin/bash
#set -x

DEST=$1
ADDRESS=https://www.lnipozzuoli.it

notifyerror() {
	echo -e "Error. New date: $(cat date.new); New msg: $(cat msg.new)"
	echo -e "Error. New date: $(cat date.new); New msg: $(cat msg.new)" | mail -s "News dalla Lega Navale" $DEST
}

notifychange() {
	echo -e "$(cat date.new)\n\n$(cat msg.new)\n\n$URL"
	echo -e "$(cat date.new)\n\n$(cat msg.new)\n\n$URL" | mail -s "News dalla Lega Navale" $DEST
}

check4changes() {
	curl -s $ADDRESS > home.html
	[ ! -s home.html ] && notifyerror && exit 1
	cat home.html | grep '<div class="latestnews-date"' | head -1 | awk -F"</i>" '{print $2}' | awk -F"</div>" '{print $1}' | xargs > date.new
	cat home.html | grep -A1 '<span itemprop="name"' | head -2 | tail -1 | awk -F"</span>" '{print $1}' | xargs > msg.new
	URL=$(cat home.html | grep "itemprop=\"url\"" | head -1 | awk '{print $2}' | sed "s,href=,$ADDRESS," | tr -d \")
	[ ! -s date.new ] && [ -z "$(cat date.new)" ] && notifyerror && exit 1
	[ ! -s msg.new ] && [ -z "$(cat msg.new)" ] && notifyerror && exit 1
	[ ! -f date.old ] && cp date.new date.old
	[ ! -f msg.old ] && cp msg.new msg.old
		
	[ ! -z "$(diff date.old date.new)" -o ! -z "$(diff msg.old msg.new)" ] && notifychange
	mv date.new date.old
	mv msg.new msg.old
	exit 0
}

check4changes || check4changes
