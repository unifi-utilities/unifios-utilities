## How to Install AdGuard Home in Container

This guide assumes you have already created and started an nspawn container as instructed in the [main README](../../README.md), and have configured an isolated macvlan network for your container.

To install AdGuard Home, we simply run the automated install as instructed in the [AdGuard Home documentation](https://github.com/AdguardTeam/AdGuardHome#automated-install-unix). 

1. Spawn a shell to your container.

    ```sh
    machinectl shell debian-custom
    ```

2. Run the automated install command from the adguard documentation and follow the prompts. Refer to the pihole documentation for more details. 

    ```sh
    apt -y install curl
    curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
    ```

3. Go to http://10.0.5.3:3000 to configure AdGuard Home (or whatever IP you configured for your container).
4. After configuration, you can access Ad Guard Home web gui at http://10.0.5.3.
5. Now you can set your LAN clients to use the AdGuard Home IP 10.0.5.3 as the DNS, or use dig to test DNS resolution from a client (e.g.: `dig @10.0.5.3 google.com A`). 
