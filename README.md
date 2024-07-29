# nouveau-reсlocking

## Description 

By default, your GPU runs at a low video core/memory frequency when using
Nouveau, because Nouveau does not support automatic memory management due to
restrictions imposed by NVIDIA. This is the main reason for the low performance
of Nouveau, which is why you only get 10% of what you get with a proprietary
driver. However, Nouveau also supports manual power management of your graphics
card, this is called reclocking. Nouveau only supports reclocking of GM10x
Maxwell, Kepler, Tesla G94-GT218 (and Fermi?) GPUs. If your video card belongs
to one of these generations, with reclocking you can get already about ~80% of
the performance (see links below for benchmarks) from using with a proprietary
driver.  This allows Nouveau to be competitive for older video cards which are
limited to support the closed NVIDIA 390xx or 340xx and lower driver. It still
might not be impressive to want to use Nouveau, but in the section below you
can read more reasons for this.

This little utility for Lua should help simplify your reclocking process and
make it easier. Note that if your GPU does not support reclocking, this utility
is probably useless for you.

It requires no external dependencies and should work on any distribution. Read
the installation block below.

**IMPORTANT NOTE:** For Turing generation and above (16xx/20xx/30xx/40xx
cards), Nouveau runs automatic power management with Nvidia's GSP firmware, so
you don't need to use this script if you own those cards. If automatic power
management doesn't work for you on these cards, make sure you have the kernel
parameter ``nouveau.config=NvGspRm=1`` set (although most distributions have it
enabled by default). Also note that owners of GPUs from Maxwell onwards can
also use NVK drivers to run Vulkan together with this script for performance
gains, but you need to install latest mesa-git with commit
(https://gitlab.freedesktop.org/mesa/mesa/-/commit/ec7924ab9036cdc4637c9878e152e4460794cb5b).

## Installation

You need Git and Lua. The script is compatible with any version of Lua, so it
should not cause compatibility issues with different distributions:

```
git clone https://github.com/ventureoo/nouveau-reclocking.git
cd nouveau-reclocking/src
sudo ./nouveau-reclocking
```

## Usage

The script has several options that can be useful for setting relative Pstates
and multicard configurations such as ``--max``, ``--min`` and ``--card``:

```
nouveau-reclocking [-c] [--save [path]] {--pstate|--max|--min|--list|--help|--version} 

Options:
  -c --card      Set for a specific card only (numeric ID)
  -s --pstate    Set Pstate value
     --max       Enable the maximum possible value of avaliable Pstate (performance)
     --min       Enable the minimum possible value of avaliable Pstate (powersave)
  --save [path]  Make the pstate level permanent (default is /etc/modprobe.d/90-nouveau.conf)
  -l --list      Print avaliable pstate levels and exit
  -h --help      Show this message
  -v --version   Display program version
  
```

If you use one of the following options: ``--max``, ``--min``, or ``--pstate``
without specifying ``--card``, the script will automatically detect cards
available for relocking and set the appropriate Pstate level for them. Also
note that any changes made without specifying the --save option will only work
until the reboot.

## Why use Nouveau

In the Linux community, Novueau can safely be considered a graphics driver
pariah. Almost everyone just uses the closed NVIDIA driver because it is more
stable and performs better. I will not argue with that. But my point of view is
that Nouveau can work quite well only on older generations of NVIDIA graphics
cards, which are limited to support versions of the driver 390xx/340xx or
older. These driver versions are no longer officially supported by NVIDIA, so
you get at least a few problems:

- Every new version of the Linux kernel breaks compatibility with the driver,
  so you have to wait for someone to make a patch for the kernel modules.

- All drivers up to 495 actually have very weak support for Wayland (340xx and
  below do not have it at all), because they do not have GBM implemented.
  EGLStreams backend from modern compositors supports only mutter, and this
  backend receives almost no fixes lately.

- Drivers below 435 have no support for PRIME Offload. This really breaks
  Optimus configurations on older driver versions, as it makes it possible to
  use only one graphics card at a time. Of course, there are various
  workarounds like ``bumblebee`` and ``acpi_call`` - but they are hacky and
  obsolete in every sense. Bumblebee hasn't been updated in over 7 years, and
  acpi_call is potentially dangerous.

- Bugs, bugs, bugs. Of course, nouveau is also full of bugs, but at least with
  it you have a chance to get a fix, while the old versions of the closed
  driver never do.

Nouveau solves all of the above problems (yes, Nouveau also supports PRIME
Offload, see https://nouveau.freedesktop.org/Optimus.html), because it is part
of the kernel and Mesa. But of course brings its own, the main of which is the
lack of automatic GPU power management, which is the cause of low performance.
However, using reclocking you can get quite comparable driver performance as
described above. It is also worth to understand that Nouveau is not standing
still, and although its development is much slower than others because of the
restrictions imposed by NVIDIA, some growth is still there e.g. Novueau
recently received a patch for multi-threading
https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/10752, which should
also improve performance.

Nouveau supports Vulkan for the latest NVIDIA GPUs with a new Mesa driver, NVK.
Note that the current stable versions of Mesa only allow NVK to work for GPUs
starting with Turing, but for the latest build from Git it also works for all
GPUs starting with Maxwell. NVK supports Vulkan 1.3 and some modern Vulkan
extensions, but it doesn't yet reach the performance level of a closed driver,
but it is only 20% slower! (benchmarks can be found here:
https://video.hardlimit.com/w/oonv6VCnX3jn6keFC8fe9N). However, if you are a
Tesla or Fermi GPU owner, you will not have Vulkan support at the hardware
level anyway :(

## Resources

The following resources were used in the creation and may be helpful to read:

- https://github.com/polkaulfield/nouveau-reclocking-guide

- https://forums.debian.net/viewtopic.php?t=146141


## Special thanks

[@vnepogodin](https://github.com/vnepogodin) for testing and bugfixing

## License

Licensed under the GPL3 license
