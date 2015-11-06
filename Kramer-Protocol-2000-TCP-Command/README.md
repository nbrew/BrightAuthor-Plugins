# Kramer Electronics Protocol 2000 BrightSign Plugin

## tl;dr

**Usage:** `proto2k!recall_preset <input number>`

## Installation

In BrightAuthor, while editing a presentation, open the Autorun presentation properties at **File > Presentation Properties > Autorun**.

1. Add a new *Script Plugin*:

	* **Name**: _proto2k_ (in all lowercase letters)
	* **Path**: Select `proto2k.brs` as the path.

2. Set the Protocol 2000 IP Address and optionally the TCP port number. Create two **User Variables** by going to **File > Presentation Properties > Variables** and adding the following:
	* **proto2k_ip** - (optional) If your switcher is not using the default Kramer IP of "192.168.1.39", set to your switcher's IP Address. Default: **192.168.1.39**
	* **proto2k_port** - (optional) Set to the TCP port number to address the switcher. If this variable is not set the plugin will use port **5000**.

## Usage

* **Advanced > Send > Send Plugin Message**. Select the "proto2k" plugin. In the parameters block, enter one of the following:

  * _recall_preset_ preset
  * _switch_video_ input output


## General Command Format:

    proto2k!<command_name> <any inputs separated by spaces>

    ' Recall Preset 1
    proto2k!recall_preset 1
        
    ' Switch Video input 1 to output 2
    proto2k!switch_video 1 2

### Recall Preset

`proto2k!recall_preset <input number>`

_ex:_ `proto2k!recall_preset 1`<br>
_ex:_ `proto2k!recall_preset 2`

### Switch Video

`proto2k!switch_video <input number> <output number>[ <machine number>]`

* **Switch Video Input 3 to Output 4**<br>
`proto2k!switch_video 3 4`

* **Switch Video Input 2 to Output 2**<br>
`proto2k!switch_video 2 2`

This plugin was developed independently of Kramer Electronics and is in no way
associated with Kramer Electronics.


