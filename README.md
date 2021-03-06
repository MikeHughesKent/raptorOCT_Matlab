# Raptor OCT Volume Assembly (Matlab)

## Introduction
Raptor (Matlab) is a set of Matlab code which can be used to build OCT volumes (and fluorescence images) where one of the two scanning axes (the slow axis) is manual or in some other way uneven. It was designed to allow 3D volumes to be built when a 1D scanning endoscopic OCT/fluorescence probe is manually scanned in along a second axis. This code was used to produce results given in the paper:

*Manuel J. Marques, Michael R. Hughes, Adrián F Uceda, Grigory Gelikonov, Adrian Bradu, Adrian Podoleanu, **Endoscopic en-face optical coherence tomography and fluorescence imaging using correlation-based probe tracking***

This paper is under review and a preprint is available on Arxiv. Please consult the paper for a detailed expanation and evaluation of the approach, and cite this paper if publishing anything using this software.

## Paper Abstract:
Forward-viewing endoscopic optical coherence tomography (OCT) provides 3D imaging in vivo, and can be combined with widefield fluorescence imaging by use of a double-clad fiber. However, it is technically challenging to build a high-performance miniaturized 2D scanning system with a large  field-of-view. In this paper we demonstrate how a 1D scanning probe, which produces cross-sectional OCT images (B-scans) and 1D fluorescence T-scans, can be transformed into a 2D scanning probe by manual scanning along the second axis. OCT volumes are assembled from the B-scans using speckle decorrelation measurements to estimate the out-of-plane motion along the manual scan direction. Motion within the plane of the B-scans is corrected using image registration by normalized cross correlation. \textit{En-face} OCT slices and fluorescence images, corrected for probe motion in 3D, can be displayed in real-time during the scan. For a B-scan frame rate of 250 Hz, and an OCT lateral resolution of approximately 20 micrometers, the approach can handle out-of-plane motion at speeds of up to 4 mm/s. 

## Examples:
- example_correlation       - Produces a correlation with out-of-plane distance curve, Fig. 3(a) of article.

- example_velocity_profiles - Produces plots of measured velocity, Fig. 3(b-d) of article.

- example_grid              - Assembles volume and fluorescence image of grid, Fig. 4 of article.

- example_tissue            - Assembles volume and fluorescence image from example scan over bovine lung tissue, Fig. 5 of article.

## B-Scan Assembly Functions:
### Primary functions:
- corr_reg7 		  - Determines shifts between OCT images in a stack.
- build_fluor 		  - Assembles fluorescence image using shifts determined by corr_reg7.
- build_volume_flat 	  - Assembles OCT volume using shifts determined by corr_reg7 and applies tilt correction.
- interp_fluor 		  - Applies interpolation method to fluorescence image assembled by build_fluor.
- interp_volume 		  - Applies interpolation method to OCT volume assembled by build_volume_flat.

### Secondary functions:
- filter_image 		  - Applies filtering to image prior to correlation calculation.
- find_top_surface2 	  - Determines location of top surface of B-scan.
- normxcorr2e 		  - Alterantive to normxcorr2, 3rd party code.
- remove_outlier_pixels     - Generates mask of bright pixels.
- build_volume_with_shifs   - Assembles OCT volume using shifts determined by corr_reg7 without applying tilt correction. Used by build_volume_flat.

### Helper functions:
- enface_from_volume        - Pulls a single en face image from a volume.

## Datasets:
Datasets are not available in this repo. Example datasets used in the paper are available at http://doi.org/10.6084/m9.figshare.16578953
