# nouveau-reсlocking

## Description

A small Lua utility to reclock your GPU when using Nouveau. This should make life easier for owners of older NVIDIA video cards limited to support the 390xx or 340xx driver branch, but it can also work for Maxwell/Kepler. 

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
