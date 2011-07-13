INSTALL = install

install:
	$(INSTALL) -D -m0644 51-android.rules /etc/udev/rules.d/51-android.rules
