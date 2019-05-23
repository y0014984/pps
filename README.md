<p align="center">
    <img src="https://github.com/y0014984/pps/logo/logo_pps_ca.jpg" width="512">
</p>

<p align="center">
    <a href="https://github.com/y0014984/pps/releases/latest">
        <img src="https://img.shields.io/badge/Version-0.2.3-blue.svg?style=flat-square" alt="PPS Version">
    </a>
    <a href="https://www.bistudio.com/community/licenses/arma-public-license-share-alike">
        <img src="https://img.shields.io/badge/License-APL%20SA-red.svg?style=flat-square" alt="PPS License">
    </a>
</p>

<p align="center">
    <sup><strong>Requires the latest version of <a href="https://github.com/CBATeam/CBA_A3/releases">CBA A3</a> for server and client and <a href="https://github.com/code34/inidbi2">INIDBI2</a> for serverside only.<br/>
    Use of <a href="https://github.com/acemod/ACE3/releases">ACE3</a> and <a href="https://github.com/michail-nikolaev/task-force-arma-3-radio/releases">TFAR</a> is optional. </strong></sup>
</p>

**PPS** my fist attempt of creating a mod for Arma 3. The main goal is to collect player statistics on client side and to send these statistics to the server side for persistent storage. The statistics are only collected in case of a running event, startet bei PPS admin in PPS interface, and if the Client activated sending data in addon settings. A normal player can only see his own statistics whereas the admin can see the statistics of all players.

The project is entirely **open-source** and all contributions are welcome. Feel free to maintain your own custom version, so long as the changes you make are open to the public in accordance with the ([APL-SA](https://www.bistudio.com/community/licenses/arma-public-license-share-alike)).

## Features

- Unified interface, for admins and players. Simply press `U` in game. It's a CBA Keybind, so you can change it.
- CBA mod settings for server and client available.
- Persistent data storage with serverside INIDBI2 mod.
- Starting and stopping events for recording statistics.
- Player must allow sending data in mod settings.
- Statistics tracking for individual values, permanently showing as a hint.

## Installation

Download the latest version and unpack it in your Arma 3 installation folder.
Simply launch Arma 3 with `-mod=@CBA_A3;@PPS` afterwards.

## Known Issues

* There are a lot of known issues, to many to list here.

## License

PPS is licensed under the ([APL-SA](https://www.bistudio.com/community/licenses/arma-public-license-share-alike)).
