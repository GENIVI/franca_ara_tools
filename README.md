# Franca/ARA Toolsuite

Translation between Franca Interface Description Language (IDL) and AUTOSAR Adaptive models.

## Development setup

### Eclipse

Eclipse Oxygen.3a Release (4.7.3a). Flavor: Eclipse Modeling Tools.

We recommend to use the [Eclipse installer](https://www.eclipse.org/downloads/packages/installer).

### AUTOSAR

Artop Release 4.12 (2019-04-26).

This supports AUTOSAR Adaptive Platform R19-03.
You need to be registered on [artop.org](https://www.artop.org) to get access to downloads and update sites.

We plan to upgrade to the latest [Adaptive Platform 19.03](https://www.autosar.org/standards/adaptive-platform/adaptive-platform-1903/) as soon as a corresponding Artop implementation is available.

### Franca

Franca Release 0.13.1.

For the transformations, it is sufficient to install _Franca Runtime_ (org.franca.core).
If you want to use the IDL editor, additionally install _Franca UI_ (org.franca.core.ui).

Detailed instructions can be found in the [Quick Install Guide](https://github.com/franca/franca/wiki/Franca-Quick-Install-Guide).
The Franca User Guide is available [here](https://drive.google.com/folderview?id=0B7JseVbR6jvhUnhLOUM5ZGxOOG8).

### Additional setup

As this is a prototype tooling, there is no Eclipse target definition yet.
We also do not provide a build system yet.
