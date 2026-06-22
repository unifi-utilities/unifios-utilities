# unifi-common

Allows you to run shell scripts at S95 anytime your UniFi device starts up.

Useful for starting scripts, applying custom config, or any other boot-time work.

> [!IMPORTANT]
> Targets **UniFi OS 4.x and above** (systemd runs natively on the host).

## Install

```bash
curl -fsL "https://raw.githubusercontent.com/unifi-utilities/unifi-common/HEAD/remote_install.sh" | /bin/bash
```

## Offline Install

1. Copy `udm-boot.service` to `/etc/systemd/system/udm-boot.service` on the device.
2. Run `manual-install/install.sh` **on the device**

## Done?

Head over to the addons repository to find some scripts to run at boot:

<https://github.com/unifi-utilities/unifi-common-addons>

## Missing something?

> [!TIP]
> We have moved the old addons to a new repository to make it easier to maintain and add new addons. If you have an addon that you would like to see added, please open an issue or submit a pull request.

<https://github.com/unifi-utilities/unifios-utilities-archived>
