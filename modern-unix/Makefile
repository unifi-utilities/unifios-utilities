RSYNC_FLAGS ?= -Ravuzh --no-o
SCP_FLAGS ?= -O -o LogLevel=Error
SSH_FLAGS ?= -o RemoteCommand=none -o LogLevel=error
SSH_HOST ?= root@192.168.16.1 # IP address of the UDM in the local network

.PHONY: push-config
push-config:
	ssh $(SSH_FLAGS) $(SSH_HOST) 'mkdir -p /data/on_boot.d /data/scripts; rm -rf /data/scripts/*.sh'
	chmod +x ./on_boot.d/*.sh
	rsync $(RSYNC_FLAGS) ./on_boot.d/ ./scripts/ ./settings/ $(SSH_HOST):/data/

.PHONY: install-tools
install-tools:
	ssh $(SSH_FLAGS) $(SSH_HOST) /data/scripts/download-tools.sh

.PHONY: all clean test
