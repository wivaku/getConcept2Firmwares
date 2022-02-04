# download Concept2 monitor firmwares

**Unofficial** shell script to list+download the [Concept2](https://www.concept2.com) firmwares for [PM5 monitors](https://www.concept2.com/service/monitors/pm5/firmware) for rower/skierg/bike.  
Technically it can also be used to download firmware for PM3 and PM4, but only the PM5 supports saving the files to a USB stick.  

The script's functionality is similar to what the [Concept2 Utility](https://www.concept2.com/service/software/concept2-utility) does:

- retrieve list of firmware versions that are currently available (stable and beta)
- delete the files that are currently in the destination folder
- download each of public or beta firmware files in that list and uncompress them

The script can save the files directly to the USB stick. Or you can save to another folder and manually move the files to the USB stick (`.../Concept2/Firmware`).

## requirements

- [**jq** - command-line JSON processor](https://stedolan.github.io/jq/)
- [**7zip** - file compression tools](https://www.7-zip.org/) or another package that can unzip `7z` files

For macOS:  
`brew install jq p7zip`

## usage

- download the `getConcept2Firmwares.sh` script and run it
- script shows list of available firmwares and asks for confirmation to download them
- make sure the downloaded files (*.7z and the expanded files) end up on your Concept2 USB stick in folder `.../Concept2/Firmware`

### optional parameters

Parameters are available to specify the **destination** (e.g. directly to your USB stick) and what **status** the firmware versions should be (public or beta).

| parameter | default value | example |
|---|---|---|
| `-d <folder>` | `$HOME/Downloads/Concept2/Firmware` | `-d /Volumes/MYCONCEPT2USB/Concept2/Firmware` |
| `-s [public \| beta]` | public | `-s beta` |
| `-m [pm3 \| pm4 \| pm5]` | pm5 | `-m pm4` |

## ⚠️ authentication

Concept2 Utility uses authentication (basic auth) to get the list of latest firmwares.  
That token is **not** included in this script and is left as an exercise for the reader.

The generic approach to get the token: by using a "man in the middle proxy tool" you can check what URL requests the Concept2 Utility makes and what authentication headers are sent. Authentication is only needed for getting that list, not for downloading the actual firmware.

Once you have the token you can store that in file `.env` or hardcode it in the script.  
The format:

```shell
TOKEN="Authorization: Basic Y...U="
```

## example

```shell
./getConcept2Firmwares.sh -s beta -d /Volumes/MYCONCEPT2USB/Concept2/Firmware
```

```text
all available pm5 firmware versions (public & beta)
public	rower	2021-12-20	PM5v1 Version 32.000	pm5_eurochinesebin_pub_secure_R032B000.7z
public	skierg	2021-12-20	PM5v1 Version 732.000	pm5ski_eurochinesebin_pub_secure_R732B000.7z
public	rower	2021-12-23	PM5v2 Version 171.000	pm5v2_eurochinesebin_pub_secure_R171B000.7z
public	skierg	2021-12-23	PM5v2 Version 871.000	pm5v2ski_eurochinesebin_pub_secure_R871B000.7z
public	rower	2021-12-23	PM5v3 Version 210.000	pm5v3_allbin_pub_secure_R210B000.7z
public	skierg	2021-12-23	PM5v3 Version 910.000	pm5v3ski_allbin_pub_secure_R910B000.7z
public	bike	2021-12-23	PM5v3 Version 361.000	pm5v3bk_allbin_pub_secure_R361B000.7z
beta	rower	2022-01-27	PM5v1 Version 32.001	pm5_eurochinesebin_beta_secure_R032B001.7z
beta	skierg	2022-01-27	PM5v1 Version 732.001	pm5ski_eurochinesebin_beta_secure_R732B001.7z

Ready to download the beta files to '/Volumes/MYCONCEPT2USB/Concept2/Firmware'. Note: all existing files will be removed!
Do you want to continue? (y/n) y
downloading the firmware files to /Volumes/MYCONCEPT2USB/Concept2/Firmware
- pm5_eurochinesebin_beta_secure_R032B001.7z
- pm5ski_eurochinesebin_beta_secure_R732B001.7z
```

## unofficial and unsupported

This script is in no way associated with [Concept2](https://concept2.com) and uses publically available information to mimic the functionality of the Concept2 Utility.

Your mileage may vary.
