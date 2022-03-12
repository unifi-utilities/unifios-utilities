# HDHomeRun VLAN Traversal

## License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
THE SOFTWARE.

## Reference

From https://community.ui.com/questions/Howto-HDHomerun-discovery-on-different-LAN-segment/97db52c6-4add-4ba1-ab0d-27ee6f43db8f

## Purpose

The HDHomeRun software sends a UDP broadcast out to the HDHomeRun tuner as part
of the discovery process.  If your HDHomeRun is on a separate VLAN, you need 
some sort of proxy to push this UDP broadcast out to the target network.

Also `socat` is a useful tool and maybe you want to cross-compile it for your 
UDMP(SE)

## Compiling `socat`

In the `build` directory, there is a Docker file to cross compile a socat 
binary for the Dream Machine Pro.

```docker build -t build_socat .```
```docker run -v $PWD:/tmp/release build_socat```

The first command builds the container, and the second runs the container.  The
container will copy the binary inside the container to `/tmp/release`.  The -v
volume mapping will case the file to apper in the current working directory of
the host.

Precompiled binary is provided.  Use at your own risk.

## Setting up the on.boot script

1. Update the `99-hdhomerun.sh` script with the IP address of your HDHomeRun
   tuner.
2. Place it in your `on_boot.d` folder and make it executable.
3. Reboot your UDMP(SE) or restart the service with something like 
   `systemctl restart udm-boot`
4. You can verify the script is running with `ps aux | grep "socat"`
5. The HDHomeRun software should now be able to discover the tuner on the 
   other VLAN.

## Testing

This was tested with an HDHomeRun PRIME.  I do not know if it works with other
hardware.