# Raptor: OCT Volume Assembly

Code used for the article:

Marques et al., Endoscopic en-face optical coherence tomography and fluorescence imaging using a double-clad optical fiber and correlation-based probe tracking.

Please refer to the paper for detailed descriptions of the code and cite the paper when re-using significant portions of the code.


## Paper Abstract:
Forward-viewing endoscopic optical coherence tomography (OCT) provides 3D imaging in vivo, and can be combined with widefield fluorescence imaging by use of a double-clad fiber. However, it is technically challenging to build a high-performance miniaturized 2D scanning system with a large field-of-view. In this paper we demonstrate how a 1D scanning probe, which produces OCT B-scans and 1D fluorescence lines, can be manually scanned with an endoscope in the direction out-of-plane of the B-scans to generate OCT volumes and 2D fluorescence images. The OCT volumes are assembled from the B-scans using a combination of normalised cross correlation and speckle decorrelation measurements to detect in-plane and out-of-plane motion respectively. En face OCT slices and fluorescence images, corrected for probe motion in 3D, can be displayed in real-time during the scan. The algorithm can handle out-of-plane motion of up to 4~mm/s for a B-scan frame rate of 250~Hz and an OCT lateral resolution of approximately 20 micrometers.

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
Datasets are not available in this repo. Example datasets will be available in a figshare download shortly.
