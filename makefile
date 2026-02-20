KANATA=./scripts/kanata.sh

.PHONY: kstart kstop krestart kstatus

kstart:
	$(KANATA) start

kstop:
	$(KANATA) stop

krestart:
	$(KANATA) restart

kstatus:
	$(KANATA) status