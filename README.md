# nouveau-reсlocking

## Description 

By default, your GPU runs at a low video core/memory frequency when using Nouveau, because Nouveau does not support automatic memory management due to restrictions imposed by NVIDIA. This is the main reason for the low performance of Nouveau, which is why you only get 10% of what you get with a proprietary driver. However, Nouveau also supports manual power management of your graphics card, this is called reclocking. Nouveau only supports reclocking of GM10x Maxwell, Kepler, Tesla G94-GT218 (and Fermi?) GPU families. If your video card belongs to one of these generations, with reclocking you can get already about ~80% of the performance (see links below for benchmarks) from using with a proprietary driver.  This allows Nouveau to be competitive for older video cards which are limited to support the closed NVIDIA 390xx or 340xx and lower driver. It still might not be impressive to want to use Nouveau, but in the section below you can read more reasons for this.

This little utility for Lua should help simplify your reclocking process and make it easier. Note that if your GPU does not support reclocking, this utility is probably useless for you.

It requires no external dependencies and should work on any distribution. Read the installation block below.

## Installation

You need Git and Lua. The script is compatible with any version of Lua, so it should not cause compatibility problems with different distributions:

```
git clone https://github.com/ventureoo/nouveau-reclocking.git
cd nouveau-reclocking/src
chmod +x nouveau-reclocking
sudo ./nouveau-reclocking
```

## Usage

The script has several options that can be useful for setting relative Pstates and multicard configurations such as ``--max``, ``--min`` and ``--card``:

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

## License

Licensed under the GPL3 license
