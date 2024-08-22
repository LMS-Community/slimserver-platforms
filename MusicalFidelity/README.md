# Lyrion Music Server on Musical Fidelity

This collection of files add support for the Musical Fidelity series for music servers to Lyrion Music Server.

## `Custom.pm` - LMS Customization

The `Slim::Utils::OS::Custom` module provides some tweaks to how LMS should behave on the Musical Fidelity devices. It defines where to store prefs, logs, etc., what plugins to skip etc. See https://lyrion.org/reference/slim-utils-os-custom/ for details.

## M6Encore - plugin to add support for MF/Encore players

This plugin adds support for the Musical Fidelity player hardware, input controls, it's UI skin etc. It could theoretically be installed even on other LMS instances. But for the time being it's here to be installed on the MF series music servers.

Please note that on a Musical Fidelity server this _must_ be installed in order to support its own playback. It _must not_ be removed, or playback will break.